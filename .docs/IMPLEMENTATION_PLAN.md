# Dandelion — ordered implementation plan

Execute phases in order. Do not begin a later phase while the current phase has failed acceptance criteria. The app-bar ownership fix appears present in the reviewed baseline; retain it and add regression tests.

## Phase 0 — Re-establish a trustworthy build and CI

**Goal:** A compatible toolchain and repeatable verification path exist before further changes.

### Step 0.1 — Verify the current working baseline

1. Check `git status --short`, current branch, current commit, and remotes.
2. Confirm that the branch is based on the latest intended `master` head; do not reset or overwrite uncommitted work.
3. Read all five existing `.docs` specifications.
4. Run `flutter --version`, `dart --version`, and `flutter pub get`. Capture output and exit codes.
5. Inspect `pubspec.yaml`, `pubspec.lock`, `analysis_options.yaml`, `.github/workflows/`, and the actual `test/` tree.

**Acceptance:** report the exact commit and clean/dirty state; know whether dependency resolution currently succeeds; list actual tests and workflows.

### Step 0.2 — Align the SDK pin and project constraint

1. Keep the declared Dart requirement `^3.13.5` unless a compatibility review proves that requirement is wrong. Do not lower it just to preserve an obsolete CI pin.
2. Select an exact stable Flutter version that bundles a Dart SDK satisfying `^3.13.5` and is compatible with the locked dependencies.
3. Confirm the chosen SDK with `flutter --version` and `dart --version` both locally and in CI.
4. Update the workflow pin and regenerate `pubspec.lock` only if dependency resolution requires it. Avoid broad dependency upgrades in this step.

**Acceptance:** local and CI resolve the same dependency set using a compatible pinned SDK.

### Step 0.3 — Repair GitHub Actions

**File:** `.github/workflows/flutter-ci.yml` (or one clearly named canonical workflow).

1. Use valid GitHub Actions structure: `name`, `on`, `permissions` if needed, `jobs`, `runs-on`, and `steps`.
2. Trigger on pull requests and pushes to `master`. Include manual dispatch if helpful for diagnosing builds.
3. Use supported setup actions as steps, pin their versions responsibly, and avoid unsupported job-level keys.
4. Run these steps in order: checkout, install the pinned Flutter SDK, `flutter pub get`, format check, `flutter analyze`, `flutter test`, and `flutter build web`.
5. Configure least-privilege workflow permissions. Do not add secrets; CI for the MVP should not require them.
6. Make each check visible as a named step. A failed required step must fail the job.
7. Do not claim test coverage by passing an empty/missing test directory; complete Step 0.4 before declaring the pipeline reliable.

**Acceptance:** a pull request and a push to `master` each trigger the intended workflow; the workflow uses a valid schema and a compatible SDK; format, analysis, tests, and web build show real passing results.

### Step 0.4 — Restore a minimal meaningful test suite

**Files:** `test/` and source files as required.

Restore tests that match the current app architecture rather than resurrecting obsolete tests verbatim.

Required minimum tests:

- App starts under `ProviderScope` with injected test repository/providers.
- Routes render the expected destination.
- Library/Wishlist navigation selects the right destination.
- Each page shows one intended page header; shell must not add a second `AppBar` over page-owned headers.
- Repository can create, read, update, archive, delete, and reopen test data.
- Invalid progress and invalid ratings are rejected.

Use an in-memory Drift database or temporary isolated test database. Tests must not touch a developer's real library. Do not require internet.

**Acceptance:** `flutter test` executes actual tests and passes; a deliberately failing assertion is known to fail the CI test job (verify workflow behavior if practical).

**Phase 0 exit gate:** compatible SDK; valid CI workflow; real tests run; format, analyze, tests, and web build pass.

---

## Phase 1 — Make import/export safe before expanding data features

**Goal:** Users can back up and restore data without silent loss.

### Step 1.1 — Choose one canonical import/export service

**Current files to inspect:**
- `lib/services/library_export_service.dart`
- `lib/services/library_export_import_service.dart`
- `lib/services/library_import_export_service.dart`

1. Search all imports and constructor uses in `lib/` and `test/`.
2. Select one canonical service for JSON export and archive import/export. Prefer a clear API that supports both operations; move shared transfer objects into one small file if necessary.
3. Migrate every call site and test.
4. Remove duplicate implementations only after all callers use the canonical service.
5. Keep a versioned schema and document the compatibility policy in `.docs/STACK.md` or this plan.

