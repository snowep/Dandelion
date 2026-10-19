# U10 — stable release and immutable tag

1. Confirm the release-candidate checklist is fully green and reviewed by the maintainer.
2. Create an **annotated** tag on the exact verified commit after the version decision is documented. Default is `v1.0.2` because pushed `v1.0.0` and `v1.0.1` already exist on older commits.
3. Confirm the tag target SHA equals the release commit SHA (dereference annotated tag objects; do not compare tag-object SHA to commit SHA).
4. Confirm `pubspec.yaml` public version matches tag and build number reflects distribution history.
5. Publish a GitHub Release entry with release notes and correct artifacts if distribution is intended. A tag by itself is not a published GitHub Release.
6. Verify the published page, downloads/checksums if provided, upgrade/migration instructions and the backup-before-upgrade note.
7. Do not force-push or move existing tags to make the history appear clean. If release policy requires replacing them, make that an explicit owner-approved repository-history operation separate from the routine release.

**Acceptance:** release URL, immutable tag target SHA, package version, CI run and backup/upgrade evidence are recorded together.
