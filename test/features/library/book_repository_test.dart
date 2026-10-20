import 'package:flutter_test/flutter_test.dart';
import 'package:drift/native.dart';
import 'package:dandelion/features/library/book.dart';
import 'package:dandelion/features/library/book_database.dart';
import 'package:dandelion/features/library/book_repository_impl.dart';

/// Helper that builds an isolated in-memory repository.
Future<BookRepositoryImpl> buildRepo() async {
  final db = AppDatabase(NativeDatabase.memory());
  return BookRepositoryImpl(db);
}

Future<void> closeRepo(BookRepositoryImpl repo) async {
  await repo.close();
}

void main() {
  group('authors persistence', () {
    test('create/read preserves multiple authors', () async {
      final repo = await buildRepo();
      try {
        final id = await repo.createBook(
          Book(
            id: 0,
            title: 'The Collected Works',
            authors: 'Jane Austen, Charles Dickens, Mark Twain',
            isbn13: '9780000000002',
          ),
        );
        expect(id, greaterThan(0));

        final read = await repo.getBookById(id);
        expect(read, isNotNull);
        expect(read!.authors, 'Jane Austen, Charles Dickens, Mark Twain');

        // A second read proves the row round-trips through Drift unchanged.
        final readAgain = await repo.getBookById(id);
        expect(readAgain!.authors, 'Jane Austen, Charles Dickens, Mark Twain');
      } finally {
        await closeRepo(repo);
      }
    });

    test('create/read preserves single author', () async {
      final repo = await buildRepo();
      try {
        final id = await repo.createBook(
          Book(
            id: 0,
            title: 'Solo Author Book',
            authors: 'Isaac Asimov',
            isbn13: '9780000000019',
          ),
        );
        final read = await repo.getBookById(id);
        expect(read!.authors, 'Isaac Asimov');
      } finally {
        await closeRepo(repo);
      }
    });

    test('update preserves authors and allows clearing', () async {
      final repo = await buildRepo();
      try {
        final id = await repo.createBook(
          Book(
            id: 0,
            title: 'Original',
            authors: 'Author A',
            isbn13: '9780000000026',
          ),
        );

        await repo.updateBook(
          (await repo.getBookById(id))!.copyWith(authors: 'Author A, Author B'),
        );

        final updated = await repo.getBookById(id);
        expect(updated!.authors, 'Author A, Author B');

        await repo.updateBook(updated.copyWith(authors: ''));
        final cleared = await repo.getBookById(id);
        expect(cleared!.authors, '');
      } finally {
        await closeRepo(repo);
      }
    });

    test('authors survive archive and reopen', () async {
      final repo = await buildRepo();
      try {
        final id = await repo.createBook(
          Book(
            id: 0,
            title: 'Archive Test',
            authors: 'Author One, Author Two',
            isbn13: '9780000000033',
          ),
        );
        await repo.archiveBook(id);

        // Archived books are still findable by ID
        final archived = await repo.getBookById(id);
        expect(archived, isNotNull);
        expect(archived!.authors, 'Author One, Author Two');
        expect(archived.archivedAt, isNotNull);
      } finally {
        await closeRepo(repo);
      }
    });
  });
}
