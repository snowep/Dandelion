// The extra repository methods below (stats, ISBN) exist only in the
// in-flight interface expansion, so they are declared without @override to
// stay valid against the committed interface as well.
// ignore_for_file: annotate_overrides
import 'package:dandelion/features/dashboard/dashboard_models.dart';
import 'package:dandelion/features/dashboard/dashboard_service.dart';
import 'package:dandelion/features/insights/dashboard_providers.dart';
import 'package:dandelion/features/library/book.dart';
import 'package:dandelion/features/library/book_repository.dart';
import 'package:dandelion/features/library/library_notifier.dart';
import 'package:dandelion/features/library/reading_record.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

/// In-memory [BookRepository] fake so tests do not need a real database.
class FakeBookRepository implements BookRepository {
  FakeBookRepository(this.books, this.records);

  List<Book> books;
  List<ReadingRecord> records;
  int getAllCalls = 0;

  @override
  Future<List<Book>> getAll() async {
    getAllCalls++;
    return books;
  }

  @override
  Future<List<ReadingRecord>> listReadingRecords({int? bookId}) async {
    if (bookId == null) return records;
    return records.where((r) => r.bookId == bookId).toList();
  }

  // Everything below is intentionally unsupported in this fake.

  @override
  Future<int> createBook(Book book,
          {ReadingStatus initialStatus = ReadingStatus.wantToRead}) =>
      throw UnimplementedError();

  @override
  Future<void> updateBook(Book book) => throw UnimplementedError();

  @override
  Future<Book?> getBookById(int id) => throw UnimplementedError();

  @override
  Future<List<Book>> listBooks({
    Map<String, dynamic>? filters,
    String? sortBy,
    bool ascending = true,
  }) async =>
      books;

  Future<List<Book>> getBooksFiltered({
    String? search,
    String? status,
    String? genre,
    String? sortBy,
    bool ascending = true,
  }) =>
      throw UnimplementedError();

  @override
  Future<void> archiveBook(int id) => throw UnimplementedError();

  @override
  Future<void> deleteBook(int id) => throw UnimplementedError();

  @override
  Future<void> toggleWishlist(int bookId) => throw UnimplementedError();

  @override
  Future<List<Book>> getBooksByWishlist({bool isInWishlist = true}) async =>
      books.where((b) => b.isInWishlist == isInWishlist).toList();

  // The methods below exist in the expanded (in-flight) repository interface
  // that the frontend consumes. They are declared without @override so this
  // fake also compiles against the smaller committed interface.

  Future<Book?> getBookByIsbn(String isbn) async {
    for (final b in books) {
      if (b.isbn13 == isbn || b.isbn10 == isbn) return b;
    }
    return null;
  }

  Future<int> getTotalBooksCount() async =>
      books.where((b) => b.archivedAt == null).length;

  Future<int> getWishlistCount() async =>
      books.where((b) => b.isInWishlist && b.archivedAt == null).length;

  Future<Map<String, int>> getReadingStatusCounts() async {
    final counts = <String, int>{};
    for (final r in records) {
      counts[r.status.name] = (counts[r.status.name] ?? 0) + 1;
    }
    return counts;
  }

  Future<double> getAverageRating() async {
    final rated = records.where((r) => r.personalRating != null).toList();
    if (rated.isEmpty) return 0.0;
    return rated.fold<double>(0.0, (s, r) => s + r.personalRating!) /
        rated.length;
  }

  Future<int> getTotalPagesRead() async => records
      .where((r) =>
          r.status == ReadingStatus.reading ||
          r.status == ReadingStatus.finished)
      .fold<int>(0, (s, r) => s + (r.currentPage ?? 0));

  Future<int> getBooksFinishedThisMonth() async {
    final now = DateTime.now();
    final monthStart = DateTime(now.year, now.month, 1);
    return records
        .where((r) =>
            r.status == ReadingStatus.finished &&
            r.finishDate != null &&
            !r.finishDate!.isBefore(monthStart))
        .length;
  }

  @override
  Future<void> createReadingRecord(ReadingRecord record) =>
      throw UnimplementedError();

  @override
  Future<void> updateReadingRecord(ReadingRecord record) =>
      throw UnimplementedError();

  @override
  Future<ReadingRecord?> getReadingRecordForBook(int bookId) =>
      throw UnimplementedError();

  @override
  Future<void> close() async {}
}

