# U4 — Fix repository, query, ISBN and nullable-field correctness

**Goal:** every control in Library filters/sorts/searches correctly; edits can clear optional values; pagination is deterministic.

## Required changes
1. `BookRepositoryImpl.getAll({limit, offset})` currently ignores `offset`; pass it into the database query, or remove the parameter if this method is intentionally always complete. Prefer distinct APIs for paginated UI and full export iteration so truncation is never silent.
2. Fix status filtering in `AppDatabase.getBooksFiltered`: `query.join(...)` is called without using the returned joined query. Implement a valid join or `EXISTS` subquery and add tests for every `ReadingStatus`.
3. Make every sort option emitted by `BookListScaffold` map to a real DB ordering: title, author, date-added, last-updated, page count, progress/rating if UI offers them. Use stable secondary order by ID and define null ordering.
4. Search the PRD-required fields: title, author, ISBN, genres, description and reading notes. Keep SQL parameters bound. Test quotes, punctuation, empty query, case/whitespace normalization, and no-result state.
5. Fix ISBN selection so an empty ISBN-13 cannot mask ISBN-10. Normalize non-empty candidates and test normalized duplicate collisions, update-self behavior and invalid ISBN inputs.
6. Fix nullable clear semantics in `Book.copyWith` and `ReadingRecord.copyWith`. Use a sentinel value or explicit clear flags for optional strings/numbers/dates; ordinary omitted argument must still mean “keep current value.” Add tests for description, pageCount, coverAssetKey, price/currency, lender/borrower fields, currentPage/progress, finishDate, notes and rating.
7. Do not load every cover byte eagerly. Use paginated queries and lazy thumbnail retrieval for UI. `getAll` used for export/statistics must remain complete; database counts/aggregates should be done with bounded SQL where reasonable.
8. Check foreign-key handling, cascade delete, transaction boundaries for create book + initial reading record, ISBN unique-index errors and stable date/time behavior.

## Acceptance
- Automated tests verify all visible sort/filter controls and pagination across at least 1,000 seeded records.
- A 750+ item library can navigate/search all records; export/statistics see full data.
- Every nullable field can be removed through the UI and stays removed after database reopen.
- No raw SQL interpolation or unchecked user-supplied sort column names.
