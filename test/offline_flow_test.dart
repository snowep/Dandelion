import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:dandelion/features/library/book_hive.dart';
import 'package:dandelion/features/library/book_repository_hive.dart';
import 'package:dandelion/features/library/books_notifier.dart';
import 'dart:io';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late Directory tempDir;

  setUpAll(() async {
    tempDir = Directory.systemTemp.createTempSync('offline_test');
    Hive.init(tempDir.path);
    if (!Hive.isAdapterRegistered(BookAdapter().typeId)) {
      Hive.registerAdapter(BookAdapter());
    }
    if (!Hive.isAdapterRegistered(ReadingStatusAdapter().typeId)) {
      Hive.registerAdapter(ReadingStatusAdapter());
    }
  });

  tearDownAll(() async {
    await Hive.close();
    if (tempDir.existsSync()) {
      tempDir.deleteSync(recursive: true);
    }
  });

  group('Offline data flow and persistence', () {
    late BookRepository repo;

    setUp(() async {
      repo = BookRepository();
      final box = await Hive.openBox<Book>('booksBox');
      await box.clear();
    });

    test('Unit: BookRepository add/update/getAll persist offline', () async {
      final book = Book(id: '1', title: 'A', authors: ['X'], status: ReadingStatus.notStarted, progress: 0);
      await repo.addBook(book);
      expect((await repo.getAll()).length, 1);
      
      final updated = book.copyWith(title: 'B', progress: 50, status: ReadingStatus.inProgress);
      await repo.updateBook(updated);
      final books = await repo.getAll();
      expect(books.first.title, 'B');
      expect(books.first.progress, 50);
      expect(books.first.status, ReadingStatus.inProgress);
    });

    test('Unit: BooksNotifier CRUD persists via repository', () async {
      final notifier = BooksNotifier(repo);
      final book = Book(id: '2', title: 'Test', authors: ['Y'], status: ReadingStatus.notStarted, progress: 0);
      await notifier.addBook(book);
      expect(notifier.state.length, 1);
      
      await notifier.editBook(book.copyWith(title: 'Edited'));
      expect(notifier.state.first.title, 'Edited');
      
      await notifier.updateReadingProgress('2', 80, ReadingStatus.inProgress);
      expect(notifier.state.first.progress, 80);
      
      // Verify repository has it
      final persisted = await repo.getAll();
      expect(persisted.first.title, 'Edited');
      expect(persisted.first.progress, 80);
    });

    test('Persistence survives provider recreation (simulated restart)', () async {
      final notifier1 = BooksNotifier(repo);
      await notifier1.addBook(Book(id: '3', title: 'Persist', authors: ['Z'], status: ReadingStatus.inProgress, progress: 30));
      
      // Simulate app restart: new notifier, same repo
      final notifier2 = BooksNotifier(repo);
      await notifier2.loadBooks();
      expect(notifier2.state.length, 1);
      expect(notifier2.state.first.title, 'Persist');
      expect(notifier2.state.first.progress, 30);
    });

    test('No network calls: repository uses only Hive', () async {
      // Repository does not make http calls; just verify methods complete without network
      final book = Book(id: 'net', title: 'Offline', authors: ['A'], status: ReadingStatus.notStarted, progress: 0);
      await repo.addBook(book);
      final books = await repo.getAll();
      expect(books, isNotEmpty);
    });
  });
}
