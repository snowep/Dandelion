# Roadmap — toward a defensible Dandelion 1.0 release

## Release-history gate comes first

This repository already has Git tags `v1.0.0` and `v1.0.1`; the latter points at current `master`. The source manifest still says `0.2.0+1` and the GitHub Releases API contains no release records. Existing tag targets are not ready according to this audit. The plan below is therefore a **1.0 readiness roadmap**, not permission to rewrite tag history.

Recommended version policy: preserve existing tags and make the next actual stable release `v1.0.2` after all gates pass. If the maintainer insists on a true `v1.0.0` tag for the first stable release, pause before RC and explicitly decide whether those already-pushed tags can be retired. See `VERSIONING_AND_TAG_POLICY.md`.

## Execution phases

| Order | Update | Main outcome | Must pass before continuing |
|---|---|---|---|
| U0 | Build, Settings and CI recovery | All imported files exist; one ProviderScope; formatting/analyze work; route tests exist | `dart format`, `flutter analyze`, `flutter test` all pass; no missing imports |
| U1 | Schema v4 migration | v3 users retain books and gain purchase/lending fields | Migration fixture from v3 upgrades without data loss; schema generation clean |
| U2 | Backup/import correctness | Full book and reading metadata + covers round-trip; failed import leaves current data unchanged | Export→import round-trip; injected write failure proves rollback |
| U3 | Cross-platform cover storage | Native and web can select, save, read and back up covers offline | Web compile/deployed smoke test; native tests; key consistency proven |
| U4 | Repository/model correctness | Pagination, filters, sort, ISBN, clearable fields and note search behave correctly | Unit/database regression tests for each exposed action |
| U5 | Catalog and library flows | Manual entry, optional lookup, preview, dedup, fallback and saved metadata integrate | Mocked provider tests, manual fallback offline, no personal-field overwrite |
| U6 | Explainable recommendations | Local and bounded external candidates ranked deterministically with grounded reasons | Tests for cold start, missing metadata, ties, dismissals and external candidates |
| U7 | Scope and UX completion | Settings, accessibility, reading tracker/purchase/lending specs align with UI and docs | Compact/wide layouts, keyboard/semantics, large text, both themes verified |
| U8 | Performance and platform validation | Large fixture responsive; data survives restart per supported platform | 5,000-book test/profiling; target smoke tests; browser persistence limitations documented |
| U9 | Release candidate | Clean dependency lock, migration/export evidence, changelog, version decision and rollback notes | Full CI green and manual checklist in `RELEASE_CHECKLIST.md` |
| U10 | Stable release | Create/publish exactly one agreed, immutable release tag and release notes | All blockers closed; CI green on release commit; backups tested before upgrade |

## First tasks in exact order

1. Read `updates/00-build-and-settings-repair.md`. Apply `dart format .` in a focused commit; implement the Settings files required by imports or remove the intended feature consistently. Keep only one ProviderScope at the root. Add a real `test/` suite immediately. Rerun CI so analyze is no longer skipped.
2. Build schema-version 4 migration from current v3. Do not edit `book_database.g.dart` by hand; run Drift generation and review the output.
3. Fix export/import before changing more persisted fields. Add purchase/lending fields to export and import, add full cover bytes, validate before writing, and make database changes transactional.
4. Replace the shared native-only cover service with native/browser implementations. Test deployed web, not only local dev server.
5. Correct query/model edge cases and add one regression test per exposed sort/filter/status/nullable field.
6. Finish catalog integration and recommendation scoring; don't add another provider or an LLM to solve this.
7. Update PRD and project status to match actual behavior. Treat purchase price and lending/borrowing as MVP only if you complete migration, UI, privacy/data handling and backup support for them.
8. Complete performance/accessibility/platform smoke tests; then RC and release gate.

## Non-goals through 1.0

No account system, remote sync, community, social profiles, reading-session timers, annotations, ebook reader, LLM recommendation calls, speculative service framework, or bulk catalog harvesting. Do not do major dependency upgrades while basic CI is red; upgrade dependencies only in a separate, tested migration if an actual incompatibility requires it.

## Release acceptance criteria

Dandelion 1.0 is ready only when: the app compiles and tests pass; existing databases migrate; an export fully restores books, reading records and cover assets; import failures roll back; offline library actions work; catalog failure never blocks manual entry; search/filter/sort match their UI; recommendations are deterministic and explainable; all six declared targets are tested or explicitly marked unsupported with a user-facing limitation; keyboard/screen-reader/text-scale behavior is reviewed; and docs/release notes describe only verified behavior.
