import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

part 'book_database.g.dart';

@DataClassName('BookRow')
@TableIndex(
  name: 'books_normalized_isbn_idx',
  columns: {#normalizedIsbn},
  unique: true,
)
class Books extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get title => text().withLength(min: 1, max: 512)();
  TextColumn get authors => text().nullable()();
  TextColumn get author => text().nullable()();
  TextColumn get description => text().nullable()();
  TextColumn get summary => text().nullable()();
  TextColumn get genres => text().nullable()();
  TextColumn get isbn => text().nullable()();
  TextColumn get normalizedIsbn => text().nullable()();
  TextColumn get publisher => text().nullable()();
  DateTimeColumn get publicationDate => dateTime().nullable()();
  IntColumn get publishedYear => integer().nullable()();
  IntColumn get pageCount => integer().nullable()();
  TextColumn get coverAssetKey => text().nullable()();
  TextColumn get coverUrl => text().nullable()();
  BoolColumn get isInWishlist => boolean().withDefault(const Constant(false))();
  TextColumn get externalCatalogId => text().nullable()();
  TextColumn get externalSourceUrl => text().nullable()();
  RealColumn get purchasePrice => real().nullable()();
  TextColumn get purchaseCurrency => text().nullable()();
  BoolColumn get isBorrowed => boolean().withDefault(const Constant(false))();
  TextColumn get lenderName => text().nullable()();
  TextColumn get lenderContact => text().nullable()();
  DateTimeColumn get borrowDate => dateTime().nullable()();
  DateTimeColumn get expectedReturnDate => dateTime().nullable()();
  BoolColumn get isLent => boolean().withDefault(const Constant(false))();
  TextColumn get borrowerName => text().nullable()();
  TextColumn get borrowerContact => text().nullable()();
  DateTimeColumn get lendDate => dateTime().nullable()();
  DateTimeColumn get expectedLendReturnDate => dateTime().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get archivedAt => dateTime().nullable()();
}

