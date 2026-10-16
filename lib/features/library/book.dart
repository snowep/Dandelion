/// Book entity representing a book in the Dandelion library.
///
/// Fields correspond to the PRD.md data model and Drift database schema.
/// All identifiers use stable IDs for state preservation across app restarts.
class Book {
  /// Unique stable identifier for the book record
  final int id;

  /// Title of the book
  final String title;

  /// Authors of the book (list as comma-separated string for simplicity)
  final String authors;

  /// Description or plot summary of the book
  final String? description;

  /// Genres associated with the book (comma-separated for simplicity)
  final String? genres;

  /// ISBN-10 identifier (unique when present)
  final String? isbn10;

  /// ISBN-13 identifier (unique when present)
  final String? isbn13;

  /// Publisher name
  final String? publisher;

  /// Publication date
  final DateTime? publicationDate;

  /// Number of pages in the book
  final int? pageCount;

  /// Reference to locally stored cover asset
  final String? coverAssetKey;

  /// Wishlist status flag
  final bool isInWishlist;

  /// External catalog ID source (e.g. Open Library ID)
  final String? externalCatalogId;

  /// Source URL for external catalog metadata
  final String? externalSourceUrl;

  /// When the book record was created
  final DateTime createdAt;

  /// When the book record was last updated
  final DateTime updatedAt;

  /// When the book was archived (null if active)
  final DateTime? archivedAt;

  /// Named constructor for creating a new active book
  Book({
    required this.id,
    required this.title,
    required this.authors,
    this.description,
    this.genres,
    this.isbn10,
    this.isbn13,
    this.publisher,
    this.publicationDate,
    this.pageCount,
    this.coverAssetKey,
    this.externalCatalogId,
    this.externalSourceUrl,
    DateTime? createdAt,
    DateTime? updatedAt,
    this.archivedAt,
    bool? isInWishlist,
  }) : createdAt = createdAt ?? DateTime.now(),
       updatedAt = updatedAt ?? DateTime.now(),
       isInWishlist = isInWishlist ?? false;

  /// Copy with modified fields - used for updates and archiving
  Book copyWith({
    int? id,
    String? title,
    String? authors,
    String? description,
    String? genres,
    String? isbn10,
    String? isbn13,
    String? publisher,
    DateTime? publicationDate,
    int? pageCount,
    String? coverAssetKey,
    bool? isInWishlist,
    String? externalCatalogId,
    String? externalSourceUrl,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? archivedAt,
  }) {
    return Book(
      id: id ?? this.id,
      title: title ?? this.title,
      authors: authors ?? this.authors,
      description: description ?? this.description,
      genres: genres ?? this.genres,
      isbn10: isbn10 ?? this.isbn10,
      isbn13: isbn13 ?? this.isbn13,
      publisher: publisher ?? this.publisher,
      publicationDate: publicationDate ?? this.publicationDate,
      pageCount: pageCount ?? this.pageCount,
      coverAssetKey: coverAssetKey ?? this.coverAssetKey,
      externalCatalogId: externalCatalogId ?? this.externalCatalogId,
      externalSourceUrl: externalSourceUrl ?? this.externalSourceUrl,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      archivedAt: archivedAt ?? this.archivedAt,
      isInWishlist: isInWishlist ?? this.isInWishlist,
    );
  }

  /// Mark this book as archived (removed from active library)
  Book get archived => copyWith(archivedAt: DateTime.now());

  /// String representation for debugging
  @override
  String toString() => 'Book(id: $id, title: $title, authors: $authors)';
}
