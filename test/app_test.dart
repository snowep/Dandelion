import 'package:flutter_test/flutter_test.dart';
import 'package:dandelion/app/app.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dandelion/features/library/library_notifier.dart';
import 'package:dandelion/features/library/book_repository.dart';
import 'package:dandelion/features/library/book.dart';
import 'package:dandelion/features/library/reading_record.dart';

// Mock repository that returns immediately
class MockBookRepository implements BookRepository {
  @override
  Future<int> createBook(
    Book book, {
    ReadingStatus initialStatus = ReadingStatus.wantToRead,
  }) => Future.value(0);

  @override
  Future<void> updateBook(Book book) => Future.value();

  @override
  Future<Book?> getBookById(int id) => Future.value(null);

  @override
  Future<List<Book>> getAll({int? limit, int? offset}) => Future.value([]);

  @override
  Future<List<Book>> listBooks({
    Map<String, dynamic>? filters,
    String? sortBy,
    bool ascending = true,
    int? limit,
    int? offset,
  }) => Future.value([]);

  @override
  Future<void> archiveBook(int id) => Future.value();

  @override
  Future<void> deleteBook(int id) => Future.value();

  @override
  Future<void> toggleWishlist(int bookId) => Future.value();

  @override
  Future<List<Book>> getBooksByWishlist({bool isInWishlist = true}) =>
      Future.value([]);

  @override
  Future<List<Book>> getBooksFiltered({
    String? search,
    String? status,
    String? genre,
    String? sortBy,
    bool ascending = true,
  }) => Future.value([]);

  @override
  Future<Book?> getBookByIsbn(String isbn) => Future.value(null);

  @override
  Future<Book?> getBookByTitleAndAuthor(String title, String author) =>
      Future.value(null);

  @override
  Future<void> createReadingRecord(ReadingRecord record) => Future.value();

  @override
  Future<void> updateReadingRecord(ReadingRecord record) => Future.value();

  @override
  Future<ReadingRecord?> getReadingRecordForBook(int bookId) =>
      Future.value(null);

  @override
  Future<List<ReadingRecord>> listReadingRecords({int? bookId}) =>
      Future.value([]);

  @override
  Future<void> close() => Future.value();

  @override
  Future<T> transaction<T>(Future<T> Function() action) => action();

  // Additional methods for dashboard and statistics
  @override
  Future<int> getTotalBooksCount() => Future.value(0);
  @override
  Future<int> getWishlistCount() => Future.value(0);
  @override
  Future<Map<String, int>> getReadingStatusCounts() => Future.value({});
  @override
  Future<double> getAverageRating() => Future.value(0.0);
  @override
  Future<int> getTotalPagesRead() => Future.value(0);
  @override
  Future<int> getBooksFinishedThisMonth() => Future.value(0);
  @override
  Future<Map<String, int>> getGenreCounts() => Future.value({});
  @override
  Future<Map<String, int>> getAuthorCounts() => Future.value({});
  @override
  Future<Map<int, int>> getPublishedYearCounts() => Future.value({});
  @override
  Future<int> getBooksReadThisYear() => Future.value(0);
  @override
  Future<int> getBooksPurchasedThisYear() => Future.value(0);
}

void main() {
  testWidgets('App builds successfully', (WidgetTester tester) async {
    final mockRepository = MockBookRepository();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [bookRepositoryProvider.overrideWithValue(mockRepository)],
        child: const DandelionApp(),
      ),
    );

    // Wait for the app to settle
    await tester.pumpAndSettle();

    // Verify the app bar title is visible
    expect(find.text('Dandelion Home'), findsOneWidget);
  });
}
