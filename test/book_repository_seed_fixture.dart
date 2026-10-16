import 'package:dandelion/features/library/book.dart';
import 'package:dandelion/features/library/book_database.dart';
import 'package:dandelion/features/library/book_repository.dart';
import 'package:dandelion/features/library/book_repository_impl.dart';
import 'package:drift/native.dart';

/// Reusable test fixture for BookRepository tests.
class BookRepositorySeedFixture {
  final AppDatabase db;
  final BookRepository repository;
  final List<Book> seedBooks;

  BookRepositorySeedFixture._({required this.db, required this.repository, required this.seedBooks});

  static Future<BookRepositorySeedFixture> create() async {
    final db = AppDatabase(NativeDatabase.memory());
    final repository = BookRepositoryImpl(db);

    final seeds = _seedDefinitions();
    for (final def in seeds) {
      await repository.createBook(
        Book(
          id: 0,
          title: def.title,
          authors: def.authors,
          description: def.description,
          genres: def.genres,
          isbn13: def.isbn13 ?? '',
          publisher: def.publisher,
          publicationDate: def.publicationDate,
          pageCount: def.pageCount,
        ),
      );
    }

    final seedBooks = seeds
        .map((d) => Book(
              id: -1,
              title: d.title,
              authors: d.authors,
              description: d.description,
              genres: d.genres,
              isbn13: d.isbn13 ?? '',
              publisher: d.publisher,
              publicationDate: d.publicationDate,
              pageCount: d.pageCount,
            ))
        .toList(growable: false);

    return BookRepositorySeedFixture._(db: db, repository: repository, seedBooks: seedBooks);
  }

  Future<void> dispose() => repository.close();

  static List<_SeedDef> _seedDefinitions() {
    return [
      _SeedDef(title: '1984', authors: 'George Orwell', genres: 'Dystopian, Classic', isbn13: '9780451524935', publisher: 'Signet Classics', publicationDate: DateTime(1949,6,8), pageCount: 328, description: 'Dystopian novel.'),
      _SeedDef(title: "Harry Potter and the Philosopher's Stone", authors: 'J.K. Rowling', genres: 'Fantasy, Young Adult', isbn13: '9780747532699', publisher: 'Bloomsbury', publicationDate: DateTime(1997,6,26), pageCount: 223),
      _SeedDef(title: 'Norwegian Wood', authors: 'Haruki Murakami', genres: 'Literary Fiction, Magical Realism', isbn13: '9780375704024', publisher: 'Vintage', publicationDate: DateTime(1987,9,4), pageCount: 296),
      _SeedDef(title: 'Beloved', authors: 'Toni Morrison', genres: 'Literary Fiction, Historical Fiction', isbn13: '9780679732868', publisher: 'Alfred A. Knopf', publicationDate: DateTime(1987,9,1), pageCount: 324),
      _SeedDef(title: 'Foundation', authors: 'Isaac Asimov', genres: 'Science Fiction, Classic', isbn13: '9780553293357', publisher: 'Spectra', publicationDate: DateTime(1951,1,1), pageCount: 244),
      _SeedDef(title: 'Things Fall Apart', authors: 'Chinua Achebe', genres: 'Postcolonial, Literary Fiction', isbn13: '9780141186389', publisher: 'Penguin Classics', publicationDate: DateTime(1958,1,1), pageCount: 209),
      _SeedDef(title: "The Handmaid's Tale", authors: 'Margaret Atwood', genres: 'Dystopian, Speculative Fiction', isbn13: '9780385490818', publisher: 'McClelland & Stewart', publicationDate: DateTime(1985,9,1), pageCount: 311),
      _SeedDef(title: 'One Hundred Years of Solitude', authors: 'Gabriel García Márquez', genres: 'Magical Realism, Literary Fiction', isbn13: '9780060883287', publisher: 'Harper & Row', publicationDate: DateTime(1967,5,30), pageCount: 417),
      _SeedDef(title: 'American Gods', authors: 'Neil Gaiman', genres: 'Fantasy, Horror', isbn13: '9780060558123', publisher: 'William Morrow', publicationDate: DateTime(2001,6,19), pageCount: 465),
      _SeedDef(title: 'Kindred', authors: 'Octavia Butler', genres: 'Science Fiction, Feminist Fiction', isbn13: '9780807083362', publisher: 'Doubleday', publicationDate: DateTime(1979,1,1), pageCount: 288),
      _SeedDef(title: 'Sapiens: A Brief History of Humankind', authors: 'Yuval Noah Harari', genres: 'Non-fiction, History', isbn13: '9780062316097', publisher: 'Harper', publicationDate: DateTime(2014,2,10), pageCount: 443),
      _SeedDef(title: 'Murder on the Orient Express', authors: 'Agatha Christie', genres: 'Mystery, Crime', isbn13: '9780062693662', publisher: 'William Morrow', publicationDate: DateTime(1934,1,1), pageCount: 307),
    ];
  }
}

class _SeedDef {
  final String title;
  final String authors;
  final String? genres;
  final String? isbn13;
  final String? publisher;
  final DateTime? publicationDate;
  final int? pageCount;
  final String? description;
  _SeedDef({required this.title, required this.authors, this.genres, this.isbn13, this.publisher, this.publicationDate, this.pageCount, this.description});
}
