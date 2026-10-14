# Dandelion — Product Requirements

**Status:** Initial specification  
**Product type:** Offline-first personal book library  
**Platforms:** Android, iOS, web, Windows, macOS, Linux  
**Initial release:** Personal use; no account or community requirement

## 1. Product purpose

Dandelion is a personal library dashboard for keeping book records, tracking reading, maintaining a wishlist, and discovering what to read next. It should feel calm and tactile, work without an internet connection, and stay responsive with a large library.

## 2. Product principles

- **Local by default:** core library actions work offline and save to SQLite where supported.
- **Useful before social:** no community infrastructure is required for the first release.
- **Fast over flashy:** motion and decoration must not delay reading or editing.
- **Explain recommendations:** show why a book was suggested.
- **Small surface area:** add a dependency or abstraction only to solve a demonstrated need.
- **User-owned data:** provide export and backup before remote sync is introduced.

## 3. Target user and jobs

The primary user wants to:
1. Record books they own, are reading, have finished, or want to read.
2. Update progress by page or percentage.
3. Review reading history and simple statistics.
4. Find a book quickly by title, author, genre, status, or notes.
5. Discover related books based on their own reading history.
6. Keep the library usable on different screen sizes and offline.

## 4. Scope

### MVP — required

- Add, edit, archive, and delete a book.
- Store title, authors, description/plot, genres, identifiers, publication details, page count, cover reference, personal rating, notes, and timestamps.
- Reading statuses: **Want to read**, **Reading**, **Paused**, **Finished**, **Did not finish**.
- Track progress by current page and optional start/finish dates.
- Wishlist view and ability to move a wishlist book into the library.
- Dashboard with currently reading, recently updated, wishlist count, finished count, and a small set of useful statistics.
- Search, sorting, filtering, and saved filter state where practical.
- Local SQLite persistence, schema migrations, and export/import.
- Material 3 Expressive visual system, adaptive layouts, keyboard support, and accessibility.
- Recommendation list based on available book metadata and reading history, with plain-language explanations.
- Empty, loading, error, and no-results states.

### Explicitly out of scope for MVP

- Public profiles, followers, comments, social feeds, and public reviews.
- Cloud accounts and automatic cross-device sync.
- AI/LLM calls, paid recommendation APIs, and required network access.
- Reading ebooks inside the app.
- Complex gamification or a custom analytics engine.

### Later phases

- Remote sync with authenticated API and conflict handling.
- Optional public profile and community features.
- Aggregated popularity signals and collaborative recommendations.
- Import integrations and external book metadata providers, each behind a clear permission and failure path.

## 5. Core user flows

### Add a book
1. Open **Add book**.
2. Enter at least a title; all other fields are optional unless a validation rule requires them.
3. Save.
4. The book appears in the selected library/status view and remains available offline.

### Track reading
1. Open a book marked Reading.
2. Update current page or progress percentage.
3. Validate progress against page count when page count is known.
4. Save progress and update the last-read timestamp.
5. Mark Finished to set the finish date; allow the user to correct it.

### Find a book
1. Enter a search query or choose a filter.
2. Search title, author, genre, description, and personal notes.
3. Apply sorting without loading the entire library into memory.
4. Preserve filters when opening a book and returning to the list where possible.

### Understand a recommendation
1. Open **For you**.
2. See a ranked list of books already in the local library or wishlist, plus any explicitly imported catalog candidates.
3. Each recommendation includes a short reason, such as “Because you finished 3 books in this genre.”
4. Allow dismissing a suggestion and recording “not interested”; use this feedback in later ranking.

## 6. Functional requirements

| ID | Requirement | Acceptance condition |
|---|---|---|
| FR-01 | Book CRUD | Create, update, archive, and delete records; destructive deletion requires confirmation. |
| FR-02 | Reading progress | Progress persists after restart and rejects impossible page values. |
| FR-03 | Search | Search works offline and returns matching metadata/notes. |
| FR-04 | Sort/filter | Sort by title, author, date added, last updated, rating, page count, and progress; filter by status and genre. |
| FR-05 | Dashboard | Counts are derived from stored data, not duplicated manually. |
| FR-06 | Recommendations | Rank candidates with deterministic scoring and display grounded reasons. |
| FR-07 | Data portability | Export a documented JSON format; validate imports before writing. |
| FR-08 | Accessibility | Controls have labels, support keyboard/focus, respect text scaling, and meet practical contrast targets. |
| FR-09 | Offline use | No network is needed to add, edit, search, or track a book. |
| FR-10 | Reliability | Migrations, import, and persistence have automated tests. |

## 7. Data model

Minimum entities:

- **Book:** id, title, authors, description, genres, identifiers, publisher, publication date, page count, cover URI/path, createdAt, updatedAt, archivedAt.
- **ReadingRecord:** id, bookId, status, currentPage, progressPercent, startedAt, finishedAt, lastReadAt, personalRating, notes.
- **ReadingEvent:** id, bookId, eventType, page, occurredAt. Store only events that provide useful history; avoid logging every keystroke.
- **RecommendationFeedback:** id, bookId, action (dismiss/not interested/saved), createdAt.
- **AppSetting:** key, value, updatedAt.

Use stable IDs. Store timestamps in UTC and render them in local time. Avoid duplicating derived values such as total finished books unless profiling proves aggregation is too slow.

## 8. Quality requirements

- Scrolling should remain smooth with thousands of records on a mid-range device.
- List screens must use bounded queries and lazy item construction.
- Cover images must be resized/cached and never loaded at original resolution without need.
- The app must not require a login to access local data.
- Database writes must be transactional where a user action updates multiple records.
- Failures must preserve existing data and show a clear recovery action.
- Provide a complete local export before adding sync.

## 9. Success checks

- A user can add a book, close the app, reopen it, and find the same data.
- A 5,000-book test dataset can be searched, sorted, and scrolled without loading all records at once.
- Recommendations are reproducible for the same input and explain their main signals.
- Core flows work in airplane mode.
- Automated tests cover data validation, migrations, ranking, and import/export.

## 10. Decisions to revisit

- Remote backend and sync protocol, only when sync is scheduled.
- External catalog provider and licensing/attribution.
- Whether popularity is based on app-wide anonymized counts, a public catalog, or both.
- Backup encryption and platform-specific file locations.
