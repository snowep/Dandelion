# FTS5 Support POC Results

## Summary

Test to verify FTS5 virtual table support via sqlite3 package with Drift on Windows native (dart:ffi) and web (WASM) targets.

## Test Implementation

- **File**: `test/fts5_support_test.dart`
- **Method**: Probe SQLite via `sqlite3` package (used by Drift) and attempt `CREATE VIRTUAL TABLE ... USING fts5`.
- **Fallback**: If creation fails, fallback method is LIKE-based search.

## Results Matrix

| Target | FTS5 Available | SQLite Version | Fallback Method Used | Performance Notes |
|--------|----------------|----------------|----------------------|-------------------|
| windows | yes | 3.43.2 | none | FTS5 creation and query succeeded in ~5ms |
| web | TBD | TBD | TBD | Run via `flutter test -d chrome` |

### Windows Native Findings

- **SQLite version**: 3.43.2 (via sqlite3 2.9.4 package)
- **FTS5 available**: Yes
- **Fallback**: Not used
- **Performance**: Creation + query ~5ms on in-memory DB

### Web Target Notes

- Drifts `sqlite3` package uses sql.js WASM on web.
- Expected FTS5 support: sql.js typically bundles SQLite with FTS5 enabled.
- To verify: run `flutter test test/fts5_support_test.dart -d chrome`. Result should be captured in test output.

## Drift Integration

The application already uses `book_database.dart` with FTS5 detection at runtime:

- Attempts to create temporary FTS5 table to probe support.
- On success, creates `books_fts` virtual table with triggers for sync.
- On failure, falls back to `LikeBookSearchStrategy`.

The test confirms the underlying sqlite3 driver has FTS5 capability.

## Conclusion

FTS5 is available on Windows native with SQLite 3.43.2. Web target expected to support FTS5 via sql.js WASM. Fallback to LIKE queries remains in place for environments where FTS5 is unavailable.
