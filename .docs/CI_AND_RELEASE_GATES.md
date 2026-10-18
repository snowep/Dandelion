# CI and verification gates

## Current truth

The current Actions workflow starts on push/PR and installs Flutter `3.47.7`; Flutter setup and dependency installation passed on the latest run. That run failed at format check because seven files were not formatted. Analyze, tests, and web build were skipped. The repository currently has no `test/` directory. Treat CI as red.

## Required CI pipeline

Run in this order, failing fast:

1. `dart format --output=none --set-exit-if-changed .`
2. `flutter analyze`
3. `flutter test`
4. `flutter build web`
5. Build/test native targets on CI runners that support them, or require a documented/manual platform smoke test where runners aren't available (notably iOS/macOS require macOS runner).
6. Validate generated Drift code is current. Use the project's locked `build_runner` version and ensure the working tree does not change after generation.

Use a Flutter version compatible with `environment.sdk: ^3.13.5`, pin it to a known stable release, and keep `pubspec.lock` committed. Avoid `flutter pub upgrade --major-versions` in a fix PR.

## Minimum automated suite before data feature work

- App startup and all nav destinations at compact/wide sizes; one page header only.
- Settings theme provider reads/writes in the same root ProviderScope.
- Book create/edit/delete/archive; unique/empty ISBN and title validation.
- Nullable fields can be cleared; reading progress bounds and status/date transitions.
- Drift migration from the current v3 schema and reopen/persistence.
- Search, filters, every sort option, stable tie ordering, pagination offset, note search.
- Cover key store/load/delete; native and web storage adapter tests.
- Catalog parsing, malformed payload, no result, timeout/rate-limit/network failure, and manual fallback.
- Export/import round-trip of all fields, reading records and covers; failed import rolls back unchanged data; duplicate/conflict choices.
- Recommendation engine scores, explanations, missing inputs, cold start, tie order and external candidates.
- 5,000-book fixture for list/search/sort and bounded cover loading.

A command that exits 0 with zero tests is not an acceptable quality gate; ensure meaningful test files exist and are discovered.

## Platform validation evidence

For Android, iOS, web, Windows, macOS and Linux, record actual build/run version, OS/browser, persistence check, image picker/store/load, and backup/restore result. If a platform cannot be built in the available environment, state that explicitly and do not mark it supported as verified.

Web checks must use both local run and deployed build: `sqlite3.wasm` and Drift worker URLs, WASM MIME type, base path, browser storage persistence, reload/reopen, private browsing behavior, CORS for catalog lookup, and cover/blob export/import. Browser storage can be cleared/evicted; export is still required.

## Release gate

No tag until: format/analyze/tests/build pass; no P0/P1 finding remains; DB upgrade and backup restore are demonstrated; all declared target behaviors are either tested or transparently limited; docs/changelog match actual behavior; `pubspec.yaml` version agrees with chosen tag; and tag-history conflict is resolved under `VERSIONING_AND_TAG_POLICY.md`.
