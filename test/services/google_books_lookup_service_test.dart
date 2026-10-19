import 'package:dandelion/services/google_books_lookup_service.dart';
import 'package:dandelion/features/library/book.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('GoogleBooksLookupService Mock Tests', () {
    test('ISBN lookup with success mock returns book', () async {
      final service = GoogleBooksLookupService(
        mockResponse: GoogleBooksMockResponse.success,
      );
      final book = await service.lookupByIsbn('9780134685991');
      expect(book, isNotNull);
      expect(book!.title, equals('Mock Google Book'));
      expect(book.authors, equals('Mock Author'));
    });

    test('ISBN lookup with not found mock returns null', () async {
      final service = GoogleBooksLookupService(
        mockResponse: GoogleBooksMockResponse.notFound,
      );
      final book = await service.lookupByIsbn('9780134685991');
      expect(book, isNull);
    });

    test('ISBN lookup with rate limit mock returns null', () async {
      final service = GoogleBooksLookupService(
        mockResponse: GoogleBooksMockResponse.rateLimit,
      );
      final book = await service.lookupByIsbn('9780134685991');
      expect(book, isNull);
    });

    test('ISBN lookup with malformed mock returns null', () async {
      final service = GoogleBooksLookupService(
        mockResponse: GoogleBooksMockResponse.malformed,
      );
      final book = await service.lookupByIsbn('9780134685991');
      expect(book, isNull);
    });

    test('ISBN lookup with timeout mock returns null', () async {
      final service = GoogleBooksLookupService(
        mockResponse: GoogleBooksMockResponse.timeout,
      );
      final book = await service.lookupByIsbn('9780134685991');
      expect(book, isNull);
    });

    test('ISBN lookup with missing cover returns book without cover', () async {
      final service = GoogleBooksLookupService(
        mockResponse: GoogleBooksMockResponse.missingCover,
      );
      final book = await service.lookupByIsbn('9780134685991');
      expect(book, isNotNull);
      expect(book!.title, equals('Mock Book No Cover'));
      expect(book.thumbnailUrl, isNull);
    });

    test('Search with success mock returns results', () async {
      final mockBook = Book(
        id: 0,
        title: 'Test Book',
        authors: 'Test Author',
        externalCatalogId: 'test-123',
      );
      final service = GoogleBooksLookupService(
        mockResponse: GoogleBooksMockResponse.success,
        mockSearchResults: [mockBook],
      );
      final results = await service.searchByTitleOrAuthor('test query');
      expect(results, isNotEmpty);
      expect(results.length, equals(1));
      expect(results[0].title, equals('Test Book'));
    });

    test('Search with not found returns empty list', () async {
      final service = GoogleBooksLookupService(
        mockResponse: GoogleBooksMockResponse.notFound,
      );
      final results = await service.searchByTitleOrAuthor('test query');
      expect(results, isEmpty);
    });

    test('Empty ISBN returns null', () async {
      final service = GoogleBooksLookupService();
      final book = await service.lookupByIsbn('');
      expect(book, isNull);
    });

    test('Invalid ISBN length returns null', () async {
      final service = GoogleBooksLookupService();
      final book = await service.lookupByIsbn('12345');
      expect(book, isNull);
    });
  });
}
