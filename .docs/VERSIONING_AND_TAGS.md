# Dandelion — versioning and Git tag rules

## 1. Canonical version format

Use Semantic Versioning for app releases:

`MAJOR.MINOR.PATCH`

Use annotated Git tags with a leading `v`:

- `v1.0.0` — stable major release
- `v1.2.0` — backward-compatible feature release
- `v1.2.1` — backward-compatible fix release

`pubspec.yaml` uses Flutter's `version` form:

`MAJOR.MINOR.PATCH+BUILD_NUMBER`

The version before `+` must match the release tag. The build number is a separate, non-negative integer used by platform packaging and must increase for each distributed build according to the project's release process. Example: tag `v1.2.1` corresponds to `version: 1.2.1+7`; `7` is a build number, not part of the Git tag.

Official SemVer specification: https://semver.org/

## 2. What kind of update is this?

### Fix update — PATCH

**Pattern:** `v1.2.3` → `v1.2.4`

Use a patch when correcting incorrect behavior without intentionally changing the product contract or adding a new capability.

Examples:

- Fix the catalog cover key so saved images load.
- Fix a crash, overflow, incorrect statistic, search edge case, or ISBN fallback.
- Fix import validation while preserving the supported backup format and compatibility.
- Improve performance without changing the feature's meaning.
- Security or data-integrity fixes that remain backward compatible.

Do not use a patch if the fix changes a released format incompatibly or requires users to lose/re-enter data.

### Minor update — MINOR

**Pattern:** `v1.2.0` → `v1.3.0`

Use a minor release for new, backward-compatible functionality. Reset PATCH to `0` when MINOR increases.

Examples:

- Add title-based catalog lookup to the manual add flow.
- Add a new sort/filter option or a new insights view.
- Add a recommendation signal while preserving existing library and backup compatibility.
- Add supported import of a new backup version while continuing to accept older supported versions.
- Add a new optional setting or user workflow without removing existing behavior.

A release may include fixes alongside a minor feature. The highest-impact applicable version type wins.

### Major update — MAJOR

**Pattern:** `v1.8.4` → `v2.0.0`

Use a major release when an intentional incompatible change is introduced to the released product contract. Reset MINOR and PATCH to `0`.

Examples:

- A backup format becomes incompatible with prior exports and there is no backward-compatible reader or safe migration.
- A database or domain migration cannot preserve old user data/meaning and requires a documented conversion step.
- A fundamental workflow, public interface, or persisted-data contract is removed or changed incompatibly.
- Supported-platform or runtime requirements change in a way that breaks previously supported installations.

A database schema change does **not** automatically require a major app release if a safe migration preserves user data and behavior. Document and test migrations; version according to the actual compatibility impact.

### Documentation, tooling, and refactor-only updates

A docs-only, test-only, CI-only, or internal refactor commit does not automatically need a product release tag. Include it in the next planned release unless it changes shipped behavior. If a tooling change forces a user-facing compatibility change, choose the version type based on that impact.

## 3. Current pre-release policy

The reviewed `pubspec.yaml` declares `1.0.0+1`, but the code audit still found release-blocking gaps. A manifest value alone does not mean a stable release was published.

Before the next tagged release:

1. Inspect Git tags and GitHub releases to determine whether `v1.0.0` has actually been distributed.
2. If **no** `v1.0.0` release/tag has been published, switch to a clear pre-1.0 development baseline such as `0.1.0+1`; reserve `v1.0.0` for the first release that satisfies all stable-release gates. This should be a deliberate version correction, not an accidental downgrade.
3. If `v1.0.0` or a later version **has** been published, do not rewrite history or reuse a tag. Keep the next version higher than the highest released version.
4. While on `0.y.z`, use `0.MINOR.PATCH`: increment MINOR for a feature or a significant compatibility-changing development milestone; increment PATCH for a fix-only update. Mark releases as prerelease until the product is explicitly declared stable.
5. At the first stable release, publish `v1.0.0`. Thereafter apply the major/minor/patch rules above.

Prerelease examples:

- `v0.1.0-alpha.1` — early integration build
- `v0.1.0-beta.1` — feature-complete candidate under broader testing
- `v0.1.0-rc.1` — release candidate
- `v1.0.0` — stable, only after release gates pass

Do not release alpha/beta/RC tags automatically from every merge. Create them intentionally when testers need an identifiable build.

## 4. Commit subject conventions

Use clear conventional commit subjects to aid release review:

- `fix: correct catalog cover storage key` → usually PATCH
- `feat: add title search to book lookup` → usually MINOR
- `feat!: replace backup format with an incompatible schema` → MAJOR, with `BREAKING CHANGE:` details in the commit body
- `docs: clarify release process` → no automatic app version bump
- `test: cover import rollback behavior` → no automatic app version bump
- `chore(ci): repair stable Flutter workflow` → no automatic app version bump
- `refactor: simplify repository queries` → no automatic app version bump unless behavior/compatibility changes

Commit prefix alone does not determine the release version. Review actual shipped behavior and compatibility.

## 5. Release-tag procedure

Run these steps only after `CI_AND_RELEASE_GATES.md` passes.

1. Confirm the intended default/release branch and clean working tree:

   ```bash
   git status --short
   git branch --show-current
   git log -1 --oneline
   git tag --list 'v*' --sort=-version:refname
   ```

2. Decide PATCH/MINOR/MAJOR using this document. Confirm that the version does not already exist. Never reuse or move a published tag.
3. Update `pubspec.yaml` to `X.Y.Z+BUILD_NUMBER`. Update `pubspec.lock` only if dependency resolution requires it. Update/create `CHANGELOG.md` with release notes and known limitations.
4. Run all required checks, commit the version/changelog changes, and wait for CI on that exact commit to pass.
5. Create an annotated tag on the release commit:

   ```bash
   git tag -a vX.Y.Z -m "Dandelion vX.Y.Z"
   ```

6. Verify the tag points at the intended commit:

   ```bash
   git show --no-patch --decorate vX.Y.Z
   ```

7. Push the branch and tag only after the owner intends to publish:

   ```bash
   git push origin master
   git push origin vX.Y.Z
   ```

8. Create a GitHub Release from `vX.Y.Z` with the changelog, upgrade/data migration notes, backup advice for schema changes, and known limitations.
9. Never force-push, delete, or recreate a release tag to change its contents. Fix a published release by publishing a higher version.

If the actual default branch is no longer `master`, use the confirmed default branch rather than blindly copying these example commands.

## 6. Version decision checklist

- [ ] Is this only correcting existing behavior? PATCH.
- [ ] Does it add backward-compatible functionality? MINOR.
- [ ] Does it break the released contract or backup/data compatibility? MAJOR.
- [ ] Can existing user data be preserved through a tested migration? If yes, a schema change alone may not be MAJOR.
- [ ] Are there new user-visible changes beyond a fix? Prefer the highest applicable type.
- [ ] Has the new version passed the release gates?
- [ ] Does `pubspec.yaml` match the tag and use a higher build number for the distributed build?
- [ ] Is the tag new, annotated, and attached to the exact release commit?
