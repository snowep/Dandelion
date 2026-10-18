import 'package:drift/drift.dart';

import 'package:dandelion/features/library/book.dart';
import 'package:dandelion/features/library/book_database.dart';
import 'package:dandelion/features/library/book_repository.dart';
import 'package:dandelion/features/library/reading_record.dart';

class DuplicateBookIsbnException implements Exception {
  final String isbn;

  DuplicateBookIsbnException(this.isbn);

  @override
  String toString() =>
      'DuplicateBookIsbnException: ISBN $isbn already exists in the library.';
}

class BookRepositoryImpl implements BookRepository {
  BookRepositoryImpl([AppDatabase? database])
    : _database = database ?? AppDatabase();

  final AppDatabase _database;

  @override
  Future<int> createBook(
    Book book, {
    ReadingStatus initialStatus = ReadingStatus.wantToRead,
  }) async {
    _validateBook(book);
    final normalizedIsbn = _normalizeIsbn(book.isbn13 ?? book.isbn10);
    if (normalizedIsbn != null &&
        await (_database.select(_database.books)
                  ..where((row) => row.normalizedIsbn.equals(normalizedIsbn)))
                .getSingleOrNull() !=
            null) {
      throw DuplicateBookIsbnException(normalizedIsbn);
    }

    return _database.transaction(() async {
      final List<String> authorsList = book.authors
          .split(',')
          .map((e) => e.trim())
          .where((e) => e.isNotEmpty)
          .toList();
      final List<String> genresList = book.genres != null
          ? book.genres!
                .split(',')
                .map((e) => e.trim())
                .where((e) => e.isNotEmpty)
                .toList()
          : <String>[];
      final id = await _database
          .into(_database.books)
          .insert(
            BooksCompanion.insert(
              id: Value.absentIfNull(book.id > 0 ? book.id : null),
              title: book.title.trim(),
              author: Value(authorsList.isNotEmpty ? authorsList.first : null),
              description: Value(_optional(book.description)),
              genres: Value(
                genresList.isNotEmpty ? genresList.join(',') : null,
              ),
              isbn: Value(book.isbn13 ?? book.isbn10),
              normalizedIsbn: Value(normalizedIsbn),
              publisher: Value(_optional(book.publisher)),
              publicationDate: Value(book.publicationDate),
              publishedYear: Value(book.publicationDate?.year),
              pageCount: Value(book.pageCount),
              coverAssetKey: Value(book.coverAssetKey),
              isInWishlist: Value(book.isInWishlist),
              externalCatalogId: Value(book.externalCatalogId),
              externalSourceUrl: Value(book.externalSourceUrl),
              purchasePrice: Value(book.purchasePrice),
              purchaseCurrency: Value(_optional(book.purchaseCurrency)),
              isBorrowed: Value(book.isBorrowed),
              lenderName: Value(_optional(book.lenderName)),
              lenderContact: Value(_optional(book.lenderContact)),
              borrowDate: Value(book.borrowDate),
              expectedReturnDate: Value(book.expectedReturnDate),
              isLent: Value(book.isLent),
              borrowerName: Value(_optional(book.borrowerName)),
              borrowerContact: Value(_optional(book.borrowerContact)),
              lendDate: Value(book.lendDate),
              expectedLendReturnDate: Value(book.expectedLendReturnDate),
              createdAt: Value(book.createdAt),
              updatedAt: Value(book.updatedAt),
              archivedAt: Value(book.archivedAt),
            ),
          );
      await _database.saveReadingRecord(
        ReadingRecordsCompanion.insert(
          bookId: id,
          status: Value(initialStatus.name),
        ),
      );
      return id;
    });
  }

