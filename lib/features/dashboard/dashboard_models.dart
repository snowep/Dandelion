import 'package:flutter/foundation.dart';

/// Aggregated dashboard metrics for the Dandelion library.
///
/// Computed by [DashboardService] from active books and reading records.
/// All counts reflect the current state of the local database.
@immutable
class DashboardMetrics {
  /// Total number of active (non-archived) books in the library.
  final int totalBooks;

  /// Number of active books currently flagged as wishlist.
  final int wishlistCount;

  /// Number of books with reading status `reading`.
  final int currentlyReading;

  /// Count of reading records per status name
  /// (wantToRead, reading, paused, finished, didNotFinish).
  final Map<String, int> readingStatusCounts;

  /// Mean personal rating across all rated books (0.0 when nothing rated).
  final double averageRating;

  /// Sum of current pages of books in `reading` or `finished` status.
  final int totalPagesRead;

  /// Books whose reading status is `finished` with a finish date in the
  /// current calendar month.
  final int booksFinishedThisMonth;

  /// Genre name (lowercase) to number of active books tagged with it.
  final Map<String, int> genreCounts;

  const DashboardMetrics({
    required this.totalBooks,
    required this.wishlistCount,
    required this.currentlyReading,
    required this.readingStatusCounts,
    required this.averageRating,
    required this.totalPagesRead,
    required this.booksFinishedThisMonth,
    required this.genreCounts,
  });

  /// Metrics for a library that has no data yet.
  static const empty = DashboardMetrics(
    totalBooks: 0,
    wishlistCount: 0,
    currentlyReading: 0,
    readingStatusCounts: {},
    averageRating: 0.0,
    totalPagesRead: 0,
    booksFinishedThisMonth: 0,
    genreCounts: {},
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DashboardMetrics &&
          other.totalBooks == totalBooks &&
          other.wishlistCount == wishlistCount &&
          other.currentlyReading == currentlyReading &&
          mapEquals(other.readingStatusCounts, readingStatusCounts) &&
          other.averageRating == averageRating &&
          other.totalPagesRead == totalPagesRead &&
          other.booksFinishedThisMonth == booksFinishedThisMonth &&
          mapEquals(other.genreCounts, genreCounts);

  @override
  int get hashCode => Object.hash(
    totalBooks,
    wishlistCount,
    currentlyReading,
    averageRating,
    totalPagesRead,
    booksFinishedThisMonth,
    Object.hashAll([...readingStatusCounts.keys, ...genreCounts.keys]),
  );

  @override
  String toString() =>
      'DashboardMetrics(totalBooks: $totalBooks, wishlistCount: '
      '$wishlistCount, currentlyReading: $currentlyReading, '
      'readingStatusCounts: $readingStatusCounts, averageRating: '
      '$averageRating, totalPagesRead: $totalPagesRead, '
      'booksFinishedThisMonth: $booksFinishedThisMonth, '
      'genreCounts: $genreCounts)';
}
