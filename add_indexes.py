import sys

file_path = 'lib/features/library/book_database.dart'

with open(file_path, 'r', encoding='utf-8') as f:
    lines = f.readlines()

# Find the end of Books class (line index of '}' after Books)
# We know Books class starts at line 10 (0-indexed) and ends at line 21? Let's search.
# We'll find the line index of the closing brace that matches the class start.
# Simpler: find the line after the updatedAt line in Books.
for i, line in enumerate(lines):
    if 'DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime);' in line and 10 < i < 30:
        # This is the Books updatedAt line (first occurrence)
        insert_idx = i + 1  # insert after this line
        # Insert blank line, then @override, then List<Index> get indexes => [...]
        lines.insert(insert_idx, '\n')
        lines.insert(insert_idx + 1, '  @override\n')
        lines.insert(insert_idx + 2, '  List<Index> get indexes => [\n')
        lines.insert(insert_idx + 3, "    Index.unique('books_normalized_isbn_idx', [normalizedIsbn]),\n")
        lines.insert(insert_idx + 4, '  ];\n')
        break

# Find the second occurrence of updatedAt (ReadingRecords)
occurrence = 0
for i, line in enumerate(lines):
    if 'DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime);' in line:
        occurrence += 1
        if occurrence == 2:
            insert_idx = i + 1  # insert after this line
            lines.insert(insert_idx, '\n')
            lines.insert(insert_idx + 1, '  @override\n')
            lines.insert(insert_idx + 2, '  List<Index> get indexes => [\n')
            lines.insert(insert_idx + 3, "    Index('reading_records_book_id_idx', [bookId]),\n")
            lines.insert(insert_idx + 4, "    Index('reading_records_start_date_idx', [startDate]),\n")
            lines.insert(insert_idx + 5, '  ];\n')
            break

with open(file_path, 'w', encoding='utf-8') as f:
    f.writelines(lines)

print('Indexes added')
