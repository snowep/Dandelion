# U9 — Stable release and immutable tag decision

**Goal:** ship a truthful, reproducible stable release; never publish a version just because a tag name already exists.

## Facts to acknowledge
- Existing `v1.0.0` points to `193d9c2e31fdfab61397596645b26df5ddeb7e9d`.
- Existing `v1.0.1` points to current head `86e48560e8500221f4056c2ba92089f01f57a125`.
- Current source manifest is still `version: 0.2.0+1`.
- Current head CI fails at formatting; analyzer, tests and web build did not run.
- GitHub Releases has no release entries. Existing tags are still real Git refs and may already be consumed.

## Required human decision
Recommended safe policy is to keep existing refs immutable and use the next stable tag `v1.0.2` after remediation. Do not create or retarget `v1.0.0` again.

If a release *named exactly* `v1.0.0` is a hard requirement, stop and ask the repository owner to explicitly decide whether the existing `v1.0.0`/`v1.0.1` tags are accidental and safe to retire. Do not delete/move them automatically. Record the decision and its impact on clones, builds and release consumers.

## Final execution
1. Complete `RELEASE_CHECKLIST.md` and attach evidence URLs to PR/release notes.
2. Verify `pubspec.yaml` marketing version and build number align with chosen strategy. Do not edit version early just to make the app “look” released.
3. Run all CI stages on the exact release commit. For required native targets absent from CI, record manual smoke-test evidence.
4. Verify clean installation, upgrade from schema v3, manual offline entry, online lookup failure fallback, and export/restore of all fields/covers.
5. Update changelog/README/docs; state what is tested and what is not.
6. Create one annotated, immutable tag at the verified commit. Create GitHub Release notes only after checks pass. Preserve the source SHA and CI run URL.
7. If a post-release bug appears, fix forward with a PATCH version; do not move the existing tag.

## Stop criteria
Any missing import, schema mismatch, import/export loss, unsupported claimed target, failed CI, missing tests, or unresolved version/tag decision blocks release.
