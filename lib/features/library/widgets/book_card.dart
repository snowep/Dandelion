import 'package:flutter/material.dart';

import '../book.dart';

class BookCard extends StatelessWidget {
  const BookCard({
    super.key,
    required this.book,
    required this.onToggleWishlist,
    required this.onEdit,
    required this.onArchive,
    required this.onDelete,
  });

  final Book book;
  final VoidCallback onToggleWishlist;
  final VoidCallback onEdit;
  final VoidCallback onArchive;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return Card(
      key: ValueKey(book.id),
      child: ListTile(
        minVerticalPadding: 12,
        leading: book.coverAssetKey == null
            ? CircleAvatar(
                backgroundColor: Theme.of(context)
                    .colorScheme
                    .secondaryContainer,
                child: Icon(
                  Icons.menu_book,
                  color: Theme.of(context).colorScheme.onSecondaryContainer,
                ),
              )
            : null,
        title: Text(book.title),
        subtitle: Text(book.authors.isEmpty ? 'Unknown author' : book.authors),
        onTap: () {},
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: Icon(
                book.isInWishlist ? Icons.favorite : Icons.favorite_border,
                color: book.isInWishlist ? Colors.red : null,
              ),
              tooltip: book.isInWishlist
                  ? 'Remove from wishlist'
                  : 'Add to wishlist',
              onPressed: onToggleWishlist,
            ),
            PopupMenuButton<String>(
              tooltip: 'Book actions',
              onSelected: (action) {
                if (action == 'edit') {
                  onEdit();
                } else if (action == 'archive') {
                  onArchive();
                } else if (action == 'delete') {
                  onDelete();
                }
              },
              itemBuilder: (context) => const [
                PopupMenuItem(value: 'edit', child: Text('Edit')),
                PopupMenuItem(value: 'archive', child: Text('Archive')),
                PopupMenuItem(value: 'delete', child: Text('Delete')),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
