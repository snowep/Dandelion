import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:dandelion/features/library/book.dart';
import 'package:dandelion/shared/services/cover_image_service.dart';

/// A scaffold for displaying a list of books with lazy loading, search, sort, and cover loading.
class BookListScaffold extends StatefulWidget {
  const BookListScaffold({
    super.key,
    required this.books,
    required this.onBookTap,
    this.onBookEdit,
    this.onBookArchive,
    this.onBookDelete,
    this.onWishlistToggle,
    this.sortBy = 'title',
    this.sortAscending = true,
  });

  final List<Book> books;
  final void Function(Book) onBookTap;
  final void Function(Book)? onBookEdit;
  final void Function(int)? onBookArchive;
  final void Function(int)? onBookDelete;
  final void Function(int)? onWishlistToggle;
  final String sortBy;
  final bool sortAscending;

  @override
  State<BookListScaffold> createState() => _BookListScaffoldState();
}

class _BookListScaffoldState extends State<BookListScaffold> {
  String _query = '';
  Timer? _debounce;

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }

  List<Book> get _filteredAndSortedBooks {
    final query = _query.trim().toLowerCase();
    if (query.isEmpty) {
      return _sortBooks(widget.books);
    }
    return _sortBooks(
      widget.books.where((book) {
        return book.title.toLowerCase().contains(query) ||
            book.authors.toLowerCase().contains(query) ||
            (book.isbn10 ?? '').contains(
              query.replaceAll(RegExp(r'[^0-9]'), ''),
            ) ||
            (book.isbn13 ?? '').contains(
              query.replaceAll(RegExp(r'[^0-9]'), ''),
            ) ||
            (book.genres ?? '').toLowerCase().contains(query) ||
            (book.description ?? '').toLowerCase().contains(query);
      }).toList(),
    );
  }

  List<Book> _sortBooks(List<Book> books) {
    final List<Book> sorted = List.from(books);
    sorted.sort((left, right) {
      dynamic leftValue;
      dynamic rightValue;
      switch (widget.sortBy) {
        case 'title':
          leftValue = left.title.toLowerCase();
          rightValue = right.title.toLowerCase();
          break;
        case 'author':
          leftValue = left.authors.toLowerCase();
          rightValue = right.authors.toLowerCase();
          break;
        case 'added':
          leftValue = left.createdAt;
          rightValue = right.createdAt;
          break;
        case 'updated':
          leftValue = left.updatedAt;
          rightValue = right.updatedAt;
          break;
        case 'rating':
          leftValue = left.title.toLowerCase();
          rightValue = right.title.toLowerCase();
          break;
        case 'pageCount':
          leftValue = left.pageCount ?? 0;
          rightValue = right.pageCount ?? 0;
          break;
        case 'progress':
          leftValue = left.title.toLowerCase();
          rightValue = right.title.toLowerCase();
          break;
        default:
          leftValue = left.title.toLowerCase();
          rightValue = right.title.toLowerCase();
      }
      if (leftValue is String && rightValue is String) {
        return widget.sortAscending
            ? leftValue.compareTo(rightValue)
            : rightValue.compareTo(leftValue);
      } else if (leftValue is DateTime && rightValue is DateTime) {
        return widget.sortAscending
            ? leftValue.compareTo(rightValue)
            : rightValue.compareTo(leftValue);
      } else {
        return widget.sortAscending
            ? (leftValue as num).compareTo(rightValue as num)
            : (rightValue as num).compareTo(leftValue as num);
      }
    });
    return sorted;
  }

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
          sliver: SliverToBoxAdapter(
            child: SearchBar(
              hintText: 'Search title, author, ISBN, or genre',
              leading: const Icon(Icons.search),
              onChanged: (query) {
                _query = query;
                _debounce?.cancel();
                _debounce = Timer(const Duration(milliseconds: 300), () {
                  if (mounted) setState(() {});
                });
              },
            ),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          sliver: SliverToBoxAdapter(
            child: Row(
              children: [
                PopupMenuButton<String>(
                  child: Text('Sort: ${widget.sortBy} ${widget.sortAscending ? '↑' : '↓'}'),
                  onSelected: (value) {
                    setState(() {
                      if (value == widget.sortBy) {
                        // Toggle sort direction by recreating the widget with new sort params?
                        // For simplicity, we require parent to control sorting.
                      }
                    });
                  },
                  itemBuilder: (context) => [
                    const PopupMenuItem(value: 'title', child: Text('Title')),
                    const PopupMenuItem(value: 'author', child: Text('Author')),
                    const PopupMenuItem(value: 'added', child: Text('Date Added')),
                    const PopupMenuItem(value: 'updated', child: Text('Last Updated')),
                  ],
                ),
                const SizedBox(width: 8),
              ],
            ),
          ),
        ),
        if (_filteredAndSortedBooks.isEmpty && _query.isNotEmpty)
          const SliverFillRemaining(
            child: Center(child: Text('No books match your search.')),
          )
        else if (_filteredAndSortedBooks.isEmpty && _query.isEmpty)
          const SliverFillRemaining(
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.menu_book_outlined, size: 48),
                  SizedBox(height: 12),
                  Text('Your list is empty.', style: TextStyle(fontSize: 16)),
                  SizedBox(height: 8),
                  Text('Add a book to get started.', style: TextStyle(color: Colors.grey)),
                ],
              ),
            ),
          )
        else
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
            sliver: SliverList.builder(
              itemCount: _filteredAndSortedBooks.length,
              itemBuilder: (context, index) {
                final book = _filteredAndSortedBooks[index];
                return Card(
                  key: ValueKey(book.id),
                  child: ListTile(
                    minVerticalPadding: 12,
                    leading: FutureBuilder<Uint8List?>(
                      future:
                          book.coverAssetKey != null && book.coverAssetKey!.isNotEmpty
                          ? CoverImageService.loadImage(book.coverAssetKey!)
                          : Future.value(null),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return const CircleAvatar(
                            backgroundColor: Colors.grey,
                            child: Icon(Icons.menu_book, color: Colors.white),
                          );
                        }
                        final Uint8List? coverBytes = snapshot.data;
                        return coverBytes != null
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(6),
                                child: Image.memory(
                                  coverBytes,
                                  width: 44,
                                  height: 64,
                                  fit: BoxFit.cover,
                                  semanticLabel: 'Cover of ${book.title}',
                                ),
                              )
                            : CircleAvatar(
                                backgroundColor: Theme.of(context).colorScheme.secondaryContainer,
                                child: Icon(
                                  Icons.menu_book,
                                  color: Theme.of(context).colorScheme.onSecondaryContainer,
                                ),
                              );
                      },
                    ),
                    title: Text(book.title),
                    subtitle: Text(book.authors.isEmpty ? 'Unknown author' : book.authors),
                    onTap: () => widget.onBookTap(book),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (widget.onWishlistToggle != null)
                          IconButton(
                            icon: Icon(
                              book.isInWishlist ? Icons.favorite : Icons.favorite_border,
                              color: book.isInWishlist ? Colors.red : null,
                            ),
                            tooltip: book.isInWishlist ? 'Remove from wishlist' : 'Add to wishlist',
                            onPressed: () => widget.onWishlistToggle!(book.id),
                          ),
                        if (widget.onBookEdit != null)
                          IconButton(
                            icon: const Icon(Icons.edit),
                            tooltip: 'Edit',
                            onPressed: () => widget.onBookEdit!(book),
                          ),
                        if (widget.onBookArchive != null)
                          IconButton(
                            icon: const Icon(Icons.archive),
                            tooltip: 'Archive',
                            onPressed: () => widget.onBookArchive!(book.id),
                          ),
                        if (widget.onBookDelete != null)
                          IconButton(
                            icon: const Icon(Icons.delete),
                            tooltip: 'Delete',
                            onPressed: () => widget.onBookDelete!(book.id),
                          ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
      ],
    );
  }
}