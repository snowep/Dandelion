const Object _sentinel = Object();

enum ReadingStatus { wantToRead, reading, paused, finished, didNotFinish }

class ReadingRecord {
  final int? id;
  final int bookId;
  final ReadingStatus status;
  final int? currentPage;
  final double? percentageOnlyProgress; // 0.0 to 1.0
  final DateTime? startDate;
  final DateTime? finishDate;
  final DateTime lastReadDate;
  final double? personalRating; // 0.0 to 5.0
  final String? notes;

  ReadingRecord({
    this.id,
    required this.bookId,
    required this.status,
    this.currentPage,
    this.percentageOnlyProgress,
    this.startDate,
    this.finishDate,
    DateTime? lastReadDate,
    this.personalRating,
    this.notes,
  }) : lastReadDate = lastReadDate ?? DateTime.now();

  ReadingRecord copyWith({
    int? id,
    int? bookId,
    ReadingStatus? status,
    Object? currentPage = _sentinel,
    Object? percentageOnlyProgress = _sentinel,
    Object? startDate = _sentinel,
    Object? finishDate = _sentinel,
    DateTime? lastReadDate,
    Object? personalRating = _sentinel,
    Object? notes = _sentinel,
  }) {
    return ReadingRecord(
      id: id ?? this.id,
      bookId: bookId ?? this.bookId,
      status: status ?? this.status,
      currentPage: identical(currentPage, _sentinel)
          ? this.currentPage
          : currentPage as int?,
      percentageOnlyProgress: identical(percentageOnlyProgress, _sentinel)
          ? this.percentageOnlyProgress
          : percentageOnlyProgress as double?,
      startDate: identical(startDate, _sentinel)
          ? this.startDate
          : startDate as DateTime?,
      finishDate: identical(finishDate, _sentinel)
          ? this.finishDate
          : finishDate as DateTime?,
      lastReadDate: lastReadDate ?? this.lastReadDate,
      personalRating: identical(personalRating, _sentinel)
          ? this.personalRating
          : personalRating as double?,
      notes: identical(notes, _sentinel) ? this.notes : notes as String?,
    );
  }
}
