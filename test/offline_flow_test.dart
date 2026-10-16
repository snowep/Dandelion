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
    directory = await Directory.systemTemp.createTemp('dandelion-library-');
    await openDatabase();
  });

  tearDown(() async {
    await repository.close();
    await directory.delete(recursive: true);
  });

  test('manual books and reading progress work offline', () async {
    final id = await repository.createBook(
      Book(
        id: 0,
        title: 'Offline Library',
        authors: 'A. Reader',
        pageCount: 250,
      ),
      initialStatus: ReadingStatus.reading,
    );

    await repository.updateReadingRecord(
      ReadingRecord(
        bookId: id,
        status: ReadingStatus.reading,
        currentPage: 75,
        percentageOnlyProgress: 0.3,
      ),
    );

    final savedBook = await repository.getBookById(id);
    final savedRecord = await repository.getReadingRecordForBook(id);
    expect(savedBook?.title, 'Offline Library');
    expect(savedRecord?.currentPage, 75);
    expect(savedRecord?.status, ReadingStatus.reading);
    expect(savedRecord?.percentageOnlyProgress, 0.3);
  });

  test('book and reading status survive close and reopen', () async {
    final id = await repository.createBook(
      Book(id: 0, title: 'Persistent', authors: 'Reader'),
      initialStatus: ReadingStatus.paused,
    );

    await repository.close();
    await openDatabase();

    expect((await repository.getBookById(id))?.title, 'Persistent');
    expect(
      (await repository.getReadingRecordForBook(id))?.status,
      ReadingStatus.paused,
    );
  });

  test('rejects duplicate ISBNs without adding another book', () async {
    final book = Book(
      id: 0,
      title: 'First edition',
      authors: 'Author',
      isbn13: '978-0-306-40615-7',
    );
    await repository.createBook(book);

    await expectLater(
      repository.createBook(
        Book(
          id: 0,
          title: 'Another edition',
          authors: 'Author',
          isbn13: '9780306406157',
        ),
      ),
      throwsA(isA<DuplicateBookIsbnException>()),
    );
    expect((await repository.getAll()).length, 1);
  });

  test('rejects progress outside valid page bounds', () async {
    final id = await repository.createBook(
      Book(id: 0, title: 'Bounded', authors: 'Reader', pageCount: 80),
    );
    await expectLater(
      repository.createReadingRecord(
        ReadingRecord(
          bookId: id,
          status: ReadingStatus.reading,
          currentPage: 81,
        ),
      ),
      throwsArgumentError,
    );
    expect(await repository.getReadingRecordForBook(id), isNotNull);
  });
}
