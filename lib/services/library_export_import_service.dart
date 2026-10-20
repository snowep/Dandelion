import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:archive/archive.dart';

import '../features/library/book.dart';
import '../features/library/reading_record.dart';
import '../features/library/book_repository.dart';
import '../shared/services/cover_image_service.dart';

class ExportData {
  final int schemaVersion;
  final DateTime exportDate;
  final List<Map<String, dynamic>> books;
  final List<Map<String, dynamic>> readingRecords;
  final Map<String, String> coversBase64;

  ExportData({
    required this.schemaVersion,
    required this.exportDate,
    required this.books,
    required this.readingRecords,
    required this.coversBase64,
  });

  Map<String, dynamic> toJson() => {
    'schemaVersion': schemaVersion,
    'exportDate': exportDate.toIso8601String(),
    'books': books,
    'readingRecords': readingRecords,
    'coversBase64': coversBase64,
  };

  static ExportData fromJson(Map<String, dynamic> json) => ExportData(
    schemaVersion: json['schemaVersion'] as int,
    exportDate: DateTime.parse(json['exportDate'] as String),
    books: (json['books'] as List).cast<Map<String, dynamic>>(),
    readingRecords: (json['readingRecords'] as List)
        .cast<Map<String, dynamic>>(),
    coversBase64: (json['coversBase64'] as Map).cast<String, String>(),
  );
}

class ImportPreview {
  final bool isValid;
  final int schemaVersion;
  final DateTime? exportDate;
  final int booksCount;
  final int readingRecordsCount;
  final List<String> errors;
  final List<String> warnings;
  final List<BookConflict> conflicts;

  ImportPreview({
    required this.isValid,
    required this.schemaVersion,
    this.exportDate,
    required this.booksCount,
    required this.readingRecordsCount,
    this.errors = const [],
    this.warnings = const [],
    this.conflicts = const [],
  });
}

class BookConflict {
  final String title;
  final String? existingIsbn;
  final String? importIsbn;
  final ConflictType type;

  BookConflict({
    required this.title,
    this.existingIsbn,
    this.importIsbn,
    required this.type,
  });
}

enum ConflictType { duplicateIsbn, duplicateTitle, missingRequired }

class ExportService {
  ExportService(this._repository);
  final BookRepository _repository;

  static const int currentSchemaVersion = 2;

  Future<ExportData> export() async {
    final books = await _repository.getAll();
    final records = await _repository.listReadingRecords();

    final booksJson = books.map(_bookToJson).toList();
    final recordsJson = records.map(_recordToJson).toList();

    final coversBase64 = <String, String>{};
    for (final book in books) {
      if (book.coverAssetKey != null && book.coverAssetKey!.isNotEmpty) {
        try {
          final bytes = await CoverImageService.loadImage(book.coverAssetKey!);
          if (bytes != null) {
            coversBase64[book.coverAssetKey!] = base64Encode(bytes);
          }
        } catch (e) {
          // If we can't load a cover, we skip it but continue with export
        }
      }
    }

    return ExportData(
      schemaVersion: currentSchemaVersion,
      exportDate: DateTime.now().toUtc(),
      books: booksJson,
      readingRecords: recordsJson,
      coversBase64: coversBase64,
    );
  }

  Map<String, dynamic> _bookToJson(Book b) => {
    'id': b.id,
    'title': b.title,
    'authors': b.authors,
    'description': b.description,
    'genres': b.genres,
    'isbn10': b.isbn10,
    'isbn13': b.isbn13,
    'publisher': b.publisher,
    'publicationDate': b.publicationDate?.toIso8601String(),
    'pageCount': b.pageCount,
    'coverAssetKey': b.coverAssetKey,
    'isInWishlist': b.isInWishlist,
    'externalCatalogId': b.externalCatalogId,
    'externalSourceUrl': b.externalSourceUrl,
    'purchasePrice': b.purchasePrice,
    'purchaseCurrency': b.purchaseCurrency,
    'isBorrowed': b.isBorrowed,
    'lenderName': b.lenderName,
    'lenderContact': b.lenderContact,
    'borrowDate': b.borrowDate?.toIso8601String(),
    'expectedReturnDate': b.expectedReturnDate?.toIso8601String(),
    'isLent': b.isLent,
    'borrowerName': b.borrowerName,
    'borrowerContact': b.borrowerContact,
    'lendDate': b.lendDate?.toIso8601String(),
    'expectedLendReturnDate': b.expectedLendReturnDate?.toIso8601String(),
    'createdAt': b.createdAt.toIso8601String(),
    'updatedAt': b.updatedAt.toIso8601String(),
    'archivedAt': b.archivedAt?.toIso8601String(),
  };

