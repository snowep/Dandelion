# Import ID mapping and conflict handling

## Problem

Imported books retain their source database IDs. Importing into a non-empty library can collide with existing IDs. The conflict branch also searches reading records using the destination book ID even though the exported record references the source ID.

## Fix

### Source-to-destination ID mapping

During import, each incoming book's source ID must be mapped to a new destination ID. The mapping is built as books are processed:

1. For each book in the archive, check if a book with the same ISBN already exists in the destination library.
2. If a match is found, use the existing destination book ID and apply the **overwrite** semantics (update both the book and its reading record).
3. If no ISBN match is found, perform an exact title-plus-full-authors match.
4. If a title+authors match is found, use that destination book ID and update its data.
5. If no match is found, allocate a new destination ID via `createBook()`.

### Skip and overwrite semantics

- **Skip**: When `skipConflicts=true`, if a book with the same ISBN or title+authors already exists, leave the destination book and its reading record **completely unchanged**. Do not update progress, status, notes, or dates.
- **Overwrite**: When `overwrite=true`, update the matched destination book with the archive's data **and** its reading record. The reading record is replaced entirely (not merged).

### Reading-record matching

The exported archive's reading records reference source book IDs. During import:

- If the archive book was **newly created** (no existing match), create a new reading record with the archive's data.
- If the archive book **matched an existing destination book** (by ISBN or title+authors), update that existing reading record using `updateReadingRecord()` with the archive's data, preserving the destination book ID.

### Regression test checklist

- A conflict reaches the preview/confirmation UI instead of being rejected as malformed.
- Skip leaves the destination book and its reading record unchanged.
- Overwrite updates the intended book and reading record.
- Importing into a non-empty library with overlapping source IDs does not collide with unrelated destination books.
- New records retain the correct progress, status, notes, dates, and rating.