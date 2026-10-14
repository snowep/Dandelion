# Dandelion

Offline-first personal book library. Record books, track reading progress, manage a wishlist, and discover the next book — all locally, without accounts or remote sync.

**Product:** Personal library dashboard for Android, iOS, web, Windows, macOS, Linux  
**MVP scope:** Manual entry + optional title/ISBN lookup, local search, status and progress tracking, recommendations from your collection, manual export/import. No accounts, remote sync, or community features.  
**Principles:** Local first, lookup optional, user owns data, explanations for recommendations, small implementation.

See the specification for details:
- [Product Requirements](./.docs/PRD.md)
- [Project Guide](./.docs/PROJECT.md)
- [Design Specification](./.docs/DESIGN.md)
- [Technical Stack](./.docs/STACK.md)
- [Conventions](./.docs/CONVENTIONS.md)

## Platform support

Targets per PRD:

- Android — supported
- iOS — supported
- Web — supported; persistence depends on browser storage mode; private browsing and managed eviction are not a reliable backup
- Windows — supported
- macOS — supported
- Linux — supported

Phase 0 work validates Drift SQLite/WASM, FTS5, cover storage, and export/import on all targets. Lookup requires internet; manual entry always works offline.

## Running the app

From the project root:

```bash
# Format, analyze, and test
dart format .
flutter analyze
flutter test
```

Run on a connected device or emulator:

```bash
flutter run -d <device>
```

Web:

```bash
flutter run -d chrome
# or build
flutter build web
```

## Development workflow

```bash
flutter pub get
dart format .
flutter analyze
flutter test
```

CI commands are the same: format, analyze, test must pass with zero lint errors.

## Docs

All canonical specifications live in `.docs/` and are the source of truth. Do not duplicate them elsewhere.
