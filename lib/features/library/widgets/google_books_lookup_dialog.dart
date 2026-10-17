import 'package:flutter/material.dart';
import 'package:dandelion/features/library/book.dart';
import 'package:dandelion/services/google_books_lookup_service.dart';

/// Dialog for looking up books by ISBN with Google Books API and result preview
class GoogleBooksLookupDialog extends StatefulWidget {
  const GoogleBooksLookupDialog({super.key, this.service});

  final GoogleBooksLookupService? service;

  @override
  State<GoogleBooksLookupDialog> createState() =>
      _GoogleBooksLookupDialogState();
}

class _GoogleBooksLookupDialogState extends State<GoogleBooksLookupDialog> {
  late final GoogleBooksLookupService _service;
  final _formKey = GlobalKey<FormState>();
  final _isbnController = TextEditingController();
  Book? _result;
  bool _isLoading = false;
  String? _error;

  // Track which fields are selected for import
  final Set<String> _selectedFields = {
    'title',
    'authors',
    'description',
    'publisher',
    'publicationDate',
    'pageCount',
    'isbn10',
    'isbn13',
  };

  @override
  void initState() {
    super.initState();
    _service = widget.service ?? GoogleBooksLookupService();
  }

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
                  style: Theme.of(context).textTheme.bodySmall
                      ?.copyWith(color: Theme.of(context).colorScheme.error),
                  textAlign: TextAlign.center,
                )
              else if (_result != null) ...[
                const SizedBox(height: 12),
                // Thumbnail
                if (_result!.thumbnailUrl != null)
                  Image.network(
                    _result!.thumbnailUrl!,
                    width: 100,
                    height: 150,
                    fit: BoxFit.cover,
                  )
                else
                  const Icon(Icons.menu_book, size: 100),
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
                        Chip(label: Text('ISBN-10: ${_result!.isbn10}')),
                      if (_result!.isbn13 != null)
                        Chip(label: Text('ISBN-13: ${_result!.isbn13}')),
                    ],
                  ),
                ],
                const SizedBox(height: 16),
                const Text(
                  'Select fields to import:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 12,
                  runSpacing: 8,
                  children: [
                    _buildFieldCheckbox('Title', 'title'),
                    _buildFieldCheckbox('Authors', 'authors'),
                    _buildFieldCheckbox('Description', 'description'),
                    _buildFieldCheckbox('Publisher', 'publisher'),
                    _buildFieldCheckbox('Publication Date', 'publicationDate'),
                    _buildFieldCheckbox('Page Count', 'pageCount'),
                    _buildFieldCheckbox('ISBN-10', 'isbn10'),
                    _buildFieldCheckbox('ISBN-13', 'isbn13'),
                  ],
                ),
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
              onPressed: () {
                // Build book with only selected fields
                final selectedBook = Book(
                  id: 0, // Will be set when saved to database
                  title: _selectedFields.contains('title')
                      ? _result!.title
                      : '',
                  authors: _selectedFields.contains('authors')
                      ? _result!.authors
                      : '',
                  description: _selectedFields.contains('description')
                      ? _result!.description
                      : null,
                  publisher: _selectedFields.contains('publisher')
                      ? _result!.publisher
                      : null,
                  publicationDate: _selectedFields.contains('publicationDate')
                      ? _result!.publicationDate
                      : null,
                  pageCount: _selectedFields.contains('pageCount')
                      ? _result!.pageCount
                      : null,
                  isbn10: _selectedFields.contains('isbn10')
                      ? _result!.isbn10
                      : null,
                  isbn13: _selectedFields.contains('isbn13')
                      ? _result!.isbn13
                      : null,
                  // We don't have coverAssetKey from lookup; that's handled by cover service
                  coverAssetKey: null,
                  genres: null,
                  externalCatalogId: _result!.externalCatalogId,
                  externalSourceUrl: _result!.externalSourceUrl,
                  thumbnailUrl: _result!.thumbnailUrl,
                );
                Navigator.of(context).pop(selectedBook);
              },
              child: const Text('Use this book'),
            ),
        ],
      ],
    );
  }

  Widget _buildFieldCheckbox(String label, String field) {
    return CheckboxListTile(
      title: Text(label),
      value: _selectedFields.contains(field),
      onChanged: (bool? value) {
        setState(() {
          if (value == true) {
            _selectedFields.add(field);
          } else {
            _selectedFields.remove(field);
          }
        });
      },
      controlAffinity: ListTileControlAffinity.leading, // Checkbox leading
      dense: true,
    );
  }
}
