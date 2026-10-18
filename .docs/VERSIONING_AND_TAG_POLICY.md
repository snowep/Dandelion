# Version, commit and tag policy

## SemVer update rules

- **PATCH** (`1.0.2`): bug fix, data integrity fix, crash fix, migration correction that preserves compatibility. No intentional public contract break.
- **MINOR** (`1.1.0`): backward-compatible feature. Add tests and docs for the feature; don't bundle unrelated dependency migrations.
- **MAJOR** (`2.0.0`): user-visible breaking behavior, incompatible data/API contract, or intentional incompatibility requiring migration/communication.
- **Prerelease** (`1.0.2-rc.1`, `1.0.2-rc.2`): candidate builds, not stable release. Fix-only changes during RC increment rc suffix; after acceptance publish `1.0.2`.
- Flutter platform build number after `+` must increase monotonically for each shipped binary as required by the target stores. Do not reset it when marketing version changes.

Use Conventional Commits (`fix:`, `feat:`, `refactor:`, `test:`, `docs:`, `build:`, `chore:`). Conventional commit type describes the change; it does not create a tag by itself. Tag only a release commit after gates pass, not each PR.

## Current repository inconsistency

Observed on 2026-10-19:
- tag `v1.0.0` points to `193d9c2e31fdfab61397596645b26df5ddeb7e9d`.
- tag `v1.0.1` points to current `master` head `86e48560e8500221f4056c2ba92089f01f57a125`.
- `pubspec.yaml` still declares `0.2.0+1`.
- GitHub Releases has no release entries.
- The tagged source has release blockers and CI is failing at format check.

## Recommended safe decision

Treat the tags as existing, immutable history. Do **not** move or reuse either tag. Stabilize code, then ship the next truthful release as `v1.0.2` after all gates pass. If the maintainer wants the first usable stable artifact specifically named `v1.0.0`, stop before RC and decide whether these tags were accidental/unconsumed. Only a human/owner decision can authorize retiring them; do not do it silently, because consumers may already reference them.

The plan pack is named “toward v1.0” to respect the requested acceptance milestone while documenting that exact tag name is already occupied. `updates/09-v1-release-and-tag-decision.md` is the mandatory decision gate.

## Release procedure

1. Ensure current `master` is green.
2. Choose the version history strategy above.
3. Update `pubspec.yaml` version and build number to match the approved release.
4. Run full CI on the release commit and smoke-test the release artifacts.
5. Write release notes with fixed issues, included features, migration/backup notes, limitations and supported targets.
6. Create one annotated tag pointing at the exact verified commit; never retarget it afterwards.
7. Create a GitHub Release tied to that tag. Store build artifacts and record the commit SHA.
8. If a defect is found after release, fix forward with a new PATCH version; never hide it by moving the previous tag.
