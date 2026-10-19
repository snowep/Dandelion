import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/material.dart';

import 'book.dart';
import 'book_repository.dart';
import 'reading_record.dart';
import '../../shared/services/cover_image_service.dart';

class LibraryScreen extends StatefulWidget {
  const LibraryScreen({super.key, required this.repository});

  final BookRepository repository;

  @override
  State<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends State<LibraryScreen> {
  _LibraryScreenState();
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
  final TextEditingController _isbn10Controller = TextEditingController();
  final TextEditingController _isbn13Controller = TextEditingController();
  final TextEditingController _publisherController = TextEditingController();

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

  Future<bool> _loadBooks() async {
    if (!mounted) return false;
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
      final futures = <Future<Uint8List?>>[];
      final ids = <int>[];
      for (final book in books) {
        final key = book.coverAssetKey;
        if (key == null) continue;
        futures.add(CoverImageService.loadImage(key));
        ids.add(book.id);
      }
      final results = await Future.wait(futures);
      for (var i = 0; i < results.length; i++) {
        final bytes = results[i];
        if (bytes != null) covers[ids[i]] = bytes;
      }
      if (!mounted) return false;
      setState(() {
        _books = books;
        _covers = covers;
        _loading = false;
      });
      return true;
    } on Object catch (error) {
      if (!mounted) return false;
      setState(() {
        _error = error.toString();
        _loading = false;
      });
      return false;
    }
  }

