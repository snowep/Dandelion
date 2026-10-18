import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'book_repository.dart';
import 'book_database.dart';
import 'book_repository_impl.dart';
import 'book.dart';

final bookRepositoryProvider = Provider<BookRepository>((ref) {
  return BookRepositoryImpl(AppDatabase());
});

final libraryNotifierProvider =
    StateNotifierProvider<LibraryNotifier, LibraryState>((ref) {
      final repository = ref.read(bookRepositoryProvider);
      return LibraryNotifier(repository);
    });

class LibraryState {
  final List<Book> books;
  final bool loading;
  final String? error;

  const LibraryState({required this.books, required this.loading, this.error});

  LibraryState copyWith({List<Book>? books, bool? loading, String? error}) {
    return LibraryState(
      books: books ?? this.books,
      loading: loading ?? this.loading,
      error: error ?? this.error,
    );
  }
}

class LibraryNotifier extends StateNotifier<LibraryState> {
  final BookRepository _repository;

  LibraryNotifier(this._repository)
    : super(const LibraryState(books: [], loading: true)) {
    loadBooks();
  }

  Future<void> loadBooks() async {
    state = state.copyWith(loading: true, error: null);
    try {
      final books = await _repository.listBooks();
      state = state.copyWith(books: books, loading: false);
    } on Object {
      state = state.copyWith(loading: false, error: 'Failed to load books');
    }
  }

  Future<void> toggleWishlist(int bookId) async {
    try {
      await _repository.toggleWishlist(bookId);
      await loadBooks();
    } on Object {
      // In a real app, we might show a snackbar or update state with error
      // For now, we just reload to revert any optimistic update
      await loadBooks();
    }
  }
}
