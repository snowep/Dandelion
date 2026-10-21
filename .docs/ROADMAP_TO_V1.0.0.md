# Roadmap toward a defensible Dandelion stable release

**Baseline:** `master` at `2dbcf7f` (2026-10-20).

## Release history gate

The repository already has `v1.0.0` and `v1.0.1`, but neither points at the current `master`; both point to older commits. `pubspec.yaml` still declares `0.2.0+1`, and there are no published GitHub Release entries. A version string or tag alone is not evidence that the application is release-ready.

Default recommendation: preserve both pushed tags, complete the readiness work, and publish the next valid release as `v1.0.2` with a matching `pubspec.yaml` version. If the owner insists that the next usable stable package must be named `v1.0.0`, stop before the release candidate and explicitly decide how to handle existing tags. Do not force-move or delete tags as part of routine cleanup.

## Ordered update plan

| Order | Update | Main outcome | Gate |
|---|---|---|---|
| U0 | CI/analyzer/test unblock | Remove four diagnostics, run tests and web build end-to-end | Current-head CI fully green; no skipped steps ✅ |
| U1 | Import matching and transaction safety | Import never mistakes the first book for a title match; no partial restore | Round-trip, conflict/overwrite and rollback tests pass ✅ |
| U2 | Real schema v3→v4 migration test | Existing libraries retain records through migration | Legacy v3 DB fixture upgraded and validated ✅ |
| U3 | Cross-platform cover storage | Native and web cover selection/read/write/export work | Web build + deployed smoke test + native tests ✅ |
| U4 | Repository and model correctness | Fix offset, status filter, sorting, ISBN and clearable nullables | Database/domain regressions pass ✅ |
| U5 | Catalog and offline library flow | Optional lookup integrates with add/edit and exact cover persistence | Provider mocked; offline/manual flow passes |
| U6 | Recommendation integrity | Only implemented signals contribute; local and external candidates are ranked | Cold-start/missing-data/determinism/explanation tests pass |
| U7 | Settings, accessibility and docs | Real theme options, responsive behavior, updated product docs | Theme/UI/accessibility checklist passes; docs cite verified state |
| U8 | Performance and platform validation | Large-library behavior and declared platform support are measured | 5,000-book profile and platform matrix complete |
| U9 | Release candidate | Version/changelog/backup proof and complete CI | All automated and manual gates green |
| U10 | Stable release | One agreed tag and release artifact/release notes | No open P0/P1; release tag matches `pubspec.yaml` |

## Immediate execution order

1. Give the agent `updates/00-ci-analysis-and-test-unblock.md` only. Fix the current analyzer findings and ensure `flutter test` and `flutter build web` actually execute. ✅
2. Immediately after CI is runnable, give it `updates/01-import-matching-and-transaction-safety.md`. Treat current archive import as untrusted until this passes. ✅
3. Give it `updates/02-real-v3-v4-migration-test.md`; schema version 4 exists, but current tests do not exercise migration. ✅
4. Continue through U3–U8 in order. Keep changes small and commit each acceptance unit separately. ✅
5. Before U9, update stale repository docs and the file manifest. Decide formal tag/version policy explicitly. ⏳
5. Do not add remote sync, community, social accounts, AI/LLM recommendation calls, or ebook-reader scope before 1.0.

## Acceptance definition

A stable release requires: full CI green; actual v3→v4 migration tests; safe export/import round trips including reading records, all book fields and covers; rollback on import failure; correct filters/sort/pagination/search; no nullable-clear defects; correct cover storage on every declared target or a documented unsupported-platform decision; deterministic explainable recommendations; usable theme behavior; keyboard/semantics/large-text checks; 5,000-book performance evidence; clean changelog/version/docs; and a tested backup before upgrading existing user data.
