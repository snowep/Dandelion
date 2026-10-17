import 'dart:convert';
import 'dart:io';

import 'package:archive/archive.dart';
import 'package:path_provider/path_provider.dart';

import '../features/library/book.dart';
import '../features/library/book_database.dart';
import '../features/library/book_repository.dart';
import '../features/library/reading_record.dart';
import '../shared/services/cover_image_service.dart';

const int _schemaVersion = 1;

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
        'covers': coversBase64,
      };

  static ExportData fromJson(Map<String, dynamic> json) {
    final covers = (json['covers'] as Map?)?.cast<String, dynamic>() ?? {};
    final coversBase64 = covers.map((k, v) => MapEntry(k, v as String));
    return ExportData(
      schemaVersion: json['schemaVersion'] as int,
      exportDate: DateTime.parse(json['exportDate'] as String),
      books: (json['books'] as List).cast<Map<String, dynamic>>(),
      readingRecords: (json['readingRecords'] as List).cast<Map<String, dynamic>>(),
      coversBase64: coversBase64,
    );
  }
}

class ExportService {
  final BookRepository _repository;

  ExportService(this._repository);

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

  Future<File> exportToZipFile() async {
    final bytes = await exportLibrary();
    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/dandelion_export.zip');
    await file.writeAsBytes(bytes);
    return file;
  }
}