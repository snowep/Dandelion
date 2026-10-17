import 'dart:convert';

import 'package:dandelion/features/library/book.dart';
import 'package:dandelion/features/library/widgets/google_books_lookup_dialog.dart';
import 'package:dandelion/services/google_books_lookup_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:flutter/services.dart';

void main() {
  group('GoogleBooksLookupDialog', () {
    late GoogleBooksLookupService mockService;
    late MockClient mockClient;

    setUp(() {
      mockClient = MockClient((request) async {
        // Simulate network delay to see loading state
        await Future.delayed(const Duration(milliseconds: 500));
        if (request.url.path.contains('volumes') &&
            request.url.queryParameters['q'] == 'isbn:0306406152') {
          return http.Response(jsonEncode({
            'totalItems': 1,
            'items': [{
              'volumeInfo': {
                'title': 'Test Book',
                'authors': ['Test Author'],
                'description': 'A test description',
                'publisher': 'Test Publisher',
                'publishedDate': '2023-01-01',
                'pageCount': 200,
                'industryIdentifiers': [
                  {'type': 'ISBN_10', 'identifier': '0306406152'},
                  {'type': 'ISBN_13', 'identifier': '9780306406152'}
                ],
                'imageLinks': {
                  'thumbnail': 'http://books.google.com/books/content?id=TestBook&printsec=frontcover&img=1&zoom=1&edge=curl&imgtk=AFLRE73Y8B7aqm9uCI0nrO0EgImynm7Z5bQoRK6vLbKnownVjnSVFfgJ1ZgB0LAGC7f3olk2dmQ1&sig=ACfU3U0mFvsT6WsuFXKYww0Ed9g-BTvaDA'
                }
              }
            }]
          }), 200);
        } else if (request.url.path.contains('volumes') &&
            request.url.queryParameters['q'] == 'isbn:INVALID') {
          return http.Response(jsonEncode({'totalItems': 0}), 200);
        } else {
          return http.Response('Not Found', 404);
        }
      });
      mockService = GoogleBooksLookupService(httpClient: mockClient);
    });

    tearDown(() {
      mockClient.close();
      mockService.close();
    });

    testWidgets('displays loading state when searching', (WidgetTester tester) async {
      await tester.pumpWidget(MaterialApp(
        home: GoogleBooksLookupDialog(service: mockService),
      ));

      // Enter ISBN and submit
      await tester.enterText(find.byType(TextFormField), '0306406152');
      await tester.tap(find.byIcon(Icons.book)); // This triggers onFieldSubmitted
      await tester.pump(); // Process the tap
      await tester.pump(); // Process the setState and build

      // Should show loading indicator
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('displays result when book is found', (WidgetTester tester) async {
      await tester.pumpWidget(MaterialApp(
        home: GoogleBooksLookupDialog(service: mockService),
      ));

      // Enter ISBN and submit
      await tester.enterText(find.byType(TextFormField), '0306406152');
      await tester.tap(find.byIcon(Icons.book));
      await tester.pumpAndSettle();

      // Should show book details
      expect(find.text('Found: Test Book'), findsOneWidget);
      expect(find.text('by Test Author'), findsOneWidget);
      expect(find.text('A test description'), findsOneWidget);
      expect(find.text('ISBN-10: 0306406152'), findsOneWidget);
      expect(find.text('ISBN-13: 9780306406152'), findsOneWidget);
      
      // Should have "Use this book" button
      expect(find.text('Use this book'), findsOneWidget);
    });

    testWidgets('shows error when book not found', (WidgetTester tester) async {
      await tester.pumpWidget(MaterialApp(
        home: GoogleBooksLookupDialog(service: mockService),
      ));

      // Enter invalid ISBN and submit
      await tester.enterText(find.byType(TextFormField), 'INVALID');
      await tester.tap(find.byIcon(Icons.book));
      await tester.pump();

      // Should show error message
      expect(find.textContaining('Book not found for ISBN: INVALID'), findsOneWidget);
      expect(find.text('Cancel'), findsOneWidget);
    });

    testWidgets('validates ISBN input', (WidgetTester tester) async {
      await tester.pumpWidget(MaterialApp(
        home: GoogleBooksLookupDialog(service: mockService),
      ));

      // Enter invalid length ISBN
      await tester.enterText(find.byType(TextFormField), '123');
      await tester.tap(find.byIcon(Icons.book));
      await tester.pump();

      // Should show validation error
      expect(find.text('ISBN must be 10 or 13 digits'), findsOneWidget);
    });

    testWidgets('closes dialog when "Use this book" is pressed', (WidgetTester tester) async {
      await tester.pumpWidget(MaterialApp(
        home: GoogleBooksLookupDialog(service: mockService),
      ));

      // Enter valid ISBN and submit
      await tester.enterText(find.byType(TextFormField), '0306406152');
      await tester.tap(find.byIcon(Icons.book));
      await tester.pumpAndSettle();

      // Dialog should be visible
      expect(find.byType(GoogleBooksLookupDialog), findsOneWidget);

      // Tap "Use this book"
      await tester.tap(find.text('Use this book'));
      await tester.pumpAndSettle();

      // Dialog should be closed
      expect(find.byType(GoogleBooksLookupDialog), findsNothing);
    });
  });
}
