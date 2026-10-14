# Dandelion — Technical Stack

## 1. Platform and language

- **Framework:** Flutter stable channel.
- **Language:** Dart with sound null safety.
- **Design:** Material 3 (`ThemeData(useMaterial3: true)`).
- **Targets:** Android, iOS, web, Windows, macOS, Linux.
- **Storage:** SQLite on platforms with a supported SQLite implementation; a local persistence adapter for platforms where SQLite is unavailable or impractical.
- **Initial network requirement:** none for core features.

Pin Flutter/Dart versions in project setup documentation and CI. Upgrade deliberately, not as an incidental part of feature work.

## 2. Architecture

Use a simple feature-oriented structure with a clear path from UI to persistence:

`Screen/Widget → feature controller or view model → repository → local database`

- Widgets render state and forward user actions.
- Controllers/view models coordinate screen state and call repositories.
- Repositories expose app-level operations, not raw SQL.
- Database code owns schema, migrations, and queries.
- Recommendation logic is a pure Dart service where practical, with deterministic input/output.
- Do not introduce a global service locator, generic use-case layer, or elaborate domain framework unless real complexity requires it.

Use the simplest state management approach that remains testable. Prefer Flutter's built-in mechanisms for local widget state. If cross-screen state becomes difficult to manage, choose one established state-management package and document why; do not mix several systems.

## 3. SQLite and persistence

Choose a maintained SQLite package compatible with the target platforms, such as `sqflite` for supported mobile/desktop targets or `drift` when typed queries, generated data access, migrations, and web support justify its additional tooling. Verify current platform support before locking the dependency. Do not assume one SQLite package works identically on every target.

Implementation requirements:
- Database schema version and explicit migrations.
- Foreign keys enabled where supported.
- Parameterized queries only; never interpolate user input into SQL.
- Index common filters and sort keys: status, normalized title, updated timestamp, and book-to-reading-record relationship.
- Use transactions for multi-record changes.
- Store book descriptions and notes as text; keep cover files outside the database and store a relative path or stable URI.
- Avoid storing full-size cover bytes in SQLite.
- Add database constraints for required fields and valid progress where practical.
- Test upgrade paths from every released schema version.

### Web platform

SQLite-on-web support depends on the chosen package and browser runtime. Verify it early with a small prototype. If the selected SQLite implementation cannot meet browser requirements, use a repository-backed browser storage implementation (for example IndexedDB) behind the same repository contract. Do not claim the web database is SQLite unless it actually is.

## 4. Local-only first, remote sync later

The first release is **manual/local-only**: no account, server, or background sync.

When remote sync is scheduled:
1. Define a server API and authentication model before adding sync UI.
2. Keep local writes immediate; record a small outbox/change log for pending changes.
3. Give each record a stable ID and a version/update timestamp.
4. Sync in bounded batches and retry safely.
5. Use idempotent operations so retries do not duplicate records.
6. Define conflicts explicitly. For simple fields, compare record versions and offer recovery for meaningful conflicts; do not silently overwrite reading progress or notes.
7. Deletions require tombstones until the server confirms replication.
8. Expose sync status and provide export/restore.
9. Encrypt traffic with TLS; store credentials using platform-appropriate secure storage.
10. Document account deletion, data export, retention, and backup behavior.

A remote database is not created by SQLite itself. It requires a separately operated service or provider.

## 5. Search

### MVP
- Use SQLite FTS5 if the chosen SQLite build supports it.
- Index title, author names, genres, description, and notes.
- Keep display sorting separate from search ranking.
- Normalize input for case and whitespace; preserve original user text.
- Escape or safely bind search input according to the query API.
- Debounce typing around 200–300 ms, cancel stale requests where possible, and avoid running a full search on every keystroke.

### Fallback
If FTS5 is unavailable on a target, use indexed prefix matching for title/author and a clearly documented basic substring fallback. Do not load all books into Dart just to search.

## 6. Sorting and filtering

Use SQL `ORDER BY`, `WHERE`, and indexes rather than sorting the entire collection in memory.

Supported sorts:
- Title A–Z / Z–A
- Author A–Z
- Date added newest/oldest
- Last updated
- Personal rating
- Page count
- Progress

