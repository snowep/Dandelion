import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:archive/archive.dart';
import 'package:drift/drift.dart';
import 'package:path_provider/path_provider.dart';

import 'package:dandelion/features/library/book.dart';
import 'package:dandelion/features/library/book_database.dart';
import 'package:dandelion/features/library/book_repository.dart';
import 'package:dandelion/features/library/reading_record.dart';
import 'package:dandelion/shared/services/cover_image_service.dart';
import 'package:dandelion/services/library_export_service.dart';

class LibraryImportExportService {
  final BookRepository _repository;
  final AppDatabase _database;
  final CoverImageService _coverImageService;

  LibraryImportExportService(
    this._repository,
    this._database,
    this._coverImageService,
  );

  /// Exports the entire library to a ZIP archive in memory.
  /// The ZIP contains a single file: library.json with the export data.
  Future<List<int>> exportLibrary() async {
    // Get all books and reading records
    final books = await _repository.getAll();
    final readingRecords = await _repository.listReadingRecords();

    // Prepare covers map: coverAssetKey -> base64 string
    final coversBase64 = <String, String>{};
    for (final book in books) {
      if (book.coverAssetKey != null) {
        final bytes = await CoverImageService.loadImage(book.coverAssetKey!);
        if (bytes != null) {
          coversBase64[book.coverAssetKey!] = base64Encode(bytes);
        }
      }
    }

    // Build export data
    final exportData = ExportData(
      schemaVersion: 1,
      exportDate: DateTime.now(),
      books: books.map((e) => _bookToMap(e)).toList(),
      readingRecords: readingRecords.map((e) => _readingRecordToMap(e)).toList(),
      coversBase64: coversBase64,
    );

    // Convert to JSON
    final jsonString = jsonEncode(exportData.toJson());

    // Create ZIP archive in memory
    final archive = Archive();
    archive.addFile(ArchiveFile('library.json', jsonString.length,
        jsonString.codeUnits));
    final zipData = ZipEncoder().encode(archive);

    return zipData;
  }

  /// Imports the library from a ZIP archive.
  /// [zipBytes] is the ZIP archive bytes.
  /// [clearExisting] must be true to proceed; otherwise, throws an exception.
  /// This function deletes all existing books and reading records before importing.
  Future<void> importLibrary(List<int> zipBytes, {required bool clearExisting}) async {
    if (!clearExisting) {
      throw ArgumentError(
          'Import requires clearExisting to be true to prevent accidental data loss.');
    }

    // Extract the ZIP archive
    final archive = ZipDecoder().decodeBytes(zipBytes);
    final libraryFile = archive.where((f) => f.name == 'library.json').first;
    if (libraryFile == null) {
      throw FormatException('ZIP archive does not contain library.json');
    }
    final jsonString = String.fromCharCodes(libraryFile.content);
    final jsonMap = jsonDecode(jsonString) as Map<String, dynamic>;

    // Validate and parse export data
    final exportData = ExportData.fromJson(jsonMap);
    if (exportData.schemaVersion != 1) {
      throw UnsupportedError(
          'Unsupported schema version: ${exportData.schemaVersion}');
    }

    // Delete all existing data
    await _database.deleteAllBooks();
    await _database.deleteAllReadingRecords();

    // TODO: Optionally delete orphaned cover image files? Not implemented for now.

    // Import books
    final bookIdMap = <int, int>{}; // exported id -> new id
    for (final bookMap in exportData.books) {
      final book = _bookFromMap(bookMap);
      // Insert book with the exported id if possible, otherwise let DB generate.
      // We try to insert with the exported id.
      final id = await _database.into(_database.books).insert(
        BooksCompanion(
          id: book.id > 0 ? Value(book.id) : Value.absent(),
          title: Value(book.title.trim()),
          author: Value(_optional(book.authors)),
          description: Value(_optional(book.description)),
          genres: Value(_optional(book.genres)),
          isbn: Value(book.isbn13 ?? book.isbn10),
          normalizedIsbn: Value(_normalizeIsbn(book.isbn13 ?? book.isbn10)),
          publisher: Value(_optional(book.publisher)),
          publicationDate: Value(book.publicationDate),
          publishedYear: Value(book.publicationDate?.year),
          pageCount: Value(book.pageCount),
          coverAssetKey: Value(book.coverAssetKey),
          isInWishlist: Value(book.isInWishlist),
          externalCatalogId: Value(book.externalCatalogId),
          externalSourceUrl: Value(book.externalSourceUrl),
          createdAt: Value(book.createdAt),
          updatedAt: Value(book.updatedAt),
          archivedAt: Value(book.archivedAt),
        ),
      );
      bookIdMap[book.id] = id;
    }

    // Import reading records
    for (final recordMap in exportData.readingRecords) {
      final record = _readingRecordFromMap(recordMap);
      final bookId = record.bookId;
      final newBookId = bookIdMap[bookId];
      if (newBookId == null) {
        throw StateError(
            'Book ID $bookId not found in imported books (possible data corruption)');
      }
      await _database.into(_database.readingRecords).insert(
        ReadingRecordsCompanion.insert(
          bookId: newBookId,
                    status: Value(record.status.name),
                    currentPage: Value(record.currentPage),
                    progressPercent: Value(
                        record.percentageOnlyProgress == null
                            ? null
                            : (record.percentageOnlyProgress! * 100).round()),
                    startDate: Value(record.startDate),
                    finishDate: Value(record.finishDate),
                    lastReadDate: Value(record.lastReadDate),
                    personalRating: Value(record.personalRating),
                    notes: Value(record.notes),
                  ),
      );
    }

    // Import cover images: we already have the coversBase64 map from exportData.
    // For each cover, store the image using the original key.
    for (final entry in exportData.coversBase64.entries) {
      final key = entry.key;
      final bytes = base64Decode(entry.value);
      await CoverImageService.storeImage(bytes, key: key);
    }
  }

