# Dandelion — refreshed repository audit and release plan

**Reviewed:** 2026-10-19  
**Repository:** https://github.com/snowep/Dandelion  
**Branch:** `master`  
**Reviewed HEAD:** [`b285f5cf7a61dabfde4ccb8bdefba70ffa0cf207`](https://github.com/snowep/Dandelion/commit/b285f5cf7a61dabfde4ccb8bdefba70ffa0cf207)

This pack replaces the earlier audit baseline at `86e48560e8500221f4056c2ba92089f01f57a125`. It is a static source/repository review plus evidence from the latest GitHub Actions run. It is **not** a claim that local Flutter tests or builds were run in this environment.

## Latest result

The new commit fixes meaningful issues: Settings files now exist, the nested `ProviderScope` was removed, a schema-v4 upgrade path was added, purchase/lending fields are serialized in the backup schema, and three initial test files now exist. The CI format check is also green.

The latest CI run still fails at `flutter analyze`. The test and web-build steps were skipped. The most urgent remaining source issue is in archive import: `importArchive()` requests title/author filtering using filter keys the repository ignores. If there is any existing book, that can treat the first result as a title match and skip or overwrite the wrong book. **Do not trust import/overwrite until this is fixed and covered by tests.**

## Files

- `AUDIT_REPORT.md` — current findings, separated into fixed, unresolved and unverified.
- `BASELINE_AND_RISKS.md` — concise technical state and evidence limits.
- `ROADMAP_TO_V1.0.0.md` — ordered path to a release candidate and formal stable release decision.
- `updates/00-...` through `updates/10-...` — bounded implementation directives to give to a coding agent one at a time.
- `EXECUTION_RULES.md` — execution constraints for any agent changing the repo.
- `CI_AND_RELEASE_GATES.md` — required automated checks and manual platform gates.
- `VERSIONING_AND_TAG_POLICY.md` — handling of existing tags and `pubspec.yaml` mismatch.
- `RELEASE_CHECKLIST.md` — final human release gate.
- `FILE_MANIFEST.json` — file hashes for this pack.

## Use

1. Give the coding agent only `updates/00-ci-analysis-and-test-unblock.md` first.
2. Require a commit/PR and its real command output; do not let it mark skipped checks as passing.
3. Then run each next directive only after the prior acceptance criteria pass.
4. Keep existing tags immutable. The repository already has `v1.0.0` and `v1.0.1`; the safe default is to preserve them and release the next verified state as `v1.0.2`, unless the maintainer explicitly decides otherwise.

No application source files were changed by this audit pack.
