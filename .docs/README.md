# Dandelion — Roadmap to a defensible 1.0 release

**Repository:** [snowep/Dandelion](https://github.com/snowep/Dandelion)  
**Reviewed branch/head:** `master` / `86e48560e8500221f4056c2ba92089f01f57a125`  
**Review date:** 2026-10-19  
**Scope:** executable instructions for a coding agent; these documents do not themselves change app source.

## Start here

1. Read `AUDIT_REPORT.md` and `VERSIONING_AND_TAG_POLICY.md` first.
2. Execute `updates/00-build-and-settings-repair.md` as the first implementation task. Do not begin later tasks while `flutter analyze` cannot run cleanly.
3. Work through update files in numeric order. Each file is one bounded change or PR; it includes requirements and acceptance criteria.
4. Use `CI_AND_RELEASE_GATES.md` at every merge and `RELEASE_CHECKLIST.md` before any stable tag/release.
5. Update `.docs/PROJECT.md` and `.docs/PRD.md` only when behavior is implemented and verified. Do not tick boxes because code was generated.

## Important version-history warning

Git tags `v1.0.0` and `v1.0.1` already exist. `v1.0.0` points to `193d9c2e31fdfab61397596645b26df5ddeb7e9d`; `v1.0.1` points to current head `86e48560e8500221f4056c2ba92089f01f57a125`. The current `pubspec.yaml` still says `0.2.0+1`, and GitHub Releases currently has no release entries. The latest tagged source has known blockers and its CI run fails at format check.

Therefore this pack plans toward **1.0 release readiness**, but it does not silently reuse or move the existing `v1.0.0` tag. Under an immutable-tag policy, the next actual stable tag should be `v1.0.2`. If the maintainer specifically requires a new, valid tag named `v1.0.0`, stop at the version-history gate and make an explicit decision about whether the existing tags can be retired/recreated. See `VERSIONING_AND_TAG_POLICY.md`.

## Product scope to preserve

- Personal, offline-first library; no account, remote sync, or community in MVP.
- Android, iOS, web, Windows, macOS, and Linux are targets, but each must be verified rather than assumed supported.
- Manual entry always works offline; title/ISBN lookup is optional and online.
- Basic statuses, page/percentage progress, dates, personal rating/notes, wishlist, local covers, manual export/import, dashboard/insights, and explainable recommendations.
- Recent code also adds purchase price/currency and lending/borrowing fields. Preserve them only as an intentional part of the MVP; if retained, add their acceptance criteria and backup/migration coverage before release.

## What was and was not verified

Verified from GitHub source and Actions metadata: current head SHA, tree contents, missing settings files, absence of a `test/` directory, database migration version and fields, export omissions, existing tags, current `pubspec` version, and the latest Actions run failure at the format step. The workflow did not reach analyze, tests, or web build.

Not done in this review: no local Flutter commands, no on-device/browser run, and no code edits to the repository. A source-level defect is not described as a runtime test result unless the CI actually observed it.