**Acceptance:** exactly one canonical path owns import/export behavior; the project compiles and tests use that path.

### Step 1.2 — Validate a backup completely before modifying the database

1. Decode the archive and reject invalid ZIP data, missing manifest, unsupported schema versions, duplicate IDs, duplicate normalized ISBNs, missing required fields, invalid statuses, impossible progress/rating values, and references to missing books.
2. Apply limits to archive size, entry count, individual file size, image size, and decompressed total size. Reject unsafe archive paths and invalid cover asset keys.
3. Validate every cover image before writing it. Do not trust extensions alone.
4. Produce an import preview containing counts, warnings, conflicts, and errors.
5. Do not delete or change existing records until all validation succeeds and the user has explicitly selected the intended import action.
6. Preserve old data by default. If a replace-library operation is offered, make the destructive behavior explicit in the UI and confirm it.

**Acceptance:** invalid input leaves all existing books, reading records, and existing cover files usable and unchanged.

### Step 1.3 — Make replacement import atomic and cover-aware

1. Stage new cover files under temporary/new asset keys; do not overwrite currently referenced cover files during validation.
2. In one Drift transaction, apply the database replacement or selected merge operation, preserve book-to-reading-record relationships, and map exported IDs to the resulting IDs.
3. Finalize/rename staged assets only after validation. If the database operation fails, roll back it and remove staged files. If asset finalization fails after a database transaction, restore consistency or roll back through an explicit recoverable staging approach; do not leave rows silently pointing to missing assets.
4. Resolve ID remapping and unique ISBN constraints deterministically.
5. Report failures with a useful message, not a swallowed exception.

**Acceptance:** tests prove successful round trip and failure rollback. A failed import cannot erase the user's previous library.

### Step 1.4 — Deliver a portable export format

1. Keep metadata-only JSON export.
2. Include a versioned `library.json` manifest and referenced cover assets in the full archive, following the canonical layout described in `.docs/STACK.md`.
3. Keep reading status, page/percentage progress, dates, ratings, personal notes, ISBNs, cover references, and schema version.
4. Use platform-appropriate file selection and save/download behavior; the export service must not require `dart:io` on web.
5. Make missing/corrupt cover handling explicit. A missing cover must not silently masquerade as a complete image backup.

**Tests:** export/import round trip with covers; empty library; missing cover; duplicate ISBN; malformed JSON/ZIP; unsupported version; path traversal; oversized entry; failed import leaves prior data intact.

**Phase 1 exit gate:** full-backup round trip works on a native test target; validation is complete before writes; rollback behavior is tested; one canonical service remains.

---

## Phase 2 — Correct the database query contract and scale beyond 500 books

**Goal:** no screen or data operation silently truncates the user's library.

### Step 2.1 — Separate paginated screen queries from complete data operations

**Files to inspect:** `book_database.dart`, `book_repository.dart`, `book_repository_impl.dart`, dashboard providers/services, Library, Wishlist, Discover, and export/import consumers.

1. Identify every caller of `getAllBooks()`, `searchBooks()`, `getAll()`, `listBooks()`, and related methods.
2. Remove the silent 500-record cap from complete-data operations used by backup or migration.
3. Add explicit bounded/paginated queries for screens (limit, offset or keyset cursor, filters, stable ordering).
4. Push filter and sort work into SQL instead of loading up to 500 records and sorting/filtering in Dart.
5. Ensure `status` filtering performs a real join/subquery; do not call a join API and discard its returned query.
6. Add stable tie-breakers and explicit null ordering so pagination doesn't reorder equal items unpredictably.
7. Use SQL aggregates for dashboard counts/means where practical instead of fetching all rows to count them.

**Acceptance:** a fixture larger than 500 books can page through every record; search, sort, filters, dashboard metrics, Discover inputs, and export do not silently omit records.

### Step 2.2 — Complete local search requirements

1. Support title, author, ISBN, genre, description, and personal notes.
2. Check FTS5 availability on target runtimes. Use FTS5 only where verified; document and test an indexed/SQL fallback where it is not available.
3. Bind input values rather than building SQL from raw input.
4. Keep catalog lookup clearly separate from offline local search.
5. Keep interactive search debounced and prevent stale responses from replacing newer results.

**Acceptance:** tests cover case/whitespace normalization, multiple search fields, notes, no results, special characters, and fallback behavior.

### Step 2.3 — Align schema and model safely

