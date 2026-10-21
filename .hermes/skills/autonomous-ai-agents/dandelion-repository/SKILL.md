Phase 2 — Backup and Restore Integrity

### Scope
Correct the backup file format, import identity mapping, matching, skip/overwrite behavior and full rollback. Ensure cover failures cannot be silently ignored.

### Success measurement
- The exported `.zip` is a valid ZIP containing `library.json`; re-importing it restores books, reading records and cover bytes.
- Importing into a populated library containing unrelated books does not collide with their IDs or modify them.
- ISBN matching and exact title-plus-full-authors matching target the intended book.
- Skip leaves the destination book and its reading record unchanged.
- Overwrite updates the intended book and reading record according to documented replacement rules.
- A forced failure partway through the import leaves the database and pre-existing covers unchanged.
- Invalid archives, duplicate incoming identities and unsupported schema versions are rejected before mutation.

### Push gate
Every scenario above has a regression test; import/export tests and the full CI workflow pass on the same commit.

## 2.1 Export format (settings_screen.dart)

### Problem
Settings export serializes JSON bytes but names the downloaded file `dandelion_library_export.zip`. The `ExportService` has a ZIP-writing helper, but Settings does not use it.

### Fix
Use `ExportService.exportToFile(File(...)..path)` which writes a genuine ZIP archive via `ZipEncoder`. The generated file begins with the ZIP signature `PK` and a ZIP decoder can open it and find `library.json`.

### Regression test
- Output begins with ZIP file signature `PK`.
- A ZIP decoder can open it and find `library.json`.
- The archive contains all expected book and reading data plus cover data.
- The generated file can be imported on both web and native platforms.

## 2.2 Import ID mapping and conflict handling

### Problem
Imported books retain their source database IDs. Importing into a non-empty library can collide with existing IDs. The conflict branch also searches reading records using the destination book ID even though the exported record references the source ID.

### Fix
- Map source book IDs to destination IDs during import.
- ISBN matching and exact title-plus-full-authors matching target the intended book.
- Skip leaves the destination book and its reading record unchanged.
- Overwrite updates the intended book and its reading record.

### Regression test
- A conflict reaches the preview/confirmation UI instead of being rejected as malformed.
- Skip leaves the destination book and reading record unchanged.
- Overwrite updates the intended book and reading record.
- Importing into a non-empty library with overlapping source IDs does not collide with unrelated destination books.
- New records retain the correct progress, status, notes, dates, and rating.

## 2.3 Atomic import and failure recovery

### Problem
Database changes are applied sequentially, and cover assets are processed afterward. A late failure can leave a partially imported library.

### Fix
Make a complete import one operation from the user's perspective. Use a database transaction for library writes and a deliberate staging/cleanup strategy for cover files so that a failed import cannot leave partial data behind.

### Regression test
- Inject a failure after at least one book has been processed.
- Verify that no partial book or reading-record changes remain.
- Verify that cover writes are either completed or cleaned up/restored on failure.
- Verify malformed archives and unsupported schemas fail without modifying the library.

## 2.4 Cover failure visibility

### Problem
`storeImage()` returns a boolean result, but import ignores it and can report success when covers were not saved.

### Fix
Import checks the boolean result of `storeImage()` and reports validation failure if covers cannot be saved.

### Regression test
- A failed cover write cannot be reported as a successful import.
- Invalid keys are rejected, and storage errors are never reported as success.
- Dedicated cover tests pass on both native and web runtimes.

## 2.5 References

- `references/export-format.md` — details of the ZIP export format and `ExportService.exportToFile` API.
- `references/import-id-mapping.md` — source-to-destination ID mapping strategy and conflict-skip-overwrite semantics.
- `references/atomic-rollback.md` — transaction boundaries and failure-injection test pattern.
- `references/cover-validation.md` — cover storage validation and failure modes on native and web.