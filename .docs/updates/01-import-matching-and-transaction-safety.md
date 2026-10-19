# U1 — archive-import matching and transaction safety

**Priority:** P0 / data integrity. Do not trust current import/overwrite until this task passes.

## Confirmed defect

`ImportService.importArchive()` calls `listBooks(filters: {'title': ..., 'authors': ...})` for its fallback title match. `BookRepositoryImpl.listBooks()` only reads `search`, `status`, and `genre`; the `title` and `authors` filter keys are ignored. The fallback can return the first book from the library and treat it as a match, causing valid imports to be skipped or the wrong record to be overwritten.

## Required changes

1. Add a dedicated exact-match API (or a direct tested query) for normalized title + normalized author. Do not call a fuzzy/search listing and then take its first result.
2. Define matching precedence: same normalized ISBN; otherwise exact normalized title and author; otherwise create new. Multiple matches must be reported as ambiguous and require a deterministic, documented user decision.
3. Fix ISBN selection: normalize both ISBN-13 and ISBN-10 and select the first non-empty valid candidate; do not use `isbn13 ?? isbn10` when fields can be empty strings.
4. Define `skip`, `overwrite`, and conflict behavior, including how an incoming reading record maps to an existing book. Apply reading-record fields consistently during overwrite; avoid duplicating or silently discarding progress, rating, notes and dates.
5. Ensure overwrite updates every supported book field, including purchase/currency and all borrower/lender fields. Null in the import must have a defined meaning: clear the field for replace semantics or preserve it for merge semantics. Implement clearable copy/update operations accordingly.
6. Validate the entire archive before mutating the database: expected top-level object/arrays/types, supported schema, required title, date/number/progress/rating bounds, duplicate incoming IDs/ISBNs, references from reading records, cover-key format, base64 decode and size limits. Avoid unbounded archive decompression/decoded payloads.
7. Make DB changes atomic. If staged cover writes fail, clean them up and roll back database writes; if DB commit fails, remove staged files. Never clear or partially overwrite the user's current library on failure.
8. Preserve complete export behavior. Do not introduce a hidden record limit. Keep backup schema-version compatibility explicit.

## Regression tests

- Import multiple ISBN-less books into an empty library; all must import.
- Import into a non-empty library with unrelated books; none may be misidentified as a title match.
- Existing matching ISBN skips/overwrites only the intended record.
- Exact title+author match works; same title/different author doesn't match; ambiguous matches are reported.
- Overwrite updates purchase and lending fields and reading record fields; nullable replacement behavior is explicit.
- Inject failure after several writes; database and existing covers remain as before the import.
- Malformed JSON/ZIP, missing fields, invalid dates/ratings/progress, invalid cover key/base64, duplicate incoming books and unsupported schema are rejected before mutation.
- Full export → new DB import → second export round-trip preserves books, records and covers.

## Acceptance

All tests pass under U0's green CI gate. Add a short note in docs explaining supported backup versions and the exact skip/overwrite semantics.
