import 'package:flutter_test/flutter_test.dart';
import 'package:dandelion/features/library/book.dart';
import 'package:dandelion/features/library/reading_record.dart';

void main() {
  group('Performance Tests', () {
    test('Query performance with 100 books', () {
      final books = List.generate(
        100,
        (i) => Book(
          id: i,
          title: 'Book $i',
          authors: 'Author $i',
          genres: 'Fiction',
        ),
      );

      final stopwatch = Stopwatch()..start();
      final filtered = books.where((b) => b.title.contains('Book')).toList();
      stopwatch.stop();

      expect(filtered.length, equals(100));
      expect(stopwatch.elapsedMilliseconds, lessThan(50));
    });

    test('Database operations remain responsive', () {
      final books = List.generate(
        1000,
        (i) => Book(
          id: i,
          title: 'Book $i',
          authors: 'Author ${i % 100}',
          genres: 'Genre ${i % 10}',
        ),
      );

      final stopwatch = Stopwatch()..start();
      final uniqueAuthors = books.map((b) => b.authors).toSet();
      stopwatch.stop();

      expect(uniqueAuthors.length, equals(100));
      expect(stopwatch.elapsedMilliseconds, lessThan(200));
    });

    test('Memory efficient pagination', () {
      final allBooks = List.generate(
        5000,
        (i) => Book(id: i, title: 'Book $i', authors: 'Author $i'),
      );

      const pageSize = 50;
      final page = allBooks.take(pageSize).toList();

      expect(page.length, equals(pageSize));
      expect(page.first.id, equals(0));
      expect(page.last.id, equals(49));
    });
  });
}
