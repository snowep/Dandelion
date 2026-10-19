import 'package:dandelion/features/discover/recommendation_engine.dart';
import 'package:dandelion/features/library/book.dart';
import 'package:dandelion/features/library/reading_record.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('RecommendationEngine Tests', () {
    final testBooks = [
      Book(
        id: 1,
        title: 'Book 1',
        authors: 'Author A',
        genres: 'Fiction, Mystery',
      ),
      Book(
        id: 2,
        title: 'Book 2',
        authors: 'Author B',
        genres: 'Science, Fiction',
      ),
      Book(id: 3, title: 'Book 3', authors: 'Author C', genres: 'Fantasy'),
      Book(id: 4, title: 'Book 4', authors: 'Author A', genres: 'Fiction'),
      Book(id: 5, title: 'Book 5', authors: 'Author D', genres: 'Non-Fiction'),
    ];

    final testRecords = [
      ReadingRecord(
        bookId: 1,
        status: ReadingStatus.finished,
        personalRating: 5,
      ),
      ReadingRecord(
        bookId: 2,
        status: ReadingStatus.reading,
        personalRating: 4,
      ),
      ReadingRecord(bookId: 3, status: ReadingStatus.wantToRead),
      ReadingRecord(
        bookId: 4,
        status: ReadingStatus.finished,
        personalRating: 3,
      ),
    ];

    test('Empty library/cold start returns zero score with explanation', () {
      final engine = RecommendationEngine([], []);
      final scored = engine.recommend(candidates: testBooks);
      expect(scored.length, equals(testBooks.length));
      for (final candidate in scored) {
        expect(candidate.score, equals(0.0));
        expect(
          candidate.explanations,
          equals(['No reading history to base recommendations on']),
        );
      }
    });

    test('Candidate with no genre/author gets novelty score only', () {
      final engine = RecommendationEngine(testBooks, testRecords);
      final emptyBook = Book(
        id: 6,
        title: 'Empty Book',
        authors: '',
        genres: '',
      );
      final scored = engine.recommend(candidates: [emptyBook]);
      expect(scored.length, equals(1));
      expect(scored[0].score, greaterThan(0.0));
      expect(scored[0].explanations, equals(['New to your library']));
    });

    test('Exact author match gets author similarity', () {
      final engine = RecommendationEngine(testBooks, testRecords);
      final authorABook = Book(
        id: 7,
        title: 'Author A Book',
        authors: 'Author A',
        genres: '',
      );
      final scored = engine.recommend(candidates: [authorABook]);
      expect(scored.length, equals(1));
      expect(scored[0].score, greaterThan(0.0));
      expect(scored[0].explanations, contains('By an author you like'));
    });

    test('Genre overlap gets genre similarity', () {
      final engine = RecommendationEngine(testBooks, testRecords);
      final fictionBook = Book(
        id: 8,
        title: 'Fiction Book',
        authors: '',
        genres: 'Fiction, Thriller',
      );
      final scored = engine.recommend(candidates: [fictionBook]);
      expect(scored.length, equals(1));
      expect(scored[0].score, greaterThan(0.0));
      expect(
        scored[0].explanations,
        contains('Shares genres with books you rated highly'),
      );
    });

    test('Finished candidate is excluded', () {
      final engine = RecommendationEngine(testBooks, testRecords);
      final scored = engine.recommend(candidates: testBooks);
      expect(scored.any((c) => c.book.id == 1), isFalse);
      expect(scored.any((c) => c.book.id == 4), isFalse);
    });

    test('Stable tie ordering by title then ID', () {
      final engine = RecommendationEngine(testBooks, testRecords);
      final tieBooks = [
        Book(id: 9, title: 'Same Title', authors: '', genres: ''),
        Book(id: 10, title: 'Same Title', authors: '', genres: ''),
      ];
      final scored = engine.recommend(candidates: tieBooks);
      expect(scored.length, equals(2));
      expect(scored[0].book.id, equals(9));
      expect(scored[1].book.id, equals(10));
    });

    test('Malformed metadata is handled gracefully', () {
      final engine = RecommendationEngine(testBooks, testRecords);
      final malformedBook = Book(
        id: 11,
        title: 'Malformed Book',
        authors: '',
        genres: 'Genre1, Genre2, , , Genre3',
      );
      final scored = engine.recommend(candidates: [malformedBook]);
      expect(scored.length, equals(1));
      expect(scored[0].score, greaterThanOrEqualTo(0.0));
      expect(scored[0].score, lessThanOrEqualTo(1.0));
    });

    test('All scores are between 0 and 1', () {
      final engine = RecommendationEngine(testBooks, testRecords);
      final scored = engine.recommend(candidates: testBooks);
      for (final candidate in scored) {
        expect(candidate.score, greaterThanOrEqualTo(0.0));
        expect(candidate.score, lessThanOrEqualTo(1.0));
      }
    });

    test('Excluded book IDs are respected', () {
      final engine = RecommendationEngine(testBooks, testRecords);
      final scored = engine.recommend(
        candidates: testBooks,
        excludeBookIds: {1, 2},
      );
      expect(scored.any((c) => c.book.id == 1), isFalse);
      expect(scored.any((c) => c.book.id == 2), isFalse);
    });
  });
}
