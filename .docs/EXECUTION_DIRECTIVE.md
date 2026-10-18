# Dandelion — execution directive

## Objective

Deliver a reliable, offline-first personal book library across Android, iOS, web, Windows, macOS, and Linux. Protect user data before expanding features.

## Product decisions that must remain fixed

- Product name: **Dandelion**.
- Framework: Flutter + Dart; UI: Material 3 Expressive.
- Personal library in the MVP. No account, remote sync, or community requirement.
- Manual book entry must always work offline.
- Title/ISBN lookup is optional and online. It must never block manual entry.
- Candidates for Discover may come from the user's library/wishlist and an external catalog.
- Tracking is basic: status, current page or percentage, start/finish dates, rating, and notes. No session timer or annotation system.
- Local cover selection and provider cover lookup are both in scope. Saved covers should remain available offline where platform storage permits.
- Manual JSON export/import is required; full backup must include cover assets.
- Recommendation ranking must be hybrid, deterministic for identical inputs, and explainable from data that actually exists.
- Remote sync, social/community features, public popularity ranking, LLM services, and ebook reading remain out of scope until separately approved.

## How to execute

1. Read the existing `.docs/PRD.md`, `DESIGN.md`, `STACK.md`, `CONVENTIONS.md`, and `PROJECT.md` before editing code.
2. Check the current branch, commit, working tree, installed Flutter/Dart versions, dependencies, workflow files, and test files. Do not assume an earlier audit is still the current head.
3. Follow the phases in `IMPLEMENTATION_PLAN.md` in order. Work on one phase at a time and keep pull requests narrow.
4. For every phase, state the goal, files affected, behavior changed, tests added, verification commands, command exit codes, and unresolved risks.
5. Add or update tests with each behavior change. A change to persisted data requires tests for restart/reopen and relevant migration paths.
6. Never delete tests merely to make analysis or CI pass. Fix the source or update tests only when their assertions no longer match the requirements.
7. Do not claim that an app, test, build, CI workflow, platform, or release is verified unless the relevant command or check actually completed successfully.
8. Do not silently change product scope, data formats, schema compatibility, dependency strategy, or versioning policy.
9. Do not add a backend, service locator, architecture layer, second catalog provider, or another state-management package without a concrete requirement and a written reason.
10. Do not add Python scripts or a Python runtime to this Flutter/Dart project. Use the existing Dart/Flutter toolchain.
11. Do not create or push release tags until `VERSIONING_AND_TAGS.md` and `CI_AND_RELEASE_GATES.md` have been satisfied.

## Required working rhythm

For each step:

1. Inspect the relevant source and its callers.
2. State the smallest complete change before editing.
3. Implement the change and its tests together.
4. Run focused tests first, then the full required verification set.
5. Inspect the diff for unrelated edits, destructive behavior, generated-file drift, and undocumented dependencies.
6. Report results truthfully. If verification fails, fix it or stop and report the blocker; do not proceed as though the gate passed.

## Definition of complete

A phase is complete only when all its acceptance criteria are met, its tests exist, required commands pass, and the status documentation matches the observable code. Generated code alone is not proof of completion.
