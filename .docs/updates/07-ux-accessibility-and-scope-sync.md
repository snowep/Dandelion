# U7 — Complete Settings, accessibility, and documentation alignment

**Goal:** the actual UI, PRD and project status describe the same feature set.

## Required changes
1. Finish Settings/theme behavior from U0; test system/light/dark. Keep Material 3 Expressive, page-owned headers and adaptive NavigationBar/NavigationRail.
2. Review every declared screen for empty, loading, offline, failure and no-results states with a recovery action. Avoid displaying raw technical stack/errors to ordinary users; keep useful diagnostic details in logs without private notes/history.
3. Verify keyboard navigation, visible focus, accessible names/tooltips, screen-reader semantics, contrast in light/dark, text scaling, reduced motion where relevant, and compact widths. Add widget tests at narrow/mobile and wide/desktop constraints.
4. Decide the status of purchase price/currency and borrowed/lent tracking. Since these fields now exist in model/DB/UI, preferred path is to retain and document them as personal-only data, finish validation and backup coverage, and add PRD acceptance criteria. If not wanted in MVP, remove the UI/model/schema only with a safe migration and no data loss; do not leave half-supported fields.
5. Update `.docs/PRD.md`, `.docs/STACK.md`, `.docs/DESIGN.md`, `.docs/PROJECT.md`, and README to match verified code. Phase checkboxes must use evidence, not intention. Mark all six targets as “verified” only where smoke tests were actually run.
6. Check old placeholders and backups (`lib/app/screens/*`, `lib/features/library/*_screen.dart`, `.backup`, `.bak`) and `go_router_config.dart` against actual references. Remove dead files in a separate cleanup commit only after proving they’re unreferenced. Do not delete user data or current generated artifacts.

## Acceptance
- One page header per route; nav selection and route URL agree.
- Setting theme changes immediately and survives restart if persistence is claimed.
- 200% text scaling / small viewport has no overflow on major screens.
- Docs state precise platform limitations and reflect only tests that ran.
