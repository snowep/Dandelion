import 'package:drift/drift.dart';

import 'book.dart';
import 'book_database.dart';
import 'book_repository.dart';
import 'reading_record.dart';

class DuplicateBookIsbnException implements Exception {
  const DuplicateBookIsbnException(this.isbn);

  final String isbn;

  @override
  String toString() => 'A book with ISBN $isbn is already in the library.';
}

class BookRepositoryImpl implements BookRepository {
  BookRepositoryImpl(this._database);

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
      final id = await _database.into(_database.books).insert(
            BooksCompanion.insert(
              id: Value.absentIfNull(book.id > 0 ? book.id : null),
              title: book.title.trim(),
              author: Value(_optional(book.authors)),
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
      final duplicate = await (_database.select(_database.books)
            ..where((row) =>
                row.normalizedIsbn.equals(normalizedIsbn) &
                row.id.isNotValue(book.id)))
          .getSingleOrNull();
      if (duplicate != null) {
        throw DuplicateBookIsbnException(normalizedIsbn);
      }
    }
    await _database.updateBook(
      BooksCompanion(
        id: Value(book.id),
        title: Value(book.title.trim()),
        author: Value(_optional(book.authors)),
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
  Future<List<Book>> getAll() async =>
      (await _database.getAllBooks()).map(_toBook).toList(growable: false);

  @override
  Future<List<Book>> listBooks({
    Map<String, dynamic>? filters,
    String? sortBy,
    bool ascending = true,
  }) async {
    final search = filters?['search'];
    final rows = search is String && search.trim().isNotEmpty
        ? await _database.searchBooks(search)
        : await _database.getAllBooks();
    final books = rows.map(_toBook).toList();
    final status = filters?['status'];
    if (status is String) {
      final records = await listReadingRecords();
      final ids = records
          .where((record) => record.status.name == status)
          .map((record) => record.bookId)
          .toSet();
      books.removeWhere((book) => !ids.contains(book.id));
    }
    final genre = filters?['genre'];
    if (genre is String && genre.trim().isNotEmpty) {
      books.removeWhere(
        (book) =>
            !(book.genres ?? '').toLowerCase().contains(genre.toLowerCase()),
      );
    }
    final field = switch (sortBy) {
      'author' => (Book book) => book.authors.toLowerCase(),
      'pageCount' => (Book book) => book.pageCount,
      'added' => (Book book) => book.createdAt,
      'updated' => (Book book) => book.updatedAt,
      _ => (Book book) => book.title.toLowerCase(),
    };
    books.sort((left, right) {
      final comparison = _compare(field(left), field(right));
      return ascending ? comparison : -comparison;
    });
    return books;
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
    await updateBook(book.copyWith(
      isInWishlist: !book.isInWishlist,
      updatedAt: DateTime.now(),
    ));
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

  Book _toBook(BookRow row) => Book(
        id: row.id,
        title: row.title,
        authors: row.author ?? '',
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
        createdAt: row.createdAt,
        updatedAt: row.updatedAt,
        archivedAt: row.archivedAt,
        isInWishlist: row.isInWishlist,
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
