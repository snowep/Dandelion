# U2 — real schema v3 → v4 migration test

**Current state:** schema version `4` and an `onUpgrade(from < 4)` migration for purchase/lending columns are already present. The current file `test/database/migration_v3_to_v4_test.dart` does **not** test migration; it checks `schemaVersion == 4` and creates a fresh in-memory database.

## Required changes

1. Build a test fixture using the actual v3 schema definition (no purchase/lending columns), seed multiple books and reading records including nullable and non-null legacy values, close it, then open the same DB through the current schema-v4 `AppDatabase` so `onUpgrade` runs.
2. Verify legacy book rows, IDs, ISBN/normalized ISBN, timestamps, wishlist state and reading records are unchanged.
3. Verify the 12 added columns exist and are null/false/defaulted appropriately: purchase price/currency, borrow state/name/contact/dates, lend state/name/contact/dates.
4. Test an empty v3 database and a database with several rows; verify a second open doesn't attempt the migration again.
5. Regenerate Drift code using `dart run build_runner build --delete-conflicting-outputs`. Do not hand-edit `.g.dart`.
6. If a real pre-v3 or v2 schema is supported, test sequential upgrades (v2→v3→v4); otherwise document the minimum supported schema and backup-before-upgrade policy.

## Acceptance

A test proves the upgrade ran on an existing v3 database and preserves data. `flutter test` and the complete CI pipeline pass. The test name must describe what it actually verifies.