  Book _bookFromMap(Map<String, dynamic> map) {
    return Book(
      id: map['id'] as int,
      title: map['title'] as String,
      authors: map['authors'] as String,
      description: map['description'],
      genres: map['genres'],
      isbn10: map['isbn10'],
      isbn13: map['isbn13'],
      publisher: map['publisher'],
      publicationDate: map['publicationDate'] != null
          ? DateTime.parse(map['publicationDate'])
          : null,
      pageCount: map['pageCount'],
      coverAssetKey: map['coverAssetKey'],
      isInWishlist: map['isInWishlist'] as bool,
      externalCatalogId: map['externalCatalogId'],
      externalSourceUrl: map['externalSourceUrl'],
      createdAt: map['createdAt'] != null
          ? DateTime.parse(map['createdAt'])
          : DateTime.now(),
      updatedAt: map['updatedAt'] != null
          ? DateTime.parse(map['updatedAt'])
          : DateTime.now(),
      archivedAt: map['archivedAt'] != null
          ? DateTime.parse(map['archivedAt'])
          : null,
    );
  }

  Map<String, dynamic> _bookToMap(Book book) {
    return {
      'id': book.id,
      'title': book.title,
      'authors': book.authors,
      'description': book.description,
      'genres': book.genres,
      'isbn10': book.isbn10,
      'isbn13': book.isbn13,
      'publisher': book.publisher,
      'publicationDate': book.publicationDate?.toIso8601String(),
      'pageCount': book.pageCount,
      'coverAssetKey': book.coverAssetKey,
      'isInWishlist': book.isInWishlist,
      'externalCatalogId': book.externalCatalogId,
      'externalSourceUrl': book.externalSourceUrl,
      'createdAt': book.createdAt.toIso8601String(),
      'updatedAt': book.updatedAt.toIso8601String(),
      'archivedAt': book.archivedAt?.toIso8601String(),
    };
  }

  ReadingRecord _readingRecordFromMap(Map<String, dynamic> map) {
    return ReadingRecord(
      id: map['id'] as int,
      bookId: map['bookId'] as int,
      status: ReadingStatus.values.firstWhere(
        (e) => e.name == map['status'],
        orElse: () => ReadingStatus.wantToRead,
      ),
      currentPage: map['currentPage'],
      percentageOnlyProgress: map['progressPercent'] != null
          ? map['progressPercent'] / 100
          : null,
      startDate: map['startDate'] != null
          ? DateTime.parse(map['startDate'])
          : null,
      finishDate: map['finishDate'] != null
          ? DateTime.parse(map['finishDate'])
          : null,
      lastReadDate: map['lastReadDate'] != null
          ? DateTime.parse(map['lastReadDate'])
          : null,
      personalRating: map['personalRating'],
      notes: map['notes'],
    );
  }

  Map<String, dynamic> _readingRecordToMap(ReadingRecord record) {
    return {
      'id': record.id,
      'bookId': record.bookId,
      'status': record.status.name,
      'currentPage': record.currentPage,
      'progressPercent':
          record.percentageOnlyProgress != null
              ? (record.percentageOnlyProgress! * 100).round()
              : null,
      'startDate': record.startDate?.toIso8601String(),
      'finishDate': record.finishDate?.toIso8601String(),
      'lastReadDate': record.lastReadDate?.toIso8601String(),
      'personalRating': record.personalRating,
      'notes': record.notes,
    };
  }

  String? _optional(String? value) =>
      value == null || value.trim().isEmpty ? null : value.trim();

  String? _normalizeIsbn(String? isbn) {
    final normalized = isbn?.replaceAll(RegExp('[^0-9Xx]'), '').toUpperCase();
    return normalized == null || normalized.isEmpty ? null : normalized;
  }
}