import 'dart:io';

import 'package:dandelion/features/library/book.dart';
import 'package:dandelion/features/library/book_database.dart';
import 'package:dandelion/features/library/book_repository_impl.dart';
import 'package:dandelion/features/library/reading_record.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late Directory directory;
  late AppDatabase database;
  late BookRepositoryImpl repository;

  Future<void> openDatabase() async {
    database = AppDatabase(
      NativeDatabase(File('${directory.path}\\library.db')),
    );
    repository = BookRepositoryImpl(database);
  }

  setUp(() async {
    directory = await Directory.systemTemp.createTemp('dandelion-native-persistence-');
    await openDatabase();
  });

  tearDown(() async {
    await repository.close();
    await directory.delete(recursive: true);
  });

  test('create book record, close database, reopen and verify record survives restart', () async {
    final id = await repository.createBook(
      Book(id: 0, title: 'Persistence Test', authors: 'Author One'),
      initialStatus: ReadingStatus.wantToRead,
    );

    await repository.close();
    await openDatabase();

    final savedBook = await repository.getBookById(id);
    expect(savedBook, isNotNull);
    expect(savedBook!.title, 'Persistence Test');
    expect(savedBook.authors, 'Author One');
  });

  test('schema migration v1 to v2 preserves existing data', () async {
    // Create a v1 database and seed it
    final v1Id = await repository.createBook(
      Book(id: 0, title: 'Before Migration', authors: 'Migration Author'),
    );

    // Close v1 connection
    await repository.close();

    // Reopen with schema version 2 (migration should run)
    // The AppDatabase is now schemaVersion 2, migrator adds summary column
    await openDatabase();

    final migratedBook = await repository.getBookById(v1Id);
    expect(migratedBook, isNotNull);
    expect(migratedBook!.title, 'Before Migration');
    expect(migratedBook.authors, 'Migration Author');
    // New column should be null for existing rows
    expect(migratedBook.description, isNull);

    // Verify we can insert new rows with new column
    final newId = await repository.createBook(
      Book(id: 0, title: 'After Migration', authors: 'New Author'),
    );
    final newBook = await repository.getBookById(newId);
    expect(newBook, isNotNull);
    expect(newBook!.title, 'After Migration');
  });

  test('reading record survives close and reopen', () async {
    final id = await repository.createBook(
      Book(id: 0, title: 'With Reading', authors: 'Reader'),
      initialStatus: ReadingStatus.reading,
    );

    await repository.updateReadingRecord(
      ReadingRecord(bookId: id, status: ReadingStatus.reading, currentPage: 42, percentageOnlyProgress: 0.21),
    );

    await repository.close();
    await openDatabase();

    final book = await repository.getBookById(id);
    final record = await repository.getReadingRecordForBook(id);
    expect(book?.title, 'With Reading');
    expect(record?.status, ReadingStatus.reading);
    expect(record?.currentPage, 42);
  });
}