Always add a stable tie-breaker such as `id` so pagination does not reorder equal values unpredictably. Define null handling for missing ratings, dates, and page counts. Use keyset pagination for large datasets when offset pagination becomes slow or unstable.

Sorting algorithm: database engine's indexed ordering/query planner. Avoid implementing custom quicksort/mergesort for data already stored in SQLite.

## 7. Recommendation engine

Use a deterministic hybrid ranker. The first version recommends from books already in the library/wishlist or a locally imported catalog. It cannot recommend arbitrary books without candidate metadata.

### Candidate scoring

For each candidate, compute normalized signals in the range 0–1:

- `genreSimilarity`: overlap between candidate genres and genres from books the user rated highly or finished.
- `authorSimilarity`: preference for authors the user rated highly; reduce the signal if author data is missing.
- `textSimilarity`: TF-IDF cosine similarity across title and description/plot text.
- `historyFit`: similarity to positively rated/finished books, weighted by recency and explicit rating.
- `novelty`: small bonus for books not already finished or dismissed.
- `popularity`: **0 in local-only MVP** unless a legitimate local popularity dataset is imported. Later, use normalized read/save/rating counts from a privacy-reviewed source.

Example starting score:

`score = 0.25*genreSimilarity + 0.10*authorSimilarity + 0.20*textSimilarity + 0.35*historyFit + 0.10*novelty`

Normalize the available weights if a signal is missing. These weights are initial tunable defaults, not scientific truths. Evaluate them against real user feedback before claiming recommendation quality.

### Algorithm details

1. Build a user preference profile from finished books, explicit ratings, and reading history. Positive ratings and completed books contribute positively; abandoned books contribute only if the user explicitly says why or rates them.
2. Represent text with TF-IDF: term frequency multiplied by inverse document frequency.
3. Compare candidate vectors with cosine similarity.
4. Compute genre similarity with weighted Jaccard similarity over genre tags.
5. Rank by weighted score, then stable tie-breakers.
6. Generate reasons from the strongest positive signals: “Similar to books you rated highly,” “Shares two of your favorite genres,” or “By an author you often finish.”
7. Record dismiss/not-interested feedback and reduce similar future candidates where appropriate.
8. Exclude books already finished by default, but provide a setting to include them.

### Popularity later

Use a smoothed, time-aware score rather than raw read count. Raw popularity favors old, widely marketed books and disadvantages new titles.

A future score may combine:
- unique readers or saves, with abuse-resistant counting;
- recent activity with time decay;
- rating quality with a minimum-sample Bayesian prior;
- relevance to the current user's preferences.

Do not upload individual reading history to create public trends without clear disclosure and opt-in. Prefer aggregated counts and minimum cohort thresholds. Keep popularity a limited signal so it cannot overwhelm personal relevance.

### Cold start

When the user has little history, rank by selected favorite genres/authors, then a neutral curated/default order. Explain that recommendations improve after the user rates or finishes books. Never fabricate confidence or reasons.

## 8. Cover images and memory

- Store cover files outside the database.
- Use thumbnails appropriate to the rendered size; decode at target dimensions when possible.
- Use a bounded cache and clear it when memory pressure requires it.
- Load covers lazily as rows enter view.
- Use placeholders and error fallbacks; do not repeatedly retry a missing image during every rebuild.
- Dispose controllers, streams, and subscriptions.
- Avoid caching every book object and cover in memory. Fetch bounded pages and retain only the state needed by the visible screen.

## 9. Testing and tooling

- Unit tests: ranking, text normalization, sorting rules, progress validation, and date handling.
- Database tests: CRUD, constraints, indexes where measurable, transactions, and migrations.
- Widget tests: forms, filters, empty/error states, adaptive navigation, and text scaling.
- Integration tests: create book → restart/reopen → search → update progress → export.
- Static checks: `dart format`, `flutter analyze`, and `flutter test`.
- Profile performance with Flutter DevTools on representative physical devices and desktop/web targets.

## 10. Dependency policy

Before adding a package, check whether Flutter/Dart, the platform, or an existing dependency already solves the problem. Confirm maintenance, license, platform support, bundle size, and testability. Add the smallest dependency that meets a concrete requirement.
