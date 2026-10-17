import 'package:dandelion/services/isbn_lookup_service.dart';

void main() async {
  final service = IsbnLookupService();
  try {
    // Try with a known ISBN-13 for a popular book
    final result = await service.lookupByIsbn('9780132350884'); // Clean Code
    if (result != null) {
      print('Found book: ${result.title} by ${result.authors}');
      print('ISBN-13: ${result.isbn13}');
      print('Publisher: ${result.publisher}');
    } else {
      print('Book not found');
    }
  } finally {
    service.close();
  }
}