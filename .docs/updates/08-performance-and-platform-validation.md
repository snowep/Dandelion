# U8 — performance and platform validation

## Requirements

1. Create deterministic fixtures for 100, 1,000 and 5,000 books, reading records and covers. Record load/search/filter/scroll/export/restore times and memory behavior.
2. Keep database queries for UI bounded/paginated and stable; don't place a silent limit on full export/statistics. Avoid loading every full cover concurrently; use thumbnails and bounded caching.
3. Test offline mode, restart persistence, data corruption/recovery and backup restore on each claimed target.
4. The repository declares web and includes WASM/worker assets, but file existence is not runtime evidence. Test built output under a real HTTP server with correct worker/WASM URL and MIME behavior, refresh/persist on supported browsers, and quota/clear-site-data scenarios.
5. Define release-supported targets explicitly: Android, iOS, web, Windows, macOS and Linux. For any target without build hardware/CI, provide manual smoke evidence or mark it unsupported in the release notes.
6. Do not upgrade major dependencies as a side effect of performance work. Measure first, then optimize one bottleneck at a time and retain before/after results.

## Acceptance

A checked-in or linked test report records fixture size, target, environment, command/smoke procedure, results and known limits. There are no unexplained data losses or serious responsiveness issues at the agreed baseline.
