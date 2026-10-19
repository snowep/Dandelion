import 'package:dandelion/services/isbn_lookup_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('IsbnLookupService Mock Tests', () {
    test('ISBN lookup with success mock returns book', () async {
      final service = IsbnLookupService(
        mockResponse: IsbnLookupMockResponse.success,
      );
      final book = await service.lookupByIsbn('9780134685991');
      expect(book, isNotNull);
      expect(book!.title, equals('Mock Book Title'));
      expect(book.authors, equals('Mock Author'));
    });

    test('ISBN lookup with not found mock returns null', () async {
      final service = IsbnLookupService(
        mockResponse: IsbnLookupMockResponse.notFound,
      );
      final book = await service.lookupByIsbn('9780134685991');
      expect(book, isNull);
    });

    test('ISBN lookup with rate limit mock returns null', () async {
      final service = IsbnLookupService(
        mockResponse: IsbnLookupMockResponse.rateLimit,
      );
      final book = await service.lookupByIsbn('9780134685991');
      expect(book, isNull);
    });

    test('ISBN lookup with malformed mock returns null', () async {
      final service = IsbnLookupService(
        mockResponse: IsbnLookupMockResponse.malformed,
      );
      final book = await service.lookupByIsbn('9780134685991');
      expect(book, isNull);
    });

    test('ISBN lookup with timeout mock returns null', () async {
      final service = IsbnLookupService(
        mockResponse: IsbnLookupMockResponse.timeout,
      );
      final book = await service.lookupByIsbn('9780134685991');
      expect(book, isNull);
    });

    test('ISBN lookup with missing cover returns book without cover', () async {
      final service = IsbnLookupService(
        mockResponse: IsbnLookupMockResponse.missingCover,
      );
      final book = await service.lookupByIsbn('9780134685991');
      expect(book, isNotNull);
      expect(book!.title, equals('Mock Book No Cover'));
    });

    test('Empty ISBN returns null', () async {
      final service = IsbnLookupService();
      final book = await service.lookupByIsbn('');
      expect(book, isNull);
    });

    test('Invalid ISBN length returns null', () async {
      final service = IsbnLookupService();
      final book = await service.lookupByIsbn('12345');
      expect(book, isNull);
    });
  });
}
