import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:dandelion/features/dashboard/dashboard_models.dart';
import 'package:dandelion/features/dashboard/dashboard_service.dart';
import 'package:dandelion/features/library/book.dart';
import 'package:dandelion/features/library/library_notifier.dart';
import 'package:dandelion/features/library/reading_record.dart';

/// Single [DashboardService] instance shared by all dashboard providers.
final dashboardServiceProvider = Provider<DashboardService>((ref) {
  return DashboardService(ref.read(bookRepositoryProvider));
});

/// Full dashboard metrics snapshot. Re-computed whenever the library state
/// changes (any [LibraryState] update triggers a refresh).
final dashboardMetricsProvider =
    FutureProvider<DashboardMetrics>((ref) {
  ref.watch(libraryNotifierProvider);
  return ref.read(dashboardServiceProvider).getMetrics();
});

/// Total number of active (non-archived) books in the library.
final totalBooksProvider = FutureProvider<int>((ref) async {
  final metrics = await ref.watch(dashboardMetricsProvider.future);
  return metrics.totalBooks;
});

/// Number of books currently flagged as wishlist.
final wishlistCountProvider = FutureProvider<int>((ref) async {
  final metrics = await ref.watch(dashboardMetricsProvider.future);
  return metrics.wishlistCount;
});

/// Count of reading records per status name.
final readingStatusCountsProvider =
    FutureProvider<Map<String, int>>((ref) async {
  final metrics = await ref.watch(dashboardMetricsProvider.future);
  return metrics.readingStatusCounts;
});

/// Mean personal rating across rated books (0.0 when nothing is rated).
final averageRatingProvider = FutureProvider<double>((ref) async {
  final metrics = await ref.watch(dashboardMetricsProvider.future);
  return metrics.averageRating;
});

/// Sum of current pages across books in `reading` or `finished` status.
final totalPagesReadProvider = FutureProvider<int>((ref) async {
  final metrics = await ref.watch(dashboardMetricsProvider.future);
  return metrics.totalPagesRead;
});

/// Books finished (finish date set) within the current calendar month.
final booksFinishedThisMonthProvider =
    FutureProvider<int>((ref) async {
  final metrics = await ref.watch(dashboardMetricsProvider.future);
  return metrics.booksFinishedThisMonth;
});

/// Top genres by active book count, descending. Parameterized by the number
/// of genres to surface.
final topGenresProvider = FutureProvider
    .family<List<MapEntry<String, int>>, int>((ref, limit) async {
  final metrics = await ref.watch(dashboardMetricsProvider.future);
  final entries = metrics.genreCounts.entries.toList(growable: false)
    ..sort((a, b) => b.value.compareTo(a.value));
  return entries.take(limit).toList(growable: false);
});

/// Books currently being read, newest activity first — a lightweight
/// "continue reading" insight list for the dashboard.
final currentlyReadingBooksProvider =
    FutureProvider<List<Book>>((ref) async {
  final metrics = await ref.watch(dashboardMetricsProvider.future);
  if (metrics.currentlyReading == 0) return const [];
  final repository = ref.read(bookRepositoryProvider);
  final records = await repository.listReadingRecords();
  final readingRecords = records
      .where((r) => r.status == ReadingStatus.reading)
      .toList(growable: false)
    ..sort((a, b) => b.lastReadDate.compareTo(a.lastReadDate));
  if (readingRecords.isEmpty) return const [];
  final books = await repository.getAll();
  final byId = {for (final b in books) b.id: b};
  return readingRecords
      .map((r) => byId[r.bookId])
      .whereType<Book>()
      .toList(growable: false);
});
