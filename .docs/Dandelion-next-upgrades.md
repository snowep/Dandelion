# Dandelion: current ecosystem and next useful upgrades

**Checked:** 2026-10-18. Verify package constraints against the locked versions before upgrading.

## 1. Current framework baseline

- Flutter stable: **3.47.0** is the recommended CI pin for this review date. The official release archive lists Flutter 3.47 for the August 2026 release window and targets 3.50 for November 2026: https://docs.flutter.dev/install/archive.
- Drift: the project constraints `drift: ^2.35.2` and `drift_flutter: ^0.3.1` align with the current package versions found in the package listings.
- File picker: `file_picker: ^13.1.0` is current in the reviewed listing. Its `PlatformFile.readAsBytes()` and `length()` APIs are appropriate for reading selected files on supported platforms. This does not by itself implement web persistence: https://pub.dev/packages/file_picker.
- HTTP: `http` 1.6.0 is the current stable version listed on pub.dev. The project constraint `^1.2.0` permits 1.x upgrades, but the resolved `pubspec.lock` must be checked: https://pub.dev/packages/http.
- GoRouter: current listing is 18.1.0, while the project constraint `^14.2.7` prevents resolving to 18.x: https://pub.dev/packages/go_router.
- Riverpod: current listing is `flutter_riverpod` 3.4.3, while the project constraint `^2.4.9` prevents resolving to 3.x: https://pub.dev/packages/flutter_riverpod.

### Upgrade policy

Do not run `flutter pub upgrade --major-versions` as one giant change. First get CI and tests working, then upgrade one family at a time. GoRouter 14 -> 18 and Riverpod 2 -> 3 should be separate migration PRs with compile/analyzer/widget-test evidence. If the current versions are stable enough and fix no real issue, defer the upgrade rather than upgrading just for a newer number.

## 2. Platform work that is still required

1. **Web cover persistence:** add a platform-specific storage interface. Use filesystem storage on native targets and IndexedDB or another tested persistent browser store on web. Test the full pick -> store -> load -> export/import cycle.
2. **Drift web verification:** validate the exact worker filename, WASM asset path, browser storage mode, deployment base path, MIME type, and cross-origin headers against the version in `pubspec.lock`. Current Drift docs: https://github.com/simolus3/drift/blob/develop/docs/content/platforms/web.md.
3. **All six targets:** after the baseline CI works, add build jobs for Android, iOS, web, Windows, macOS, and Linux. Use hosted runners suitable for each target; iOS/macOS builds require macOS runners. Smoke-test real persistence separately from compile-only builds.
4. **Dependency monitoring:** add Dependabot (or equivalent) for GitHub Actions and Pub. Group patch/minor updates; isolate major upgrades for review. Retain `pubspec.lock` and require CI before merging dependency updates.
5. **Release support:** add a concise CHANGELOG, release checklist, and backup/restore test requirement. Only tag a release after CI and restore verification pass. Keep MAJOR/MINOR/PATCH tags immutable.

## 3. Features worth adding after reliability

Don't add these before the P0 fixes and test foundation. Choose one at a time based on actual use.

- **Saved filters / custom shelves:** let the user organize a personal library by genre, topic, project, or location. This is distinct from the existing read-status filter.
- **Series and edition awareness:** model editions separately from a work if users need translations, multiple formats, ISBN variants, and series order. Don't overload the current Book row with more nullable edition fields.
- **Duplicate review tool:** detect ISBN duplicates and near-matches by normalized title/author; let the user inspect and merge without losing notes, cover assets, ratings, or progress.
- **Import adapters:** after the JSON archive is reliable, add CSV/Goodreads-style imports as explicit adapters with preview, field mapping, duplicate review, and rollback.
- **Useful offline search:** search notes as well as title/author/ISBN/genre/description, debounce input, use database-side filtering and pagination, and test against a 5,000-book dataset.
- **Book lookup UX:** add title search and a clear preview/select-fields step in addition to ISBN lookup. Manual entry must remain available when offline or the provider is unavailable.
- **Recommendation feedback:** dismiss/not-interested/save actions, grounded explanation strings, and tests for cold start and missing metadata. First implement the intended signals correctly; do not add LLM calls or popularity scoring to fake completeness.
- **Accessibility and layout QA:** keyboard navigation, screen-reader labels, large text, narrow desktop/web widths, contrast, focus order, reduced-motion behavior, and empty/error/offline states.

## 4. Definition of MVP ready

Dandelion is ready for a personal MVP only when all are true:

- [ ] CI passes format, analyze, tests, and web build on the pinned SDK.
- [ ] Meaningful tests exist; `flutter test` does not pass merely because there are no tests.
- [ ] Library CRUD and reading records survive native and web app restarts in supported storage conditions.
- [ ] Failed import leaves the existing library and cover assets unchanged.
- [ ] Full backup includes all book records and cover assets, without truncation at 500 records.
- [ ] Search and screen lists are paginated; statistics and export use explicit complete-data operations.
- [ ] Catalog lookup is optional, has a preview, handles errors, and never blocks manual entry.
- [ ] Recommendation scores only use implemented signals and explanations match the actual score.
- [ ] Six-platform support is build/smoke-tested rather than merely stated in README.
- [ ] Privacy and data retention remain local-first; sync/community stay out of the MVP.
