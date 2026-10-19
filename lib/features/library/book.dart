const Object _sentinel = Object();

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

  /// Thumbnail URL for the book cover (from external catalog, not stored locally)
  final String? thumbnailUrl;

  /// Purchase price (for self-purchased books)
  final double? purchasePrice;

  /// Currency for purchase price
  final String? purchaseCurrency;

  /// Whether this book was borrowed from someone
  final bool isBorrowed;

  /// Lender name (when borrowed)
  final String? lenderName;

  /// Lender contact info (when borrowed)
  final String? lenderContact;

  /// Date when borrowed
  final DateTime? borrowDate;

  /// Expected return date (when borrowed)
  final DateTime? expectedReturnDate;

  /// Whether this book is lent to someone
  final bool isLent;

  /// Borrower name (when lent)
  final String? borrowerName;

  /// Borrower contact info (when lent)
  final String? borrowerContact;

  /// Date when lent out
  final DateTime? lendDate;

  /// Expected return date (when lent)
  final DateTime? expectedLendReturnDate;

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
    this.description = '',
    this.genres = '',
    this.isbn10 = '',
    this.isbn13 = '',
    this.publisher = '',
    this.publicationDate,
    this.pageCount,
    this.coverAssetKey,
    this.externalCatalogId = '',
    this.externalSourceUrl = '',
    this.thumbnailUrl,
    this.purchasePrice,
    this.purchaseCurrency,
    this.isBorrowed = false,
    this.lenderName,
    this.lenderContact,
    this.borrowDate,
    this.expectedReturnDate,
    this.isLent = false,
    this.borrowerName,
    this.borrowerContact,
    this.lendDate,
    this.expectedLendReturnDate,
    DateTime? createdAtParam,
    DateTime? updatedAtParam,
    this.archivedAt,
    bool? isInWishlistParam,
  }) : createdAt = createdAtParam ?? DateTime.now(),
       updatedAt = updatedAtParam ?? DateTime.now(),
       isInWishlist = isInWishlistParam ?? false;

  /// Copy with modified fields - used for updates and archiving
  /// Use _clear sentinel to explicitly clear nullable fields (e.g., description: _clear)
  Book copyWith({
    int? id,
    String? title,
    String? authors,
    Object? description = _sentinel,
    Object? genres = _sentinel,
    Object? isbn10 = _sentinel,
    Object? isbn13 = _sentinel,
    Object? publisher = _sentinel,
    Object? publicationDate = _sentinel,
    Object? pageCount = _sentinel,
    Object? coverAssetKey = _sentinel,
    bool? isInWishlist,
    Object? externalCatalogId = _sentinel,
    Object? externalSourceUrl = _sentinel,
    Object? thumbnailUrl = _sentinel,
    Object? purchasePrice = _sentinel,
    Object? purchaseCurrency = _sentinel,
    bool? isBorrowed,
    Object? lenderName = _sentinel,
    Object? lenderContact = _sentinel,
    Object? borrowDate = _sentinel,
    Object? expectedReturnDate = _sentinel,
    bool? isLent,
    Object? borrowerName = _sentinel,
    Object? borrowerContact = _sentinel,
    Object? lendDate = _sentinel,
    Object? expectedLendReturnDate = _sentinel,
    Object? createdAt = _sentinel,
    Object? updatedAt = _sentinel,
    Object? archivedAt = _sentinel,
  }) {
    return Book(
      id: id ?? this.id,
      title: title ?? this.title,
      authors: authors ?? this.authors,
      description: identical(description, _sentinel)
          ? this.description
          : description as String?,
      genres: identical(genres, _sentinel) ? this.genres : genres as String?,
      isbn10: identical(isbn10, _sentinel) ? this.isbn10 : isbn10 as String?,
      isbn13: identical(isbn13, _sentinel) ? this.isbn13 : isbn13 as String?,
      publisher: identical(publisher, _sentinel)
          ? this.publisher
          : publisher as String?,
      publicationDate: identical(publicationDate, _sentinel)
          ? this.publicationDate
          : publicationDate as DateTime?,
      pageCount: identical(pageCount, _sentinel)
          ? this.pageCount
          : pageCount as int?,
      coverAssetKey: identical(coverAssetKey, _sentinel)
          ? this.coverAssetKey
          : coverAssetKey as String?,
      externalCatalogId: identical(externalCatalogId, _sentinel)
          ? this.externalCatalogId
          : externalCatalogId as String?,
      externalSourceUrl: identical(externalSourceUrl, _sentinel)
          ? this.externalSourceUrl
          : externalSourceUrl as String?,
      thumbnailUrl: identical(thumbnailUrl, _sentinel)
          ? this.thumbnailUrl
          : thumbnailUrl as String?,
      purchasePrice: identical(purchasePrice, _sentinel)
          ? this.purchasePrice
          : purchasePrice as double?,
      purchaseCurrency: identical(purchaseCurrency, _sentinel)
          ? this.purchaseCurrency
          : purchaseCurrency as String?,
      isBorrowed: isBorrowed ?? this.isBorrowed,
      lenderName: identical(lenderName, _sentinel)
          ? this.lenderName
          : lenderName as String?,
      lenderContact: identical(lenderContact, _sentinel)
          ? this.lenderContact
          : lenderContact as String?,
      borrowDate: identical(borrowDate, _sentinel)
          ? this.borrowDate
          : borrowDate as DateTime?,
      expectedReturnDate: identical(expectedReturnDate, _sentinel)
          ? this.expectedReturnDate
          : expectedReturnDate as DateTime?,
      isLent: isLent ?? this.isLent,
      borrowerName: identical(borrowerName, _sentinel)
          ? this.borrowerName
          : borrowerName as String?,
      borrowerContact: identical(borrowerContact, _sentinel)
          ? this.borrowerContact
          : borrowerContact as String?,
      lendDate: identical(lendDate, _sentinel)
          ? this.lendDate
          : lendDate as DateTime?,
      expectedLendReturnDate: identical(expectedLendReturnDate, _sentinel)
          ? this.expectedLendReturnDate
          : expectedLendReturnDate as DateTime?,
      createdAtParam: identical(createdAt, _sentinel)
          ? this.createdAt
          : createdAt as DateTime?,
      updatedAtParam: identical(updatedAt, _sentinel)
          ? this.updatedAt
          : updatedAt as DateTime?,
      archivedAt: identical(archivedAt, _sentinel)
          ? this.archivedAt
          : archivedAt as DateTime?,
      isInWishlistParam: isInWishlist ?? this.isInWishlist,
    );
  }

  /// Mark this book as archived (removed from active library)
  Book get archived => copyWith(archivedAt: DateTime.now());

  /// String representation for debugging
  @override
  String toString() => 'Book(id: $id, title: $title, authors: $authors)';
}
