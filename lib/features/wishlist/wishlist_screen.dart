import 'package:flutter/material.dart';
import 'package:dandelion/features/library/book.dart';
import 'package:dandelion/features/library/book_repository.dart';
import 'package:dandelion/features/library/reading_record.dart';
import 'package:dandelion/shared/services/cover_image_service.dart';
import 'package:dandelion/shared/widgets/book_list_scaffold.dart';

class WishlistScreen extends StatefulWidget {
  const WishlistScreen({super.key, required this.repository});

  final BookRepository repository;

  @override
  State<WishlistScreen> createState() => _WishlistScreenState();
}

class _WishlistScreenState extends State<WishlistScreen> {
  List<Book> _wishlistBooks = const [];
  final String _sortBy = 'title';
  final bool _sortAscending = true;

  @override
  void initState() {
    super.initState();
    _loadWishlist();
  }

  Future<void> _loadWishlist() async {
    if (!mounted) return;
    try {
      final books = await widget.repository.getBooksByWishlist(
        isInWishlist: true,
      );
      if (!mounted) return;
      setState(() {
        _wishlistBooks = books;
      });
    } on Object catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not load wishlist: $e')),
      );
    }
  }

  Future<bool> _showBookEditor({Book? book}) async {
    if (!mounted) return false;
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
    if (saved == true) await _loadWishlist();
    return saved ?? false;
  }

  Future<void> _moveToWantToRead(Book book) async {
    final record = await widget.repository.getReadingRecordForBook(book.id);
    if (record != null) {
      await widget.repository.updateReadingRecord(
        record.copyWith(
          status: ReadingStatus.wantToRead,
          lastReadDate: DateTime.now(),
        ),
      );
    } else {
      await widget.repository.createReadingRecord(
        ReadingRecord(
          bookId: book.id,
          status: ReadingStatus.wantToRead,
          lastReadDate: DateTime.now(),
        ),
      );
    }
    await widget.repository.updateBook(
      book.copyWith(isInWishlist: false, updatedAt: DateTime.now()),
    );
    await _loadWishlist();
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Wishlist'),
        actions: [
          IconButton(
            tooltip: 'Add book manually',
            onPressed: () => _showBookEditor(),
            icon: const Icon(Icons.add),
          ),
        ],
      ),
      body: BookListScaffold(
        books: _wishlistBooks,
        onBookTap: (book) => _showProgressEditor(book),
        onBookEdit: (book) => _showBookEditor(book: book),
        onBookArchive: (id) async {
          await widget.repository.archiveBook(id);
          await _loadWishlist();
        },
        onBookDelete: (id) async {
          final confirmed = await showDialog<bool>(
            context: context,
            builder: (dialogContext) => AlertDialog(
              title: const Text('Delete book?'),
              content: Text(
                '“${_wishlistBooks.firstWhere((b) => b.id == id).title}” will be removed from your wishlist.',
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
            await widget.repository.deleteBook(id);
            await _loadWishlist();
          }
        },
        onWishlistToggle: (id) async {
          final book = _wishlistBooks.firstWhere((b) => b.id == id);
          await _moveToWantToRead(book);
        },
        sortBy: _sortBy,
        sortAscending: _sortAscending,
      ),
      floatingActionButton: FloatingActionButton(
        tooltip: 'Add book manually',
        onPressed: () => _showBookEditor(),
        child: const Icon(Icons.add),
      ),
    );
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
      await _loadWishlist();
    }
  }
}