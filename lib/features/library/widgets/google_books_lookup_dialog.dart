import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:dandelion/features/library/book.dart';
import 'package:dandelion/services/google_books_lookup_service.dart';

/// Dialog for looking up books by ISBN with Google Books API and result preview
class GoogleBooksLookupDialog extends StatefulWidget {
  const GoogleBooksLookupDialog({super.key});

  @override
  State<GoogleBooksLookupDialog> createState() => _GoogleBooksLookupDialogState();
}

class _GoogleBooksLookupDialogState extends State<GoogleBooksLookupDialog> {
  final _formKey = GlobalKey<FormState>();
  final _isbnController = TextEditingController();
  final GoogleBooksLookupService _service = GoogleBooksLookupService();
  Book? _result;
  bool _isLoading = false;
  String? _error;

  @override
  void dispose() {
    _isbnController.dispose();
    _service.close();
    super.dispose();
  }

  Future<void> _lookupIsbn() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _error = null;
      _result = null;
    });

    final isbn = _isbnController.text.trim();
    try {
      final book = await _service.lookupByIsbn(isbn);
      if (!mounted) return;

      setState(() {
        _isLoading = false;
        _result = book;
        if (book == null) {
          _error = 'Book not found for ISBN: $isbn';
        }
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _error = 'Error looking up ISBN: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Lookup Book by ISBN'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _isbnController,
                decoration: const InputDecoration(
                  labelText: 'ISBN-10 or ISBN-13',
                  hintText: 'Enter ISBN (e.g. 9780134685991)',
                  prefixIcon: Icon(Icons.book),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter an ISBN';
                  }
                  // Remove non-digit/X characters for validation
                  final cleaned = value.replaceAll(RegExp(r'[^0-9Xx]'), '');
                  if (cleaned.length != 10 && cleaned.length != 13) {
                    return 'ISBN must be 10 or 13 digits';
                  }
                  return null;
                },
                onFieldSubmitted: (_) => _lookupIsbn(),
              ),
              const SizedBox(height: 16),
              if (_isLoading)
                const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              else if (_error != null)
                Text(
                  _error!,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.error,
                      ),
                  textAlign: TextAlign.center,
                )
              else if (_result != null) ...[
                const SizedBox(height: 12),
                Text(
                  'Found: ${_result!.title}',
                  style: Theme.of(context).textTheme.titleMedium,
                  textAlign: TextAlign.center,
                ),
                Text(
                  'by ${_result!.authors}',
                  style: Theme.of(context).textTheme.bodyMedium,
                  textAlign: TextAlign.center,
                ),
                if (_result!.description != null &&
                    _result!.description!.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text(
                    _result!.description!,
                    style: Theme.of(context).textTheme.bodySmall,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
                if (_result!.publisher != null) ...[
                  const SizedBox(height: 8),
                  Text(
                    'Publisher: ${_result!.publisher}',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
                if (_result!.publicationDate != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    'Published: ${_result!.publicationDate!.year}',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
                if (_result!.pageCount != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    'Pages: ${_result!.pageCount}',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
                if (_result!.isbn10 != null || _result!.isbn13 != null) ...[
                  const SizedBox(height: 12),
                  const Text(
                    'ISBN:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Wrap(
                    spacing: 8,
                    children: [
                      if (_result!.isbn10 != null)
                        Chip(
                          label: Text('ISBN-10: ${_result!.isbn10}'),
                        ),
                      if (_result!.isbn13 != null)
                        Chip(
                          label: Text('ISBN-13: ${_result!.isbn13}'),
                        ),
                    ],
                  ),
                ],
              ],
            ],
          ),
        ),
      ),
      actions: [
        if (_isLoading) ...[
          const TextButton(onPressed: null, child: Text('Looking up...')),
        ] else ...[
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          if (_result != null)
            FilledButton(
              onPressed: () => Navigator.of(context).pop(_result),
              child: const Text('Use this book'),
            )
        ],
      ],
    );
  }
}