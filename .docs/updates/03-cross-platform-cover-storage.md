# U3 — Make cover storage work on native and web

**Goal:** selected or catalog cover images can be stored, reloaded offline and exported on every supported target.

## Relevant files
- `lib/shared/services/cover_image_service.dart`
- `lib/features/discover/discover_screen.dart`
- `lib/features/library/library_screen.dart`
- `lib/features/home/home_screen.dart`, `lib/features/insights/insights_screen.dart`
- `pubspec.yaml`, web assets/deployment config, backup service, tests

## Required changes
1. Remove `dart:io`, `File`, `Directory`, and path-provider calls from cross-platform shared code. Introduce a narrow cover storage API with platform-specific native filesystem implementation and web browser-persistent blob implementation (e.g. IndexedDB via an established compatible package). Do not build a generic media framework.
2. Use file-picker bytes where available; do not require `PlatformFile.path` on web. Validate image type/content and size, decode image, generate bounded thumbnails, and expose useful errors.
3. In Discover, generate a single cover key and use it for both storage and `Book.coverAssetKey`. The current method generates two different UUIDs. Ensure storage directory/namespace exists before writing.
4. Browser cover bytes must survive reload/reopen where browser storage supports persistence and remain readable offline. Show a clear warning when the chosen storage is not persistent.
5. Avoid downloading large images during every rebuild. Cache thumbnails with a bounded policy and load them only as items enter the viewport.
6. Keep backup/export aligned with the same storage API so files/blobs can be included and restored.
7. Add tests for select/store/load/delete, corrupted/oversized images, bad keys/path traversal, storage failure, and catalog cover save → DB reload → display.

## Platform verification
- `flutter build web` must pass.
- Verify `web/sqlite3.wasm` and `web/drift_worker.dart.js` remain available at the correct URLs.
- Smoke-test deployed web, base path, browser reload, offline reload after initial installation, file picking, cover save/load, and export/import.
- Verify native file handling on at least one mobile and one desktop target, with all six target results recorded before release.

## Non-goals
No network image cache framework, no community cover CDN, no bulk catalog scraping.
