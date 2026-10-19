# CI and release gates

## Current CI evidence

Latest run: [Flutter CI run #34](https://github.com/snowep/Dandelion/actions/runs/39174776122), commit `b285f5cf7a61dabfde4ccb8bdefba70ffa0cf207`.

- Dependency setup: passed.
- Format check: passed (`46 files (0 changed)`).
- Analyze: failed with four findings (two warnings and two infos).
- Tests: skipped.
- Web build: skipped.

## Required CI order

1. Checkout exact commit.
2. Install pinned Flutter stable SDK compatible with `environment.sdk: ^3.13.5`.
3. `flutter pub get`.
4. `dart format --output=none --set-exit-if-changed .`.
5. `flutter analyze`.
6. `flutter test --reporter expanded` (or the project-supported equivalent).
7. `flutter build web`.
8. Produce a separate platform smoke-test report for every platform the release claims to support. Native compile/build jobs should be added where runners and SDKs are available.

## Required coverage before stable release

- Widget tests: root app, root `ProviderScope`, routes and selected navigation, theme selection, no duplicate app bars, empty/error/loading states, narrow layout and large text.
- Database/repository: create/read/update/archive/delete; schema v3→v4 migration preserving old rows; status filter; all visible sort values; pagination offset; search; ISBN normalization/duplicates; nullable clearing.
- Import/export: full field round trip; reading-record round trip; cover bytes/keys; valid legacy/current archive policy; malformed archive, unsupported schema, missing/invalid fields, incoming duplicates, destination conflicts, skip/overwrite semantics, full import rollback on injected failure.
- Cover: selected bytes when path is absent, native and web storage, missing directory, invalid format/size, load/store/delete, import/export restoration.
- Catalog: mock responses, no network, provider errors, missing metadata, offline manual entry and dedup flow.
- Recommendations: cold start, metadata gaps, tie stability, positive/negative signals and actual ranking of catalog candidates.

## Release gates

No stable tag until format/analyze/test/web build pass on the same commit, user-data migration and backup restore are demonstrated, P0/P1 findings are closed, platform support is explicit, docs match implementation, and the tag/package version decision is approved.
