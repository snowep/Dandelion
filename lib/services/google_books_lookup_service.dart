import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:dandelion/features/library/book.dart';

/// Mock response types for testing
enum GoogleBooksMockResponse {
  success,
  notFound,
  rateLimit,
  malformed,
  missingCover,
  timeout,
}

/// Service for looking up book metadata using Google Books API.
class GoogleBooksLookupService {
  final String _baseUrl = 'https://www.googleapis.com/books/v1/volumes';
  final http.Client _httpClient;
  final GoogleBooksMockResponse? _mockResponse;
  final Book? _mockBook;
  final List<Book>? _mockSearchResults;

  // Cache for ISBN lookups
  static final Map<String, Book?> _isbnCache = {};
  static final Map<String, DateTime> _isbnCacheTimestamps = {};
  // Cache for search results
  static final Map<String, List<Book>> _searchCache = {};
  static final Map<String, DateTime> _searchCacheTimestamps = {};
  static const Duration _cacheDuration = Duration(hours: 1);

  GoogleBooksLookupService({
    http.Client? httpClient,
    GoogleBooksMockResponse? mockResponse,
    Book? mockBook,
    List<Book>? mockSearchResults,
  }) : _httpClient = httpClient ?? http.Client(),
       _mockResponse = mockResponse,
       _mockBook = mockBook,
       _mockSearchResults = mockSearchResults;

