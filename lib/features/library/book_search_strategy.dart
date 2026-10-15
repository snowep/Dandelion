import 'package:drift/drift.dart';
import '../book_database.dart';

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