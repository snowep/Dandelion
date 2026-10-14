# Dandelion — Product Requirements

**Status:** Updated initial specification  
**Product:** Offline-first personal book library  
**Targets:** Android, iOS, web, Windows, macOS, Linux  
**MVP:** Personal use; no account, remote sync, or community requirement

## 1. Purpose

Dandelion is a personal library dashboard to record books, track basic reading progress, manage a wishlist, and find the next book. It should work offline, remain responsive with a large collection, and explain its recommendations.

## 2. Product rules

- **Local first:** adding, editing, searching, tracking, and exporting work without internet.
- **Lookup is optional:** title/ISBN lookup and external discovery need internet; manual entry always remains available.
- **No premature social layer:** remote sync and community are later phases.
- **Explain recommendations:** each suggestion gives a reason grounded in available data.
- **Small implementation:** no speculative abstractions, complex reading-session tracking, or AI service in the MVP.
- **User owns the data:** export and restore must be dependable before remote sync is considered.

## 3. Primary jobs

1. Keep a record of books owned, being read, finished, paused, or wanted.
2. Update current page or completion percentage.
3. See simple reading statistics and finished-book history.
4. Search by title, author, ISBN, genre, plot/description, or notes.
5. Look up a book by title or ISBN, review the metadata, and decide what to import.
6. Discover books from the local library/wishlist and from an external catalog.
7. Export the library with its cover images and restore it later.

## 4. Scope

### MVP — required

- Create, edit, archive, and delete book records.
- Manual book entry plus optional online title/ISBN lookup.
- A metadata preview before any lookup result is saved. The user chooses which fields to accept.
- Local cover image selection and optional cover lookup from a metadata provider.
- Store selected/downloaded cover images locally; remote cover URLs are not the only copy.
- Reading statuses: **Want to read**, **Reading**, **Paused**, **Finished**, **Did not finish**.
- Basic progress: current page, optional page count, calculated percentage, start date, finish date, and personal rating.
- Wishlist and a one-action move from wishlist to another status.
- Dashboard with currently reading, recently updated, wishlist count, finished count, and a few useful statistics.
- Offline local search, sorting, and filtering.
- Recommendations from both the user's collection/wishlist and on-demand external catalog results.
- Manual export/import. Full backup includes book data and cover assets.
- Material 3 Expressive design, adaptive layouts, keyboard support, and accessibility.
- Loading, empty, failure, offline, and no-results states.

### Out of scope for MVP

- Public profiles, followers, comments, social feeds, public reviews, or app-wide popularity ranking.
- Remote accounts and automatic cross-device sync.
- Reading sessions, duration tracking, quotations, or annotation systems.
- AI/LLM calls or paid recommendation APIs.
- Reading ebooks inside the app.
- Bulk data harvesting from catalog providers.

### Later phases

- Remote synchronization with authentication, conflict handling, and recovery.
- Optional community features and privacy/moderation controls.
- Popularity signals based on legitimate aggregated read/save activity, once a community exists.
- Additional catalog providers or import integrations only when they solve a real gap.

## 5. Core flows

### Add manually

1. Open **Add book** and choose manual entry.
2. Enter a title; other metadata is optional.
3. Optionally choose a local cover.
4. Save. The book is available offline.

### Look up a book

1. Enter an ISBN or title and request a catalog lookup.
2. If online lookup is unavailable or fails, continue with manual entry.
3. Review candidate editions and their available metadata/cover.
4. Select a result and decide which fields to import. Do not overwrite personal notes, rating, status, or progress.
5. Check for duplicates by normalized ISBN first; if missing, use normalized title plus author as a warning, not an automatic destructive merge.
6. Save the selected metadata locally and keep an attribution/source URL where provided.

### Track reading

1. Open a book marked Reading.
2. Update current page or percentage.
3. If page count is known, validate that `0 <= currentPage <= pageCount`; calculate percentage from pages unless the user explicitly uses percentage-only progress.
4. Mark Finished to set the finish date. Let the user correct the date.
5. Persist the change locally without creating per-session logs.

### Discover books

1. Open **Discover**.
2. See local candidates not already finished, plus external candidates when online lookup is available.
3. For each result, show the source and a concise reason, e.g. “Shares two genres with books you rated highly.”
4. External results remain catalog candidates until the user saves them to the library or wishlist.

### Export and restore

1. Export a versioned archive containing `library.json` and referenced cover assets.
2. Allow metadata-only JSON export if the user does not need the images.
3. Validate an import completely before writing any changes.
4. Show an import preview and conflict choices. Never silently replace the existing library.

