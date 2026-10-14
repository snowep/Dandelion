# Dandelion — Technical Stack

## 1. Recommended baseline

- **Framework:** Flutter stable channel; Dart with sound null safety.
- **Design:** Material 3 (`ThemeData(useMaterial3: true)`).
- **Targets:** Android, iOS, web, Windows, macOS, Linux.
- **Database candidate:** Drift with SQLite on native targets and its WebAssembly SQLite implementation in browsers. Confirm package/version/platform support in Phase 0 before locking dependencies.
- **Initial network use:** optional book metadata lookup and external discovery only. No account, app backend, sync, or community in MVP.

Pin Flutter/Dart versions and package versions through the project setup and lockfile. Upgrade intentionally.

## 2. Structure

Use a small feature-oriented structure:

`Screen/Widget → feature controller or view model → repository → database/provider`

- Widgets render state and forward actions.
- A small controller/view model coordinates screen state only where necessary.
- Repositories expose useful operations, not raw SQL.
- Database code owns schema, migrations, and queries.
- One catalog service handles search-by-title/ISBN, result parsing, and cover metadata. Don't build a provider framework until a second provider is actually needed.
- Recommendation ranking is deterministic Dart logic with unit tests.

Use Flutter's built-in local state first. Add one established state-management package only if cross-screen state becomes demonstrably difficult. No global service locator or speculative use-case layer.

## 3. Local persistence across platforms

### Recommended candidate: Drift

Evaluate `drift` plus `drift_flutter` first because it can share most query/schema code across native and web while using different database runtimes underneath:

- **Android/iOS/Windows/macOS/Linux:** SQLite on the app's private local storage.
- **Web:** Drift's SQLite build compiled to WebAssembly, persisted through browser storage such as the Origin Private File System API or IndexedDB fallback.

This matches the adaptive-storage choice without duplicating repository query logic. It is still a candidate until the phase-0 proof of concept passes on the intended targets.

### Platform constraints that must be tested

- Drift web requires the matching `sqlite3.wasm` and web worker assets in the deployed web bundle. Keep them aligned with the locked Drift/sqlite3 versions.
- The WASM asset must be served with `Content-Type: application/wasm`.
- Some web storage modes work better with `Cross-Origin-Opener-Policy: same-origin` and `Cross-Origin-Embedder-Policy: require-corp` (or the supported alternative). Hosting configuration must be checked.
- Browser support and behavior differ. Private browsing can fall back to IndexedDB or even in-memory storage. Some Chrome-on-Android multi-tab configurations have persistence/race limitations without the needed APIs/headers. Show a warning if only a weak/nonpersistent mode is available.
- Browser data is scoped to that browser/origin and can be cleared by the user or browser. It is not a substitute for export.
- SQLite FTS5 availability must be verified on every target/build. If unavailable in one runtime, use an explicit fallback rather than assuming the extension exists.
- Native desktop SQLite loading/packaging must be verified on clean Windows, macOS, and Linux builds, not only on the developer machine.

### Database rules

- Version the schema and write explicit migrations.
- Enable foreign keys where supported.
- Bind query values; never concatenate user input into SQL.
- Index common filters and sort fields: status, normalized title, updated time, and relationships.
- Use transactions for multi-record changes.
- Store cover image bytes outside the SQLite database. Store a stable asset key/path and source URL in the book record.
- Keep queries bounded and never load the whole library just to sort or search.

## 4. Cover image storage

- **Native:** copy/import selected or downloaded cover files into app-managed local storage. Keep only their relative asset key in the database.
- **Web:** store cover blobs in persistent browser storage (for example IndexedDB) behind the cover repository; don't assume native filesystem paths exist.
- Resize large images and generate/use thumbnails for book cards.
- A downloaded provider cover should remain usable offline when successfully stored locally.
- Keep remote source URLs and provider attribution where supplied. If a provider's cover cannot be downloaded or used, show it remotely only when permitted and use a placeholder on failure.
- Validate file type and size. Do not trust filename extensions alone.

A small platform-specific cover-storage implementation is justified because native files and browser blobs are different storage primitives. Keep its interface narrow; don't generalize it into a media framework.

## 5. Book metadata lookup and external candidates

Metadata lookup is an optional online feature. Manual add/edit must always work without a provider.

### Flow

1. Accept ISBN-10/ISBN-13 or a title query.
2. Request a bounded result set; don't crawl or bulk-download catalogs.
3. Normalize provider results into the fields the app actually uses.
4. Present candidates for user selection and show edition/ISBN where available.
5. Let the user choose/adjust imported fields. Keep personal notes, reading status, progress, and rating untouched.
6. Deduplicate by normalized ISBN. If no ISBN exists, warn on a likely title+author match and let the user decide.
7. Cache the selected metadata and useful recent query results with an expiry policy. Store only the selected cover locally for offline use.
8. Handle timeout, rate limit, malformed responses, missing fields, and no cover without blocking manual entry.

**Provider decision:** evaluate Open Library first because its documented Search API supports title/author/edition-oriented results and its Covers API provides cover URLs. Before adopting it, test the exact endpoints from Flutter web, review current usage/rate limits and cover guidelines, and keep attribution. Direct browser requests depend on the provider's CORS behavior. If web requests are blocked, do not hide the failure or quietly introduce an unrequested backend; test an alternative provider or defer web lookup while keeping manual entry fully usable. Google Books is an alternative to evaluate, not a second provider to integrate pre-emptively.

Do not use catalog ratings, result order, or edition counts as “how many people read this.” Those are different signals.

