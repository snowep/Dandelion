import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:drift/drift.dart' hide isNull, isNotNull;
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

  test('migrates from v3 to v4 preserving legacy data and initializing new columns', () async {
    // Create a temporary directory for the test database
    final directory = await Directory.systemTemp.createTemp();
    final v3DbPath = '${directory.path}/test_v3.db';

    try {
      // STEP 1: Create and populate v3 database (schema version 3)
      final v3Db = V3Database(NativeDatabase(File(v3DbPath)));
      try {
        // Add some test data with v3 schema
        await v3Db
            .into(v3Db.books)
            .insert(
              BooksCompanion(
                id: Value(1),
                title: Value('Test Book 1'),
                authors: Value('Author One'),
                summary: Value('A great book'),
                isInWishlist: Value(true),
                // Legacy columns that existed in v3
                isbn: Value('1234567890'),
                publisher: Value('Test Publisher'),
                publicationDate: Value(DateTime(2020, 1, 1)),
                pageCount: Value(300),
                coverAssetKey: Value('cover1.jpg'),
                externalCatalogId: Value('ext1'),
                externalSourceUrl: Value('http://example.com'),
                createdAt: Value(DateTime(2023, 1, 1)),
                updatedAt: Value(DateTime(2023, 1, 15)),
              ),
            );

        await v3Db
            .into(v3Db.books)
            .insert(
              BooksCompanion(
                id: Value(2),
                title: Value('Test Book 2'),
                authors: Value('Author Two'),
                summary: Value('Another book'),
                isInWishlist: Value(false),
                // Some nullable fields
                isbn: Value(null),
                publisher: Value(null),
                publicationDate: Value(null),
                pageCount: Value(null),
                coverAssetKey: Value(null),
                externalCatalogId: Value(null),
                externalSourceUrl: Value(null),
                createdAt: Value(DateTime(2023, 2, 1)),
                updatedAt: Value(DateTime(2023, 2, 15)),
              ),
            );

        // Add a reading record
        await v3Db
            .into(v3Db.readingRecords)
            .insert(
              ReadingRecordsCompanion(
                id: Value(1),
                bookId: Value(1),
                status: Value('reading'),
                currentPage: Value(50),
                progressPercent: Value(25),
                startDate: Value(DateTime(2023, 1, 10)),
              ),
            );

        await v3Db.close();
      } finally {
        await v3Db.close();
      }

      // STEP 2: Open the same database with current schema (v4) to trigger migration
      final v4Db = AppDatabase(NativeDatabase(File(v3DbPath)));
      try {
        // Verify schema version is now 4
        expect(v4Db.schemaVersion, 4);

        // Get all books and verify data preservation
        final books = await v4Db.getAllBooks();
        expect(books.length, 2);

        // Find our test books
        final book1 = books.firstWhere((b) => b.id == 1);
        final book2 = books.firstWhere((b) => b.id == 2);

        // Verify legacy data is preserved for book 1
        expect(book1.title, 'Test Book 1');
        expect(book1.authors, 'Author One');
        expect(book1.summary, 'A great book');
        expect(book1.isInWishlist, true);
        expect(book1.isbn, '1234567890');
        expect(book1.publisher, 'Test Publisher');
        expect(book1.publicationDate, DateTime(2020, 1, 1));
        expect(book1.pageCount, 300);
        expect(book1.coverAssetKey, 'cover1.jpg');
        expect(book1.externalCatalogId, 'ext1');
        expect(book1.externalSourceUrl, 'http://example.com');
        expect(book1.createdAt, DateTime(2023, 1, 1));
        expect(book1.updatedAt, DateTime(2023, 1, 15));

        // Verify legacy data is preserved for book 2
        expect(book2.title, 'Test Book 2');
        expect(book2.authors, 'Author Two');
        expect(book2.summary, 'Another book');
        expect(book2.isInWishlist, false);
        expect(book2.isbn, isNull);
        expect(book2.publisher, isNull);
        expect(book2.publicationDate, isNull);
        expect(book2.pageCount, isNull);
        expect(book2.coverAssetKey, isNull);
        expect(book2.externalCatalogId, isNull);
        expect(book2.externalSourceUrl, isNull);
        expect(book2.createdAt, DateTime(2023, 2, 1));
        expect(book2.updatedAt, DateTime(2023, 2, 15));

        // Verify new v4 columns are properly initialized (null/false/default)
        // Purchase fields
        expect(book1.purchasePrice, isNull);
        expect(book1.purchaseCurrency, isNull);
        expect(book2.purchasePrice, isNull);
        expect(book2.purchaseCurrency, isNull);

        // Borrow fields
        expect(book1.isBorrowed, false);
        expect(book1.lenderName, isNull);
        expect(book1.lenderContact, isNull);
        expect(book1.borrowDate, isNull);
        expect(book1.expectedReturnDate, isNull);
        expect(book2.isBorrowed, false);
        expect(book2.lenderName, isNull);
        expect(book2.lenderContact, isNull);
        expect(book2.borrowDate, isNull);
        expect(book2.expectedReturnDate, isNull);

        // Lent fields
        expect(book1.isLent, false);
        expect(book1.borrowerName, isNull);
        expect(book1.borrowerContact, isNull);
        expect(book1.lendDate, isNull);
        expect(book1.expectedLendReturnDate, isNull);
        expect(book2.isLent, false);
        expect(book2.borrowerName, isNull);
        expect(book2.borrowerContact, isNull);
        expect(book2.lendDate, isNull);
        expect(book2.expectedLendReturnDate, isNull);

        // Verify reading records are preserved
        final records = await v4Db.getReadingRecordsForBook(1);
        expect(records.length, 1);
        final record = records.first;
        expect(record.bookId, 1);
        expect(record.status, 'reading');
        expect(record.currentPage, 50);
        expect(record.progressPercent, 25);
        expect(record.startDate, DateTime(2023, 1, 10));
        expect(record.finishDate, isNull);
        expect(record.lastReadDate, isNotNull); // Has default value
        expect(record.personalRating, isNull);
        expect(record.notes, isNull);

        // Verify second open doesn't re-run migration (no errors)
        await v4Db.close();
        final v4DbSecond = AppDatabase(NativeDatabase(File(v3DbPath)));
        try {
          expect(v4DbSecond.schemaVersion, 4);
          final booksSecond = await v4DbSecond.getAllBooks();
          expect(booksSecond.length, 2);
        } finally {
          await v4DbSecond.close();
        }
      } finally {
        await v4Db.close();
      }
    } finally {
      // Clean up
      await directory.delete(recursive: true);
    }
  });

  test('migrates empty v3 database to v4', () async {
    // Create a temporary directory for the test database
    final directory = await Directory.systemTemp.createTemp();
    final v3DbPath = '${directory.path}/test_empty_v3.db';

    try {
      // STEP 1: Create empty v3 database (schema version 3)
      final v3Db = V3Database(NativeDatabase(File(v3DbPath)));
      try {
        // Don't add any data - just create the v3 schema
        await v3Db.close();
      } finally {
        await v3Db.close();
      }

      // STEP 2: Open the same database with current schema (v4) to trigger migration
      final v4Db = AppDatabase(NativeDatabase(File(v3DbPath)));
      try {
        // Verify schema version is now 4
        expect(v4Db.schemaVersion, 4);

        // Get all books and verify empty
        final books = await v4Db.getAllBooks();
        expect(books.length, 0);

        // Verify new v4 columns exist by trying to insert a book with them
        await v4Db
            .into(v4Db.books)
            .insert(
              BooksCompanion(
                title: Value('New Book'),
                authors: Value('New Author'),
                // Test that new columns accept null values
                purchasePrice: Value(null),
                purchaseCurrency: Value(null),
                isBorrowed: Value(false),
                lenderName: Value(null),
                lenderContact: Value(null),
                borrowDate: Value(null),
                expectedReturnDate: Value(null),
                isLent: Value(false),
                borrowerName: Value(null),
                borrowerContact: Value(null),
                lendDate: Value(null),
                expectedLendReturnDate: Value(null),
              ),
            );

        final booksAfterInsert = await v4Db.getAllBooks();
        expect(booksAfterInsert.length, 1);
        final newBook = booksAfterInsert.first;
        expect(newBook.title, 'New Book');
        expect(newBook.authors, 'New Author');
        expect(newBook.purchasePrice, isNull);
        expect(newBook.purchaseCurrency, isNull);
        expect(newBook.isBorrowed, false);
      } finally {
        await v4Db.close();
      }
    } finally {
      // Clean up
      await directory.delete(recursive: true);
    }
  });
}
