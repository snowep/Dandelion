# U9 — release candidate and version decision

## Prerequisites

- CI is fully green on the release candidate commit: format, analyze, test and web build all ran and passed.
- Actual v3→v4 migration fixture passed.
- Import/export full round trip, conflict handling and rollback tests passed.
- Native/web cover behavior was validated for all supported targets.
- P0/P1 findings are closed, and remaining P2 items are resolved or explicitly scoped out with owner approval.
- README/PRD/PROJECT/roadmap/audit/changelog match the actual code.

## Release candidate steps

1. Check the exact release commit and clean worktree.
2. Decide whether existing tags `v1.0.0` and `v1.0.1` remain historical and use `v1.0.2` as the next release (recommended), or whether the maintainer is explicitly pursuing a different policy. Never move tags silently.
3. Set `pubspec.yaml` to the chosen semantic version plus a build number that respects distribution history; make the public version match the release tag.
4. Add release notes with verified features, migration behavior, backup advice, platforms/limitations and known issues.
5. Run all automated gates on the final versioned commit; any source or manifest change after a green run requires CI to run again.
6. Test backup from the previous supported version, upgrade/migrate, then restore that backup into a clean environment.

## Acceptance

A release-candidate record lists commit SHA, tag decision, manifest version/build number, CI URL, migration/backup proof, platform smoke results and release notes. No release is created while any prerequisite is unchecked.
