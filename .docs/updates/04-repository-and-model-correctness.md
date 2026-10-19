# U4 — repository query and model correctness

## Required changes

1. Implement `offset` in `BookRepositoryImpl.getAll`; add a stable sort/tie-breaker and a two-page test. Maintain a separate complete iterator/query for export/statistics so pagination never truncates backups.
2. Fix `AppDatabase.getBooksFiltered`: `query.join([...])` currently returns a joined query but its result is discarded. Use a correctly assigned joined select or a correlated subquery for reading status. Test every `ReadingStatus` filter against multiple books.
3. Map every visible sort value to a supported database expression. Current DB logic explicitly supports title, author and updated/date, then defaults to title; align labels (`added`, `updated`, etc.) to actual fields and use a stable tie-breaker.
4. Search reading notes if product requirements retain notes-search. Use a valid join/EXISTS query without returning duplicate books.
5. Add exact filter semantics for any exposed `filters` map. Do not silently ignore keys; make unsupported keys typed/explicit.
6. Fix nullable clearing. `Book.copyWith` and `ReadingRecord.copyWith` currently use `x ?? this.x`. Use a sentinel/`clearX` flag or another type-safe pattern so the UI and import can explicitly clear cover key, page count, description, purchase/lender data, finish date, notes, rating and progress.
7. Normalize ISBN candidates independently, ignore blank values, validate ISBN-10/13 checksums where appropriate, and check duplicates across supported forms. Avoid relying on empty strings as IDs.
8. Make validation rules explicit for progress/page count/rating/date relationships. Reject invalid state at repository boundaries, not just in widgets.
9. Add tests for create/update/archive/delete, uniqueness, clearability, nullable sorting, every filter/sort, offset, notes search, ISBN fallback and archive inclusion.

## Acceptance

Repository behavior matches UI labels and PRD; all exposed parameters have tested behavior. Export remains uncapped and deterministic.
