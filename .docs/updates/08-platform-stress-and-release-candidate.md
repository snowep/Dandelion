# U8 — Platform matrix, data-scale test and release candidate

**Goal:** gather evidence that the app is stable at the intended scope before a stable version is tagged.

## Required validation
1. Add an automated large-library fixture (5,000 books, reading records and representative covers). Check Library scroll/search/sort/status filter, dashboard queries, Discover ranking and export completeness. Record performance rather than using subjective “feels fast.”
2. Test create/edit/clear/archive/delete, ISBN duplicate handling, status/progress, notes, purchase and lending fields, local cover storage, lookup preview, backup/restore and failure recovery.
3. Validate DB migration from v3; preserve old record IDs/values. Exercise backup format version compatibility.
4. Build/run on Android, iOS, Web, Windows, macOS and Linux when environments permit. For unavailable environments, state not verified and don’t claim full support. For web, test deployed assets/headers/base URL plus reload/offline behavior and browser storage warnings.
5. Verify image picking, persistence, cover render, restore, and no orphaned/cross-linked cover file on each available target.
6. Inspect logs for uncaught exceptions, noisy stack traces, unhandled network failures and private-data logging. Add retries/empty states when necessary.
7. Dependency audit is informational first. Do not upgrade GoRouter/Riverpod major versions while stabilizing. Any needed major upgrade is its own task with migration tests and isolated diff.
8. Make a release candidate only once all P0/P1 findings are closed, then test it on a clean install and from a previous schema/database. Include upgrade and restore procedures in notes.

## Acceptance
- CI is green through format, analyze, tests, web build.
- Platform status table has evidence and any unsupported target explicitly identified.
- 5,000-book test exercises no silent 500-row truncation or full-cover eager load.
- All critical data paths pass normal and failure-injection tests.
- No new blocker from the RC; if found, fix and produce a new RC identifier.
