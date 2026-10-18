# Dandelion stable release checklist

Do not release until all required boxes below are checked with evidence.

## Code and CI
- [ ] `dart format --output=none --set-exit-if-changed .` passes.
- [ ] `flutter analyze` passes with no errors (warnings reviewed, none ignored to hide defects).
- [ ] `flutter test` discovers and passes the real suite.
- [ ] `flutter build web` passes using locked dependencies.
- [ ] Native build/run evidence exists for every target claimed supported, or published limitations explicitly name unverified targets.
- [ ] No settings import refers to a missing file; exactly one intended root ProviderScope.
- [ ] No unreviewed `.backup`/`.bak` files or dead competing screen/config files remain.

## Data safety
- [ ] Database migration from v3 adds purchase/lending fields and preserves all existing records/progress/notes.
- [ ] Import/export round-trip preserves every `Book`, `ReadingRecord`, purchase/lending fields, and cover bytes.
- [ ] Invalid import and injected mid-import failure leave existing DB and cover files unchanged.
- [ ] Backup count matches source count beyond 500 records.
- [ ] No unsafe archive paths, malformed fields, oversized payloads or invalid IDs are accepted.
- [ ] ISBN duplicate logic and nullable-field clearing have regression tests.

## Product behavior
- [ ] Manual add/edit works offline; catalog outage never blocks manual entry.
- [ ] Status/progress/date/rating/notes work and can be corrected/cleared.
- [ ] Search includes the documented fields; each visible filter/sort has a passing test.
- [ ] Covers persist offline after restart on tested targets.
- [ ] Local and external recommendations are deterministic, correctly scored and have grounded explanations.
- [ ] Purchase/lending fields are either fully supported/tested/documented or removed from MVP deliberately.
- [ ] Keyboard, screen reader semantics, large text and light/dark/system themes are reviewed.
- [ ] Empty/loading/offline/error/no-results states are understandable and recoverable.

## Release metadata
- [ ] `.docs/PRD.md`, `.docs/PROJECT.md`, README and changelog match verified behavior.
- [ ] `pubspec.yaml` version/build number matches the approved version strategy.
- [ ] Existing tag collision decision is recorded.
- [ ] Release commit SHA and exact CI run URL are recorded.
- [ ] Release notes include migration/back-up instructions and known limitations.
- [ ] Annotated immutable tag is created only after all checks pass; GitHub Release is created from that tag.