  Future<bool> _showBookEditor({Book? book}) async {
    if (!mounted) return false;
    if (!mounted) return false;
    final titleController = TextEditingController(text: book?.title ?? '');
    final authorsController = TextEditingController(text: book?.authors ?? '');
    final pageCountController = TextEditingController(
      text: book?.pageCount?.toString() ?? '',
    );
    final descriptionController = TextEditingController(
      text: book?.description ?? '',
    );
    final purchasePriceController = TextEditingController(
      text: book?.purchasePrice?.toStringAsFixed(2) ?? '',
    );
    final purchaseCurrencyController = TextEditingController(
      text: book?.purchaseCurrency ?? '',
    );
    var isBorrowedController = book?.isBorrowed ?? false;
    final lenderNameController = TextEditingController(
      text: book?.lenderName ?? '',
    );
    final lenderContactController = TextEditingController(
      text: book?.lenderContact ?? '',
    );
    var borrowDateController = book?.borrowDate;
    var expectedReturnDateController = book?.expectedReturnDate;
    var isLentController = book?.isLent ?? false;
    final borrowerNameController = TextEditingController(
      text: book?.borrowerName ?? '',
    );
    final borrowerContactController = TextEditingController(
      text: book?.borrowerContact ?? '',
    );
    var lendDateController = book?.lendDate;
    var expectedLendReturnDateController = book?.expectedLendReturnDate;
    var selectedStatus = ReadingStatus.wantToRead;
    if (book != null) {
      final record = await widget.repository.getReadingRecordForBook(book.id);
      if (mounted) {
        selectedStatus = record?.status ?? ReadingStatus.wantToRead;
      }
    }
    var coverAssetKey = book?.coverAssetKey;
    if (!mounted) return false;
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
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: purchasePriceController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Purchase Price',
                          prefixText: '\$',
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                        controller: purchaseCurrencyController,
                        decoration: const InputDecoration(
                          labelText: 'Currency',
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                TextField(
                  decoration: const InputDecoration(labelText: 'ISBN-10'),
                  controller: TextEditingController(text: book?.isbn10 ?? ''),
                  onChanged: (value) => _isbn10Controller.text = value,
                ),
                TextField(
                  decoration: const InputDecoration(labelText: 'ISBN-13'),
                  controller: TextEditingController(text: book?.isbn13 ?? ''),
                  onChanged: (value) => _isbn13Controller.text = value,
                ),
                TextField(
                  decoration: const InputDecoration(labelText: 'Publisher'),
                  controller: TextEditingController(
                    text: book?.publisher ?? '',
                  ),
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
                const SizedBox(height: 8),
                const Text(
                  'Lending/Borrowing Tracking',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                SwitchListTile(
                  title: const Text('Borrowed from someone'),
                  value: isBorrowedController,
                  onChanged: (value) =>
                      setDialogState(() => isBorrowedController = value),
                ),
                if (isBorrowedController) ...[
                  TextField(
                    controller: lenderNameController,
                    decoration: const InputDecoration(
                      labelText: "Lender's Name",
                    ),
                  ),
                  TextField(
                    controller: lenderContactController,
                    decoration: const InputDecoration(
                      labelText: "Lender's Contact",
                    ),
                  ),
                  ListTile(
                    leading: const Icon(Icons.calendar_today),
                    title: const Text('Borrow Date'),
                    trailing: IconButton(
                      icon: const Icon(Icons.edit),
                      onPressed: () async {
                        final date = await showDatePicker(
                          context: dialogContext,
                          initialDate: borrowDateController ?? DateTime.now(),
                          firstDate: DateTime(2000),
                          lastDate: DateTime.now(),
                        );
                        if (date != null && dialogContext.mounted) {
                          setDialogState(() => borrowDateController = date);
                        }
                      },
                    ),
                  ),
                  ListTile(
                    leading: const Icon(Icons.calendar_today),
                    title: const Text('Expected Return Date'),
                    trailing: IconButton(
                      icon: const Icon(Icons.edit),
                      onPressed: () async {
                        final date = await showDatePicker(
                          context: dialogContext,
                          initialDate:
                              expectedReturnDateController ??
                              DateTime.now().add(const Duration(days: 14)),
                          firstDate: DateTime(2000),
                          lastDate: DateTime(2030),
                        );
                        if (date != null && dialogContext.mounted) {
                          setDialogState(
                            () => expectedReturnDateController = date,
                          );
                        }
                      },
                    ),
                  ),
                ],
                SwitchListTile(
                  title: const Text('Lent to someone'),
                  value: isLentController,
                  onChanged: (value) =>
                      setDialogState(() => isLentController = value),
                ),
                if (isLentController) ...[
                  TextField(
                    controller: borrowerNameController,
                    decoration: const InputDecoration(
                      labelText: "Borrower's Name",
                    ),
                  ),
                  TextField(
                    controller: borrowerContactController,
                    decoration: const InputDecoration(
                      labelText: "Borrower's Contact",
                    ),
                  ),
                  ListTile(
                    leading: const Icon(Icons.calendar_today),
                    title: const Text('Lend Date'),
                    trailing: IconButton(
                      icon: const Icon(Icons.edit),
                      onPressed: () async {
                        final date = await showDatePicker(
                          context: dialogContext,
                          initialDate: lendDateController ?? DateTime.now(),
                          firstDate: DateTime(2000),
                          lastDate: DateTime.now(),
                        );
                        if (date != null && dialogContext.mounted) {
                          setDialogState(() => lendDateController = date);
                        }
                      },
                    ),
                  ),
                  ListTile(
                    leading: const Icon(Icons.calendar_today),
                    title: const Text('Expected Return Date'),
                    trailing: IconButton(
                      icon: const Icon(Icons.edit),
                      onPressed: () async {
                        final date = await showDatePicker(
                          context: dialogContext,
                          initialDate:
                              expectedLendReturnDateController ??
                              DateTime.now().add(const Duration(days: 14)),
                          firstDate: DateTime(2000),
                          lastDate: DateTime(2030),
                        );
                        if (date != null && dialogContext.mounted) {
                          setDialogState(
                            () => expectedLendReturnDateController = date,
                          );
                        }
                      },
                    ),
                  ),
                ],
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
                final authors = authorsController.text.trim();
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
                          authors: authors,
                          description: _nullable(descriptionController.text),
                          pageCount: pages,
                          coverAssetKey: coverAssetKey,
                          publisher: _publisherController.text.trim().isEmpty
                              ? null
                              : _publisherController.text.trim(),
                          isbn10: _isbn10Controller.text.trim().isEmpty
                              ? null
                              : _isbn10Controller.text.trim(),
                          isbn13: _isbn13Controller.text.trim().isEmpty
                              ? null
                              : _isbn13Controller.text.trim(),
                          purchasePrice: double.tryParse(
                            purchasePriceController.text,
                          ),
                          purchaseCurrency:
                              purchaseCurrencyController.text.trim().isEmpty
                              ? null
                              : purchaseCurrencyController.text.trim(),
                          isBorrowed: isBorrowedController,
                          lenderName: lenderNameController.text.trim().isEmpty
                              ? null
                              : lenderNameController.text.trim(),
                          lenderContact:
                              lenderContactController.text.trim().isEmpty
                              ? null
                              : lenderContactController.text.trim(),
                          borrowDate: borrowDateController,
                          expectedReturnDate: expectedReturnDateController,
                          isLent: isLentController,
                          borrowerName:
                              borrowerNameController.text.trim().isEmpty
                              ? null
                              : borrowerNameController.text.trim(),
                          borrowerContact:
                              borrowerContactController.text.trim().isEmpty
                              ? null
                              : borrowerContactController.text.trim(),
                          lendDate: lendDateController,
                          expectedLendReturnDate:
                              expectedLendReturnDateController,
                        )
                      : book.copyWith(
                          title: title,
                          authors: authors,
                          description: _nullable(descriptionController.text),
                          pageCount: pages,
                          coverAssetKey: coverAssetKey,
                          publisher: _publisherController.text.trim().isEmpty
                              ? null
                              : _publisherController.text.trim(),
                          isbn10: _isbn10Controller.text.trim().isEmpty
                              ? null
                              : _isbn10Controller.text.trim(),
                          isbn13: _isbn13Controller.text.trim().isEmpty
                              ? null
                              : _isbn13Controller.text.trim(),
                          purchasePrice: double.tryParse(
                            purchasePriceController.text,
                          ),
                          purchaseCurrency:
                              purchaseCurrencyController.text.trim().isEmpty
                              ? null
                              : purchaseCurrencyController.text.trim(),
                          isBorrowed: isBorrowedController,
                          lenderName: lenderNameController.text.trim().isEmpty
                              ? null
                              : lenderNameController.text.trim(),
                          lenderContact:
                              lenderContactController.text.trim().isEmpty
                              ? null
                              : lenderContactController.text.trim(),
                          borrowDate: borrowDateController,
                          expectedReturnDate: expectedReturnDateController,
                          isLent: isLentController,
                          borrowerName:
                              borrowerNameController.text.trim().isEmpty
                              ? null
                              : borrowerNameController.text.trim(),
                          borrowerContact:
                              borrowerContactController.text.trim().isEmpty
                              ? null
                              : borrowerContactController.text.trim(),
                          lendDate: lendDateController,
                          expectedLendReturnDate:
                              expectedLendReturnDateController,
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
    purchasePriceController.dispose();
    purchaseCurrencyController.dispose();
    lenderNameController.dispose();
    lenderContactController.dispose();
    borrowerNameController.dispose();
    borrowerContactController.dispose();
    if (saved == true) await _loadBooks();
    return saved ?? false;
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
      appBar: AppBar(title: const Text('Library')),
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
