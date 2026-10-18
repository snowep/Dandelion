# Dandelion — current repository audit

**Baseline:** `master` at [`86e4856`](https://github.com/snowep/Dandelion/commit/86e48560e8500221f4056c2ba92089f01f57a125), 2026-10-19.  
**Overall assessment:** good prototype/foundation; not release-ready. Do not rewrite the app. Stabilize the current Flutter/Riverpod/GoRouter/Drift structure.

## Executive summary

The app has grown past the original scaffold: Library, Wishlist, Discover, dashboard/insights, reading tracking, lookup services, Drift persistence, cover handling, and import/export code exist. The per-screen AppBar decision appears implemented. However, the current head has a build-blocking missing Settings feature, CI is red, there are no checked-in tests, schema changes were added without a schema-version bump/migration, import/export silently omits the newest book fields, and the shared cover service is not web-safe. Recommendation scoring is knowingly incomplete.

## Findings by severity

### P0 — fix before other feature work

1. **Imports reference files absent from the repository.** `lib/app/app.dart` imports `lib/features/settings/theme_notifier.dart`; `lib/app/app_router.dart` imports `lib/features/settings/settings_screen.dart`, adds `/settings`, and both navigation layouts show Settings. The current tree has no `lib/features/settings/` directory. `flutter analyze`/build is expected to fail once CI gets past formatting. Either implement the intended Settings screen/provider or remove every route/import/nav reference consistently. The PRD requires theme behavior, so implementing the small Settings feature is preferred.
2. **Database schema did not advance for new columns.** `AppDatabase.schemaVersion` is still `3`, with migrations only for `summary` (<2) and `isInWishlist` (<3). The earlier `v0.2.5` tree had schema v3 but none of the new purchase/lending columns. `193d9c2` added `purchasePrice`, `purchaseCurrency`, `isBorrowed`, `lenderName`, `lenderContact`, `borrowDate`, `expectedReturnDate`, `isLent`, `borrowerName`, `borrowerContact`, `lendDate`, and `expectedLendReturnDate` while leaving schema version/migration unchanged. Existing v3 databases need an explicit upgrade (next schema v4) before those columns are queried or written.
3. **No automated tests are checked in.** Recursive tree inspection reports no `test/` directory. A previous change removed old widget, persistence, offline-flow, FTS5, cover and catalog tests. Recreate tests before any claim of completion.
4. **Version history is inconsistent.** Existing tags `v1.0.0` and `v1.0.1` point at incomplete commits; `master` equals `v1.0.1`. `pubspec.yaml` says `0.2.0+1`; GitHub Releases API returns an empty list. This needs an explicit tag/release decision. Do not blindly move or reuse tags.

### P1 — user data and platform risk

5. **Backup omits fields introduced by the reading-tracker update.** `_bookToJson` and import reconstruction in `lib/services/library_export_import_service.dart` do not include purchase price/currency or lending/borrowing details. A round-trip loses those values.
6. **Import is not atomic.** `ImportService.importArchive` validates some fields, then loops through and writes records without a database transaction. Mid-import errors can leave a partial library. It also has no transaction rollback for cover file writes and does not comprehensively validate archive size, types, record references, imported duplicate IDs/ISBNs, or cover entries.
7. **Cross-platform cover storage is missing.** `lib/shared/services/cover_image_service.dart` imports `dart:io`, uses `File`/`Directory`, and requires a local picker path. It is shared by screens targeting web, so web compatibility is not established and is likely to fail. Implement separate native and browser persistence behind a narrow cover-storage interface.
8. **Catalog cover key is generated twice.** In `DiscoverScreen._saveCatalogBook`, one UUID is passed to `storeImage` and another UUID is saved as `coverAssetKey`; that means the saved book points at a different file. `storeImage` also does not create the `covers/` directory. Generate one key, initialize storage, and test save/reload.
9. **Theme state is split across ProviderScopes.** `main.dart` already wraps `DandelionApp` in `ProviderScope`; `DandelionApp` creates a second ProviderScope around `MaterialApp`. It watches theme state from the outer container while descendants would read from the inner one. Remove the nested scope so theme settings and the app shell use the same provider container.
10. **Recommendation implementation violates its stated formula.** `RecommendationEngine` explicitly leaves text similarity and history fit stubbed at zero but still counts their weights; it rebuilds preference profiles for each candidate and external candidates are shown in catalog order, not ranked by the engine. The current UI therefore does not meet the documented hybrid recommendation spec.

### P2 — correctness, search, performance, maintainability

11. **`BookRepositoryImpl.getAll` ignores `offset`.** It accepts `offset` but only passes `limit` to `getAllBooks`. Any caller using that method for pagination will repeat the first page. `getAllBooks` no longer has the old fixed 500 limit, so do not reintroduce a silent cap; instead define pagination for views and complete iteration for exports/statistics.
12. **Status filter likely discards its join.** `getBooksFiltered` calls `query.join([...])` without assigning the returned query, then references `readingRecords.status`. Add a database regression test and use a joined query/subquery correctly.
13. **Sort UI and data layer are out of sync.** DB sorting handles only `title`, `author`, and `date`; unsupported keys fall back to title. Visible `added`/`updated` (and any other UI options) must map to a supported query with stable tie-breakers.
14. **Notes are absent from local search.** PRD says search title, author, ISBN, genres, description and notes; current database search queries do not include reading-record notes.
15. **Nullable `copyWith` values cannot be cleared.** Both `Book.copyWith` and `ReadingRecord.copyWith` use `x ?? this.x`. Users cannot clear optional details such as page count, cover key, purchase info, lender/borrower values, finish date, notes or rating. Add sentinel/clear flags and tests.
16. **ISBN fallback is fragile.** `isbn10`/`isbn13` default to empty strings, and repository selection uses `book.isbn13 ?? book.isbn10`; empty-but-non-null ISBN13 can mask a valid ISBN10. Choose the first normalized, non-empty candidate and test duplicate cases.
17. **Cover loading can be unbounded.** Library loads cover bytes for all returned books concurrently; dashboard/Discover/export call full-list getters. Use lazy thumbnails/bounded caching for UI and complete but bounded iteration for export.
18. **Docs/code scope drift and dead files.** `.docs/PROJECT.md` still claims Phase 0 with all tasks unchecked. PRD does not reflect recent price/lending fields. Several old placeholder screen files and `.backup`/`.bak` files remain tracked. Verify references, delete obsolete duplicates only in a cleanup PR, and update docs after verified work.

## CI evidence

The latest Actions run is [`Flutter CI #30`](https://github.com/snowep/Dandelion/actions/runs/39163199619), on the current head. SDK setup and `flutter pub get` passed. The `dart format --output=none --set-exit-if-changed .` step failed because 7 files would change: `app.dart`, `book.dart`, `book_database.dart`, `book_repository_impl.dart`, `library_notifier.dart`, `library_screen.dart`, and `library_export_import_service.dart`. Analyze, tests and web build were skipped. Therefore no green static analysis, test suite, or web build has been demonstrated.

## What is good enough to keep

- Flutter + Dart and feature-based folder shape.
- Riverpod for state, GoRouter for navigation, Drift for local database.
- Per-screen AppBar ownership (appears fixed).
- The adaptive NavigationBar/NavigationRail idea.
- Manual entry as the offline fallback; online lookup optional.
- Existing DB generated code and WASM/worker assets as useful foundations, subject to migration/runtime validation.

## Exit verdict

**Not release-ready.** The immediate goal is to get a complete app through CI, restore tests, and protect existing user data. No new broad feature should start until P0 and P1 findings have passing regression tests.
