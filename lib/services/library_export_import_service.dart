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
    if (zipData != null) {
      await file.writeAsBytes(zipData);
    }
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

    for (final b in booksList) {
      if ((b as Map)['title'] == null ||
          (b['title'] as String).trim().isEmpty) {
        conflicts.add(
          BookConflict(title: 'Untitled', type: ConflictType.missingRequired),
        );
        errors.add('Book missing required title');
      }
    }

    final existingBooks = await _repository.getAll();
    final existingIsbns = existingBooks
        .map(
          (b) => (b.isbn13 ?? b.isbn10) != null
              ? _normalizeIsbn(b.isbn13 ?? b.isbn10)
              : null,
        )
        .whereType<String>()
        .toSet();

    for (final b in booksList) {
      final m = b as Map;
      final isbn = _normalizeIsbn(
        (m['isbn13'] as String?) ?? (m['isbn10'] as String?),
      );
      final title = (m['title'] as String?) ?? '';
      if (isbn != null && existingIsbns.contains(isbn)) {
        conflicts.add(
          BookConflict(
            title: title,
            existingIsbn: isbn,
            importIsbn: isbn,
            type: ConflictType.duplicateIsbn,
          ),
        );
        warnings.add('Duplicate ISBN detected for "$title" ($isbn)');
      }
    }

    return ImportPreview(
      isValid: errors.isEmpty,
      schemaVersion: schemaVersion,
      exportDate: exportDate,
      booksCount: booksList.length,
      readingRecordsCount: recordsList.length,
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

    for (final bookJson in exportData.books) {
      final book = Book(
        id: bookJson['id'],
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

      final normalizedIsbn = _normalizeIsbn(book.isbn13 ?? book.isbn10);
      final hasIsbn = normalizedIsbn != null && normalizedIsbn.isNotEmpty;

      Book? existingBook;
      if (hasIsbn) {
        existingBook = await _repository.getBookByIsbn(normalizedIsbn);
      }

      Book? titleMatch;
      if (existingBook == null) {
        final books = await _repository.listBooks(
          filters: {'title': book.title, 'authors': book.authors},
        );
        titleMatch = books.isNotEmpty ? books.first : null;
      }

      final shouldSkip =
          skipConflicts && (existingBook != null || titleMatch != null);
      final shouldOverwrite =
          overwrite && (existingBook != null || titleMatch != null);

      if (shouldSkip && !shouldOverwrite) {
        continue;
      }

      if (existingBook != null && shouldOverwrite) {
        await _repository.updateBook(
          book.copyWith(id: existingBook.id, updatedAt: DateTime.now()),
        );
      } else if (titleMatch != null && shouldOverwrite) {
        await _repository.updateBook(
          titleMatch.copyWith(
            title: book.title,
            authors: book.authors,
            description: book.description,
            genres: book.genres,
            isbn10: book.isbn10,
            isbn13: book.isbn13,
            publisher: book.publisher,
            publicationDate: book.publicationDate,
            pageCount: book.pageCount,
            coverAssetKey: book.coverAssetKey,
            isInWishlist: book.isInWishlist,
            externalCatalogId: book.externalCatalogId,
            externalSourceUrl: book.externalSourceUrl,
            createdAt: book.createdAt,
            updatedAt: DateTime.now(),
            archivedAt: book.archivedAt,
          ),
        );
      } else {
        final id = await _repository.createBook(
          book,
          initialStatus: ReadingStatus.wantToRead,
        );

        final recordJson = exportData.readingRecords
            .where((r) => r['bookId'] == book.id)
            .firstOrNull;

        if (recordJson != null) {
          final readingRecord = ReadingRecord(
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
          );

          await _repository.createReadingRecord(readingRecord);
        }
      }
    }

    for (final entry in exportData.coversBase64.entries) {
      final key = entry.key;
      final bytes = base64Decode(entry.value);
      await CoverImageService.storeImage(bytes, key: key);
    }
  }

  Future<void> importFromFile(File file) async {
    final bytes = await file.readAsBytes();
    await importArchive(bytes);
  }
}
