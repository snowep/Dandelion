# U2 — Make backup/import complete and failure-safe

**Goal:** manual backup is trustworthy for every saved record and every included cover, including the new purchase/lending fields.

## Relevant files
- `lib/services/library_export_import_service.dart`
- `lib/features/library/book_repository.dart` and implementation
- `lib/features/library/book_database.dart`
- cover storage service / future cross-platform adapter
- tests under `test/services/` and `test/features/library/`

## Required changes
1. Extend `_bookToJson` and import parsing for `purchasePrice`, `purchaseCurrency`, all borrow/lend booleans, people/contact details, dates, and any field added to `Book` in the future. Use one canonical field-to-JSON map to prevent drift.
2. Decide and document a backup `schemaVersion` independent from Drift schema version; define handling for current version 1 and unsupported/future versions.
3. Ensure export reads **all** books/reading records (not UI page limit), and include cover assets referenced by books. Include stable asset keys and validated bytes.
4. Validate all archive content before mutation: JSON types and required fields, supported version, duplicate imported IDs/ISBNs, reading-record references, status enum, bounds (page/progress/rating), cover key/path safety, entry count and total decompressed size.
5. Add a preview/conflict policy that distinguishes skip vs overwrite. Never silently overwrite personal notes, rating, progress, or reading status when applying catalog metadata. For backup restore, require explicit choice for conflicts.
6. Make database writes atomic. Use a Drift transaction for data; stage incoming cover files and clean up staged/orphaned files on failure. A failed import must leave current DB and current cover assets unchanged.
7. Add tests for JSON-only and archive round-trip, old backup version compatibility, new fields, missing/corrupt cover, duplicate ISBN, dangling reading record, oversized payload, unsafe key, and an injected failure halfway through import.
8. Keep `dart:io` out of shared code used by web; use platform file APIs only after the cross-platform cover adapter in U3 exists, or implement the small adapter within this task as required to unblock testing.

## Acceptance
- Export → import → export is semantically identical for books, reading records, all latest fields and covers.
- Invalid or failed import leaves pre-import data unchanged.
- Backups include more than 500 records.
- Export/import has a real user-facing entry point or the docs explicitly state the UI task that wires it next; do not mark FR-08 done if only a service exists.
