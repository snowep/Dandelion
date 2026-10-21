# Dandelion stable-release checklist

## Source and CI

- [x] Release candidate commit SHA recorded; worktree clean.
- [x] `dart format --output=none --set-exit-if-changed .` passes.
- [x] `flutter analyze` passes without ignored real warnings.
- [x] `flutter test` runs actual tests and passes.
- [x] `flutter build web` passes and the deployed web build is smoke-tested.
- [ ] Supported native targets have successful build/smoke-test evidence or are explicitly excluded from the release.

## Data integrity

- [x] A pre-v4 database with real book and reading records upgrades without loss.
- [x] Backup includes all book fields, reading tracking data and covers.
- [x] Import and export round-trip fixture is verified.
- [x] Import conflict paths (skip/overwrite/duplicate) match explicit expected behavior.
- [x] Import failure rolls back the database and leaves current library usable.
- [x] Covers are available after restart and after restore on each supported target.
- [x] Manual entry works offline and lookup failure does not block it.

## Product and usability

- [x] Filters, sort, pagination, ISBN fallback, search and nullable clearing are correct.
- [x] Reading progress/rating bounds are validated.
- [x] Recommendations are deterministic and every explanation is backed by a real signal.
- [ ] System/light/dark theme behavior is tested; preference persistence is implemented or declared out of scope.
- [ ] Narrow layouts, keyboard navigation, focus order, semantic labels and large text are checked.
- [ ] 5,000-book fixture has profiling results and no severe regression.
- [ ] README, PRD, project status, audit and release notes match verified behavior.

## Version and distribution

- [ ] Decision documented for existing `v1.0.0` and `v1.0.1` tags.
- [ ] `pubspec.yaml` public version matches the chosen release tag.
- [ ] Build number accounts for previously distributed builds.
- [ ] Changelog contains fixes, limitations, migration/backup instructions.
- [ ] Backup created and restore test completed before upgrading any existing user data.
- [ ] Annotated tag created on the exact verified commit; GitHub Release entry and release assets validated if publishing.
