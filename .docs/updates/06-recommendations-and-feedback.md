# U6 — Complete deterministic, explainable recommendations

**Goal:** implement the documented hybrid algorithm instead of ranking with placeholder values.

## Relevant files
- `lib/features/discover/recommendation_engine.dart`
- `lib/features/discover/discover_screen.dart`
- `lib/features/library/book.dart`, `reading_record.dart`, repository and tests
- `.docs/PRD.md`, `.docs/STACK.md`

## Required changes
1. Build the preference profile once per ranking operation from finished/high-rated history; do not rebuild it inside every candidate score.
2. Implement supported signals from the PRD: weighted genre overlap (e.g. weighted Jaccard), author preference, normalized text similarity (TF-IDF + cosine over title/description), history fit weighted by rating/recency, and novelty/dismissal feedback.
3. Normalize weights over **signals that can genuinely be computed** for a candidate. Do not include hard-coded stubbed zeroes in `totalWeight` as the current code does.
4. Handle cold start/no positive history, missing descriptions/genres/authors, external candidates with sparse metadata, and already finished/dismissed candidates explicitly.
5. Rank both local collection/wishlist candidates and bounded external catalog candidates. Current external candidates are provider ordered rather than scored by the engine.
6. Use stable tie-breakers and deterministic output for identical inputs. Provide explanations based only on actual computed signals; never claim text or author affinity when metadata is missing.
7. Keep popularity/community ranking out of MVP. No LLM, embeddings API or online recommendation dependency.

## Tests and acceptance
- Unit tests for each signal, missing fields, cold start, recency/rating handling, normalization, ties, dismissal, local and external candidates.
- A given fixture returns same scores/order on repeated runs.
- Explanation text matches the signals that actually produced the score.
- Profiling: avoid O(candidates × library × history) rebuild loops for a 5,000-book fixture.