@DataClassName('ReadingRecordRow')
@TableIndex(name: 'reading_records_book_idx', columns: {#bookId}, unique: true)
class ReadingRecords extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get bookId =>
      integer().references(Books, #id, onDelete: KeyAction.cascade)();
  TextColumn get status => text().withDefault(const Constant('wantToRead'))();
  IntColumn get currentPage => integer().nullable()();
  IntColumn get progressPercent => integer().nullable()();
  DateTimeColumn get startDate => dateTime().nullable()();
  DateTimeColumn get finishDate => dateTime().nullable()();
  DateTimeColumn get lastReadDate =>
      dateTime().withDefault(currentDateAndTime)();
  RealColumn get personalRating => real().nullable()();
  TextColumn get notes => text().nullable()();
}

@DriftDatabase(tables: [Books, ReadingRecords])
class AppDatabase extends _$AppDatabase {
  AppDatabase([QueryExecutor? executor])
    : super(
        executor ??
            driftDatabase(
              name: 'dandelion',
              web: DriftWebOptions(
                sqlite3Wasm: Uri.parse('sqlite3.wasm'),
                driftWorker: Uri.parse('drift_worker.dart.js'),
              ),
            ),
      );

  @override
  int get schemaVersion => 4;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (migrator) => migrator.createAll(),
    onUpgrade: (migrator, from, to) async {
      if (from < 2) {
        await migrator.addColumn(books, books.summary);
      }
      if (from < 3) {
        await migrator.addColumn(books, books.isInWishlist);
      }
      if (from < 4) {
        await migrator.addColumn(books, books.purchasePrice);
        await migrator.addColumn(books, books.purchaseCurrency);
        await migrator.addColumn(books, books.isBorrowed);
        await migrator.addColumn(books, books.lenderName);
        await migrator.addColumn(books, books.lenderContact);
        await migrator.addColumn(books, books.borrowDate);
        await migrator.addColumn(books, books.expectedReturnDate);
        await migrator.addColumn(books, books.isLent);
        await migrator.addColumn(books, books.borrowerName);
        await migrator.addColumn(books, books.borrowerContact);
        await migrator.addColumn(books, books.lendDate);
        await migrator.addColumn(books, books.expectedLendReturnDate);
      }
    },
  );

  Future<List<BookRow>> getAllBooks({
    bool includeArchived = false,
    int? limit,
  }) {
    final query = select(books)
      ..orderBy([(book) => OrderingTerm.desc(book.updatedAt)]);
    if (!includeArchived) {
      query.where((book) => book.archivedAt.isNull());
    }
    if (limit != null) {
      query.limit(limit);
    }
    return query.get();
  }

  Future<List<BookRow>> searchBooks(String query, {int? limit}) {
    final term = '%${query.trim()}%';
    var queryBuilder = select(books)
      ..where(
        (book) =>
            book.archivedAt.isNull() &
            (book.title.like(term) |
                book.author.like(term) |
                book.isbn.like(term) |
                book.genres.like(term) |
                book.description.like(term)),
      )
      ..orderBy([(book) => OrderingTerm.asc(book.title)]);

    if (limit != null) {
      queryBuilder.limit(limit);
    }

    return queryBuilder.get();
  }

  Future<BookRow?> getBookById(int id) =>
      (select(books)..where((book) => book.id.equals(id))).getSingleOrNull();

  Future<int> insertBook(BooksCompanion book) => into(books).insert(book);

  Future<bool> updateBook(BooksCompanion book) => update(books).replace(book);

  Future<int> archiveBook(int id) =>
      (update(books)..where((book) => book.id.equals(id))).write(
        BooksCompanion(archivedAt: Value(DateTime.now())),
      );

  Future<int> deleteBook(int id) =>
      (delete(books)..where((book) => book.id.equals(id))).go();

  Future<void> deleteAllBooks() => (delete(books)).go();

  Future<void> deleteAllReadingRecords() => (delete(readingRecords)).go();

  Future<ReadingRecordRow?> getReadingRecordForBook(int bookId) => (select(
    readingRecords,
  )..where((record) => record.bookId.equals(bookId))).getSingleOrNull();

  Future<int> saveReadingRecord(ReadingRecordsCompanion record) =>
      into(readingRecords).insertOnConflictUpdate(record);

  /// Get books filtered by search, status, genre, and sort.
  /// Returns a list of [BookRow] that match the filters.
  Future<List<BookRow>> getBooksFiltered({
    String? search,
    String? status,
    String? genre,
    String? sortBy,
    bool ascending = true,
    int? limit,
    int? offset,
  }) {
    var query = select(books)..where((tbl) => tbl.archivedAt.isNull());

    if (search != null && search.trim().isNotEmpty) {
      final term = '%${search.trim()}%';
      query.where(
        (tbl) =>
            tbl.title.like(term) |
            tbl.author.like(term) |
            tbl.isbn.like(term) |
            tbl.genres.like(term) |
            tbl.description.like(term),
      );
    }

    if (status != null && status.trim().isNotEmpty) {
      query.join([
        innerJoin(readingRecords, readingRecords.bookId.equalsExp(books.id)),
      ]);
      query.where((tbl) => readingRecords.status.equals(status));
    }

    if (genre != null && genre.trim().isNotEmpty) {
      final lowerGenre = genre.trim().toLowerCase();
      query.where((tbl) => tbl.genres.contains(lowerGenre));
    }

    // Sorting
    switch (sortBy) {
      case 'title':
        query.orderBy([
          (tbl) => OrderingTerm(
            expression: tbl.title,
            mode: ascending ? OrderingMode.asc : OrderingMode.desc,
          ),
        ]);
        break;
      case 'author':
        query.orderBy([
          (tbl) => OrderingTerm(
            expression: tbl.author,
            mode: ascending ? OrderingMode.asc : OrderingMode.desc,
          ),
        ]);
        break;
      case 'date':
        query.orderBy([
          (tbl) => OrderingTerm(
            expression: tbl.updatedAt,
            mode: ascending ? OrderingMode.asc : OrderingMode.desc,
          ),
        ]);
        break;
      default:
        // default to title ascending
        query.orderBy([
          (tbl) => OrderingTerm(expression: tbl.title, mode: OrderingMode.asc),
        ]);
    }

    if (limit != null) {
      query.limit(limit, offset: offset);
    }

    return query.get();
  }
}