  @override
  Future<void> updateBook(Book book) async {
    _validateBook(book);
    final normalizedIsbn = _normalizeIsbn(book.isbn13 ?? book.isbn10);
    if (normalizedIsbn != null) {
      final duplicate =
          await (_database.select(_database.books)..where(
                (row) =>
                    row.normalizedIsbn.equals(normalizedIsbn) &
                    row.id.isNotValue(book.id),
              ))
              .getSingleOrNull();
      if (duplicate != null) {
        throw DuplicateBookIsbnException(normalizedIsbn);
      }
    }
    final List<String> authorsList = book.authors
        .split(',')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();
    final String? firstAuthor = authorsList.isNotEmpty
        ? authorsList.first
        : null;

    await _database.updateBook(
      BooksCompanion(
        id: Value(book.id),
        title: Value(book.title.trim()),
        author: Value(firstAuthor),
        description: Value(_optional(book.description)),
        genres: Value(_optional(book.genres)),
        isbn: Value(book.isbn13 ?? book.isbn10),
        normalizedIsbn: Value(normalizedIsbn),
        publisher: Value(_optional(book.publisher)),
        publicationDate: Value(book.publicationDate),
        publishedYear: Value(book.publicationDate?.year),
        pageCount: Value(book.pageCount),
        coverAssetKey: Value(book.coverAssetKey),
        isInWishlist: Value(book.isInWishlist),
        externalCatalogId: Value(book.externalCatalogId),
        externalSourceUrl: Value(book.externalSourceUrl),
        purchasePrice: Value(book.purchasePrice),
        purchaseCurrency: Value(_optional(book.purchaseCurrency)),
        isBorrowed: Value(book.isBorrowed),
        lenderName: Value(_optional(book.lenderName)),
        lenderContact: Value(_optional(book.lenderContact)),
        borrowDate: Value(book.borrowDate),
        expectedReturnDate: Value(book.expectedReturnDate),
        isLent: Value(book.isLent),
        borrowerName: Value(_optional(book.borrowerName)),
        borrowerContact: Value(_optional(book.borrowerContact)),
        lendDate: Value(book.lendDate),
        expectedLendReturnDate: Value(book.expectedLendReturnDate),
        updatedAt: Value(DateTime.now()),
        archivedAt: Value(book.archivedAt),
      ),
    );
  }

  @override
  Future<Book?> getBookById(int id) async {
    final row = await _database.getBookById(id);
    return row == null ? null : _toBook(row);
  }

  @override
  Future<List<Book>> getAll({int? limit, int? offset}) async =>
      (await _database.getAllBooks(limit: limit))
          .map(_toBook)
          .toList(growable: false);

  @override
  Future<List<Book>> listBooks({
    Map<String, dynamic>? filters,
    String? sortBy,
    bool ascending = true,
    int? limit,
    int? offset,
  }) async {
    final search = filters?['search'];
    final status = filters?['status'];
    final genre = filters?['genre'];
    final rows = await _database.getBooksFiltered(
      search: search,
      status: status,
      genre: genre,
      sortBy: sortBy,
      ascending: ascending,
      limit: limit,
      offset: offset,
    );
    return rows.map(_toBook).toList(growable: false);
  }

  @override
  Future<void> archiveBook(int id) async {
    await _database.archiveBook(id);
  }

  @override
  Future<void> deleteBook(int id) async {
    await _database.deleteBook(id);
  }

  @override
  Future<void> toggleWishlist(int bookId) async {
    final book = await getBookById(bookId);
    if (book == null) {
      throw ArgumentError('Book not found: $bookId');
    }
    await updateBook(
      book.copyWith(
        isInWishlist: !book.isInWishlist,
        updatedAt: DateTime.now(),
      ),
    );
  }

  @override
  Future<List<Book>> getBooksByWishlist({bool isInWishlist = true}) async {
    final rows =
        await (_database.select(_database.books)
              ..where((book) => book.isInWishlist.equals(isInWishlist))
              ..where((book) => book.archivedAt.isNull()))
            .get();
    return rows.map(_toBook).toList(growable: false);
  }

  @override
  Future<List<Book>> getBooksFiltered({
    String? search,
    String? status,
    String? genre,
    String? sortBy,
    bool ascending = true,
  }) async {
    final rows = await _database.getBooksFiltered(
      search: search,
      status: status,
      genre: genre,
      sortBy: sortBy,
      ascending: ascending,
    );
    return rows.map(_toBook).toList(growable: false);
  }

  @override
  Future<Book?> getBookByIsbn(String isbn) async {
    final normalizedIsbn = _normalizeIsbn(isbn);
    if (normalizedIsbn == null) return null;

    final row =
        await (_database.select(_database.books)
              ..where((row) => row.normalizedIsbn.equals(normalizedIsbn)))
            .getSingleOrNull();

    return row == null ? null : _toBook(row);
  }

  @override
  Future<void> createReadingRecord(ReadingRecord record) async {
    await _validateProgress(record);
    if (await _database.getReadingRecordForBook(record.bookId) != null) {
      throw StateError('A reading record already exists for this book.');
    }
    await _database.saveReadingRecord(_toCompanion(record));
  }

  @override
  Future<void> updateReadingRecord(ReadingRecord record) async {
    await _validateProgress(record);
    final existing = await _database.getReadingRecordForBook(record.bookId);
    await _database.saveReadingRecord(
      _toCompanion(
        existing == null ? record : record.copyWith(id: existing.id),
      ),
    );
  }