  Map<String, dynamic> _recordToJson(ReadingRecord r) => {
    'id': r.id,
    'bookId': r.bookId,
    'status': r.status.name,
    'currentPage': r.currentPage,
    'percentageOnlyProgress': r.percentageOnlyProgress,
    'startDate': r.startDate?.toIso8601String(),
    'finishDate': r.finishDate?.toIso8601String(),
    'lastReadDate': r.lastReadDate.toIso8601String(),
    'personalRating': r.personalRating,
    'notes': r.notes,
  };

  Future<void> exportToFile(File file) async {
    final data = await export();
    final bytes = utf8.encode(jsonEncode(data.toJson()));
    final archive = Archive();
    archive.addFile(ArchiveFile('library.json', bytes.length, bytes));
    final zipData = ZipEncoder().encode(archive);
    await file.writeAsBytes(zipData);
  }
}

class ImportService {
  ImportService(this._repository);
  final BookRepository _repository;

  static const int supportedSchemaVersion = 2;

  Future<ImportPreview> validateArchive(Uint8List archiveBytes) async {
    final errors = <String>[];
    final warnings = <String>[];
    final conflicts = <BookConflict>[];

    Map<String, dynamic> jsonMap;
    try {
      if (archiveBytes.length < 4 ||
          archiveBytes[0] != 0x50 ||
          archiveBytes[1] != 0x4B ||
          archiveBytes[2] != 0x03 ||
          archiveBytes[3] != 0x04) {
        jsonMap = jsonDecode(utf8.decode(archiveBytes));
      } else {
        final archive = ZipDecoder().decodeBytes(archiveBytes);
        final libraryFile = archive.files.firstWhere(
          (f) => f.name == 'library.json',
          orElse: () => throw FormatException('library.json missing'),
        );
        jsonMap = jsonDecode(utf8.decode(libraryFile.content as List<int>));
      }
    } catch (e) {
      return ImportPreview(
        isValid: false,
        schemaVersion: -1,
        booksCount: 0,
        readingRecordsCount: 0,
        errors: ['Failed to read archive: $e'],
      );
    }

    // Validate top-level structure
    if (!jsonMap.containsKey('schemaVersion') ||
        !jsonMap.containsKey('exportDate') ||
        !jsonMap.containsKey('books') ||
        !jsonMap.containsKey('readingRecords')) {
      return ImportPreview(
        isValid: false,
        schemaVersion: -1,
        booksCount: 0,
        readingRecordsCount: 0,
        errors: [
          'Invalid archive structure: missing required top-level fields',
        ],
      );
    }

    final schemaVersion = jsonMap['schemaVersion'] as int? ?? -1;
    if (schemaVersion != supportedSchemaVersion) {
      errors.add(
        'Unsupported schema version $schemaVersion, expected $supportedSchemaVersion',
      );
    }

    final exportDateStr = jsonMap['exportDate'] as String?;
    DateTime? exportDate;
    if (exportDateStr != null) {
      try {
        exportDate = DateTime.parse(exportDateStr);
      } catch (_) {
        warnings.add('Invalid exportDate format');
      }
    }

    final booksList = (jsonMap['books'] as List?) ?? [];
    final recordsList = (jsonMap['readingRecords'] as List?) ?? [];

    // Validate books structure and collect data for duplicate detection
    final List<Map<String, dynamic>> validBooks = [];
    final Set<String> incomingIsbns = <String>{};
    final Set<String> incomingTitleAuthors = <String>{};

    for (int i = 0; i < booksList.length; i++) {
      final b = booksList[i];
      if (b == null || b is! Map<String, dynamic>) {
        errors.add('Book at index $i is not a valid object');
        continue;
      }

      final title = b['title'] as String?;
      if (title == null || title.trim().isEmpty) {
        errors.add('Book at index $i missing required title');
        continue;
      }

      final authors = b['authors'] as String?;
      if (authors == null || authors.trim().isEmpty) {
        errors.add('Book at index $i missing required authors');
        continue;
      }

      // Validate optional fields with type checking
      final description = b['description'];
      if (description != null && description is! String) {
        warnings.add('Book at index $i description is not a string');
      }

      final genres = b['genres'];
      if (genres != null && genres is! String) {
        warnings.add('Book at index $i genres is not a string');
      }

      final isbn10 = b['isbn10'];
      final isbn13 = b['isbn13'];
      final normalizedIsbn10 = _normalizeIsbn(isbn10 as String?);
      final normalizedIsbn13 = _normalizeIsbn(isbn13 as String?);
      final normalizedIsbn = normalizedIsbn10 ?? normalizedIsbn13;

      final publisher = b['publisher'];
      if (publisher != null && publisher is! String) {
        warnings.add('Book at index $i publisher is not a string');
      }

      final publicationDateStr = b['publicationDate'] as String?;
      DateTime? publicationDate;
      if (publicationDateStr != null) {
        try {
          publicationDate = DateTime.parse(publicationDateStr);
        } catch (_) {
          warnings.add(
            'Book at index $i publicationDate is not a valid ISO date',
          );
        }
      }

      final pageCount = b['pageCount'];
      if (pageCount != null && (pageCount is! int || pageCount <= 0)) {
        warnings.add('Book at index $i pageCount is not a positive integer');
      }

      final coverAssetKey = b['coverAssetKey'];
      if (coverAssetKey != null && coverAssetKey is! String) {
        warnings.add('Book at index $i coverAssetKey is not a string');
      }

      final isInWishlist = b['isInWishlist'];
      if (isInWishlist != null && isInWishlist is! bool) {
        warnings.add('Book at index $i isInWishlist is not a boolean');
      }

      final externalCatalogId = b['externalCatalogId'];
      if (externalCatalogId != null && externalCatalogId is! String) {
        warnings.add('Book at index $i externalCatalogId is not a string');
      }

      final externalSourceUrl = b['externalSourceUrl'];
      if (externalSourceUrl != null && externalSourceUrl is! String) {
        warnings.add('Book at index $i externalSourceUrl is not a string');
      }

      final purchasePrice = b['purchasePrice'];
      if (purchasePrice != null &&
          (purchasePrice is! num || purchasePrice < 0)) {
        warnings.add(
          'Book at index $i purchasePrice is not a non-negative number',
        );
      }

      final purchaseCurrency = b['purchaseCurrency'];
      if (purchaseCurrency != null && purchaseCurrency is! String) {
        warnings.add('Book at index $i purchaseCurrency is not a string');
      }

      final isBorrowed = b['isBorrowed'];
      if (isBorrowed != null && isBorrowed is! bool) {
        warnings.add('Book at index $i isBorrowed is not a boolean');
      }

      final lenderName = b['lenderName'];
      if (lenderName != null && lenderName is! String) {
        warnings.add('Book at index $i lenderName is not a string');
      }

      final lenderContact = b['lenderContact'];
      if (lenderContact != null && lenderContact is! String) {
        warnings.add('Book at index $i lenderContact is not a string');
      }

      final borrowDateStr = b['borrowDate'] as String?;
      DateTime? borrowDate;
      if (borrowDateStr != null) {
        try {
          borrowDate = DateTime.parse(borrowDateStr);
        } catch (_) {
          warnings.add('Book at index $i borrowDate is not a valid ISO date');
        }
      }

      final expectedReturnDateStr = b['expectedReturnDate'] as String?;
      DateTime? expectedReturnDate;
      if (expectedReturnDateStr != null) {
        try {
          expectedReturnDate = DateTime.parse(expectedReturnDateStr);
        } catch (_) {
          warnings.add(
            'Book at index $i expectedReturnDate is not a valid ISO date',
          );
        }
      }

      final isLent = b['isLent'];
      if (isLent != null && isLent is! bool) {
        warnings.add('Book at index $i isLent is not a boolean');
      }

      final borrowerName = b['borrowerName'];
      if (borrowerName != null && borrowerName is! String) {
        warnings.add('Book at index $i borrowerName is not a string');
      }

      final borrowerContact = b['borrowerContact'];
      if (borrowerContact != null && borrowerContact is! String) {
        warnings.add('Book at index $i borrowerContact is not a string');
      }

      final lendDateStr = b['lendDate'] as String?;
      DateTime? lendDate;
      if (lendDateStr != null) {
        try {
          lendDate = DateTime.parse(lendDateStr);
        } catch (_) {
          warnings.add('Book at index $i lendDate is not a valid ISO date');
        }
      }

      final expectedLendReturnDateStr = b['expectedLendReturnDate'] as String?;
      DateTime? expectedLendReturnDate;
      if (expectedLendReturnDateStr != null) {
        try {
          expectedLendReturnDate = DateTime.parse(expectedLendReturnDateStr);
        } catch (_) {
          warnings.add(
            'Book at index $i expectedLendReturnDate is not a valid ISO date',
          );
        }
      }

      final createdAtStr = b['createdAt'] as String?;
      DateTime? createdAt;
      if (createdAtStr != null) {
        try {
          createdAt = DateTime.parse(createdAtStr);
        } catch (_) {
          warnings.add('Book at index $i createdAt is not a valid ISO date');
        }
      } else {
        createdAt = DateTime.now();
      }

      final updatedAtStr = b['updatedAt'] as String?;
      DateTime? updatedAt;
      if (updatedAtStr != null) {
        try {
          updatedAt = DateTime.parse(updatedAtStr);
        } catch (_) {
          warnings.add('Book at index $i updatedAt is not a valid ISO date');
        }
      } else {
        updatedAt = DateTime.now();
      }

      final archivedAtStr = b['archivedAt'] as String?;
      DateTime? archivedAt;
      if (archivedAtStr != null) {
        try {
          archivedAt = DateTime.parse(archivedAtStr);
        } catch (_) {
          warnings.add('Book at index $i archivedAt is not a valid ISO date');
        }
      }

      // Check for duplicate ISBN in incoming books
      if (normalizedIsbn != null && normalizedIsbn.isNotEmpty) {
        if (incomingIsbns.contains(normalizedIsbn)) {
          warnings.add(
            'Duplicate ISBN "$normalizedIsbn" found in incoming books at index $i',
          );
        } else {
          incomingIsbns.add(normalizedIsbn);
        }
      }

      // Check for duplicate title+author in incoming books
      final titleKey =
          '${title.trim().toLowerCase()}|${authors.trim().toLowerCase()}';
      if (incomingTitleAuthors.contains(titleKey)) {
        warnings.add(
          'Duplicate title+author combination found in incoming books at index $i',
        );
      } else {
        incomingTitleAuthors.add(titleKey);
      }

      // Add to valid books for further processing
      validBooks.add({
        'id': b['id'] ?? 0,
        'title': title.trim(),
        'authors': authors.trim(),
        'description': description ?? '',
        'genres': genres ?? '',
        'isbn10': isbn10,
        'isbn13': isbn13,
        'normalizedIsbn': normalizedIsbn,
        'publisher': publisher ?? '',
        'publicationDate': publicationDate,
        'pageCount': pageCount is int ? pageCount : 0,
        'coverAssetKey': coverAssetKey ?? '',
        'isInWishlist': isInWishlist ?? false,
        'externalCatalogId': externalCatalogId ?? '',
        'externalSourceUrl': externalSourceUrl ?? '',
        'purchasePrice': purchasePrice is num ? purchasePrice.toDouble() : null,
        'purchaseCurrency': purchaseCurrency as String?,
        'isBorrowed': isBorrowed ?? false,
        'lenderName': lenderName as String?,
        'lenderContact': lenderContact as String?,
        'borrowDate': borrowDate,
        'expectedReturnDate': expectedReturnDate,
        'isLent': isLent ?? false,
        'borrowerName': borrowerName as String?,
        'borrowerContact': borrowerContact as String?,
        'lendDate': lendDate,
        'expectedLendReturnDate': expectedLendReturnDate,
        'createdAt': createdAt,
        'updatedAt': updatedAt,
        'archivedAt': archivedAt,
      });
    }

    // Validate reading records structure
    final List<Map<String, dynamic>> validRecords = [];
    final Set<int> incomingRecordIds = <int>{};
    final Set<int> incomingBookIdsFromRecords = <int>{};

    for (int i = 0; i < recordsList.length; i++) {
      final r = recordsList[i];
      if (r == null || r is! Map<String, dynamic>) {
        errors.add('Reading record at index $i is not a valid object');
        continue;
      }

      final id = r['id'] as int?;
      if (id == null || id < 0) {
        errors.add('Reading record at index $i missing or invalid id');
        continue;
      }

      if (incomingRecordIds.contains(id)) {
        errors.add('Duplicate reading record id $id found in incoming records');
        continue;
      }
      incomingRecordIds.add(id);

      final bookId = r['bookId'] as int?;
      if (bookId == null || bookId < 0) {
        errors.add('Reading record at index $i missing or invalid bookId');
        continue;
      }
      incomingBookIdsFromRecords.add(bookId);

      final status = r['status'] as String?;
      if (status == null ||
          !ReadingStatus.values.map((e) => e.name).contains(status)) {
        errors.add('Reading record at index $i missing or invalid status');
        continue;
      }

      final currentPage = r['currentPage'];
      if (currentPage != null && (currentPage is! int || currentPage < 0)) {
        warnings.add(
          'Reading record at index $i currentPage is not a non-negative integer',
        );
      }

      final progressPercent = r['progressPercent'];
      if (progressPercent != null &&
          (progressPercent is! int ||
              progressPercent < 0 ||
              progressPercent > 100)) {
        warnings.add(
          'Reading record at index $i progressPercent is not between 0 and 100',
        );
      }

      final startDateStr = r['startDate'] as String?;
      DateTime? startDate;
      if (startDateStr != null) {
        try {
          startDate = DateTime.parse(startDateStr);
        } catch (_) {
          warnings.add(
            'Reading record at index $i startDate is not a valid ISO date',
          );
        }
      }

      final finishDateStr = r['finishDate'] as String?;
      DateTime? finishDate;
      if (finishDateStr != null) {
        try {
          finishDate = DateTime.parse(finishDateStr);
        } catch (_) {
          warnings.add(
            'Reading record at index $i finishDate is not a valid ISO date',
          );
        }
      }

      final lastReadDateStr = r['lastReadDate'] as String?;
      DateTime? lastReadDate;
      if (lastReadDateStr != null) {
        try {
          lastReadDate = DateTime.parse(lastReadDateStr);
        } catch (_) {
          warnings.add(
            'Reading record at index $i lastReadDate is not a valid ISO date',
          );
        }
      }

      final personalRating = r['personalRating'];
      if (personalRating != null &&
          (personalRating is! num ||
              personalRating < 0 ||
              personalRating > 5)) {
        warnings.add(
          'Reading record at index $i personalRating is not between 0 and 5',
        );
      }

      final notes = r['notes'];
      if (notes != null && notes is! String) {
        warnings.add('Reading record at index $i notes is not a string');
      }

      validRecords.add({
        'id': id,
        'bookId': bookId,
        'status': status,
        'currentPage': currentPage is int ? currentPage : 0,
        'progressPercent': progressPercent is int ? progressPercent : null,
        'startDate': startDate,
        'finishDate': finishDate,
        'lastReadDate': lastReadDate ?? DateTime.now(),
        'personalRating': personalRating is num
            ? personalRating.toDouble()
            : null,
        'notes': notes ?? '',
      });
    }

    // Check for references from reading records to non-existent books
    final validBookIdsFromBooks = <int>{};
    for (final book in validBooks) {
      final id = book['id'] as int;
      if (id > 0) {
        validBookIdsFromBooks.add(id);
      }
    }

    for (final bookId in incomingBookIdsFromRecords) {
      if (bookId > 0 && !validBookIdsFromBooks.contains(bookId)) {
        errors.add('Reading record references non-existent book id $bookId');
      }
    }

    // Check if any validation errors occurred
    if (errors.isNotEmpty) {
      return ImportPreview(
        isValid: false,
        schemaVersion: schemaVersion,
        exportDate: exportDate,
        booksCount: validBooks.length,
        readingRecordsCount: validRecords.length,
        errors: errors,
        warnings: warnings,
        conflicts: <BookConflict>[],
      );
    }

    // Fetch existing books for conflict detection
    final existingBooks = await _repository.getAll();
    final existingIsbns = <String>{};
    final existingTitleAuthors = <String>{};

    for (final book in existingBooks) {
      final isbn = _normalizeIsbn(book.isbn13 ?? book.isbn10);
      if (isbn != null && isbn.isNotEmpty) {
        existingIsbns.add(isbn);
      }
      final titleKey =
          '${book.title.trim().toLowerCase()}|${book.authors.trim().toLowerCase()}';
      existingTitleAuthors.add(titleKey);
    }

    // Detect conflicts with existing books

    for (final book in validBooks) {
      final title = book['title'] as String;
      final author = book['authors'] as String;
      final normalizedIsbn = book['normalizedIsbn'] as String?;

      Book? existingBook;

      // Check ISBN match first (highest precedence)
      if (normalizedIsbn != null && normalizedIsbn.isNotEmpty) {
        existingBook = await _repository.getBookByIsbn(normalizedIsbn);
      }

      // Check exact title+author match second
      if (existingBook == null && title.isNotEmpty && author.isNotEmpty) {
        existingBook = await _repository.getBookByTitleAndAuthor(title, author);
      }

      if (existingBook != null) {
        conflicts.add(
          BookConflict(
            title: title,
            existingIsbn: existingBook.isbn13 ?? existingBook.isbn10,
            importIsbn: normalizedIsbn,
            type: ConflictType.duplicateIsbn,
          ),
        );
      }
    }

    return ImportPreview(
      isValid: errors.isEmpty && conflicts.isEmpty,
      schemaVersion: schemaVersion,
      exportDate: exportDate,
      booksCount: validBooks.length,
      readingRecordsCount: validRecords.length,
      errors: errors,
      warnings: warnings,
      conflicts: conflicts,
    );
  }

