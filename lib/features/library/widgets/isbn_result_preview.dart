import 'package:flutter/material.dart';
import 'package:dandelion/features/library/book.dart';

/// Widget to display book details from ISBN lookup result
class IsbnResultPreview extends StatelessWidget {
  const IsbnResultPreview({
    super.key,
    required this.book,
  });

  final Book book;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              book.title,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              'by ${book.authors}',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            if (book.description != null &&
                book.description!.isNotEmpty) ...[
              const SizedBox(height: 12),
              const Text(
                'Description:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              Text(
                book.description!,
                style: Theme.of(context).textTheme.bodyMedium,
                maxLines: 4,
                overflow: TextOverflow.ellipsis,
              ),
            ],
            const SizedBox(height: 12),
            if (book.isbn10 != null || book.isbn13 != null) ...[
              const Text(
                'ISBN:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              Wrap(
                spacing: 8,
                children: [
                  if (book.isbn10 != null)
                    Chip(
                      label: Text('ISBN-10: ${book.isbn10}'),
                    ),
                  if (book.isbn13 != null)
                    Chip(
                      label: Text('ISBN-13: ${book.isbn13}'),
                    ),
                ],
              ),
            ],
            if (book.publisher != null) ...[
              const SizedBox(height: 8),
              Text(
                'Publisher: ${book.publisher}',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
            if (book.publicationDate != null) ...[
              const SizedBox(height: 4),
              Text(
                'Published: ${book.publicationDate!.year}',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
            if (book.pageCount != null) ...[
              const SizedBox(height: 4),
              Text(
                'Pages: ${book.pageCount}',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ],
        ),
      ),
    );
  }
}