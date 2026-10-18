# U0 — Restore a buildable app, Settings, and CI

**Order:** first. Do not start later updates before this exits.  
**Goal:** current source is analyzable and the CI run reaches every gate.

## Inspect first
- `lib/main.dart`, `lib/app/app.dart`, `lib/app/app_router.dart`, `lib/app/app_shell.dart`, `lib/app/app_theme.dart`.
- `lib/features/settings/` (currently absent), `pubspec.yaml`, `analysis_options.yaml`, `.github/workflows/flutter-ci.yml`.
- Latest Actions failure: https://github.com/snowep/Dandelion/actions/runs/39163199619

## Required changes
1. Run `dart format .` and commit only intended source formatting. Then keep the format check as a gate; do not remove it.
2. Resolve the missing `theme_notifier.dart` and `settings_screen.dart` imports. Preferred: implement a minimal Material 3 Settings screen with System/Light/Dark theme selection, persist preference using the project's existing lightweight local settings mechanism if available, and test it. Alternative only if implementation would expand scope: consistently remove route/import/nav entries and return to system theme; document this explicitly.
3. Keep one root `ProviderScope` in `main.dart`. Remove nested `ProviderScope` from `DandelionApp`; ensure theme notifier and route descendants use the same provider container.
4. Ensure every route path matches one navigation destination. `/settings` index is 5, and both compact `NavigationBar` and wide `NavigationRail` should match.
5. Create the `test/` directory and initial meaningful tests: app startup, all route labels and one header per page, Settings theme state update, and destination selection at compact/wide widths.
6. Keep CI SDK compatible with `environment.sdk: ^3.13.5`; current Flutter `3.47.7` installed and dependencies resolved successfully in the last run, so do not change it without evidence.
7. CI must format → analyze → test → web build. Ensure test discovery is meaningful.

## Acceptance
- Both missing imports resolve.
- Theme setting changes `MaterialApp.router.themeMode` and persists only if the planned persistence has an automated test.
- All six nav destinations work at compact and wide sizes and a page does not show duplicate app bars.
- `dart format --output=none --set-exit-if-changed .`, `flutter analyze`, `flutter test`, and `flutter build web` all pass.
- Record actual outputs; do not report analyze/test/build as passed if any step was skipped.

## Non-goals
No database schema refactor, package major upgrades, recommendations work, or additional unrelated UI changes.
