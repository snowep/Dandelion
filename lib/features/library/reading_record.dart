enum ReadingStatus { WantToRead, Reading, Paused, Finished, DidNotFinish }

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
    int? currentPage,
    double? percentageOnlyProgress,
    DateTime? startDate,
    DateTime? finishDate,
    DateTime? lastReadDate,
    double? personalRating,
    String? notes,
  }) {
    return ReadingRecord(
      id: id ?? this.id,
      bookId: bookId ?? this.bookId,
      status: status ?? this.status,
      currentPage: currentPage ?? this.currentPage,
      percentageOnlyProgress:
          percentageOnlyProgress ?? this.percentageOnlyProgress,
      startDate: startDate ?? this.startDate,
      finishDate: finishDate ?? this.finishDate,
      lastReadDate: lastReadDate ?? this.lastReadDate,
      personalRating: personalRating ?? this.personalRating,
      notes: notes ?? this.notes,
    );
  }
}