1. Inspect use of both `authors` and `author` in the Drift schema and migrations.
2. Choose one canonical persisted author representation or document why two representations are required.
3. Migrate existing data without loss; never edit a released schema without updating schema version and migration tests.
4. Keep normalized ISBN uniqueness explicit and predictable.
5. Review foreign keys, cascade deletion, query indexes, and timestamp normalization.

**Acceptance:** schema, domain model, repository, and backup format represent the same fields; migration tests start from prior schema versions.

**Phase 2 exit gate:** tests with more than 500 records prove complete, deterministic query and export behavior.

---

## Phase 3 — Fix domain-field clearing and book-state correctness

**Goal:** edit flows can express the user's intent without retaining stale values.

### Step 3.1 — Correct nullable `copyWith` semantics

1. Review `Book.copyWith()` and `ReadingRecord.copyWith()`.
2. Adopt one consistent explicit clearing pattern for nullable fields (for example a documented sentinel or explicit clear flags).
3. Apply it to description, page count, cover key, publication date, external metadata, current page/percentage, start/finish dates, rating, and notes where each field can be cleared.
4. Preserve the current value only when the caller omits the parameter; clear it when the caller explicitly requests clearing.

**Tests:** retain omitted values; clear every nullable user-editable field; update unrelated fields without dropping other data.

### Step 3.2 — Fix ISBN normalization and duplicate rules

1. Normalize spaces, hyphens, and case.
2. Select the first non-empty valid ISBN-13, otherwise ISBN-10; do not treat the default empty string as present data.
3. Test duplicate detection on create/update and exclusion of the current book while editing.
4. Keep a title+author match as a warning when ISBN is missing; do not auto-merge uncertain records.
5. Ensure metadata lookup cannot overwrite personal notes, rating, reading status, progress, or dates without explicit user choice.

**Tests:** ISBN-10 only, ISBN-13 only, empty values, formatted ISBNs, duplicate create, duplicate update, and edit preserving personal fields.

### Step 3.3 — Validate progress and state transitions

1. Enforce `currentPage >= 0` and `currentPage <= pageCount` when page count is known.
2. Enforce percentage from 0 to 1 and rating from 0 to 5.
3. Set finish date when a book is marked Finished; preserve/correct it according to explicit user action when changing status later.
4. Make transition out of Wishlist consistent across the `isInWishlist` flag and reading status.
5. Ensure errors appear in the UI and never become silent failed writes.

**Acceptance:** repository tests and widget tests cover valid/invalid values, status changes, and date clearing/editing.

---

## Phase 4 — Implement truly cross-platform cover storage

**Goal:** manual and catalog covers work on all intended platforms and remain retrievable after restart.

### Step 4.1 — Separate platform storage from UI

1. Keep cover operations behind a small repository/service interface.
2. Native platforms may use app-managed filesystem storage.
3. Web must use a browser-supported persistent store for cover bytes (for example IndexedDB), not `dart:io` or a native document directory.
4. Use the file picker's bytes interface where a real filesystem path is unavailable.
5. Do not let web-imported Dart files import `dart:io` unconditionally. Use supported APIs/conditional implementations where required.
6. Validate byte type, decoded image, and size; resize large images and bound caches.

### Step 4.2 — Fix catalog cover identity

1. Generate the asset key once.
2. Pass the exact key to `storeImage()` and to the book's `coverAssetKey`.
3. Create/initialize native directories when needed; ensure the web store is initialized as well.
4. If download/storage fails, save the book without a local cover and show a placeholder; don't save a broken key.
5. Ensure the same path/key validation applies on store, load, delete, and import.

**Acceptance:** tests prove manual and provider cover store/load/delete behavior; catalog cover bytes reopen after restarting the app; no mismatched keys. Web browser storage and deployed asset paths are smoke-tested separately.

---

## Phase 5 — Finish optional title/ISBN lookup integration

**Goal:** lookup is useful but cannot block manual book entry.

1. Connect the lookup flow to the Library add/edit UI with both ISBN and title search (use the existing service/dialog where suitable).
2. Show a preview of the candidate edition and allow the user to choose metadata fields before save.
3. Explain that lookup needs internet; if it fails, keep the user's manual form values intact and allow saving manually.
4. Keep result parsing tolerant of absent/malformed fields, rate limits, timeout, and no result.
5. Deduplicate by normalized ISBN first, then warn for likely normalized title+author matches.
6. Store source/provider metadata and attribution where required.
7. Test browser CORS and requests from target platforms before claiming lookup support there.

**Acceptance:** manual create works offline; lookup works where tested; provider failure leaves manual create available; selected metadata cannot silently overwrite personal reading data.

