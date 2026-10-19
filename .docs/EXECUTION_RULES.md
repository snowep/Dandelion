# Execution rules for coding agents

1. **Work from the exact HEAD** `b285f5cf7a61dabfde4ccb8bdefba70ffa0cf207` or a newer confirmed `master`. Check branch, commit and worktree before editing; never reset or overwrite user changes.
2. Work on one directive at a time, in its own commit/PR. Do not mix refactors or feature expansion into a focused repair.
3. Keep the existing Flutter/Dart + Riverpod + GoRouter + Drift design. No rewrite, no new backend, no remote sync/community work for this release.
4. First reproduce a bug with a minimal test. Add regression tests for every fix that affects persistence, import/export, query semantics or model copying.
5. Do not mark `flutter test` or `flutter build web` successful unless logs show the command executed and exited 0 on the proposed commit. A skipped step is not a pass.
6. After each change run, in order: `dart format .`, `flutter analyze`, `flutter test`, `flutter build web`. For migration/Drift changes also run `dart run build_runner build --delete-conflicting-outputs` and inspect the generated diff.
7. Keep the complete export uncapped. UI lists may paginate, but export, database migration, backup and statistics must not silently truncate records.
8. Import must validate all input before writes, resolve conflicts explicitly, and be atomic for database state. Stage external files first and clean them up on rollback/failure.
9. Do not manually edit `book_database.g.dart`; regenerate it. Do not bump schema/version without a migration/version policy and tests.
10. Avoid analyzer suppression as a substitute for fixing a real issue. Do not lower CI quality gates merely to force green.
11. Do not delete `.backup`, `.bak`, or duplicate screen files until all references are traced and a separate cleanup change demonstrates they are unused.
12. Each task report must include files changed, root cause, tests added, exact commands and exit codes, remaining limitations, and commit/PR URL. No unverified claims.
13. Preserve existing Git tags. Version/tag changes require the explicit release decision described in `VERSIONING_AND_TAG_POLICY.md`.