  static String? _normalizeIsbn(String? isbn) {
    if (isbn == null) return null;
    final n = isbn.replaceAll(RegExp(r'[^0-9Xx]'), '').toUpperCase();
    return n.isEmpty ? null : n;
  }

  Future<void> importArchive(
    Uint8List archiveBytes, {
    bool skipConflicts = true,
    bool overwrite = false,
  }) async {
    final preview = await validateArchive(archiveBytes);
    if (!preview.isValid) {
      throw StateError(
        'Import validation failed: ${preview.errors.join('; ')}',
      );
    }

    Map<String, dynamic> jsonMap;
    if (archiveBytes.length < 4 ||
        archiveBytes[0] != 0x50 ||
        archiveBytes[1] != 0x4B ||
        archiveBytes[2] != 0x03 ||
        archiveBytes[3] != 0x04) {
      jsonMap = jsonDecode(utf8.decode(archiveBytes));
    } else {
      final archive = ZipDecoder().decodeBytes(archiveBytes);
      final libraryFile = archive.files.firstWhere(
        (f) => f.name == 'library.json',
        orElse: () => throw FormatException('library.json missing in archive'),
      );
      jsonMap = jsonDecode(utf8.decode(libraryFile.content as List<int>));
    }

    final exportData = ExportData.fromJson(jsonMap);

    // Fix 1: Source-to-destination ID mapping
        final sourceToDestId = <int, int>{};

        // Fix 5: Atomic rollback using database transaction
        await _repository.transaction(() async {
      for (final bookJson in exportData.books) {
        final sourceId = bookJson['id'] as int;
        final normalizedIsbn = _normalizeIsbn(
          (bookJson['isbn13'] as String?) ?? (bookJson['isbn10'] as String?),
        );
        final title = (bookJson['title'] as String?) ?? '';
        final author = (bookJson['authors'] as String?) ?? '';

        Book? existingBook;

        // Matching precedence: ISBN -> exact title+author -> create new
        if (normalizedIsbn != null && normalizedIsbn.isNotEmpty) {
          existingBook = await _repository.getBookByIsbn(normalizedIsbn);
        }

        if (existingBook == null && title.isNotEmpty && author.isNotEmpty) {
          existingBook = await _repository.getBookByTitleAndAuthor(title, author);
        }

        final shouldSkip = skipConflicts && existingBook != null;
        final shouldOverwrite = overwrite && existingBook != null;

        // Fix 2: Correct skip behavior - truly skip, no updates to existing book/record
        if (shouldSkip && !shouldOverwrite) {
          continue;
        }

        // Fix 4: Overwrite semantics - overwrite both book AND reading record
        if (existingBook != null && shouldOverwrite) {
          final book = Book(
            id: 0,
            title: bookJson['title'] as String,
            authors: bookJson['authors'] as String,
            description: bookJson['description'],
            genres: bookJson['genres'],
            isbn10: bookJson['isbn10'],
            isbn13: bookJson['isbn13'],
            publisher: bookJson['publisher'],
            publicationDate: bookJson['publicationDate'] != null
                ? DateTime.parse(bookJson['publicationDate'] as String)
                : null,
            pageCount: bookJson['pageCount'],
            coverAssetKey: bookJson['coverAssetKey'],
            isInWishlistParam: bookJson['isInWishlist'] ?? false,
            externalCatalogId: bookJson['externalCatalogId'],
            externalSourceUrl: bookJson['externalSourceUrl'],
            purchasePrice: bookJson['purchasePrice'] != null
                ? (bookJson['purchasePrice'] as num).toDouble()
                : null,
            purchaseCurrency: bookJson['purchaseCurrency'],
            isBorrowed: bookJson['isBorrowed'] ?? false,
            lenderName: bookJson['lenderName'],
            lenderContact: bookJson['lenderContact'],
            borrowDate: bookJson['borrowDate'] != null
                ? DateTime.parse(bookJson['borrowDate'] as String)
                : null,
            expectedReturnDate: bookJson['expectedReturnDate'] != null
                ? DateTime.parse(bookJson['expectedReturnDate'] as String)
                : null,
            isLent: bookJson['isLent'] ?? false,
            borrowerName: bookJson['borrowerName'],
            borrowerContact: bookJson['borrowerContact'],
            lendDate: bookJson['lendDate'] != null
                ? DateTime.parse(bookJson['lendDate'] as String)
                : null,
            expectedLendReturnDate: bookJson['expectedLendReturnDate'] != null
                ? DateTime.parse(bookJson['expectedLendReturnDate'] as String)
                : null,
            createdAtParam: bookJson['createdAt'] != null
                ? DateTime.parse(bookJson['createdAt'] as String)
                : DateTime.now(),
            updatedAtParam: bookJson['updatedAt'] != null
                ? DateTime.parse(bookJson['updatedAt'] as String)
                : DateTime.now(),
            archivedAt: bookJson['archivedAt'] != null
                ? DateTime.parse(bookJson['archivedAt'] as String)
                : null,
          );
          
          await _repository.updateBook(book.copyWith(id: existingBook.id, updatedAt: DateTime.now()));
          
          // Also overwrite reading record
          final recordJson = exportData.readingRecords
              .where((r) => r['bookId'] == sourceId)
              .firstOrNull;
          if (recordJson != null) {
            await _repository.updateReadingRecord(ReadingRecord(
              bookId: existingBook.id,
              status: ReadingStatus.values.firstWhere(
                (s) => s.name == recordJson['status'],
                orElse: () => ReadingStatus.wantToRead,
              ),
              currentPage: recordJson['currentPage'],
              percentageOnlyProgress: recordJson['percentageOnlyProgress'],
              startDate: recordJson['startDate'] != null
                  ? DateTime.parse(recordJson['startDate'] as String)
                  : null,
              finishDate: recordJson['finishDate'] != null
                  ? DateTime.parse(recordJson['finishDate'] as String)
                  : null,
              lastReadDate: DateTime.parse(recordJson['lastReadDate'] as String),
              personalRating: recordJson['personalRating'],
              notes: recordJson['notes'],
            ));
          }
          sourceToDestId[sourceId] = existingBook.id;
        } else {
          // Create new book (Fix 1: source ID not reused, new destination ID assigned)
          final book = Book(
            id: 0,
            title: bookJson['title'] as String,
            authors: bookJson['authors'] as String,
            description: bookJson['description'],
            genres: bookJson['genres'],
            isbn10: bookJson['isbn10'],
            isbn13: bookJson['isbn13'],
            publisher: bookJson['publisher'],
            publicationDate: bookJson['publicationDate'] != null
                ? DateTime.parse(bookJson['publicationDate'] as String)
                : null,
            pageCount: bookJson['pageCount'],
            coverAssetKey: bookJson['coverAssetKey'],
            isInWishlistParam: bookJson['isInWishlist'] ?? false,
            externalCatalogId: bookJson['externalCatalogId'],
            externalSourceUrl: bookJson['externalSourceUrl'],
            purchasePrice: bookJson['purchasePrice'] != null
                ? (bookJson['purchasePrice'] as num).toDouble()
                : null,
            purchaseCurrency: bookJson['purchaseCurrency'],
            isBorrowed: bookJson['isBorrowed'] ?? false,
            lenderName: bookJson['lenderName'],
            lenderContact: bookJson['lenderContact'],
            borrowDate: bookJson['borrowDate'] != null
                ? DateTime.parse(bookJson['borrowDate'] as String)
                : null,
            expectedReturnDate: bookJson['expectedReturnDate'] != null
                ? DateTime.parse(bookJson['expectedReturnDate'] as String)
                : null,
            isLent: bookJson['isLent'] ?? false,
            borrowerName: bookJson['borrowerName'],
            borrowerContact: bookJson['borrowerContact'],
            lendDate: bookJson['lendDate'] != null
                ? DateTime.parse(bookJson['lendDate'] as String)
                : null,
            expectedLendReturnDate: bookJson['expectedLendReturnDate'] != null
                ? DateTime.parse(bookJson['expectedLendReturnDate'] as String)
                : null,
            createdAtParam: bookJson['createdAt'] != null
                ? DateTime.parse(bookJson['createdAt'] as String)
                : DateTime.now(),
            updatedAtParam: bookJson['updatedAt'] != null
                ? DateTime.parse(bookJson['updatedAt'] as String)
                : DateTime.now(),
            archivedAt: bookJson['archivedAt'] != null
                ? DateTime.parse(bookJson['archivedAt'] as String)
                : null,
          );
          
          final id = await _repository.createBook(book, initialStatus: ReadingStatus.wantToRead);
          sourceToDestId[sourceId] = id;

          // Fix 3: Correct record matching - use source book ID from export to find matching destination record
          final recordJson = exportData.readingRecords
              .where((r) => r['bookId'] == sourceId)
              .firstOrNull;
          if (recordJson != null) {
            await _repository.updateReadingRecord(ReadingRecord(
              bookId: id,
              status: ReadingStatus.values.firstWhere(
                (status) => status.name == recordJson['status'],
                orElse: () => ReadingStatus.wantToRead,
              ),
              currentPage: recordJson['currentPage'],
              percentageOnlyProgress: recordJson['percentageOnlyProgress'],
              startDate: recordJson['startDate'] != null
                  ? DateTime.parse(recordJson['startDate'] as String)
                  : null,
              finishDate: recordJson['finishDate'] != null
                  ? DateTime.parse(recordJson['finishDate'] as String)
                  : null,
              lastReadDate: DateTime.parse(recordJson['lastReadDate'] as String),
              personalRating: recordJson['personalRating'],
              notes: recordJson['notes'],
            ));
          }
        }
      }

      // Fix 6: Cover failure visibility - check cover-storage results and report failures
      final failedCovers = <String>[];
      for (final entry in exportData.coversBase64.entries) {
        final key = entry.key;
        final bytes = base64Decode(entry.value);
        final success = await CoverImageService.storeImage(bytes, key: key);
        if (!success) {
          failedCovers.add(key);
        }
      }
      if (failedCovers.isNotEmpty) {
        throw StateError('Cover storage failed for keys: ${failedCovers.join(', ')}');
      }
    });
  }

  Future<void> importFromFile(File file) async {
    final bytes = await file.readAsBytes();
    await importArchive(bytes);
  }
}