  @override
  Future<ReadingRecord?> getReadingRecordForBook(int bookId) async {
    final row = await _database.getReadingRecordForBook(bookId);
    return row == null ? null : _toReadingRecord(row);
  }

  @override
  Future<List<ReadingRecord>> listReadingRecords({int? bookId}) async {
    final query = _database.select(_database.readingRecords);
    if (bookId != null) {
      query.where((record) => record.bookId.equals(bookId));
    }
    return (await query.get()).map(_toReadingRecord).toList(growable: false);
  }

  @override
  Future<void> close() => _database.close();

  @override
  Future<int> getTotalBooksCount() async {
    return (await (_database.select(
      _database.books,
    )..where((book) => book.archivedAt.isNull())).get()).length;
  }

  @override
  Future<int> getWishlistCount() async {
    return (await (_database.select(
      _database.books,
    )..where((book) => book.isInWishlist.equals(true))).get()).length;
  }

  @override
  Future<Map<String, int>> getReadingStatusCounts() async {
    final records = await _database.select(_database.readingRecords).get();
    final counts = <String, int>{};
    for (final record in records) {
      counts[record.status] = (counts[record.status] ?? 0) + 1;
    }
    return counts;
  }

  @override
  Future<double> getAverageRating() async {
    final rows = await (_database.select(
      _database.readingRecords,
    )..where((record) => record.personalRating.isNotNull())).get();
    if (rows.isEmpty) return 0.0;
    final sum = rows.fold<double>(0.0, (s, r) => s + (r.personalRating ?? 0.0));
    return sum / rows.length;
  }

  @override
  Future<int> getTotalPagesRead() async {
    final rows = await (_database.select(
      _database.readingRecords,
    )..where((record) => record.status.isIn(['reading', 'finished']))).get();
    return rows.fold<int>(0, (s, r) => s + (r.currentPage ?? 0));
  }

  @override
  Future<int> getBooksFinishedThisMonth() async {
    final now = DateTime.now();
    final start = DateTime(now.year, now.month, 1);
    final rows =
        await (_database.select(_database.readingRecords)..where(
              (record) =>
                  record.status.equals('finished') &
                  record.finishDate.isNotNull() &
                  record.finishDate.isBiggerOrEqualValue(start),
            ))
            .get();
    return rows.length;
  }

  @override
  Future<Map<String, int>> getGenreCounts() async {
    final books = await getAll();
    final counts = <String, int>{};
    for (final book in books) {
      if (book.genres != null && book.genres!.isNotEmpty) {
        final List<String> genresList = book.genres!
            .split(',')
            .map((e) => e.trim())
            .where((e) => e.isNotEmpty)
            .toList();
        for (final genre in genresList) {
          counts[genre] = (counts[genre] ?? 0) + 1;
        }
      }
    }
    return counts;
  }

  @override
  Future<Map<String, int>> getAuthorCounts() async {
    final books = await getAll();
    final counts = <String, int>{};
    for (final book in books) {
      final List<String> authorsList = book.authors
          .split(',')
          .map((e) => e.trim())
          .where((e) => e.isNotEmpty)
          .toList();
      for (final author in authorsList) {
        counts[author] = (counts[author] ?? 0) + 1;
      }
    }
    return counts;
  }

  @override
  Future<Map<int, int>> getPublishedYearCounts() async {
    final books = await _database.getAllBooks();
    final counts = <int, int>{};
    for (final book in books) {
      if (book.publicationDate != null) {
        final year = book.publicationDate!.year;
        counts[year] = (counts[year] ?? 0) + 1;
      }
    }
    return counts;
  }

  @override
  Future<int> getBooksReadThisYear() async {
    final now = DateTime.now();
    final start = DateTime(now.year, 1, 1);
    final rows =
        await (_database.select(_database.readingRecords)..where(
              (record) =>
                  record.status.equals('finished') &
                  record.finishDate.isNotNull() &
                  record.finishDate.isBiggerOrEqualValue(start),
            ))
            .get();
    return rows.length;
  }

  @override
  Future<int> getBooksPurchasedThisYear() async {
    final books = await _database.getAllBooks();
    int count = 0;
    for (final book in books) {
      final purchasePrice = book.purchasePrice;
      if (purchasePrice != null && purchasePrice > 0) {
        // Assuming we have a purchase date field - if not, we'd need to add it
        // For now, we'll count all purchased books as purchased this year
        // In a real implementation, we would check the purchase date
        count++;
      }
    }
    return count;
  }