  /// Looks up book metadata by ISBN-10 or ISBN-13.
  ///
  /// Returns a [Book] object with populated metadata if found,
  /// or null if not found or an error occurs.
  Future<Book?> lookupByIsbn(String isbn) async {
    if (isbn.isEmpty) return null;

    // Normalize ISBN (remove hyphens, spaces)
    final normalizedIsbn = isbn
        .replaceAll(RegExp(r'[^0-9Xx]'), '')
        .toUpperCase();

    // Validate ISBN length
    if (normalizedIsbn.length != 10 && normalizedIsbn.length != 13) {
      return null;
    }

    // Handle mock responses for testing
    if (_mockResponse != null) {
      return _handleMockIsbnResponse(normalizedIsbn);
    }

    final now = DateTime.now();
    // Check cache
    if (_isbnCache.containsKey(normalizedIsbn)) {
      final timestamp = _isbnCacheTimestamps[normalizedIsbn]!;
      if (now.difference(timestamp) < _cacheDuration) {
        return _isbnCache[normalizedIsbn];
      }
    }

    try {
      final uri = Uri.parse('$_baseUrl?q=isbn:$normalizedIsbn&maxResults=1');
      final response = await _httpClient
          .get(uri)
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        final totalItems = jsonData['totalItems'] ?? 0;
        if (totalItems > 0) {
          final items = jsonData['items'] as List;
          final volumeInfo = items[0]['volumeInfo'];
          final book = _parseBookFromVolumeInfo(volumeInfo, normalizedIsbn);
          // Update cache
          _isbnCache[normalizedIsbn] = book;
          _isbnCacheTimestamps[normalizedIsbn] = now;
          return book;
        }
      }
      // If not found or error, return null
      return null;
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

  Book? _handleMockIsbnResponse(String normalizedIsbn) {
    switch (_mockResponse!) {
      case GoogleBooksMockResponse.success:
        return _mockBook ??
            Book(
              id: 0,
              title: 'Mock Google Book',
              authors: 'Mock Author',
              description: 'Mock Google description',
              isbn10: normalizedIsbn.length == 10 ? normalizedIsbn : null,
              isbn13: normalizedIsbn.length == 13 ? normalizedIsbn : null,
              publisher: 'Mock Publisher',
              publicationDate: DateTime(2021),
              pageCount: 350,
              genres: 'Fiction',
              thumbnailUrl: 'https://example.com/cover.jpg',
              externalCatalogId: normalizedIsbn,
              externalSourceUrl: '$_baseUrl?q=isbn:$normalizedIsbn',
            );
      case GoogleBooksMockResponse.notFound:
        return null;
      case GoogleBooksMockResponse.rateLimit:
        return null;
      case GoogleBooksMockResponse.malformed:
        return null;
      case GoogleBooksMockResponse.missingCover:
        return _mockBook ??
            Book(
              id: 0,
              title: 'Mock Book No Cover',
              authors: 'Mock Author',
              isbn10: normalizedIsbn.length == 10 ? normalizedIsbn : null,
              isbn13: normalizedIsbn.length == 13 ? normalizedIsbn : null,
              externalCatalogId: normalizedIsbn,
            );
      case GoogleBooksMockResponse.timeout:
        return null;
    }
  }

  /// Searches for books by title or author.
  ///
  /// Returns a list of [Book] objects matching the query.
  Future<List<Book>> searchByTitleOrAuthor(
    String query, {
    int limit = 10,
  }) async {
    if (query.isEmpty) return [];

    // Handle mock responses for testing
    if (_mockResponse != null) {
      if (_mockResponse == GoogleBooksMockResponse.success) {
        return _mockSearchResults ??
            [
              Book(
                id: 0,
                title: 'Mock Search Result: $query',
                authors: 'Mock Author',
                description: 'Mock search description',
                genres: 'Fiction',
                externalCatalogId: 'mock-123',
                externalSourceUrl: 'https://example.com/mock-123',
              ),
            ];
      }
      return [];
    }

    final cacheKey = '$query-$limit';
    final now = DateTime.now();
    // Check cache
    if (_searchCache.containsKey(cacheKey)) {
      final timestamp = _searchCacheTimestamps[cacheKey]!;
      if (now.difference(timestamp) < _cacheDuration) {
        return _searchCache[cacheKey]!;
      }
    }

    try {
      final uri = Uri.parse(
        '$_baseUrl?q=${Uri.encodeComponent(query)}&maxResults=$limit',
      );
      final response = await _httpClient
          .get(uri)
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        final items = jsonData['items'] as List?;
        if (items == null) return [];
        final result = items
            .take(limit)
            .map((item) => item['volumeInfo'] as Map<String, dynamic>?)
            .whereType<Map<String, dynamic>>()
            .map((info) => _parseBookFromVolumeInfo(info, ''))
            .whereType<Book>()
            .toList();
        // Update cache
        _searchCache[cacheKey] = result;
        _searchCacheTimestamps[cacheKey] = now;
        return result;
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

  Book _parseBookFromVolumeInfo(Map<String, dynamic> volumeInfo, String isbn) {
    final title = volumeInfo['title'] ?? 'Unknown Title';
    final authorsList = volumeInfo['authors'] as List<dynamic>?;
    final authors = authorsList != null && authorsList.isNotEmpty
        ? authorsList.join(', ')
        : 'Unknown Author';
    final description = volumeInfo['description'] as String?;
    final publisher = volumeInfo['publisher'] as String?;
    final publishedDate = volumeInfo['publishedDate'] as String?;
    final pageCount = volumeInfo['pageCount'] as int?;
    final categories = volumeInfo['categories'] as List<dynamic>?;

    // Industry identifiers
    final identifiers = volumeInfo['industryIdentifiers'] as List<dynamic>?;
    String? isbn10;
    String? isbn13;
    if (identifiers != null) {
      for (final id in identifiers) {
        final type = id['type'] as String?;
        final value = id['identifier'] as String?;
        if (type == 'ISBN_10' && value != null) {
          isbn10 = value;
        } else if (type == 'ISBN_13' && value != null) {
          isbn13 = value;
        }
      }
    }
    // If ISBN not found in identifiers, use the provided one (from lookupByIsbn)
    if (isbn10 == null && isbn13 == null && isbn.isNotEmpty) {
      if (isbn.length == 10) {
        isbn10 = isbn;
      } else if (isbn.length == 13) {
        isbn13 = isbn;
      }
    }

    // Extract genres from categories
    final genres = categories != null && categories.isNotEmpty
        ? categories.map((e) => e.toString()).join(', ')
        : null;

    // Image links
    final imageLinks = volumeInfo['imageLinks'] as Map<String, dynamic>?;
    final thumbnailUrl = imageLinks?['thumbnail'] as String?;

    // Remove unused variables: printType, maturityRating, allowAnonLogging, contentVersion, smallThumbnailUrl

    return Book(
      id: 0, // Will be set when saved to database
      title: title.toString(),
      authors: authors,
      description: description,
      publisher: publisher,
      publicationDate: _parseDate(publishedDate),
      pageCount: pageCount,
      // We don't store coverAssetKey here; that's handled by cover service
      isbn10: isbn10,
      isbn13: isbn13,
      genres: genres,
      externalCatalogId: isbn10 ?? isbn13 ?? isbn,
      externalSourceUrl: volumeInfo['infoLink'] as String?,
      thumbnailUrl: thumbnailUrl,
    );
  }

  DateTime? _parseDate(String? dateString) {
    if (dateString == null || dateString.isEmpty) return null;
    try {
      // Google Books API dates can be: YYYY, YYYY-MM, YYYY-MM-DD
      final cleaned = dateString.trim();
      if (cleaned.length == 4 && RegExp(r'^\\d{4}$').hasMatch(cleaned)) {
        // Just a year
        return DateTime(int.parse(cleaned));
      }
      if (cleaned.length == 7 && RegExp(r'^\\d{4}-\\d{2}$').hasMatch(cleaned)) {
        // Year-month
        final parts = cleaned.split('-');
        return DateTime(int.parse(parts[0]), int.parse(parts[1]));
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
