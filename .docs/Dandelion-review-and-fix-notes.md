# Dandelion: current codebase assessment and first fixes

**Review date:** 2026-10-18  
**Reviewed default-branch head:** `147ce5bb788206ce7d954dcc4eadb4719de4e245`  
**Status:** static source review. No Flutter commands were executed.

## Verdict

Dandelion is a useful prototype, not yet a trustworthy cross-platform MVP. It has a real Drift-backed data layer and substantial Library/Wishlist/Discover/Insights screens, but several reliability, portability, and verification gaps remain. Do not release it as a dependable personal data store until backup/import and persistence have tests.

## Included in `Dandelion-first-fixes.patch`

1. Correct the GitHub Actions workflow structure, trigger on `master`, pin Flutter 3.47.0, and run format/analyze/test/web-build checks.
2. Fix the catalog cover-key mismatch by using one UUID both when storing the asset and when saving its key on the book.
3. Use `PlatformFile.length()` and `PlatformFile.readAsBytes()` for picked image content instead of requiring a local path. Add the missing `dart:typed_data` import and create the native `covers/` directory before writing downloaded covers.
4. Fix ISBN selection so an empty default ISBN-13 does not hide a valid ISBN-10.
5. Add a small repository test suite covering book creation/reading-record creation, ISBN-10 fallback, blank title rejection, and invalid reading progress.

The workflow uses Flutter 3.47.0 because the official Flutter SDK archive documents 3.47 as the stable line for the August 2026 release window; 3.50 has a November 2026 target and is not the correct assumption for October 18. See https://docs.flutter.dev/install/archive.

The repository integration did not grant permission to create a branch, so these source changes have **not** been applied to `snowep/Dandelion` or opened as a pull request. The patch was syntax-checked with `git apply --stat`, but it was **not** run against a full checkout, and the Flutter tests/build have not been executed. Treat it as a proposed patch pending application and CI verification.

## Important remaining work

### P0 — Protect the user's library

- Make import validation complete before deleting or replacing current data.
- Put database replacement into a transaction and prove rollback on malformed records or duplicate ISBNs.
- Validate cover keys and payload sizes. Restore cover assets safely, and ensure database rows never point at missing cover files.
- Add round-trip and failed-import-preserves-existing-data tests.

### P0 — Restore verification

- The current default branch does not contain `test/` tests; a previous commit removed the existing widget, offline flow, persistence, cover, lookup, FTS5, and wishlist tests.
- Add repository/database, migration, import/export, recommendation, cover service, navigation, and responsive widget tests.
- Run `dart format .`, `flutter analyze`, `flutter test`, and `flutter build web` locally or in CI. Do not label the patch green before those commands pass.

### P1 — Fix complete-data operations

- `AppDatabase.getAllBooks()` and `searchBooks()` cap results at 500. This can silently truncate exports, statistics, and recommendations. Introduce bounded pagination for UI queries and an explicit complete export path.
- `Book.copyWith()` and `ReadingRecord.copyWith()` use `value ?? existingValue`, so nullable fields cannot be explicitly cleared.
- Repository ISBN selection uses `book.isbn13 ?? book.isbn10`; because model fields default to empty strings, an empty ISBN-13 can mask a valid ISBN-10.
- The schema/model has both plural `authors` and singular `author` columns while the repository mainly uses `author`; reconcile this mapping instead of keeping competing sources of truth.

### P1 — Make web storage real, not just compilable

- `CoverImageService` still uses `dart:io File` and `getApplicationDocumentsDirectory()` to persist/load/delete stored covers. This is native filesystem storage, not a browser-persistent cover store.
- The patch uses `PlatformFile.readAsBytes()` for picked file input; this improves input portability but **does not finish web persistence**. Implement a platform-specific cover storage adapter. On web, persist blobs in IndexedDB (or a tested equivalent); on native targets, use app-managed files.
- Check the Drift web configuration against the pinned package version. The app references `drift_worker.dart.js`; current Drift documentation describes the WASM module and worker setup, so verify the exact worker filename, MIME type, base path, and production headers.
- Test close/reopen persistence on native and web, including deployed web builds and browser storage warnings.

### P1 — Make Discover recommendations honest

- Text similarity and history fit are still stubs, but their weights remain in the formula. The ranking therefore does not normalize only over implemented signals.
- External catalog candidates are displayed without passing through the recommendation engine.
- Catalog candidates can be added immediately; the documented product flow requires preview and selective metadata import.
- The current Discover catalog query is derived from the most common saved genre rather than a user-controlled title/author query.

### P1/P2 — Cover handling

- The included patch fixes the mismatched key but does not finish cross-platform storage.
- `storeImage()` should create the `covers/` directory before writing.
- Cover asset persistence must be abstracted for web, and tests must verify store -> reload -> display.
- The currently used `file_picker` package is 13.1.0; its current package documentation supports web picking and provides `PlatformFile.readAsBytes()`/`length()`. Picking a file and persisting its bytes are separate responsibilities. See https://pub.dev/packages/file_picker.
- Current Drift web documentation describes configuring the SQLite WASM module and worker and selecting a supported browser persistence implementation. Verify the exact file names and configuration against the locked Drift versions instead of copying config from a different version. See https://github.com/simolus3/drift/blob/develop/docs/content/platforms/web.md and https://pub.dev/documentation/drift/latest/wasm/.
- Flutter's current WebAssembly docs explain the `--wasm` build path and the cross-origin headers needed for multithreaded web builds. Add `flutter build web --wasm` to CI only after the dependency set is confirmed compatible. See https://docs.flutter.dev/platform-integration/web/wasm.

### P2 — Product polish and maintainability

- The source has overlapping export/import service implementations; choose one canonical service, migrate callers, then remove duplicates.
- Some lookup dialogs/services exist, but the main Library manual-entry flow does not clearly expose lookup as an optional step.
- Dashboard metrics and recommendation inputs currently load whole sets into memory. Keep screen queries bounded and use SQL aggregation for counts.
- Replace generic starter metadata in `pubspec.yaml` and `web/index.html` with real Dandelion app title/description before release.
- Add accessibility checks for large text, narrow screens, keyboard focus, semantics, contrast, loading/error/empty states.

## Recommended execution order

1. Apply the first-fix patch on a new branch.
2. Run format, analyze, tests, and web build. Repair every failure; don't disable checks to make CI green.
3. Restore a meaningful test suite.
4. Make import/export atomic and test the rollback path.
5. Remove the 500-record truncation from complete-data operations and add pagination for the UI.
6. Repair nullable field clearing and ISBN fallback.
7. Implement native/web cover storage correctly and prove persistence.
8. Complete the hybrid recommendation signals and preview/selective-import flow.
9. Reconcile duplicate services and update implementation-status documentation only after verification.

## Current feature readiness

| Area | Assessment |
|---|---|
| Navigation and per-screen app bars | Core duplicate-app-bar issue appears resolved |
| Library CRUD and reading records | Basic implementation exists; test coverage and edge cases remain |
| Wishlist | Basic implementation exists; test coverage remains |
| External lookup | Basic service exists; preview/selective import and errors need verification |
| Recommendations | Partially implemented; not yet the documented hybrid algorithm |
| Native cover storage | Basic implementation, with catalog-key bug patched by the included patch |
| Web cover storage | Not yet implemented as durable browser storage |
| Backup/restore | Export/import code exists; restore is not safe enough yet |
| Tests and CI | Not release-ready until the workflow works and a real suite is restored |
| All six platforms | Claimed scope, not proven by this static review |
