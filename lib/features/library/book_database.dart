import 'package:drift/drift.dart';
import 'package:sqlite3/sqlite3.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'dart:io';

part 'book_database.g.dart';

// Part 1: Book table
@DataClassName('Book')
class Books extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get title => text(); // not null by default
  TextColumn get author => text().nullable();
  TextColumn get isbn => text().nullable();
  TextColumn get normalizedIsbn => text().nullable();
  IntColumn get publishedYear => integer().nullable();
  IntColumn get pageCount => integer().nullable();
  TextColumn get coverUrl => text().nullable();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime);
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime);

  @override
  List<Index> get indexes => [
    Index.unique('books_normalized_isbn_idx', [normalizedIsbn]),
  ];
}

// Part 2: ReadingRecord table
@DataClassName('ReadingRecord')
class ReadingRecords extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get bookId => integer().references(Books, #id);
  DateTimeColumn get startDate => dateTime();
  DateTimeColumn get endDate => dateTime().nullable();
  IntColumn get progressPercent => integer().withDefault(const Constant(0));
  TextColumn get notes => text().nullable();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime);
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime);

  @override
  List<Index> get indexes => [
    Index('reading_records_book_id_idx', [bookId]),
    Index('reading_records_start_date_idx', [startDate]),
  ];
}

// Part 3: Database
@DriftDatabase(tables: [Books, ReadingRecords])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 1;


  // You can add custom queries here
  Future<List<Book>> getAllBooks() => select(books).get();
  Future<Book?> getBookById(int id) => (select(books)..where((t) => t.id.equals(id))).getSingleOrNull();
  Future<int> insertBook(Book book) => into(books).insert(book);
  Future<int> updateBook(Book book) => update(books).replace(book);
  Future<int> deleteBook(int id) => (delete(books)..where((t) => t.id.equals(id))).go();
  /// Search books using the current search strategy (FTS5 or LIKE fallback).
  Future<List<Book>> searchBooks(String query) => searchStrategy.searchBooks(query);
  Future<List<ReadingRecord>> getReadingRecordsForBook(int bookId) =>
      (select(readingRecords)..where((t) => t.bookId.equals(bookId))).get();
  Future<int> insertReadingRecord(ReadingRecord record) =>
      into(readingRecords).insert(record);
  Future<int> updateReadingRecord(ReadingRecord record) =>
      update(readingRecords).replace(record);
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'dandelion.db'));
    final sqliteDb = file.open();

    // Check FTS5 support and initialize search strategy.
    final AppDatabase db = AppDatabase(sqliteDb);
    await db._initializeSearchStrategy();
    return sqliteDb;
  });
}

abstract class BookSearchStrategy {
  Future<List<Book>> searchBooks(String query);
}

class Fts5BookSearchStrategy implements BookSearchStrategy {
  final AppDatabase _db;

  Fts5BookSearchStrategy(this._db);

  @override
  Future<List<Book>> searchBooks(String query) async {
    // Assuming we have an FTS5 virtual table named 'books_fts' that mirrors the Books table
    // and has a book_id column that references the books table.
    // We use the MATCH operator for FTS5.
    final results = await _db.customSelect(
      '''
      SELECT b.* FROM books b
      JOIN books_fts fts ON b.id = fts.book_id
      WHERE fts MATCH :query
      ''',
      variables: {'query': query},
    ).map((row) => Book.fromData(row.data)).toList();
    return results;
  }
}

class LikeBookSearchStrategy implements BookSearchStrategy {
  final AppDatabase _db;

  LikeBookSearchStrategy(this._db);

  @override
  Future<List<Book>> searchBooks(String query) async {
    // Use LIKE with wildcards on the indexed columns: title, author, normalizedIsbn
    // We search for the query in any of these columns.
    final searchTerm = '%$query%';
    return (_db.select(_db.books)
          .where((tbl) =>
              tbl.title.like(searchTerm) |
              tbl.author.like(searchTerm) |
              tbl.normalizedIsbn.like(searchTerm)))
        .get();
  }
}

extension AppDatabaseExtensions on AppDatabase {
  late final BookSearchStrategy _searchStrategy;

  BookSearchStrategy get searchStrategy => _searchStrategy;

  Future<void> _initializeSearchStrategy() async {
    // Check if FTS5 is supported by attempting to create a virtual table.
    bool fts5Supported = false;
    try {
      // Try to create a temporary FTS5 table to see if it's supported.
      await customCreateTable('CREATE VIRTUAL TABLE IF NOT EXISTS temp_books_fts USING fts5(title, author, normalizedIsbn, content=\"books\", content_rowid=\"id\")');
      fts5Supported = true;
      // Drop the temporary table.
      await customDelete('DROP TABLE temp_books_fts');
    } catch (e) {
      // FTS5 not supported.
      fts5Supported = false;
    }

    // If FTS5 is supported, create the FTS5 virtual table for real use.
    if (fts5Supported) {
      try {
        await customCreateTable('''
          CREATE VIRTUAL TABLE IF NOT EXISTS books_fts USING fts5(
            title,
            author,
            normalizedIsbn,
            content=\"books\",
            content_rowid=\"id\"
          )
        ''');
        // Set up triggers to keep the FTS5 table in sync with the books table.
        await customCreateTable('''
          CREATE TRIGGER IF NOT EXISTS books_fts_insert AFTER INSERT ON books BEGIN
            INSERT INTO books_fts(rowid, title, author, normalizedIsbn) VALUES (new.id, new.title, new.author, new.normalizedIsbn);
          END
        ''');
        await customCreateTable('''
          CREATE TRIGGER IF NOT EXISTS books_fts_delete AFTER DELETE ON books BEGIN
            INSERT INTO books_fts(books_fts, rowid, title, author, normalizedIsbn) VALUES ('delete', old.id, old.title, old.author, old.normalizedIsbn);
          END
        ''');
        await customCreateTable('''
          CREATE TRIGGER IF NOT EXISTS books_fts_update AFTER UPDATE ON books BEGIN
            INSERT INTO books_fts(books_fts, rowid, title, author, normalizedIsbn) VALUES ('delete', old.id, old.title, old.author, old.normalizedIsbn);
            INSERT INTO books_fts(rowid, title, author, normalizedIsbn) VALUES (new.id, new.title, new.author, new.normalizedIsbn);
          END
        ''');
      } catch (e) {
        // If something goes wrong, fall back to LIKE.
        fts5Supported = false;
      }
    }

    // Set the search strategy based on FTS5 support.
    _searchStrategy = fts5Supported
        ? Fts5BookSearchStrategy(this)
        : LikeBookSearchStrategy(this);
  }
}
