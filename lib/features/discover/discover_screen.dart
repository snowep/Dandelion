import 'package:flutter/material.dart';
import 'package:dandelion/features/library/book.dart';
import 'package:dandelion/features/library/book_repository.dart';
import 'package:dandelion/features/library/reading_record.dart';
import 'package:dandelion/features/discover/recommendation_engine.dart';
import 'package:dandelion/services/google_books_lookup_service.dart';
import 'package:dandelion/shared/services/cover_image_service.dart';
import 'package:dandelion/shared/widgets/book_list_scaffold.dart';
import 'package:http/http.dart' as http;
import 'package:uuid/uuid.dart';

class DiscoverScreen extends StatefulWidget {
  const DiscoverScreen({super.key, required this.repository});

  final BookRepository repository;

  @override
  State<DiscoverScreen> createState() => _DiscoverScreenState();
}

class _DiscoverScreenState extends State<DiscoverScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<Book> _libraryCandidates = [];
  List<Book> _catalogCandidates = [];
  Map<int, List<String>> _recommendationReasons = {};
  bool _loadingLibrary = true;
  bool _loadingCatalog = false;
  String? _catalogError;
  final GoogleBooksLookupService _lookupService = GoogleBooksLookupService();
  RecommendationEngine? _engine;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      if (_tabController.index == 1 &&
          _catalogCandidates.isEmpty &&
          _catalogError == null) {
        _loadCatalogCandidates();
      }
    });
    _loadLibraryCandidates();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _lookupService.close();
    super.dispose();
  }

  Future<void> _loadLibraryCandidates() async {
    if (!mounted) return;
    setState(() {
      _loadingLibrary = true;
    });
    try {
      final books = await widget.repository.getAll();
      final records = await widget.repository.listReadingRecords();
      _engine = RecommendationEngine(books, records);

      // Exclude books already in library or wishlist
      final excludeIds = books
          .where((b) => b.isInWishlist)
          .map((b) => b.id)
          .toSet();

      final scored = _engine!.recommend(
        candidates: books,
        excludeBookIds: excludeIds,
      );

      final reasonsMap = <int, List<String>>{};
      for (final candidate in scored) {
        reasonsMap[candidate.book.id] = candidate.explanations;
      }

      if (!mounted) return;
      setState(() {
        _libraryCandidates = scored.map((c) => c.book).toList();
        _recommendationReasons = reasonsMap;
        _loadingLibrary = false;
      });
    } on Object catch (_) {
      if (!mounted) return;
      setState(() {
        _loadingLibrary = false;
      });
    }
  }

  Future<void> _loadCatalogCandidates() async {
    if (!mounted) return;
    setState(() {
      _loadingCatalog = true;
      _catalogError = null;
    });
    try {
      final books = await widget.repository.getAll();
      final records = await widget.repository.listReadingRecords();
      final engine = RecommendationEngine(books, records);

      // Get all library book IDs to exclude
      final excludeIds = books.map((b) => b.id).toSet();

      // Use top genre for search query
      final genreCounts = <String, int>{};
      for (final book in books) {
        if (book.genres != null && book.genres!.isNotEmpty) {
          for (final genre in book.genres!.split(',')) {
            final g = genre.trim().toLowerCase();
            genreCounts[g] = (genreCounts[g] ?? 0) + 1;
          }
        }
      }
      if (genreCounts.isEmpty) {
        setState(() {
          _loadingCatalog = false;
          _catalogError = 'No genres found in library';
        });
        return;
      }
      final topGenre = genreCounts.entries
          .reduce((a, b) => a.value > b.value ? a : b)
          .key;
      final query = 'books about $topGenre';

      final results = await _lookupService.searchByTitleOrAuthor(query);

      // Rank catalog candidates using the same engine
      final scored = engine.recommend(
        candidates: results,
        excludeBookIds: excludeIds,
      );

      if (!mounted) return;
      setState(() {
        _catalogCandidates = scored.map((c) => c.book).toList();
        _loadingCatalog = false;
      });
    } on Object catch (e) {
      if (!mounted) return;
      setState(() {
        _catalogError = e.toString();
        _loadingCatalog = false;
      });
    }
  }

  Future<void> _saveCatalogBook(Book book, {bool toWishlist = false}) async {
    try {
      String? coverAssetKey;
      if (book.thumbnailUrl != null && book.thumbnailUrl!.isNotEmpty) {
        try {
          final response = await http.get(Uri.parse(book.thumbnailUrl!));
          if (response.statusCode == 200) {
            final uuid = const Uuid().v4();
            final key = 'covers/cover_$uuid.png';
            final success = await CoverImageService.storeImage(
              response.bodyBytes,
              key: key,
            );
            if (success) {
              coverAssetKey = key;
            }
          }
        } on Object catch (_) {}
      }

      await widget.repository.createBook(
        book.copyWith(coverAssetKey: coverAssetKey, isInWishlist: toWishlist),
        initialStatus: toWishlist
            ? ReadingStatus.wantToRead
            : ReadingStatus.reading,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Saved to ${toWishlist ? 'wishlist' : 'library'}!'),
          ),
        );
      }

      await _loadLibraryCandidates();
    } on Object catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Could not save book: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Discover'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'From your library'),
            Tab(text: 'Catalog candidates'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _loadingLibrary
              ? const Center(child: CircularProgressIndicator())
              : _libraryCandidates.isEmpty
              ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.explore_outlined, size: 48),
                      const SizedBox(height: 12),
                      const Text('No recommendations yet'),
                      const SizedBox(height: 8),
                      const Text(
                        'Add books to your library to get recommendations.',
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                )
              : BookListScaffold(
                  books: _libraryCandidates,
                  onBookTap: (book) {
                    showDialog(
                      context: context,
                      builder: (dialogContext) => AlertDialog(
                        title: Text(book.title),
                        content: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (book.authors.isNotEmpty)
                              Text('by ${book.authors}'),
                            if (book.genres != null && book.genres!.isNotEmpty)
                              Text('Genres: ${book.genres}'),
                            if (book.description != null &&
                                book.description!.isNotEmpty)
                              Padding(
                                padding: const EdgeInsets.only(top: 8),
                                child: Text(book.description!),
                              ),
                            const SizedBox(height: 12),
                            const Text(
                              'Recommendation reasons:',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            ...(_recommendationReasons[book.id] ?? []).map(
                              (reason) => Text('• $reason'),
                            ),
                          ],
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(dialogContext),
                            child: const Text('Close'),
                          ),
                        ],
                      ),
                    );
                  },
                  onBookEdit: null,
                  onBookArchive: null,
                  onBookDelete: null,
                  onWishlistToggle: (id) async {
                    await widget.repository.toggleWishlist(id);
                    await _loadLibraryCandidates();
                  },
                ),
          _loadingCatalog
              ? const Center(child: CircularProgressIndicator())
              : _catalogError != null
              ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.error_outline,
                        size: 48,
                        color: Colors.red,
                      ),
                      const SizedBox(height: 12),
                      Text('Could not load catalog: $_catalogError'),
                      const SizedBox(height: 8),
                      ElevatedButton(
                        onPressed: _loadCatalogCandidates,
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                )
              : _catalogCandidates.isEmpty
              ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.search_off, size: 48),
                      const SizedBox(height: 12),
                      const Text('No catalog results'),
                      const SizedBox(height: 8),
                      const Text(
                        'Try another search or check your internet connection.',
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  itemCount: _catalogCandidates.length,
                  itemBuilder: (context, index) {
                    final book = _catalogCandidates[index];
                    return Card(
                      child: ListTile(
                        leading:
                            book.thumbnailUrl != null &&
                                book.thumbnailUrl!.isNotEmpty
                            ? Image.network(
                                book.thumbnailUrl!,
                                width: 44,
                                height: 64,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) =>
                                    const CircleAvatar(
                                      backgroundColor: Colors.grey,
                                      child: Icon(
                                        Icons.menu_book,
                                        color: Colors.white,
                                      ),
                                    ),
                              )
                            : const CircleAvatar(
                                backgroundColor: Colors.grey,
                                child: Icon(
                                  Icons.menu_book,
                                  color: Colors.white,
                                ),
                              ),
                        title: Text(book.title),
                        subtitle: Text(
                          book.authors.isEmpty
                              ? 'Unknown author'
                              : book.authors,
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.favorite_border),
                              tooltip: 'Add to wishlist',
                              onPressed: () =>
                                  _saveCatalogBook(book, toWishlist: true),
                            ),
                            IconButton(
                              icon: const Icon(Icons.add),
                              tooltip: 'Add to library',
                              onPressed: () => _saveCatalogBook(book),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
        ],
      ),
    );
  }
}
