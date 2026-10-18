import 'package:flutter_test/flutter_test.dart';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:dandelion/features/library/book_database.dart';

void main() {
  test('schemaVersion is 4', () {
    final db = AppDatabase(NativeDatabase.memory());
    expect(db.schemaVersion, 4);
  });

  test('can open and use database without throwing', () async {
    final db = AppDatabase(NativeDatabase.memory());
    try {
      // Use the database
      await db
          .into(db.books)
          .insert(
            const BooksCompanion(
              title: Value('Test'),
              authors: Value('Author'),
            ),
          );
      final books = await db.getAllBooks();
      expect(books.length, 1);
    } finally {
      await db.close();
    }
  });
}
