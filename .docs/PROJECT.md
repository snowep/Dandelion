# Dandelion — Project Guide

## Current state

**Phase:** 0 — specification and technical validation  
**Release target:** local-first personal library  
**Remote sync:** not in the first release  
**Community:** later phase

This file is the entry point. Read it first, then open the document relevant to the task.

## Project files

| File | Purpose |
|---|---|
| `PRD.md` | User needs, scope, flows, acceptance criteria, and phases. |
| `DESIGN.md` | Material 3 Expressive, navigation, slivers, adaptive layout, and accessibility. |
| `STACK.md` | Persistence, search, recommendation algorithm, performance, and tests. |
| `CONVENTIONS.md` | Implementation rules for humans and coding agents. |
| `PROJECT.md` | This overview and the delivery roadmap. |

## Non-negotiable decisions

- Flutter + Dart, with Material 3 enabled.
- Support mobile, web, and desktop; verify package support on each target.
- Local data works without an account or internet.
- The first release does not include community or remote sync.
- Use SQLite where the platform/package combination genuinely supports it; use a local storage adapter on web if required.
- Large lists use lazy slivers and bounded database queries.
- Recommendations must be explainable and must not invent metadata.
- Follow `CONVENTIONS.md`: read existing code, choose the simplest safe solution, and test risky logic.

## Roadmap

### Phase 0 — Validate foundations

- [ ] Install the stable Flutter SDK and create the multi-platform project.
- [ ] Confirm Android, web, and one desktop target build.
- [ ] Prototype database persistence on Android and web before choosing the final storage package.
- [ ] Verify schema migration and export/import with a small sample.
- [ ] Establish theme, linting, formatting, and test commands.

**Exit condition:** the same basic book record can be saved, reopened, and retrieved on the intended target platforms.

### Phase 1 — Personal library MVP

- [ ] Book model, schema, repository, and migrations.
- [ ] Add/edit/archive/delete book flows.
- [ ] Library, wishlist, and reading status.
- [ ] Progress tracking and reading history.
- [ ] Search, sort, and filters.
- [ ] Dashboard and basic insights.
- [ ] JSON export/import with validation.
- [ ] Light/dark/system-color theme and adaptive navigation.
- [ ] Widget, database, and integration tests.

**Exit condition:** core flows work offline and survive app restart; data can be exported and restored.

### Phase 2 — Recommendations and polish

- [ ] TF-IDF text vectors and cosine similarity.
- [ ] Genre overlap, author preference, and history-based scoring.
- [ ] Explainable reasons and dismiss/not-interested feedback.
- [ ] Test cold-start behavior and missing metadata.
- [ ] Profile memory and scrolling with a 5,000-book fixture.
- [ ] Fix measured bottlenecks rather than adding speculative caching.

**Exit condition:** recommendation results are deterministic, understandable, and tested; large-library interactions remain usable.

### Phase 3 — Remote sync

Only start after local storage and export/import are reliable.

- [ ] Select and document backend, API, authentication, and hosting.
- [ ] Define record versions, change log/outbox, retry, and idempotency.
- [ ] Define conflict rules for reading progress, notes, and deletion.
- [ ] Add secure credential storage and transport security.
- [ ] Add sync status, failure recovery, account/data deletion, and backup tests.

**Exit condition:** offline edits sync safely across two devices without silent data loss.

### Phase 4 — Community

- [ ] Public profiles and privacy settings.
- [ ] Explicit opt-in for public reading data.
- [ ] Reviews, ratings, and shared lists.
- [ ] Abuse reporting, moderation, blocking, and deletion policies before public launch.
- [ ] Aggregated popularity metrics with minimum sample thresholds.
- [ ] Collaborative filtering only after enough trustworthy interaction data exists.

**Exit condition:** privacy, moderation, data deletion, and abuse handling are designed alongside community features.

## First implementation sequence

1. Create the Flutter project and verify target builds.
2. Implement one `Book` model and local repository.
3. Add persistence and a test proving data survives a restart.
4. Build the adaptive app shell and theme.
5. Implement the library list with `CustomScrollView` and `SliverList`.
6. Add editing, progress, search, filters, and export in small tested changes.

Do not build all screens before verifying persistence and platform support.

## Verification commands

Run from the project root:

```bash
dart format .
flutter analyze
flutter test
```

Use the relevant `flutter run -d <device>` target to smoke-test each supported platform. For web and desktop, confirm storage behavior separately; a successful Android build does not prove cross-platform persistence works.

## Status reporting

For each task, report only:
- **Changed:** observable behavior.
- **Verified:** commands and tests actually run.
- **Remaining:** concrete blocker or next action.

Do not report a feature as complete based only on generated code.
