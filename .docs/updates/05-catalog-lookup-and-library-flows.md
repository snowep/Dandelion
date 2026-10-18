# U5 — Finish catalog lookup and the end-to-end library flows

**Goal:** title/ISBN lookup is useful but optional, transparent and cannot overwrite personal data.

## Relevant files
- `lib/services/google_books_lookup_service.dart`
- `lib/services/isbn_lookup_service.dart`
- `lib/features/library/widgets/google_books_lookup_dialog.dart`
- `lib/features/library/widgets/isbn_lookup_dialog.dart`
- `lib/features/library/library_screen.dart`
- repository/model/tests and `.docs/PRD.md`

## Required changes
1. Trace which lookup dialog/service is actually wired into Library and Discover. There are two lookup services that may duplicate responsibilities; consolidate only after confirming call sites. Prefer one clear Google Books integration unless testing shows a concrete need for a second provider.
2. Provide a title/ISBN search action with a bounded candidate list, edition/ISBN information, metadata preview, and field selection before save. Manual entry must always remain available.
3. Provider failures (offline, timeout, HTTP error, malformed JSON, empty result, rate limit) show an actionable state but must not stop manual save.
4. Normalize ISBN and check duplicates first by ISBN, then warn on probable normalized title+author matches. Never auto-merge or silently overwrite user-owned notes, rating, reading progress/status, personal dates, or cover chosen by the user.
5. Preserve provider source URL and attribution where provided. Validate cover URL/content/size before storing. Do not invent absent authors, genres, page counts, or release dates.
6. Search by title/author uses provider-supported query syntax; add request timeouts, bounded result size, and deterministic mock tests. Avoid two global caches with unbounded lifetime; use a modest TTL policy.
7. Make lookup and export/import entry points obvious in UI, with loading, empty, offline, error and retry states.

## Acceptance
- Mock provider tests cover good/partial/malformed/no results and timeout.
- Manual add/edit succeeds in airplane mode.
- Lookup preview only imports selected metadata and preserves personal fields.
- Saved catalog cover reloads locally after app restart where storage is supported.
