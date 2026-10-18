# U1 — Add a safe Drift v3 → v4 migration

**Goal:** users with the existing schema v3 database keep their data and gain the new purchase/lending columns.

## Relevant files
- `lib/features/library/book_database.dart`
- generated `lib/features/library/book_database.g.dart`
- `lib/features/library/book.dart`
- `lib/features/library/book_repository_impl.dart`
- new migration/database tests under `test/`

## Required changes
1. Increase `AppDatabase.schemaVersion` from 3 to 4.
2. Add `onUpgrade` migration for all columns introduced after v3: `purchasePrice`, `purchaseCurrency`, `isBorrowed`, `lenderName`, `lenderContact`, `borrowDate`, `expectedReturnDate`, `isLent`, `borrowerName`, `borrowerContact`, `lendDate`, `expectedLendReturnDate`.
3. Use nullable/default-compatible column migrations. Preserve existing books/reading records; do not delete/recreate the database.
4. Regenerate Drift code using the locked build_runner/drift_dev versions. Never hand-edit `.g.dart`.
5. Review `Book` ↔ `BookRow` ↔ `BooksCompanion` mapping for every field, including author collection conversion and price numeric conversion.
6. Test creating a v3 database with representative existing data, opening it through current `AppDatabase`, and asserting all old data survives plus new columns are writable/readable.
7. Also test a fresh database from scratch and opening the already-current v4 database again.

## Acceptance
- No SQL “no such column” error when upgrading v3.
- Counts, IDs, reading state, notes and coverAssetKey from v3 remain unchanged.
- New nullable fields default safely and round-trip through repository CRUD.
- `flutter test` includes a migration test. Build-runner output leaves no unexplained generated diff.

## Non-goals
Do not add more domain fields or a new ORM abstraction in this task.
