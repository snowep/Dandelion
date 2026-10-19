import 'package:dandelion/features/library/book.dart';
import 'package:dandelion/features/library/reading_record.dart';

/// A recommendation engine for the Discover screen.
///
/// Computes a score for a book candidate based on the user's library
/// using only signals that can be computed from local data.
/// Weights are normalized over available signals only.
class RecommendationEngine {
  RecommendationEngine(this._libraryBooks, this._readingRecords);

  final List<Book> _libraryBooks;
  final List<ReadingRecord> _readingRecords;

  /// Computes recommendations for all candidates in one pass.
  /// Returns scored candidates sorted by score descending, then by title for stable ordering.
  List<ScoredCandidate> recommend({
    required List<Book> candidates,
    Set<int>? excludeBookIds,
  }) {
    final profile = _buildUserProfile();
    final bookIdToRecord = <int, ReadingRecord>{};
    for (final record in _readingRecords) {
      bookIdToRecord[record.bookId] = record;
    }

    final scored = <ScoredCandidate>[];
    for (final candidate in candidates) {
      // Skip books already in library/wishlist
      if (excludeBookIds != null && excludeBookIds.contains(candidate.id)) {
        continue;
      }
      // Skip if already finished in library
      final record = bookIdToRecord[candidate.id];
      if (record != null && record.status == ReadingStatus.finished) {
        continue;
      }

      final result = _scoreCandidate(candidate, profile, record);
      scored.add(
        ScoredCandidate(
          book: candidate,
          score: result.score,
          explanations: result.explanations,
        ),
      );
    }

    // Stable sort: score descending, then title ascending, then id ascending
    scored.sort((a, b) {
      final scoreCmp = b.score.compareTo(a.score);
      if (scoreCmp != 0) return scoreCmp;
      final titleCmp = a.book.title.toLowerCase().compareTo(
        b.book.title.toLowerCase(),
      );
      if (titleCmp != 0) return titleCmp;
      return a.book.id.compareTo(b.book.id);
    });

    return scored;
  }

  /// Builds a user preference profile from reading records.
  /// Called once per recommendation request.
  UserProfile _buildUserProfile() {
    final preferredGenres = <String>{};
    final preferredAuthors = <String>{};

    for (final record in _readingRecords) {
      // Only consider finished or rated >= 3 as positive signals
      final isPositive =
          record.status == ReadingStatus.finished ||
          (record.personalRating ?? 0) >= 3;
      if (!isPositive) continue;

      final book = _libraryBooks.firstWhere(
        (b) => b.id == record.bookId,
        orElse: () => Book(id: 0, title: '', authors: ''),
      );

      if (book.genres != null && book.genres!.isNotEmpty) {
        for (final genre in book.genres!.split(',')) {
          final g = genre.trim().toLowerCase();
          if (g.isNotEmpty) {
            preferredGenres.add(g);
          }
        }
      }
      if (book.authors.isNotEmpty) {
        final author = book.authors.toLowerCase();
        if (author.isNotEmpty) {
          preferredAuthors.add(author);
        }
      }
    }

    return UserProfile(
      preferredGenres: preferredGenres,
      preferredAuthors: preferredAuthors,
    );
  }

  /// Scores a single candidate against the user profile.
  /// Returns score in [0, 1] and explanations that match actual positive signals.
  ScoreResult _scoreCandidate(
    Book candidate,
    UserProfile profile,
    ReadingRecord? existingRecord,
  ) {
    double genreSimilarity = 0.0;
    bool hasGenreSignal = false;
    bool hasAuthorSignal = false;

    // Genre similarity: Jaccard index between candidate genres and preferred genres
    if (candidate.genres != null &&
        candidate.genres!.isNotEmpty &&
        profile.preferredGenres.isNotEmpty) {
      hasGenreSignal = true;
      final candidateGenres = <String>{};
      for (final g in candidate.genres!.split(',')) {
        final trimmed = g.trim();
        if (trimmed.isNotEmpty) {
          candidateGenres.add(trimmed.toLowerCase());
        }
      }
      if (candidateGenres.isNotEmpty) {
        final intersection = candidateGenres
            .intersection(profile.preferredGenres)
            .length;
        final union = candidateGenres.union(profile.preferredGenres).length;
        genreSimilarity = union > 0 ? intersection / union : 0.0;
      }
    }

    // Author similarity: 1 if any author matches preferred authors, else 0
    double authorSimilarity = 0.0;
    if (candidate.authors.isNotEmpty && profile.preferredAuthors.isNotEmpty) {
      hasAuthorSignal = true;
      final candidateAuthors = <String>{};
      for (final a in candidate.authors.split(',')) {
        candidateAuthors.add(a.trim().toLowerCase());
      }
      if (candidateAuthors.any((a) => profile.preferredAuthors.contains(a))) {
        authorSimilarity = 1.0;
      }
    }

    // Novelty: 1 if not already finished, 0 if finished
    // Only counts as a signal if we have some reading history (cold start check)
    double novelty = 0.0;
    final bool hasReadingHistory =
        profile.preferredGenres.isNotEmpty ||
        profile.preferredAuthors.isNotEmpty;
    final bool hasNoveltySignal = hasReadingHistory;
    if (existingRecord != null &&
        existingRecord.status == ReadingStatus.finished) {
      novelty = 0.0;
    } else {
      novelty = 1.0;
    }

    // Weights from PRD §8 - only include available signals
    const double wGenre = 0.25;
    const double wAuthor = 0.10;
    // Text similarity and history fit are not implemented - omitted from weights
    const double wNovelty = 0.10;

    double totalWeight = 0.0;
    double weightedSum = 0.0;

    if (hasGenreSignal) {
      totalWeight += wGenre;
      weightedSum += wGenre * genreSimilarity;
    }
    if (hasAuthorSignal) {
      totalWeight += wAuthor;
      weightedSum += wAuthor * authorSimilarity;
    }
    if (hasNoveltySignal) {
      totalWeight += wNovelty;
      weightedSum += wNovelty * novelty;
    }

    // Cold start: no positive signals from reading history
    if (totalWeight == 0) {
      return ScoreResult(
        score: 0.0,
        explanations: ['No reading history to base recommendations on'],
      );
    }

    final score = (weightedSum / totalWeight).clamp(0.0, 1.0);

    // Build explanations from actual positive signals only
    final explanations = <String>[];
    if (hasGenreSignal && genreSimilarity > 0.2) {
      explanations.add('Shares genres with books you rated highly');
    }
    if (hasAuthorSignal && authorSimilarity > 0.5) {
      explanations.add('By an author you like');
    }
    if (hasNoveltySignal && novelty > 0.5) {
      explanations.add('New to your library');
    }

    return ScoreResult(score: score, explanations: explanations);
  }
}

class UserProfile {
  final Set<String> preferredGenres;
  final Set<String> preferredAuthors;

  UserProfile({required this.preferredGenres, required this.preferredAuthors});
}

class ScoreResult {
  final double score;
  final List<String> explanations;

  ScoreResult({required this.score, required this.explanations});
}

class ScoredCandidate {
  final Book book;
  final double score;
  final List<String> explanations;

  ScoredCandidate({
    required this.book,
    required this.score,
    required this.explanations,
  });
}
