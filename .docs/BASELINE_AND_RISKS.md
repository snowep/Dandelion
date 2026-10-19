# Baseline and risk register

**Snapshot:** 2026-10-19  
**Branch:** `master`  
**HEAD:** [`b285f5cf7a61dabfde4ccb8bdefba70ffa0cf207`](https://github.com/snowep/Dandelion/commit/b285f5cf7a61dabfde4ccb8bdefba70ffa0cf207)

| ID | Severity | Risk | Current evidence | Exit evidence |
|---|---|---|---|---|
| R0 | P0 | Import may skip valid books or overwrite the wrong item because title/author filter keys are ignored | Source review of `importArchive` and `listBooks`; no regression test | Exact-match implementation + tests against non-empty destination |
| R1 | P0 | CI doesn't reach tests/build | Latest Actions run #34 failed `flutter analyze`; format passed | Format, analyze, test, web build all pass on same commit |
| R2 | P1 | v3→v4 migration is implemented but not actually tested | Migration test only constructs a fresh memory DB | Real v3 fixture upgrades with data preserved |
| R3 | P1 | Import is not atomic; overwrite omits some fields/reading records | Source review; no transfer tests | Full round-trip and injected-failure rollback tests |
| R4 | P1 | Covers use native-only filesystem APIs, don't ensure destination dir exists on store, and catalog cover key mismatches file key | `cover_image_service.dart`, `discover_screen.dart` | Native/web tests and matching key proof |
| R5 | P1 | Stable tags, package version and docs conflict | Existing tags target older commits; manifest `0.2.0+1`; no GitHub Release entries | Version decision recorded; manifest/tag/release notes agree |
| R6 | P2 | Status filter join likely not applied correctly | `getBooksFiltered` calls `query.join` without assigning result | Repository/database tests demonstrate every status works |
| R7 | P2 | Pagination offset ignored in `getAll` | `BookRepositoryImpl.getAll` ignores `offset` | Two-page test returns distinct stable pages |
| R8 | P2 | Nullable model fields cannot be cleared | `copyWith` uses nullable args + `?? this.field` | Clearing tests for Book and ReadingRecord fields |
| R9 | P2 | Theme switch doesn't express System/Light/Dark correctly or persist choice | Initial state is `system`; switch only reflects `dark`; notifier isn't persisted | Widget tests for each choice and restart/persistence test if persistence remains in scope |
| R10 | P2 | Recommendation denominator includes stubbed signals | `textSimilarity` and `historyFit` are hard-coded zero but weighted | deterministic ranking + tests for sparse metadata and cold start |
| R11 | P2 | UI/metadata performance not measured at large scale | no 5,000-book perf test or cross-platform smoke evidence | documented profiling output and platform matrix |

## What the audit did and did not do

Reviewed repository tree, source files, recent commit history, tag targets, latest Actions run and its job log. Did not modify the repo, run Flutter locally, or claim the skipped CI steps pass. Static findings must be verified by running the specified regression tests after changes.
