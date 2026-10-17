import 'dart:convert';

import 'package:dandelion/services/google_books_lookup_service.dart';
import 'package:dandelion/features/library/book.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('GoogleBooksLookupService', () {
    late GoogleBooksLookupService service;
    late MockClient mockClient;

    setUp(() {
      mockClient = MockClient((request) async {
        if (request.url.path.contains('volumes') &&
            request.url.queryParameters['q'] == 'isbn:0306406152') {
          return http.Response(json.encode({
            'totalItems': 1,
            'items': [{
              'volumeInfo': {
                'title': 'The Watchmen',
                'authors': ['Alan Moore'],
                'description': 'A groundbreaking graphic novel',
                'publisher': 'DC Comics',
                'publishedDate': '1986-09-01',
                'pageCount': 416,
                'industryIdentifiers': [
                  {'type': 'ISBN_10', 'identifier': '0930289234'},
                  {'type': 'ISBN_13', 'identifier': '9780930289232'}
                ],
                'imageLinks': {
                  'thumbnail': 'http://books.google.com/books/content?id=Watchmen&printsec=frontcover&img=1&zoom=1&edge=curl&imgtk=AFLRE73Y8B7aqm9uCI0nrO0EgImynm7Z5bQoRK6vLbKnownVjnSVFfgJ1ZgB0LAGC7f3olk2dmQ1&sig=ACfU3U0mFvsT6WsuFXKYww0Ed9g-BTvaDA'
                }
              }
            }]
          }), 200);
        } else if (request.url.path.contains('volumes') &&
            request.url.queryParameters['q'] == 'isbn:INVALID') {
          return http.Response(json.encode({'totalItems': 0}), 200);
        } else {
          return http.Response('Not Found', 404);
        }
      });
      service = GoogleBooksLookupService(httpClient: mockClient);
    });

    tearDown(() {
      mockClient.close();
      service.close();
    });

    test('returns book data for valid ISBN', () async {
      final book = await service.lookupByIsbn('0-306-40615-2');
      expect(book, isNotNull);
      expect(book?.title, 'The Watchmen');
      expect(book?.authors, 'Alan Moore');
      expect(book?.isbn10, '0930289234');
      expect(book?.isbn13, '9780930289232');
      expect(book?.description, 'A groundbreaking graphic novel');
      expect(book?.pageCount, 416);
    });

    test('returns null for invalid ISBN', () async {
      final book = await service.lookupByIsbn('INVALID');
      expect(book, isNull);
    });

    test('returns null for empty ISBN', () async {
      final book = await service.lookupByIsbn('');
      expect(book, isNull);
    });

    test('normalizes ISBN by removing hyphens', () async {
      final book1 = await service.lookupByIsbn('0-306-40615-2');
      final book2 = await service.lookupByIsbn('0306406152');
      expect(book1?.title, book2?.title);
      expect(book1?.isbn10, book2?.isbn10);
    });

    test('caches results', () async {
      // First call
      final book1 = await service.lookupByIsbn('0306406152');
      expect(book1, isNotNull);
      
      // Second call should use cache
      final book2 = await service.lookupByIsbn('0306406152');
      expect(book2, isNotNull);
      expect(book1?.title, book2?.title);
    });
  });
}