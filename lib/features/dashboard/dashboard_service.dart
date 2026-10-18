import 'package:flutter/foundation.dart';

import 'package:dandelion/features/dashboard/dashboard_models.dart';
import 'package:dandelion/features/library/book.dart';
import 'package:dandelion/features/library/book_repository.dart';
import 'package:dandelion/features/library/reading_record.dart';

/// Computes dashboard metrics and insights from the local library data.
///
/// The service reads the whole active library once per refresh and derives
/// every metric from the books and reading records in memory. This keeps the
/// queries simple and works identically on native and web targets.
class DashboardService {
  DashboardService(this._repository);

  final BookRepository _repository;

  /// Builds the full [DashboardMetrics] snapshot for the dashboard UI.
  Future<DashboardMetrics> getMetrics() async {
    final books = await _repository.getAll();
    final records = await _repository.listReadingRecords();
    return _compute(books, records, now: DateTime.now());
  }

  /// Computes metrics from already-loaded data. Visible for testing so the
  /// derivation logic can be exercised without a database.
  @visibleForTesting
  DashboardMetrics computeFrom(
    List<Book> books,
    List<ReadingRecord> records, {
    DateTime? now,
  }) {
    return _compute(books, records, now: now ?? DateTime.now());
  }

  DashboardMetrics _compute(
    List<Book> books,
    List<ReadingRecord> records, {
    required DateTime now,
  }) {
    final activeBooks = books.where((b) => b.archivedAt == null).toList();
    final wishlistCount = activeBooks.where((b) => b.isInWishlist).length;

    final statusCounts = <String, int>{};
    for (final record in records) {
      final key = record.status.name;
      statusCounts[key] = (statusCounts[key] ?? 0) + 1;
    }

    final ratedRecords = records
        .where((r) => r.personalRating != null)
        .toList(growable: false);
    final averageRating = ratedRecords.isEmpty
        ? 0.0
        : ratedRecords.fold<double>(
                0.0,
                (sum, r) => sum + (r.personalRating ?? 0.0),
              ) /
              ratedRecords.length;

    final totalPagesRead = records
        .where(
          (r) =>
              r.status == ReadingStatus.reading ||
              r.status == ReadingStatus.finished,
        )
        .fold<int>(0, (sum, r) => sum + (r.currentPage ?? 0));

    final monthStart = DateTime(now.year, now.month, 1);
    final nextMonthStart = DateTime(now.year, now.month + 1, 1);
    final booksFinishedThisMonth = records
        .where(
          (r) =>
              r.status == ReadingStatus.finished &&
              r.finishDate != null &&
              !r.finishDate!.isBefore(monthStart) &&
              r.finishDate!.isBefore(nextMonthStart),
        )
        .length;

    final genreCounts = <String, int>{};
    for (final book in activeBooks) {
      final genres = (book.genres ?? '')
          .split(',')
          .map((g) => g.trim().toLowerCase())
          .where((g) => g.isNotEmpty);
      for (final genre in genres) {
        genreCounts[genre] = (genreCounts[genre] ?? 0) + 1;
      }
    }

    return DashboardMetrics(
      totalBooks: activeBooks.length,
      wishlistCount: wishlistCount,
      currentlyReading: statusCounts['reading'] ?? 0,
      readingStatusCounts: statusCounts,
      averageRating: averageRating,
      totalPagesRead: totalPagesRead,
      booksFinishedThisMonth: booksFinishedThisMonth,
      genreCounts: genreCounts,
    );
  }
}
