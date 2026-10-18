# Dandelion — audit baseline and known risks

**Snapshot reviewed:** 2026-10-18  
**Repository:** [snowep/Dandelion](https://github.com/snowep/Dandelion)  
**Branch reviewed:** `master`  
**Commit reviewed:** [`147ce5bb788206ce7d954dcc4eadb4719de4e245`](https://github.com/snowep/Dandelion/commit/147ce5bb788206ce7d954dcc4eadb4719de4e245)

This is a static-review baseline. It is not a claim that the source compiles or that the application has been tested on all platforms. Re-check the repository head before executing this plan.

## Improvements observed

- The duplicate app-bar ownership issue appears resolved. `lib/app/app_shell.dart` provides navigation; pages own their headers.
- `go_router`, Riverpod, Drift, a Book/ReadingRecord model, and a repository exist.
- Library and Wishlist support core record operations; Home and Insights read dashboard statistics.
- Discover has local recommendation logic and a Google Books catalog path.
- Export/import implementations have been started.
- `web/sqlite3.wasm` and `web/drift_worker.dart.js` paths appear in the repository; the worker was fetchable in the reviewed snapshot. Presence alone does not prove deployment works.

## Risks that must be resolved

### B0 — Build and verification foundation

- `pubspec.yaml` declares Dart `^3.13.5` in the reviewed snapshot.
- `.github/workflows/flutter-ci.yml` pinned Flutter `3.22.0`, which bundled Dart 3.4, and used a push trigger for `main` while the reviewed branch was `master`. Its job-level structure also included invalid fields where valid workflow syntax expects `runs-on` and a `steps` list.
- GitHub status queries for the reviewed commit returned no status checks and no workflow runs through the available check endpoint. This is not proof that CI was never run; it means this audit could not verify a green run.
- The prior tests were removed in commit [`0b474417`](https://github.com/snowep/Dandelion/commit/0b47441797129472a0f56cfbae0503fd79ed98b9). Expected test paths such as `test/widget_test.dart` were not present in the reviewed snapshot. Re-check before recreating them.

### B1 — Protect the library before import/export work

- `lib/services/library_import_export_service.dart` clears existing books/records before finishing the import. Validation is incomplete and the whole database operation is not transactional. An error during import can leave the user's previous library deleted or the new library incomplete.
- Three overlapping export/import service implementations exist: `library_export_service.dart`, `library_export_import_service.dart`, and `library_import_export_service.dart`. Choose one canonical implementation after tracing all callers.
- The current ZIP approach places encoded cover data inside `library.json` rather than using a clear archive layout with independently referenced cover files. Align the final format with `.docs/STACK.md`, version it, and test round trips.

### B2 — Remove silent record truncation

- `AppDatabase.getAllBooks()` and `searchBooks()` impose a 500-row limit.
- `BookRepositoryImpl.listBooks()` also loads results then performs some status filtering and sorting in Dart.
- Dashboard, Discover, and export consumers depend on repository methods. A capped query can make records, metrics, recommendations, or backups incomplete for users with more than 500 books.
- Search does not currently include personal reading notes, although notes are in the product requirements.

### B3 — Cross-platform covers

- `CoverImageService` uses `dart:io`, filesystem paths, and `path_provider` directly; this is not a web-compatible storage implementation.
- The file-picker path requires a physical path instead of handling selected bytes when a path is unavailable.
- `DiscoverScreen._saveCatalogBook()` generates one UUID for writing a downloaded cover and another for the stored `coverAssetKey`, so the book can point to a different file from the one saved.
- `storeImage()` does not ensure its destination directory exists.

### B4 — Domain correctness

- `Book.copyWith()` and `ReadingRecord.copyWith()` use nullable parameters with `value ?? this.value`, so the caller cannot explicitly clear a nullable field reliably.
- ISBN selection uses `isbn13 ?? isbn10`. Since ISBN properties default to empty strings, an empty ISBN-13 can prevent ISBN-10 fallback.
- The Drift schema has both `authors` and `author` columns. Trace data usage and normalize the model/schema without losing existing data; include migrations if changing a shipped schema.
- Filtering, sorting, and joined status behavior need tests; ensure database-side query methods actually apply requested filters.

### B5 — Discovery is incomplete

- `RecommendationEngine` explicitly leaves text similarity and history fit stubbed, but still adds their weights to the score. This can skew ranking.
- Catalog candidates are fetched separately and are not scored by the same recommendation engine.
- Recommendation explanations must only describe signals genuinely computed from available data.
- Lookup dialogs/services exist, but the manual Library add/edit flow must be inspected and completed so optional title/ISBN lookup is accessible without removing manual entry.

### B6 — Tests, responsive UI, and docs

- Restore automated regression, repository, migration, import/export, cover, lookup, recommendation, and route/header tests.
- Test narrow layouts and large text. The dashboard's three summary cards in a single `Row` may still overflow on narrow widths; the latest home overflow fix addressed a different section.
- `.docs/PROJECT.md` still describes Phase 0 with unchecked tasks. Update it only after verifying working features and platform support.

## Do not assume

- Do not assume that static code is compiled successfully.
- Do not assume that a file-picker API or path-provider call works on web because native tests pass.
- Do not assume that the existence of a WASM file means production hosting serves it with the right MIME type or worker paths.
- Do not assume that an export succeeds just because a ZIP was generated; prove a round trip with records and cover bytes.
- Do not assume that empty test/status output means success.
- Do not assume all screens, lookup flows, full-text search, backup, or recommendations are complete because their source files exist.
