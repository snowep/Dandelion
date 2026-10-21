# Dandelion — Project Guide

## Current state

**Phase:** 4 — Documentation and release readiness  
**Release:** personal library with backup/restore, cross-platform cover storage, and import safety  
**Book entry:** manual entry plus optional title/ISBN lookup  
**Storage:** SQLite native on native; SQLite WASM/browser storage on web, with cover persistence via covers/ directory and IndexedDB; export/import round-trip validated with atomic rollback  
**Remote sync/community:** not yet implemented; offline-first personal library

Read this file first. Then open the specification that applies to the task.

## Project documents

| File | Use it for |
|---|---|
| `PRD.md` | Scope, user flows, data model, and acceptance criteria. |
| `DESIGN.md` | Material 3 Expressive, slivers, adaptive layout, and accessibility. |
| `STACK.md` | Storage, lookup, search, recommendation algorithms, and platform constraints. |
| `CONVENTIONS.md` | Coding rules for humans and coding agents. |
| `PROJECT.md` | Roadmap and verification checklist. |

## Locked decisions

- Flutter + Dart, Material 3 Expressive.
- Targets: Android, iOS, web, Windows, macOS, Linux.
- Core library actions work offline without an account.
- Manual book entry is always available; title/ISBN lookup is optional and online.
- Use local covers and optional catalog-provided covers; store selected covers for offline use.
- Reading tracking stays basic: status, page/percentage, dates, rating. No session timer or annotation system in MVP.
- Discover includes saved books and external catalog candidates. Catalog data must not be invented.
- Recommendations use genre, author, text, and reading-history signals. Public popularity is deferred until trustworthy community data exists.
- Manual export/import is required. Full backup includes cover files.
- No remote sync or community in the first release.
- Follow `CONVENTIONS.md`: smallest complete change, test risky logic, no speculative abstractions.

## Roadmap

See `ROADMAP_TO_V1.0.0.md` for the ordered update plan. The current verified state completes U0–U3. Work continues through U4–U8.

**Exit condition:** documentation and release gates matched to verified implementation; all P0/P1 findings resolved; platform support explicit; changelog and version policy approved.
