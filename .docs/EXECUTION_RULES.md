# Coding-agent execution rules

## Required loop for every update

1. Confirm the current branch and commit; inspect callers, repository layer, schema/migration, UI entry points, and tests before editing.
2. Pick exactly one update directive under `updates/`. Do not silently combine a different phase.
3. State expected touched files and observable behavior before implementation.
4. Make the smallest complete code change, including migrations, generated files, tests, and documentation that the change requires.
5. Run the specific new tests, then `dart format .`, `flutter analyze`, and `flutter test`. Run the target build requested by the directive. Record exact outputs/results.
6. If a command cannot run, state why. Never describe skipped checks as passed.
7. Review the diff for data loss, stale imports, accidental `.backup`/generated-file edits, and scope drift.
8. Update `.docs/PROJECT.md` only from actual verified status.
9. Open a PR/commit with a conventional message. Do not push directly to `master` unless the repository owner explicitly directs it.

## Hard constraints

- Preserve local-first, personal scope and manual offline entry.
- No account, remote sync, community, paid API, or LLM dependency for the MVP.
- Never delete user data without an explicit confirmed flow; imports must be validated and atomic.
- Every database schema change needs a monotonically increased Drift schema version and migration tests from real prior versions.
- Never manually edit generated Drift code; regenerate it using the locked toolchain.
- UI never performs raw SQL or provider response parsing.
- Use one provider container at the root; no nested `ProviderScope` unless there is a deliberate, documented override boundary.
- Never silently cap exports, counts or complete-data jobs. UI lists should paginate/lazy-load; exports must include all records.
- Do not add an abstraction, dependency, provider, or feature “for later.”
- External data is untrusted. Preserve users' private notes, ratings and reading state during metadata updates.
- No release tag until the full CI and release checklist pass.

## Required PR/agent report format

- **Changed:** observable behavior and source files.
- **Tests run:** exact commands and results (including skipped commands).
- **Data compatibility:** affected schema/backup versions and migration proof.
- **Platforms checked:** targets actually tested; say “not tested” for the rest.
- **Remaining:** known failures/risks and next directive.
