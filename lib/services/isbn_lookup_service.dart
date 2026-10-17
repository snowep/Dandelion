import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:dandelion/features/library/book.dart';

/// Service for looking up book metadata by ISBN using external catalogs.
class IsbnLookupService {
  final String _baseUrl = 'https://openlibrary.org';
  final http.Client _httpClient;

  IsbnLookupService({http.Client? httpClient})
      : _httpClient = httpClient ?? http.Client();

  /// Looks up book metadata by ISBN-10 or ISBN-13.
  ///
  /// Returns a [Book] object with populated metadata if found,
  /// or null if not found or an error occurs.
  Future<Book?> lookupByIsbn(String isbn) async {
    if (isbn.isEmpty) return null;

    // Normalize ISBN (remove hyphens, spaces)
    final normalizedIsbn =
        isbn.replaceAll(RegExp(r'[^0-9Xx]'), '').toUpperCase();

    // Validate ISBN length
    if (normalizedIsbn.length != 10 && normalizedIsbn.length != 13) {
      return null;
    }

    try {
      final uri = Uri.parse('$_baseUrl/isbn/$normalizedIsbn.json');
      final response = await _httpClient.get(uri);

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        return _parseBookFromJson(jsonData, normalizedIsbn);
      } else if (response.statusCode == 404) {
        // ISBN not found
        return null;
      } else {
        // Other HTTP error
        return null;
      }
    } on http.ClientException catch (_) {
      // Network error
      return null;
    } on FormatException catch (_) {
      // JSON parsing error
      return null;
    } catch (_) {
      // Other unexpected error
      return null;
    }
  }

  /// Searches for books by title or author.
  ///
  /// Returns a list of [Book] objects matching the query.
  Future<List<Book>> searchByTitleOrAuthor(String query,
      {int limit = 10}) async {
    if (query.isEmpty) return [];

    try {
      final uri = Uri.parse(
          '$_baseUrl/search.json?q=${Uri.encodeComponent(query)}&limit=$limit');
      final response = await _httpClient.get(uri);

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        final List<dynamic> docs = jsonData['docs'] ?? [];
        return docs
            .take(limit)
            .map((doc) => _parseBookFromSearchJson(doc))
            .whereType<Book>()
            .toList();
      } else {
        return [];
      }
    } on http.ClientException catch (_) {
      return [];
    } on FormatException catch (_) {
      return [];
    } catch (_) {
      return [];
    }
  }

  Book _parseBookFromJson(Map<String, dynamic> json, String isbn) {
    final title = json['title'] ?? 'Unknown Title';
    final authors = json['authors'] != null
        ? (json['authors'] as List)
            .map((author) => author['name'] as String? ?? 'Unknown Author')
            .toList()
            .join(', ')
        : 'Unknown Author';
    final description = json['description'];
    final String? descriptionStr;
    if (description is String) {
      descriptionStr = description;
    } else if (description is Map && description['value'] is String) {
      descriptionStr = description['value'] as String;
    } else {
      descriptionStr = null;
    }
    final publishDate = json['publish_date'];
    final int? pageCount = json['number_of_pages'];
    final String? isbn10 =
        json['isbn_10'] != null && (json['isbn_10'] as List).isNotEmpty
            ? (json['isbn_10'] as List)[0]
            : null;
    final String? isbn13 =
        json['isbn_13'] != null && (json['isbn_13'] as List).isNotEmpty
            ? (json['isbn_13'] as List)[0]
            : null;

    return Book(
      id: 0, // Will be set when saved to database
      title: title.toString(),
      authors: authors,
      description: descriptionStr,
      // genres: Not available from basic ISBN lookup, would need additional call
      isbn10: isbn10,
      isbn13: isbn13,
      publisher: json['publishers'] != null && (json['publishers'] as List).isNotEmpty
          ? (json['publishers'] as List)[0]['name'] as String?
          : null,
      publicationDate: _parseDate(publishDate),
      pageCount: pageCount,
      // coverAssetKey: Would need to fetch cover image separately
      externalCatalogId: isbn, // Using ISBN as external ID for now
      externalSourceUrl: '$_baseUrl/isbn/$isbn',
    );
  }

  Book _parseBookFromSearchJson(Map<String, dynamic> json) {
    final title = json['title'] ?? 'Unknown Title';
    final authors = json['author_name'] != null
        ? (json['author_name'] as List)
            .map((author) => author.toString())
            .join(', ')
        : 'Unknown Author';
    final String? isbn10 =
        json['isbn'] != null && (json['isbn'] as List).isNotEmpty
            ? (json['isbn'] as List)
                .firstWhere((isbn) => isbn.toString().length == 10,
                    orElse: () => '')
                .toString()
            : null;
    final String? isbn13 =
        json['isbn'] != null && (json['isbn'] as List).isNotEmpty
            ? (json['isbn'] as List)
                .firstWhere((isbn) => isbn.toString().length == 13,
                    orElse: () => '')
                .toString()
            : null;

    return Book(
      id: 0,
      title: title.toString(),
      authors: authors,
      // description: Not always available in search results
      isbn10: isbn10,
      isbn13: isbn13,
      // Other fields would need additional lookup
    );
  }

  DateTime? _parseDate(String? dateString) {
    if (dateString == null || dateString.isEmpty) return null;
    try {
      // Try parsing various date formats
      final cleaned = dateString.trim();
      if (cleaned.length == 4 && RegExp(r'^\d{4}$').hasMatch(cleaned)) {
        // Just a year
        return DateTime(int.parse(cleaned));
      }
      // Try parsing as YYYY-MM-DD
      return DateTime.parse(cleaned);
    } catch (_) {
      return null;
    }
  }

  void close() {
    _httpClient.close();
  }
}