---

## Phase 6 — Complete the hybrid recommendation engine

**Goal:** rank both local and external candidates honestly and explain the result.

### Step 6.1 — Implement only real signals

The product spec's starting weights are:

`score = 0.25*genreSimilarity + 0.10*authorSimilarity + 0.20*textSimilarity + 0.35*historyFit + 0.10*novelty`

1. Implement genre similarity and author preference using normalized values.
2. Implement title/description text similarity (TF-IDF + cosine similarity) or explicitly remove that signal from the score until implemented.
3. Implement history fit from actual statuses, ratings, and recency without assuming every finished book is a favorite.
4. Compute novelty from actual status/dismissal information; do not label a candidate “new” merely because it is not finished if it is already saved.
5. Normalize over signals that have usable input data. A stubbed zero is not the same as a real negative signal.
6. Keep ranking deterministic for identical records and use a stable tie-breaker.

### Step 6.2 — Rank external catalog candidates

1. Build the preference profile from local reading records.
2. Fetch a bounded result set only when the user opens or requests catalog discovery.
3. Exclude or clearly label candidates already in the library/wishlist using ISBN and provider IDs where available.
4. Score external candidates using available metadata and adjust weights when fields are missing.
5. Keep external candidates unsaved until the user explicitly saves them.
6. Generate explanation strings only for signals that were computed and contributed to the score.
7. Handle cold start, empty genres, failed network calls, and catalog results with missing metadata.

**Tests:** empty history; missing genres/author/description; tied results; finished/dismissed items; duplicate catalog results; external candidates; weight normalization; grounded explanation output.

**Acceptance:** neither local nor external ranking pretends to use unimplemented signals; both paths are deterministic and explainable.

---

## Phase 7 — UX, accessibility, integration, and performance

1. Add route/header regression tests at compact and wide widths. The shell owns navigation only; each screen owns its header.
2. Test viewport widths around the 720-pixel navigation breakpoint and a narrow mobile width (for example 320 px).
3. Fix summary cards and other dashboard rows that overflow when space or text size is constrained; prefer responsive wrap/sliver layouts over hard-coded height increases alone.
4. Test system light/dark themes, large text scaling, keyboard navigation, semantics, focus order, and contrast.
5. Ensure Library/ Wishlist/Discover/Insights expose loading, empty, offline, error, retry, and no-results states.
6. Keep long lists lazy and paginate. Load covers near the viewport and use resized thumbnails; do not load every cover into memory at once.
7. Profile a 5,000-book fixture and fix measured bottlenecks. Do not add complex caches/isolates before measuring.
8. Test navigation and primary book actions end-to-end with a deterministic test repository/database and without internet.

**Acceptance:** no known overflow at required widths and text sizes; core flows are accessible; a 5,000-book fixture is usable without loading all rows/images at once.

---

## Phase 8 — Platform proof and documentation reconciliation

1. Test persistence on Android, iOS, web, Windows, macOS, and Linux where available. Record exactly which targets were built and manually smoke-tested.
2. For web, test a deployed build as well as local development: `sqlite3.wasm`, worker paths, MIME type, base path, browser persistence, reload/reopen, private-browsing limitation, and relevant headers.
3. Verify that browser storage limitations are clearly explained and never presented as a backup.
4. Test native desktop SQLite packaging on clean runners/devices where practical.
5. Update `.docs/PROJECT.md` checkboxes only after the corresponding exit criteria pass. Record untested targets as unverified rather than supported by assumption.
6. Keep `.docs/PRD.md`, `STACK.md`, and `CONVENTIONS.md` consistent with actual APIs and behavior. Do not rewrite the product scope to match an incomplete implementation.
7. Complete the pre-release checklist in `CI_AND_RELEASE_GATES.md` before making any Git tag.

**Acceptance:** every claimed platform has evidence, backups round-trip, and documentation accurately distinguishes complete, partial, and unverified functionality.

## Required report at the end of each phase

Use this format:

- **Phase / step:** identifier and short name.
- **Changed:** observable behavior and file paths.
- **Tests added:** names and risks covered.
- **Verification:** exact command, exit code, and result.
- **Not verified:** platforms, flows, or claims not tested.
- **Remaining blockers:** concrete issue and the step that will resolve it.
- **Version impact:** none / patch / minor / breaking; explain according to `VERSIONING_AND_TAGS.md`.

Do not tag a release after every commit. Tags represent an approved release, not an implementation step.
