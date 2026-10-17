import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/material.dart';

import 'book.dart';
import 'book_repository.dart';
import 'reading_record.dart';
import '../../shared/services/cover_image_service.dart';

import 'package:dandelion/features/library/widgets/isbn_lookup_dialog.dart';

class LibraryScreen extends StatefulWidget {
  const LibraryScreen({super.key, required this.repository});

  final BookRepository repository;

  @override
  State<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends State<LibraryScreen> {
  List<Book> _books = const [];
  Map<int, Uint8List> _covers = const {};
  bool _loading = true;
  String? _error;
  String _query = '';
  String _sortBy = 'title';
  bool _sortAscending = true;
  String? _statusFilter;
  String? _genreFilter;
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _loadBooks();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }

  Future<void> _loadBooks() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final books = await widget.repository.listBooks(
        filters: {
          'search': _query,
          'status': ?_statusFilter,
          'genre': ?_genreFilter,
        },
        sortBy: _sortBy,
        ascending: _sortAscending,
      );
      final covers = <int, Uint8List>{};
      for (final book in books) {
        final key = book.coverAssetKey;
        if (key == null) continue;
        final bytes = await CoverImageService.loadImage(key);
        if (bytes != null) covers[book.id] = bytes;
      }
      if (!mounted) return;
      setState(() {
        _books = books;
        _covers = covers;
        _loading = false;
      });
    } on Object catch (error) {
      if (!mounted) return;
      setState(() {
        _error = error.toString();
        _loading = false;
      });
    }
  }

  Future<void> _showBookEditor({Book? book}) async {
    final titleController = TextEditingController(text: book?.title ?? '');
    final authorsController = TextEditingController(text: book?.authors ?? '');
    final pageCountController = TextEditingController(
      text: book?.pageCount?.toString() ?? '',
    );
    final descriptionController = TextEditingController(
      text: book?.description ?? '',
    );
    var selectedStatus = book == null
        ? ReadingStatus.wantToRead
        : (await widget.repository.getReadingRecordForBook(book.id))?.status ??
              ReadingStatus.wantToRead;
    var coverAssetKey = book?.coverAssetKey;

    final saved = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text(book == null ? 'Add book manually' : 'Edit book'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: titleController,
                  autofocus: true,
                  textCapitalization: TextCapitalization.sentences,
                  decoration: const InputDecoration(labelText: 'Title *'),
                ),
                TextField(
                  controller: authorsController,
                  textCapitalization: TextCapitalization.words,
                  decoration: const InputDecoration(labelText: 'Authors'),
                ),
                TextField(
                  controller: pageCountController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Page count'),
                ),
                TextField(
                  controller: descriptionController,
                  minLines: 2,
                  maxLines: 4,
                  decoration: const InputDecoration(labelText: 'Description'),
                ),
                const SizedBox(height: 8),
                OutlinedButton.icon(
                  onPressed: () async {
                    try {
                      final key = await CoverImageService.pickAndStoreImage();
                      if (key != null) {
                        setDialogState(() => coverAssetKey = key);
                      }
                    } on Object catch (error) {
                      if (!dialogContext.mounted) return;
                      ScaffoldMessenger.of(dialogContext).showSnackBar(
                        SnackBar(
                          content: Text('Could not select cover: $error'),
                        ),
                      );
                    }
                  },
                  icon: const Icon(Icons.image_outlined),
                  label: Text(
                    coverAssetKey == null
                        ? 'Choose cover image'
                        : 'Cover selected',
                  ),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<ReadingStatus>(
                  initialValue: selectedStatus,
                  decoration: const InputDecoration(labelText: 'Status'),
                  items: ReadingStatus.values
                      .map(
                        (status) => DropdownMenuItem(
                          value: status,
                          child: Text(_statusLabel(status)),
                        ),
                      )
                      .toList(),
                  onChanged: (status) {
                    if (status != null) {
                      setDialogState(() => selectedStatus = status);
                    }
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () async {
                final title = titleController.text.trim();
                final pages = int.tryParse(pageCountController.text.trim());
                if (title.isEmpty ||
                    (pageCountController.text.isNotEmpty && pages == null) ||
                    (pages != null && pages <= 0)) {
                  return;
                }
                try {
                  final value = book == null
                      ? Book(
                          id: 0,
                          title: title,
                          authors: authorsController.text.trim(),
                          description: _nullable(descriptionController.text),
                          pageCount: pages,
                          coverAssetKey: coverAssetKey,
                        )
                      : book.copyWith(
                          title: title,
                          authors: authorsController.text.trim(),
                          description: _nullable(descriptionController.text),
                          pageCount: pages,
                          coverAssetKey: coverAssetKey,
                          updatedAt: DateTime.now(),
                        );
                  if (book == null) {
                    await widget.repository.createBook(
                      value,
                      initialStatus: selectedStatus,
                    );
                  } else {
                    await widget.repository.updateBook(value);
                    final record = await widget.repository
                        .getReadingRecordForBook(book.id);
                    await widget.repository.updateReadingRecord(
                      record?.copyWith(status: selectedStatus) ??
                          ReadingRecord(
                            bookId: book.id,
                            status: selectedStatus,
                          ),
                    );
                  }
                  if (dialogContext.mounted) {
                    Navigator.pop(dialogContext, true);
                  }
                } on Object catch (error) {
                  if (!dialogContext.mounted) return;
                  ScaffoldMessenger.of(dialogContext).showSnackBar(
                    SnackBar(content: Text('Could not save book: $error')),
                  );
                }
              },
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
    titleController.dispose();
    authorsController.dispose();
    pageCountController.dispose();
    descriptionController.dispose();
    if (saved == true) await _loadBooks();
  }

  Future<void> _showIsbnLookupDialog() async {
    final Book? result = await showDialog<Book>(
      context: context,
      builder: (context) => const IsbnLookupDialog(),
    );
    if (result != null && mounted) {
      await widget.repository.createBook(
        result,
        initialStatus: ReadingStatus.wantToRead,
      );
      await _loadBooks();
    }
  }

  Future<void> _showProgressEditor(Book book) async {
    final currentRecord = await widget.repository.getReadingRecordForBook(
      book.id,
    );
    var progress = currentRecord?.percentageOnlyProgress ?? 0.0;
    var status = currentRecord?.status ?? ReadingStatus.reading;
    if (!mounted) return;
    final record = await showDialog<ReadingRecord>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text('Reading progress: ${book.title}'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('${(progress * 100).round()}% complete'),
              Slider(
                value: progress,
                divisions: 100,
                label: '${(progress * 100).round()}%',
                onChanged: (value) => setDialogState(() => progress = value),
              ),
              DropdownButton<ReadingStatus>(
                value: status,
                items: ReadingStatus.values
                    .map(
                      (value) => DropdownMenuItem(
                        value: value,
                        child: Text(_statusLabel(value)),
                      ),
                    )
                    .toList(),
                onChanged: (value) {
                  if (value != null) setDialogState(() => status = value);
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(
                dialogContext,
                (currentRecord ??
                        ReadingRecord(bookId: book.id, status: status))
                    .copyWith(
                      status: status,
                      percentageOnlyProgress: progress,
                      finishDate: status == ReadingStatus.finished
                          ? DateTime.now()
                          : null,
                    ),
              ),
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
    if (record != null) {
      await widget.repository.updateReadingRecord(record);
      await _loadBooks();
    }
  }

  Future<void> _deleteBook(Book book) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete book?'),
        content: Text(
          '“${book.title}” and its reading record will be removed.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await widget.repository.deleteBook(book.id);
      await _loadBooks();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Library'),
        actions: [
          IconButton(
            tooltip: 'Add book manually',
            onPressed: () => _showBookEditor(),
            icon: const Icon(Icons.add),
          ),
        ],
      ),
      body: CustomScrollView(
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
            sliver: SliverToBoxAdapter(
              child: SearchBar(
                hintText: 'Search title, author, ISBN, or genre',
                leading: const Icon(Icons.search),
                onChanged: (query) {
                  _query = query;
                  _debounce?.cancel();
                  _debounce = Timer(
                    const Duration(milliseconds: 300),
                    _loadBooks,
                  );
                },
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            sliver: SliverToBoxAdapter(
              child: Row(
                children: [
                  PopupMenuButton<String>(
                    child: const Text('Sort'),
                    onSelected: (value) {
                      setState(() {
                        if (value == 'title' && _sortBy == 'title') {
                          _sortAscending = !_sortAscending;
                        } else {
                          _sortBy = value;
                          _sortAscending = true;
                        }
                        _loadBooks();
                      });
                    },
                    itemBuilder: (context) => [
                      const PopupMenuItem(value: 'title', child: Text('Title')),
                      const PopupMenuItem(
                        value: 'author',
                        child: Text('Author'),
                      ),
                      const PopupMenuItem(
                        value: 'updated',
                        child: Text('Date'),
                      ),
                    ],
                  ),
                  const SizedBox(width: 8),
                  Wrap(
                    spacing: 8,
                    children: [
                      ChoiceChip(
                        label: const Text('Want'),
                        selected: _statusFilter == 'wantToRead',
                        onSelected: (_) {
                          setState(() {
                            _statusFilter = _statusFilter == 'wantToRead'
                                ? null
                                : 'wantToRead';
                            _loadBooks();
                          });
                        },
                      ),
                      ChoiceChip(
                        label: const Text('Reading'),
                        selected: _statusFilter == 'reading',
                        onSelected: (_) {
                          setState(() {
                            _statusFilter = _statusFilter == 'reading'
                                ? null
                                : 'reading';
                            _loadBooks();
                          });
                        },
                      ),
                      ChoiceChip(
                        label: const Text('Finished'),
                        selected: _statusFilter == 'finished',
                        onSelected: (_) {
                          setState(() {
                            _statusFilter = _statusFilter == 'finished'
                                ? null
                                : 'finished';
                            _loadBooks();
                          });
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          if (_loading)
            const SliverFillRemaining(
              child: Center(child: CircularProgressIndicator()),
            )
          else if (_error != null)
            SliverFillRemaining(
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('Could not load your library.\n$_error'),
                    const SizedBox(height: 12),
                    FilledButton(
                      onPressed: _loadBooks,
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            )
          else if (_books.isEmpty)
            SliverFillRemaining(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.menu_book_outlined, size: 48),
                      const SizedBox(height: 12),
                      Text(
                        _query.isEmpty
                            ? 'Your library is empty'
                            : 'No books match “$_query”',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _query.isEmpty
                            ? 'Add a book manually. You can do this offline.'
                            : 'Try another title, author, ISBN, or genre.',
                        textAlign: TextAlign.center,
                      ),
                      if (_query.isEmpty) ...[
                        const SizedBox(height: 16),
                        FilledButton.icon(
                          onPressed: () => _showBookEditor(),
                          icon: const Icon(Icons.add),
                          label: const Text('Add book'),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
              sliver: SliverList.builder(
                itemCount: _books.length,
                itemBuilder: (context, index) {
                  final book = _books[index];
                  return Card(
                    key: ValueKey(book.id),
                    child: ListTile(
                      minVerticalPadding: 12,
                      leading: _covers[book.id] == null
                          ? CircleAvatar(
                              backgroundColor: Theme.of(context)
                                  .colorScheme
                                  .secondaryContainer,
                              child: Icon(
                                Icons.menu_book,
                                color: Theme.of(context)
                                    .colorScheme
                                    .onSecondaryContainer,
                              ),
                            )
                          : ClipRRect(
                              borderRadius: BorderRadius.circular(6),
                              child: Image.memory(
                                _covers[book.id]!,
                                width: 44,
                                height: 64,
                                fit: BoxFit.cover,
                                semanticLabel: 'Cover of ${book.title}',
                              ),
                            ),
                      title: Text(book.title),
                      subtitle: Text(
                        book.authors.isEmpty ? 'Unknown author' : book.authors,
                      ),
                      onTap: () => _showProgressEditor(book),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: Icon(
                              book.isInWishlist
                                  ? Icons.favorite
                                  : Icons.favorite_border,
                              color: book.isInWishlist ? Colors.red : null,
                            ),
                            tooltip: book.isInWishlist
                                ? 'Remove from wishlist'
                                : 'Add to wishlist',
                            onPressed: () {
                              widget.repository
                                  .toggleWishlist(book.id)
                                  .then((_) => _loadBooks());
                            },
                          ),
                          PopupMenuButton<String>(
                            tooltip: 'Book actions',
                            onSelected: (action) {
                              if (action == 'edit') {
                                _showBookEditor(book: book);
                              } else if (action == 'archive') {
                                widget.repository
                                    .archiveBook(book.id)
                                    .then((_) => _loadBooks());
                              } else if (action == 'delete') {
                                _deleteBook(book);
                              }
                            },
                            itemBuilder: (context) => const [
                              PopupMenuItem(value: 'edit', child: Text('Edit')),
                              PopupMenuItem(
                                value: 'archive',
                                child: Text('Archive'),
                              ),
                              PopupMenuItem(
                                value: 'delete',
                                child: Text('Delete'),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        tooltip: 'Add book manually',
        onPressed: () => _showBookEditor(),
        child: const Icon(Icons.add),
      ),
    );
  }

  static String? _nullable(String value) =>
      value.trim().isEmpty ? null : value.trim();

  static String _statusLabel(ReadingStatus status) => switch (status) {
    ReadingStatus.wantToRead => 'Want to read',
    ReadingStatus.reading => 'Reading',
    ReadingStatus.paused => 'Paused',
    ReadingStatus.finished => 'Finished',
    ReadingStatus.didNotFinish => 'Did not finish',
  };
}
