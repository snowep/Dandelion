# Dandelion versioning and existing tag policy

## Verified state on 2026-10-19

- `master` HEAD: `b285f5cf7a61dabfde4ccb8bdefba70ffa0cf207`.
- Tag `v1.0.0` targets commit `193d9c2e31fdfab61397596645b26df5ddeb7e9d`.
- Tag `v1.0.1` targets commit `86e48560e8500221f4056c2ba92089f01f57a125`.
- Current `pubspec.yaml`: `version: 0.2.0+1`.
- GitHub Releases API: zero published Release entries.

The tags are real repository history even though no GitHub Release entries exist. They are not current-master aliases.

## Rule

Use SemVer tags `vMAJOR.MINOR.PATCH`. Flutter manifest version uses `MAJOR.MINOR.PATCH+BUILD_NUMBER`; its public version should agree with the release tag. Increase the build number for each distributed build according to the distribution history. Confirm whether any APK/installer has already been distributed before choosing the next build number.

## Recommendation

Preserve pushed `v1.0.0` and `v1.0.1` tags. Once the product is actually release-ready, set `pubspec.yaml` to the agreed next version (`1.0.2+<next-build-number>`), update changelog/release notes, verify the same commit passes all gates, create an annotated `v1.0.2` tag on that commit, and publish a GitHub Release.

If the maintainer's intent is that the first real stable package must still be called `v1.0.0`, stop before RC. Confirm whether existing tags may be retired and understand that deleting/moving published tags can break consumer references. Do not force-move or delete tags silently.

Do not use `pubspec.yaml` version changes as a substitute for release criteria. Do not claim GitHub Release publication when only a Git tag exists.