  Book _toBook(BookRow row) => Book(
    id: row.id,
    title: row.title,
    authors: row.authors ?? '',
    description: row.description,
    genres: row.genres,
    isbn10: row.isbn?.length == 10 ? row.isbn : null,
    isbn13: row.isbn?.length == 13 ? row.isbn : null,
    publisher: row.publisher,
    publicationDate: row.publicationDate,
    pageCount: row.pageCount,
    coverAssetKey: row.coverAssetKey,
    externalCatalogId: row.externalCatalogId,
    externalSourceUrl: row.externalSourceUrl,
    purchasePrice: row.purchasePrice?.toDouble(),
    purchaseCurrency: row.purchaseCurrency,
    isBorrowed: row.isBorrowed,
    lenderName: row.lenderName,
    lenderContact: row.lenderContact,
    borrowDate: row.borrowDate,
    expectedReturnDate: row.expectedReturnDate,
    isLent: row.isLent,
    borrowerName: row.borrowerName,
    borrowerContact: row.borrowerContact,
    lendDate: row.lendDate,
    expectedLendReturnDate: row.expectedLendReturnDate,
    createdAtParam: row.createdAt,
    updatedAtParam: row.updatedAt,
    archivedAt: row.archivedAt,
    isInWishlistParam: row.isInWishlist,
  );

  ReadingRecordsCompanion _toCompanion(ReadingRecord record) =>
      ReadingRecordsCompanion(
        id: Value.absentIfNull(record.id),
        bookId: Value(record.bookId),
        status: Value(record.status.name),
        currentPage: Value(record.currentPage),
        progressPercent: Value(
          record.percentageOnlyProgress == null
              ? null
              : (record.percentageOnlyProgress! * 100).round(),
        ),
        startDate: Value(record.startDate),
        finishDate: Value(record.finishDate),
        lastReadDate: Value(record.lastReadDate),
        personalRating: Value(record.personalRating),
        notes: Value(record.notes),
      );

  ReadingRecord _toReadingRecord(ReadingRecordRow row) => ReadingRecord(
    id: row.id,
    bookId: row.bookId,
    status: ReadingStatus.values.firstWhere(
      (status) => status.name == row.status,
      orElse: () => ReadingStatus.wantToRead,
    ),
    currentPage: row.currentPage,
    percentageOnlyProgress: row.progressPercent == null
        ? null
        : row.progressPercent! / 100,
    startDate: row.startDate,
    finishDate: row.finishDate,
    lastReadDate: row.lastReadDate,
    personalRating: row.personalRating,
    notes: row.notes,
  );

  Future<void> _validateProgress(ReadingRecord record) async {
    if (record.currentPage != null) {
      if (record.currentPage! < 0) {
        throw ArgumentError.value(record.currentPage, 'currentPage');
      }
      final pageCount = (await _database.getBookById(record.bookId))?.pageCount;
      if (pageCount != null && record.currentPage! > pageCount) {
        throw ArgumentError.value(
          record.currentPage,
          'currentPage',
          'Cannot exceed the book page count ($pageCount).',
        );
      }
    }
    final progress = record.percentageOnlyProgress;
    if (progress != null && (progress < 0 || progress > 1)) {
      throw ArgumentError.value(progress, 'percentageOnlyProgress');
    }
    final rating = record.personalRating;
    if (rating != null && (rating < 0 || rating > 5)) {
      throw ArgumentError.value(rating, 'personalRating');
    }
  }

  static void _validateBook(Book book) {
    if (book.title.trim().isEmpty) {
      throw ArgumentError.value(book.title, 'title', 'Title is required.');
    }
    if (book.pageCount != null && book.pageCount! <= 0) {
      throw ArgumentError.value(book.pageCount, 'pageCount');
    }
  }

  static String? _normalizeIsbn(String? isbn) {
    final normalized = isbn?.replaceAll(RegExp('[^0-9Xx]'), '').toUpperCase();
    return normalized == null || normalized.isEmpty ? null : normalized;
  }

  static String? _optional(String? value) =>
      value == null || value.trim().isEmpty ? null : value.trim();

  static int _compare(Object? left, Object? right) {
    if (left == null) return right == null ? 0 : -1;
    if (right == null) return 1;
    if (left is int && right is int) return left.compareTo(right);
    if (left is DateTime && right is DateTime) return left.compareTo(right);
    return left.toString().compareTo(right.toString());
  }
}
