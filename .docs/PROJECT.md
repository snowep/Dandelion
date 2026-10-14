# Dandelion — Project Guide

## Current state

**Phase:** 0 — foundation and platform validation  
**Release:** offline-first personal library  
**Book entry:** manual entry plus optional title/ISBN lookup  
**Storage:** SQLite native; browser-persistent SQLite/WASM or supported browser storage on web, behind the same data API  
**Remote sync/community:** later phases, not MVP

Read this file first. Then open the specification that applies to the task.

## Project documents

| File | Use it for |
|---|---|
| `PRD.md` | Scope, user flows, data model, and acceptance criteria. |
| `DESIGN.md` | Material 3 Expressive, slivers, adaptive layout, and accessibility. |
| `STACK.md` | Storage, lookup, search, recommendation algorithms, and platform constraints. |
| `CONVENTIONS.md` | Coding rules for humans and coding agents. |
| `PROJECT.md` | Roadmap and verification checklist. |

## Locked decisions

- Flutter + Dart, Material 3 Expressive.
- Targets: Android, iOS, web, Windows, macOS, Linux.
- Core library actions work offline without an account.
- Manual book entry is always available; title/ISBN lookup is optional and online.
- Use local covers and optional catalog-provided covers; store selected covers for offline use.
- Reading tracking stays basic: status, page/percentage, dates, rating. No session timer or annotation system in MVP.
- Discover includes saved books and external catalog candidates. Catalog data must not be invented.
- Recommendations use genre, author, text, and reading-history signals. Public popularity is deferred until trustworthy community data exists.
- Manual export/import is required. Full backup includes cover files.
- No remote sync or community in the first release.
- Follow `CONVENTIONS.md`: smallest complete change, test risky logic, no speculative abstractions.

## Roadmap

### Phase 0 — Prove the platform foundations

- [ ] Install stable Flutter and create the project for the intended targets.
- [ ] Build and smoke-test Android, iOS, web, Windows, macOS, and Linux where development environments allow.
- [ ] Prototype the Drift database on a native target and web.
- [ ] Verify web assets (`sqlite3.wasm` and Drift worker), MIME type, deployment base path, browser storage mode, and whether required COOP/COEP headers can be configured.
- [ ] Test normal browser persistence, reload/reopen, private browsing behavior, and concurrent tabs on the intended browsers.
- [ ] Verify FTS5 on every database runtime; define a tested fallback if unavailable.
- [ ] Evaluate title/ISBN metadata lookup from native and browser targets. Check current API rate limits, CORS, attribution, cover-use rules, and response quality.
- [ ] Prove cover file selection/storage and ZIP/JSON export/import on native and web.
- [ ] Establish theme, lints, tests, and CI commands.

**Exit condition:** local data can be created, reopened, searched, and exported on intended platforms; known web limitations are visible and documented. Lookup failure never blocks manual entry.

### Phase 1 — Personal library MVP

- [ ] Book model, schema, migrations, repository, and cover storage.
- [ ] Add/edit/archive/delete and manual entry.
- [ ] Title/ISBN lookup with preview, field selection, dedup warnings, and manual fallback.
- [ ] Library, wishlist, statuses, basic progress, and finish dates.
- [ ] Local covers and optional provider cover retrieval.
- [ ] Offline local search, sorting, and filters.
- [ ] Dashboard and simple insights.
- [ ] Versioned JSON/archive export and validated import, including covers.
- [ ] Light/dark/system theme and adaptive navigation.
- [ ] Widget, database, provider, import/export, and integration tests.

**Exit condition:** core actions work offline, lookup is optional, data survives restart under supported platform conditions, and a full archive can restore records and cover assets.

### Phase 2 — Recommendations and performance

- [ ] Genre overlap, author preference, TF-IDF text similarity, history fit, and novelty.
- [ ] Rank both saved items and bounded external catalog candidates.
- [ ] Generate grounded explanations and record dismiss/not-interested feedback.
- [ ] Test cold start, missing metadata, ranking ties, and external candidates.
- [ ] Profile 5,000-book data, long scrolling, and cover memory.
- [ ] Fix measured bottlenecks only.

**Exit condition:** deterministic and explainable recommendations work offline for saved data and online for catalog candidates when the provider is available.

### Phase 3 — Remote sync

Start only after persistence and export/import are reliable.

- [ ] Choose backend, API, authentication, and hosting.
- [ ] Define versions, change log/outbox, safe retries, and idempotency.
- [ ] Define conflicts for progress, notes, and deletion.
- [ ] Add secure credential storage, transport security, status, and recovery UI.
- [ ] Test multi-device sync, account deletion, and backup restore.

**Exit condition:** offline edits sync across devices without silent data loss.

### Phase 4 — Community

- [ ] Profiles and privacy controls.
- [ ] Opt-in sharing of reading data.
- [ ] Reviews, ratings, and shared lists.
- [ ] Moderation, abuse reporting, blocking, and deletion policies before public launch.
- [ ] Popularity scoring from aggregated, trustworthy reads/saves with minimum sample thresholds.
- [ ] Collaborative filtering only after there is enough reliable interaction data.

**Exit condition:** moderation, privacy, deletion, and anti-abuse measures exist with community features, not afterward.

## First implementation sequence

1. Create the Flutter project and verify target builds.
2. Build a tiny Drift proof of concept on native and web, including close/reopen persistence.
3. Verify FTS5, wasm assets, browser storage mode, file selection, and export/import before choosing final package versions.
4. Implement the Book model, schema, repository, and migration tests.
5. Build the adaptive Material 3 shell and a lazy `CustomScrollView`/`SliverList` library.
6. Add manual entry and basic reading status/progress.
7. Add provider lookup/cover retrieval with preview and offline fallback.
8. Add search, sort, filter, backup, and then recommendations.

Do not build all screens before verifying database and browser storage behavior.

## Verification commands

Run from the project root:

```bash
dart format .
flutter analyze
flutter test
```

Use `flutter run -d <device>` or the corresponding target command to smoke-test actual platforms. For web, test the deployed build as well as local development: WASM MIME types, worker assets, headers, browser storage, and CORS can differ after deployment.

## Status report format

- **Changed:** observable behavior.
- **Verified:** exact commands/tests actually run.
- **Remaining:** concrete blocker or risk.

Don't report a feature as complete based on generated code alone.