Book _book(
  int id, {
  String genres = '',
  bool wishlist = false,
  bool archived = false,
}) =>
    Book(
      id: id,
      title: 'Book $id',
      authors: 'Author $id',
      genres: genres.isEmpty ? null : genres,
      isInWishlist: wishlist,
      archivedAt: archived ? DateTime(2026, 1, 1) : null,
    );

ReadingRecord _record(
  int bookId,
  ReadingStatus status, {
  int? currentPage,
  double? rating,
  DateTime? finishDate,
  DateTime? lastReadDate,
}) =>
    ReadingRecord(
      bookId: bookId,
      status: status,
      currentPage: currentPage,
      personalRating: rating,
      finishDate: finishDate,
      lastReadDate: lastReadDate,
    );

void main() {
  final now = DateTime(2026, 10, 17, 12, 0);

  List<Book> sampleBooks() => [
        _book(1, genres: 'Fiction,  Classics'),
        _book(2, genres: 'fiction', wishlist: true),
        _book(3, genres: 'Science Fiction'),
        _book(4, archived: true), // archived: must be excluded everywhere
        _book(5, wishlist: true),
      ];

  List<ReadingRecord> sampleRecords() => [
        _record(1, ReadingStatus.wantToRead),
        _record(2, ReadingStatus.reading, currentPage: 120, rating: 4.0),
        _record(3, ReadingStatus.finished,
            currentPage: 300, rating: 5.0, finishDate: DateTime(2026, 10, 5)),
        // Finished last month: must NOT count towards this month.
        _record(5, ReadingStatus.finished,
            currentPage: 250, finishDate: DateTime(2026, 9, 20)),
        // Paused book with progress: counts towards pages read.
        _record(4, ReadingStatus.paused, currentPage: 80),
        // Rated but not finished: counts towards average rating only.
        _record(6, ReadingStatus.didNotFinish, rating: 2.0),
      ];

  DashboardService serviceFor(FakeBookRepository repository) {
    final svc = DashboardService(repository);
    return svc;
  }

  group('DashboardService metric computation', () {
    test('empty library yields empty metrics', () {
      final service = serviceFor(FakeBookRepository([], []));
      final metrics = service.computeFrom([], [], now: now);
      expect(metrics, DashboardMetrics.empty);
    });

    test('counts only active books and wishlist flags', () {
      final repository = FakeBookRepository(sampleBooks(), []);
      final metrics = serviceFor(repository).computeFrom(
        repository.books,
        repository.records,
        now: now,
      );
      expect(metrics.totalBooks, 4, reason: 'archived book is excluded');
      expect(metrics.wishlistCount, 2);
    });

    test('derives status counts, average rating and pages read', () {
      final repository = FakeBookRepository(sampleBooks(), sampleRecords());
      final metrics = serviceFor(repository).computeFrom(
        repository.books,
        repository.records,
        now: now,
      );
      expect(metrics.readingStatusCounts, {
        'wantToRead': 1,
        'reading': 1,
        'finished': 2,
        'paused': 1,
        'didNotFinish': 1,
      });
      expect(metrics.currentlyReading, 1);
      // (4.0 + 5.0 + 2.0) / 3
      expect(metrics.averageRating, closeTo(11 / 3, 0.0001));
      // reading(120) + finished(300) + finished(250); paused/didNotFinish excluded
      expect(metrics.totalPagesRead, 670);
    });

    test('finished this month counts only current-month finishes', () {
      final repository = FakeBookRepository(sampleBooks(), sampleRecords());
      final metrics = serviceFor(repository).computeFrom(
        repository.books,
        repository.records,
        now: now,
      );
      expect(metrics.booksFinishedThisMonth, 1);

      // A finish dated exactly on the month boundary counts.
      final boundary = [
        _record(3, ReadingStatus.finished, finishDate: DateTime(2026, 10, 1)),
      ];
      final boundaryMetrics = serviceFor(repository)
          .computeFrom(repository.books, boundary, now: now);
      expect(boundaryMetrics.booksFinishedThisMonth, 1);

      // A finish dated on the last day of the month counts too.
      final late = [
        _record(3, ReadingStatus.finished, finishDate: DateTime(2026, 10, 31)),
      ];
      final lateMetrics = serviceFor(repository)
          .computeFrom(repository.books, late, now: now);
      expect(lateMetrics.booksFinishedThisMonth, 1);
    });

    test('finished without finish date does not count for the month', () {
      final repository = FakeBookRepository(sampleBooks(), [
        _record(3, ReadingStatus.finished), // no finishDate
      ]);
      final metrics = serviceFor(repository).computeFrom(
        repository.books,
        repository.records,
        now: now,
      );
      expect(metrics.booksFinishedThisMonth, 0);
    });

    test('genre counts are normalized: split, trimmed, lowercased', () {
      final repository = FakeBookRepository(sampleBooks(), []);
      final metrics = serviceFor(repository).computeFrom(
        repository.books,
        repository.records,
        now: now,
      );
      expect(metrics.genreCounts, {
        'fiction': 2, // 'Fiction,  Classics' + 'fiction'
        'classics': 1,
        'science fiction': 1,
      });
    });
  });

  group('dashboard providers', () {
    late FakeBookRepository repository;
    late ProviderContainer container;

    setUp(() async {
      repository = FakeBookRepository(sampleBooks(), sampleRecords());
      container = ProviderContainer(
        overrides: [bookRepositoryProvider.overrideWithValue(repository)],
      );
      addTearDown(container.dispose);

      // Initialize the library notifier and let its initial async load settle,
      // so dashboard providers are not invalidated mid-build when they start
      // watching it.
      container.read(libraryNotifierProvider);
      for (var i = 0; i < 50; i++) {
        if (!container.read(libraryNotifierProvider).loading) break;
        await Future<void>.delayed(Duration.zero);
      }
    });

    /// Reads [dashboardMetricsProvider], pumping the event loop until the
    /// value is available (and optionally matches [until]). Polling avoids
    /// awaiting a `.future` across a Riverpod invalidation, which can orphan
    /// the awaited future.
    Future<DashboardMetrics> readMetrics(
      ProviderContainer container, {
      bool Function(DashboardMetrics)? until,
    }) async {
      for (var i = 0; i < 100; i++) {
        final asyncValue = container.read(dashboardMetricsProvider);
        if (asyncValue.hasValue) {
          final metrics = asyncValue.value as DashboardMetrics;
          if (until == null || until(metrics)) return metrics;
        }
        await Future<void>.delayed(Duration.zero);
      }
      throw StateError('dashboardMetricsProvider never settled');
    }

    test('dashboardMetricsProvider aggregates every metric', () async {
      final metrics = await readMetrics(container);
      expect(metrics.totalBooks, 4);
      expect(metrics.wishlistCount, 2);
      expect(metrics.currentlyReading, 1);
      expect(metrics.averageRating, closeTo(11 / 3, 0.0001));
      expect(metrics.totalPagesRead, 670);
      expect(metrics.booksFinishedThisMonth, 1);
      expect(metrics.genreCounts['fiction'], 2);
    });

    test('individual providers project their metric', () async {
      expect(await container.read(totalBooksProvider.future), 4);
      expect(await container.read(wishlistCountProvider.future), 2);
      expect(
        await container.read(readingStatusCountsProvider.future),
        {
          'wantToRead': 1,
          'reading': 1,
          'finished': 2,
          'paused': 1,
          'didNotFinish': 1,
        },
      );
      expect(await container.read(averageRatingProvider.future),
          closeTo(11 / 3, 0.0001));
      expect(await container.read(totalPagesReadProvider.future), 670);
      expect(await container.read(booksFinishedThisMonthProvider.future), 1);
    });

    test('topGenresProvider returns genres sorted by count', () async {
      final top2 = await container.read(topGenresProvider(2).future);
      expect(top2.first.key, 'fiction');
      expect(top2.first.value, 2);
      expect(top2, hasLength(2));
      expect(top2[1].value, 1);
    });

    test('currentlyReadingBooksProvider returns the reading book', () async {
      final reading = await container.read(currentlyReadingBooksProvider.future);
      expect(reading, hasLength(1));
      expect(reading.first.id, 2);
    });

    test('providers refresh when the library state changes', () async {
      final before = await readMetrics(container);
      expect(before.totalBooks, 4);

      // Simulate a library mutation: the notifier reloads from the repository.
      repository.books = [
        ...repository.books,
        _book(99, genres: 'Poetry'),
      ];
      await container
          .read(libraryNotifierProvider.notifier)
          .loadBooks();

      final after = await readMetrics(container,
          until: (metrics) => metrics.totalBooks == 5);
      expect(after.totalBooks, 5);
      expect(after.genreCounts['poetry'], 1);
    });
  });
}
