# Dandelion — repository audit (refreshed)

**Reviewed:** 2026-10-19  
**HEAD:** [`b285f5cf7a61dabfde4ccb8bdefba70ffa0cf207`](https://github.com/snowep/Dandelion/commit/b285f5cf7a61dabfde4ccb8bdefba70ffa0cf207)  
**Previous baseline:** `86e48560e8500221f4056c2ba92089f01f57a125`  
**Verdict:** stronger prototype; still not release-ready. Keep the existing Flutter/Riverpod/GoRouter/Drift architecture. Stabilize and test it rather than rewriting it.

## What the latest commits improved

| Area | New state | Evidence / qualification |
|---|---|---|
| Settings imports | **Resolved at source level** | `lib/features/settings/settings_screen.dart` and `theme_notifier.dart` are now present. Settings behavior still needs a UI test and better theme-mode control. |
| Provider tree | **Resolved at source level** | `DandelionApp` no longer creates a nested `ProviderScope`; `main.dart` owns the root provider scope. |
| Database schema | **Implemented, not migration-verified** | `schemaVersion` is now `4` and `onUpgrade(from < 4)` adds the 12 purchase/lending columns. The test named `migration_v3_to_v4_test.dart` only opens a new in-memory v4 database; it does not open a legacy v3 database. |
| Backup fields | **Partially resolved** | JSON export and the new-book import path include purchase, currency, borrowing and lending fields. Conflict overwrite still omits those fields and nullable `copyWith` values cannot be cleared. |
| Tests | **Improved, still too thin** | Three test files now exist. There are no repository/filter, actual migration, import/export, cover, lookup, recommendation, or cross-platform integration regressions. |
| Formatting | **Resolved for current CI run** | Latest CI's format step succeeds: 46 files, 0 changed. |
| CI | **Still red** | Latest run fails at `flutter analyze`; `flutter test` and `flutter build web` are skipped. |
| Docs | **Committed but stale** | Several `.docs` files still cite the earlier `86e4856` baseline or older source state. `.docs/ROADMAP_TO_V1.0.0.md` incorrectly says `v1.0.1` points to current `master`; it points to `86e4856`, while current `master` is four commits newer. |

## P0 — block further release work

### 1. Fix the archive-import false-match/data-corruption bug

`ImportService.importArchive()` calls:

```dart
_repository.listBooks(filters: {'title': book.title, 'authors': book.authors})
```

But `BookRepositoryImpl.listBooks()` only extracts `search`, `status`, and `genre` from `filters`. `title` and `authors` are ignored. The fallback `titleMatch` therefore may be the first book returned, not a real title/author match. With default `skipConflicts: true`, this can skip valid imports; with `overwrite: true`, it can overwrite the wrong existing book. Replace this with a real exact normalized match operation, add collision-safe rules, and test with a non-empty destination library.

### 2. Restore a green automated verification gate

Latest run: [Flutter CI run #34](https://github.com/snowep/Dandelion/actions/runs/39174776122), commit `b285f5cf7a61dabfde4ccb8bdefba70ffa0cf207`.

`Format check` passed. `flutter analyze` failed with four findings:

- Warning: unused `_compare` at `lib/features/library/book_repository_impl.dart:544:14`.
- Info: `BuildContext` used across async gap at `lib/features/library/library_screen.dart:138:16`.
- Info: `BuildContext` used across async gap at `lib/features/wishlist/wishlist_screen.dart:62:16`.
- Warning: unnecessary null comparison at `lib/services/library_export_import_service.dart:170:17`.

The workflow skipped `flutter test` and `flutter build web`, so neither has a passing result. Fix all four findings rather than suppressing warnings, then make the pipeline finish end-to-end.

## P1 — protect existing user data and validate the platform

### 3. Make import atomic and define overwrite semantics

Database writes are performed in a loop without one transaction spanning the complete import. A mid-import failure may leave a partial library. Cover file writes happen after database writes and can fail independently. The import validator is also permissive about field types, cross-file references, duplicate incoming records, bounds, and archive size.

The overwrite-by-title/author path fails to copy the purchase and lending fields into the matched record. Reading-record data is only applied in the create-new path, not consistently on overwrite. `copyWith(x: null)` does not clear nullable fields, so overwriting with a backup cannot reliably remove an existing nullable value. Define and test explicit merge/replace/skip semantics. Stage covers, validate the entire input, then use rollback-safe writes and cleanup.

### 4. Test the actual v3 → v4 migration

The migration code now exists, but the current migration test creates a fresh `AppDatabase(NativeDatabase.memory())`. That exercises `onCreate`, not `onUpgrade`. Build a v3 fixture with an existing book and reading record, reopen it through the v4 database, and verify all old values remain while all new fields have correct defaults/nulls. Run code generation and ensure the generated Drift file is consistent.

### 5. Implement browser-safe cover storage

`lib/shared/services/cover_image_service.dart` imports `dart:io`, uses `File`/`Directory` and `path_provider`, and expects a file path from the picker. This is shared across screens in a project that declares web support. The current CI has not reached a web build. Provide conditional native/web persistence and use selected bytes when a physical path is unavailable. `storeImage()` does not create the `covers/` directory. `DiscoverScreen._saveCatalogBook()` generates one UUID for the stored image and a second UUID for `coverAssetKey`, so the metadata points at the wrong filename.

### 6. Prove complete export/restore

Straight JSON export now includes the purchase/lending fields; that part should not be reported as entirely missing. Remaining risks are: import matching and overwrite are incorrect, no transaction protects partial restore, cover writes are unverified, legacy backup-version policy is unclear, and no round-trip regression tests exist. Test books, reading records, nullable fields, covers, duplicate ISBNs, archive corruption, and a forced mid-import failure.

## P2 — correctness, usability, and maintainability

7. **Repository offset bug remains.** `BookRepositoryImpl.getAll({limit, offset})` ignores `offset`. It only passes `limit` to `getAllBooks()`.
8. **Status filter join remains incorrect.** `getBooksFiltered()` invokes `query.join([...])` without assigning the returned joined query, then references `readingRecords.status`; add a regression test and build the query correctly.
9. **Sort/filter contract mismatch.** Database sort supports `title`, `author`, and `date`, then defaults to title. Ensure every visible sort control maps to explicit DB behavior with stable tie-breakers. Verify repository filters are implemented, not merely accepted by the API.
10. **Search does not include reading notes.** If retained in PRD, implement it with a correct query/join; otherwise explicitly change product scope.
11. **Nullable copy operations cannot clear values.** `Book.copyWith` and `ReadingRecord.copyWith` use `x ?? this.x`, blocking clear operations for nullable data.
12. **ISBN fallback is fragile.** Repository code selects `book.isbn13 ?? book.isbn10`; empty-but-non-null ISBN-13 can mask valid ISBN-10.
13. **Theme control is misleading.** `ThemeModeNotifier` starts at `ThemeMode.system`, while the Settings switch only checks `themeMode == ThemeMode.dark` and calls a toggle that maps system to light. Provide explicit System/Light/Dark selection or a switch whose boolean value truly sets the selected state. Theme persistence across restart is not implemented.
14. **Recommendation score still includes stub signals.** `textSimilarity` and `historyFit` are set to `0`, but their weights still enter the denominator. Preference profiles are rebuilt for every candidate, and external catalog candidates are not ranked by the same engine.
15. **Performance is not proven.** Keep unlimited/full export correctness, but separate complete iteration from paginated UI queries and avoid eager concurrent cover loading for a large library. Profile a 5,000-book fixture before optimizing speculatively.
16. **Docs and cleanup lag behind code.** `pubspec.yaml` is `0.2.0+1`; previous `.docs/VERSIONING_AND_TAGS.md` says `1.0.0+1`. `.docs/PROJECT.md` still says Phase 0 tasks are unchecked. Old `.backup`/`.bak` files and duplicate legacy screens remain tracked; check references before removing them.

## Release/tag state

- Current `master`: `b285f5cf7a61dabfde4ccb8bdefba70ffa0cf207`.
- `v1.0.0` points to commit `193d9c2e31fdfab61397596645b26df5ddeb7e9d`.
- `v1.0.1` points to commit `86e48560e8500221f4056c2ba92089f01f57a125`.
- `pubspec.yaml` still says `0.2.0+1`.
- GitHub Releases API currently returns zero published releases.

Do not move/delete tags automatically. The safe default is to resolve the current history/version mismatch and publish the next verified release as `v1.0.2`, updating `pubspec.yaml` to match. If the maintainer specifically requires `v1.0.0` as the first usable stable tag, that requires an explicit decision about the already-pushed `v1.0.0` and `v1.0.1` refs. See `VERSIONING_AND_TAG_POLICY.md`.

## Keep these choices

- Flutter/Dart, Riverpod, GoRouter, Drift and the current feature-based organization.
- Single root `ProviderScope`.
- Page-owned app bars and adaptive shell navigation.
- Manual entry as the offline fallback; external lookup must remain optional.
- No remote sync/community work before the local library and backups are reliable.

**Exit verdict:** not release-ready. First clear CI and add meaningful regressions. Next fix archive import integrity before trusting backups. Then validate v3 migration, cover storage, repository/model behavior, and each declared platform.