## 6. Sorting, local search, and filters

### Sorting

Use database-side `ORDER BY`, `WHERE`, and indexes. Sort by title, author, date added, last updated, rating, page count, or progress. Add a stable tie-breaker such as `id`; define how null values are ordered. Use keyset pagination if large offsets become slow or unstable. Do not implement quicksort/mergesort for data already stored in SQLite.

### Search

- Use SQLite FTS5 if the selected runtime exposes it, indexing title, authors, genres, description, and personal notes.
- Test FTS5 at phase 0 in native and web builds.
- If unsupported, use indexed title/author prefix search plus a documented basic substring fallback; don't pull every record into Dart.
- Normalize case and whitespace. Bind all search input safely.
- Debounce interactive search around 200–300 ms and discard stale responses if the user has typed a new query.

Local search works offline. Catalog lookup is a separate, explicitly online operation.

## 7. Hybrid recommendation engine

Candidates include (a) books already saved in the library/wishlist and (b) external catalog results fetched on demand. The app can only recommend external candidates for which it has metadata; do not claim comprehensive catalog coverage.

### Starting score

Normalize each available signal to 0–1:

`score = 0.25*genreSimilarity + 0.10*authorSimilarity + 0.20*textSimilarity + 0.35*historyFit + 0.10*novelty`

- `genreSimilarity`: weighted Jaccard similarity with genres from finished or positively rated books.
- `authorSimilarity`: preference for authors whose books the user finished or rated highly.
- `textSimilarity`: TF-IDF vectors over title and plot/description, compared with cosine similarity.
- `historyFit`: similarity to positive history, weighted by rating and recency.
- `novelty`: small bonus for not-finished/not-dismissed candidates.

When a candidate has missing fields, normalize over available weights instead of assigning a bad score for unknown data. A local library candidate can use the full set of signals. An external candidate may only have genres/title/plot and therefore may score on fewer signals.

### Ranking steps

1. Build a preference profile from finished books and explicit ratings. Do not assume that every finished book is a favorite.
2. Tokenize titles/descriptions, normalize case, remove common stop words, and calculate TF-IDF.
3. Calculate cosine similarity for text and weighted Jaccard for genres.
4. Apply author preference, recency-weighted history fit, and novelty/dismissal rules.
5. Normalize available weights, sort descending by score, and use stable tie-breakers.
6. Generate explanations from the strongest known signals, e.g. “Shares two genres with books you rated highly.”
7. For cold start, offer a small optional favorite-genre/author setup and otherwise use neutral catalog relevance.

Weights are starting values and need feedback-based evaluation. Keep ranking deterministic for the same input. Do not require an LLM or online embedding service.

### Popularity — later only

Popularity is **not part of the local-only MVP score**. Once public/community data exists, use a modest, time-decayed signal based on unique readers/saves with a minimum-sample or Bayesian smoothing rule. Raw read counts favor older/popular titles. Keep personal relevance dominant, explain the signal, and publish no individual reading history without explicit opt-in.

## 8. Manual export/import

Use a versioned archive for full backup:

- `library.json`: schema/version plus books, statuses, ratings, notes, settings selected for export, and asset references.
- `covers/`: locally stored cover assets referenced by the export.

Also allow metadata-only JSON export for simple interchange. On import, validate version, IDs, sizes, types, and required fields before writing; show a preview; wrap database writes in a transaction; report conflicts; and never overwrite silently. Reject unsafe archive paths and unreasonable file sizes. Import/export must work offline.

Web export/import uses browser download/file selection APIs; native targets use platform file dialogs/share destinations as appropriate. Verify the chosen file-picker/archive packages on all six targets before selecting dependencies.

## 9. Memory and performance

- Use lazy sliver builders and bounded query pages.
- Load cover images only near the viewport and decode to thumbnail dimensions.
- Bound image and metadata caches.
- Avoid loading the whole library or full-size images into memory.
- Do expensive text vector/ranking work off the UI path if profiling shows it blocks frames; first keep the implementation simple and measure.
- Dispose controllers, streams, and subscriptions.
- Use Flutter DevTools to measure before adding extra cache layers or compute/isolate complexity.

## 10. Tests and commands

- Unit: progress validation, text normalization, TF-IDF/cosine, genre overlap, ranking ties, cold start, and missing metadata.
- Database: CRUD, constraints, migration paths, search behavior, and transactions.
- Provider: ISBN/title mapping, malformed data, missing cover, timeout, rate limiting, and CORS smoke test on web.
- Storage: write/reopen on Android, iOS, web, Windows, macOS, and Linux build targets where available; explicitly test private-browsing/web persistence warnings.
- Import/export: round trip with covers; malformed archives; duplicate IDs; rejected paths; failed import leaves existing data unchanged.
- Widget/integration: add manually offline, lookup preview, save a result, update progress, search, export, restore.
- Run `dart format .`, `flutter analyze`, and `flutter test`. Never claim they passed unless executed.

## 11. Official references to re-check before implementation

- [Drift web platform support and setup](https://github.com/simolus3/drift/blob/develop/docs/content/platforms/web.md)
- [Flutter web WebAssembly support](https://docs.flutter.dev/platform-integration/web/wasm)
- [Open Library API usage guidelines and rate limits](https://openlibrary.org/developers/api)
- [Open Library Search API](https://openlibrary.org/dev/docs/api/search)
- [Open Library Covers API guidelines](https://openlibrary.org/dev/docs/api/covers)
- [Google Books Volumes API](https://developers.google.com/books/docs/v1/reference/volumes/list)
