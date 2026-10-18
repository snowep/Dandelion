import 'package:dandelion/features/library/book.dart';
import 'package:dandelion/features/library/reading_record.dart';

abstract class BookRepository {
  Future<int> createBook(
    Book book, {
    ReadingStatus initialStatus = ReadingStatus.wantToRead,
  });
  Future<void> updateBook(Book book);
  Future<Book?> getBookById(int id);
  Future<List<Book>> getAll();
  Future<List<Book>> listBooks({
    Map<String, dynamic>? filters,
    String? sortBy,
    bool ascending = true,
  });
  Future<void> archiveBook(int id);
  Future<void> deleteBook(int id);
  Future<void> toggleWishlist(int bookId);
  Future<List<Book>> getBooksByWishlist({bool isInWishlist = true});
  Future<List<Book>> getBooksFiltered({
    String? search,
    String? status,
    String? genre,
    String? sortBy,
    bool ascending = true,
  });
  Future<Book?> getBookByIsbn(String isbn);
  Future<void> createReadingRecord(ReadingRecord record);
  Future<void> updateReadingRecord(ReadingRecord record);
  Future<ReadingRecord?> getReadingRecordForBook(int bookId);
  Future<List<ReadingRecord>> listReadingRecords({int? bookId});
  Future<void> close();

  // Additional methods for dashboard and statistics
  Future<int> getTotalBooksCount();
  Future<int> getWishlistCount();
  Future<Map<String, int>> getReadingStatusCounts();
  Future<double> getAverageRating();
  Future<int> getTotalPagesRead();
  Future<int> getBooksFinishedThisMonth();
}
