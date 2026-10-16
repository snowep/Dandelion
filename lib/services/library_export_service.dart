import 'dart:convert';
import 'dart:io';

import 'package:archive/archive.dart';
import 'package:path_provider/path_provider.dart';

import '../features/library/book.dart';
import '../features/library/book_database.dart';
import '../features/library/book_repository.dart';
import '../features/library/reading_record.dart';

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
