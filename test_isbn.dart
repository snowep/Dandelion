import 'package:dandelion/services/isbn_lookup_service.dart';

void main() async {
  final service = IsbnLookupService();
  try {
    final result = await service.lookupByIsbn('9780134685991'); // Effective Java ISBN-13
    if (result != null) {
      print('Found book: ${result.title} by ${result.authors}');
    } else {
      print('Book not found');
    }
  } finally {
    service.close();
  }
}