## 6. Functional requirements

| ID | Requirement | Acceptance condition |
|---|---|---|
| FR-01 | Book records | Create, edit, archive, and delete; confirm destructive delete. |
| FR-02 | Reading progress | Page/percentage persists after restart and rejects impossible values. |
| FR-03 | Local search | Search title, author, ISBN, genres, description, and notes offline. |
| FR-04 | Sorting/filtering | Sort by title, author, added/updated date, rating, page count, or progress; filter by status and genre. |
| FR-05 | Catalog lookup | Search by title/ISBN, preview results, handle failure, and allow manual fallback. |
| FR-06 | Cover images | Use local covers or optionally retrieve a catalog cover; display a fallback on missing assets. |
| FR-07 | Discover | Rank local and external candidates; show grounded recommendation reasons and source. |
| FR-08 | Data portability | Export and restore JSON/archive; validate before database writes. |
| FR-09 | Cross-platform persistence | Data survives restart on each supported platform under supported storage conditions. |
| FR-10 | Accessibility | Labels, focus, keyboard behavior, screen-reader semantics, and text scaling work. |
| FR-11 | Reliability | Automated tests cover storage, migrations, progress, lookup parsing, ranking, and import/export. |

## 7. Data model

- **Book:** stable ID, title, authors, description/plot, genres, ISBN-10/13 and other identifiers, publisher, publication date, page count, cover asset reference, external catalog ID/source URL, createdAt, updatedAt, archivedAt.
- **ReadingRecord:** bookId, status, currentPage, optional percentage-only progress, startedAt, finishedAt, lastReadAt, personalRating, notes.
- **RecommendationFeedback:** bookId or external candidate ID, action (`dismiss`, `notInterested`, `saved`), createdAt.
- **CatalogCache:** only the limited lookup/discovery metadata needed to avoid repeat requests; apply an expiry policy and never treat cache as the user's saved library.
- **AppSetting:** key, value, updatedAt.

Do not add a reading-session/event table for the basic tracker. Store times in UTC and display in local time. Derived dashboard counts should be queried/calculated rather than manually duplicated.

## 8. Recommendation rules

Rank saved books and wishlist candidates using reading history. For external candidates, use available metadata and the user's preference profile; never invent missing details.

Start with normalized signals from 0 to 1:

`score = 0.25*genreSimilarity + 0.10*authorSimilarity + 0.20*textSimilarity + 0.35*historyFit + 0.10*novelty`

- Genre similarity: weighted Jaccard overlap with genres from positively rated/finished books.
- Author similarity: preference for authors whose books the user finished or rated highly.
- Text similarity: TF-IDF + cosine similarity over title and description/plot.
- History fit: similarity to positive reading history, weighted by explicit rating and recency.
- Novelty: small preference for candidates not already finished or dismissed.
- Missing signals: normalize the remaining weights rather than treating unknown values as zero quality.
- Cold start: use optional genre/author preferences, then a neutral catalog ordering until enough personal history exists.
- Popularity: **not a required MVP signal**. Add a limited, time-decayed, sample-smoothed signal only when a trustworthy public/community data source exists.

Weights are starting values to be tested, not proven constants. Display one or two of the strongest available reasons. Keep ranking deterministic for identical inputs.

## 9. Quality requirements

- Core library behavior is offline-first.
- Lookup clearly indicates when internet is required and never blocks manual entry.
- A 5,000-book fixture can be searched, sorted, and scrolled without loading every row or cover into memory.
- Cover files are resized for display, loaded lazily, and cached within a bound.
- Database writes affecting several records are transactional.
- Web storage limitations are visible; private browsing or browser-managed data eviction must not be presented as a reliable backup.
- A full export can restore metadata and locally stored covers.

## 10. Success checks

- A saved book persists across restart on each supported target in a normal, supported storage context.
- Core library flows work in airplane mode.
- Title/ISBN lookup can fail without blocking manual entry.
- Import validation errors do not partially mutate the library.
- A 5,000-book test dataset stays responsive with lazy lists and bounded queries.
- Recommendations are deterministic, explainable, and tested for cold-start/missing metadata cases.

## 11. Open implementation gates

- Verify the chosen database package, browser persistence mode, and all six target builds in Phase 0.
- Verify the metadata provider's API behavior, rate limits, attribution, image-use rules, and browser CORS before committing to it. Open Library is a candidate, not a guaranteed choice.
- Decide whether a second provider is necessary only after testing the first.
