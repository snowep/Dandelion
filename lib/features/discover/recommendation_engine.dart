import 'package:dandelion/features/library/book.dart';
import 'package:dandelion/features/library/reading_record.dart';

/// A simple recommendation engine for the Discover screen.
///
/// It computes a score for a book candidate based on the user's library
/// using the formula from PRD §8:
///   score = 0.25*genreSimilarity + 0.10*authorSimilarity + 0.20*textSimilarity
///           + 0.35*historyFit + 0.10*novelty
///
/// For now, we implement genre similarity (Jaccard), author similarity
/// (preference for authors of finished/rated books), and novelty.
/// Text similarity and history fit are stubbed to 0, and we normalize
/// the weights over the available signals.
class RecommendationEngine {
  RecommendationEngine(this._libraryBooks, this._readingRecords);

  final List<Book> _libraryBooks;
  final List<ReadingRecord> _readingRecords;

  /// Build a user profile from the library: preferred genres and authors.
  /// We consider books that are finished or have a rating >= 3 as positive signals.
  UserProfile _buildUserProfile() {
    final Set<String> preferredGenres = {};
    final Set<String> preferredAuthors = {};

    for (final record in _readingRecords) {
      // Only consider finished or rated >= 3 as positive.
      final bool isPositive =
          record.status == ReadingStatus.finished ||
          (record.personalRating ?? 0) >= 3;
      if (!isPositive) continue;

      final book = _libraryBooks.firstWhere(
        (b) => b.id == record.bookId,
        orElse: () => Book(id: 0, title: '', authors: ''),
      );
      if (book.genres != null && book.genres!.isNotEmpty) {
        for (final genre in book.genres!.split(',')) {
          preferredGenres.add(genre.trim().toLowerCase());
        }
      }
      if (book.authors.isNotEmpty) {
        preferredAuthors.add(book.authors.toLowerCase());
      }
    }

    return UserProfile(
      preferredGenres: preferredGenres,
      preferredAuthors: preferredAuthors,
    );
  }

  /// Score a candidate book (from library or catalog) relative to the user profile.
  /// Returns a score between 0 and 1, and a list of explanation strings.
  ///
  /// For catalog candidates, we may have missing fields; we normalize weights
  /// over the available signals.
  ScoreResult score(Book candidate) {
    final profile = _buildUserProfile();

    // Genre similarity: Jaccard index between candidate genres and preferred genres.
    double genreSimilarity = 0.0;
    if (candidate.genres != null && candidate.genres!.isNotEmpty) {
      final candidateGenres = <String>{};
      for (final g in candidate.genres!.split(',')) {
        candidateGenres.add(g.trim().toLowerCase());
      }
      if (candidateGenres.isNotEmpty && profile.preferredGenres.isNotEmpty) {
        final intersection = candidateGenres
            .intersection(profile.preferredGenres)
            .length;
        final union = candidateGenres.union(profile.preferredGenres).length;
        genreSimilarity = intersection / union;
      }
    }

    // Author similarity: 1 if any author matches preferred authors, else 0.
    double authorSimilarity = 0.0;
    if (candidate.authors.isNotEmpty && profile.preferredAuthors.isNotEmpty) {
      // Simple check: if the author string contains any preferred author.
      // For simplicity, we split by ',' and trim.
      final candidateAuthors = <String>{};
      for (final a in candidate.authors.split(',')) {
        candidateAuthors.add(a.trim().toLowerCase());
      }
      if (candidateAuthors.any((a) => profile.preferredAuthors.contains(a))) {
        authorSimilarity = 1.0;
      }
    }

    // Text similarity: stubbed to 0 (would need TF-IDF over title/description).
    double textSimilarity = 0.0;

    // History fit: stubbed to 0 (would need more complex modeling).
    double historyFit = 0.0;

    // Novelty: bonus for books not already finished or dismissed.
    // We consider a book novel if it is not in the library with status finished.
    double novelty = 0.0;
    final bool isAlreadyFinished = _readingRecords.any(
      (record) =>
          record.bookId == candidate.id &&
          record.status == ReadingStatus.finished,
    );
    if (!isAlreadyFinished) {
      novelty = 1.0;
    }

    // Weights from PRD §8.
    const double wGenre = 0.25;
    const double wAuthor = 0.10;
    const double wText = 0.20;
    const double wHistory = 0.35;
    const double wNovelty = 0.10;

    // Determine which signals are available (non-zero weight and we have data).
    // For simplicity, we consider a signal available if we can compute it
    // (i.e., not stubbed to 0 due to missing data). In this implementation,
    // genre and author are based on actual data; text and history are stubbed.
    // Novelty is based on data.
    double totalWeight = 0.0;
    double weightedSum = 0.0;

    totalWeight += wGenre;
    weightedSum += wGenre * genreSimilarity;
    totalWeight += wAuthor;
    weightedSum += wAuthor * authorSimilarity;
    totalWeight += wText;
    weightedSum += wText * textSimilarity;
    totalWeight += wHistory;
    weightedSum += wHistory * historyFit;
    totalWeight += wNovelty;
    weightedSum += wNovelty * novelty;

    // Avoid division by zero.
    final double score = totalWeight > 0 ? weightedSum / totalWeight : 0.0;

    // Build explanation from the top signals.
    final List<String> explanations = <String>[];
    if (genreSimilarity > 0.3) {
      explanations.add('Shares genres with books you rated highly');
    } else if (authorSimilarity > 0.5) {
      explanations.add('By an author you like');
    }
    if (novelty > 0.5) {
      explanations.add('New to your library');
    }
    // We could add more explanations based on text or history.

    return ScoreResult(
      score: score.clamp(0.0, 1.0),
      explanations: explanations,
    );
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
