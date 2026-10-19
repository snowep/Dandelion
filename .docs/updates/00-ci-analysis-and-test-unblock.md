# U0 — CI/analyzer/test unblock

**Priority:** P0. **Do this first.** Baseline: `b285f5cf7a61dabfde4ccb8bdefba70ffa0cf207`.

## Current failure

CI run [#34](https://github.com/snowep/Dandelion/actions/runs/39174776122) passes dependency resolution and formatting but fails at `flutter analyze`; tests and web build are skipped.

## Required changes

1. Remove unused `_compare` from `lib/features/library/book_repository_impl.dart` if genuinely unused; do not leave dead helpers.
2. Fix or correctly guard `BuildContext` use across async gaps in `lib/features/library/library_screen.dart` around line 138 and `lib/features/wishlist/wishlist_screen.dart` around line 62. Use `mounted` checks where appropriate, or capture required values before awaiting.
3. Remove the unnecessary null comparison around `lib/services/library_export_import_service.dart:170` without changing export behavior.
4. Fix the Settings control: currently the state begins as `ThemeMode.system`; the switch shows `false` and calls `toggleBrightness()` regardless of the requested boolean. Choose explicit System/Light/Dark UI or use `onChanged: (isDark) => setThemeMode(isDark ? ThemeMode.dark : ThemeMode.light)`. Add a widget-level test for all choices. Decide and test whether setting persistence is in MVP scope.
5. Add focused tests as needed to make `flutter test` meaningful. Do not change analysis rules to ignore findings just to make the workflow green.
6. Run format, analyze, tests and web build. Commit the fixes and re-check the new Actions run on the exact commit.

## Acceptance

- `dart format --output=none --set-exit-if-changed .` exits 0.
- `flutter analyze` exits 0.
- `flutter test` executes and exits 0 (not skipped).
- `flutter build web` executes and exits 0 (not skipped).
- Root provider scope and Settings route still work.
- Report exact commit, test count, command outputs and any platform-specific limitations.
