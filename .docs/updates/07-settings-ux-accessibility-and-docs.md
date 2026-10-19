# U7 — Settings, accessibility and documentation alignment

## Settings

The missing Settings files and nested `ProviderScope` issue are now fixed in source, but the theme control is not yet correct for all states. The notifier begins at `ThemeMode.system`, the switch indicates only `ThemeMode.dark`, and the callback toggles state rather than applying the requested boolean. Replace this with explicit System/Light/Dark selection or a correctly controlled light/dark switch. Decide whether persistence is in 1.0; if included, test persistence across restart.

## Usability and accessibility

1. Test compact width and wide desktop layouts, long titles, empty/error/loading states, large text scaling, keyboard-only navigation, visible focus, screen-reader semantics and contrast in light/dark themes.
2. Check that each page owns exactly one AppBar and shell navigation never overlaps content.
3. Test destructive actions with confirmation and visible outcomes/errors.
4. Verify form validation for ISBN, price/currency, dates, rating, page count and lending/borrowing states.
5. Make export/import visible from an appropriate user-facing screen with actionable progress, success and failure messages.

## Documentation

1. Update `.docs/AUDIT_REPORT.md`, `.docs/BASELINE_AND_RISKS.md`, `.docs/ROADMAP_TO_V1.0.0.md`, `.docs/PROJECT.md`, `.docs/PRD.md`, `.docs/VERSIONING_AND_TAGS.md`, and `.docs/FILE_MANIFEST.json` only after the relevant work is verified.
2. Replace references to `86e4856` and the outdated claim that `v1.0.1` is current master.
3. Resolve `pubspec.yaml` `0.2.0+1` versus `.docs/VERSIONING_AND_TAGS.md` `1.0.0+1` in the approved release step, not as an arbitrary mid-feature edit.
4. Trace references to legacy screens and `.backup`/`.bak` files before a cleanup PR.

## Acceptance

Theme behavior and accessibility checks are tested. Docs describe only demonstrated features and current SHAs; tracked backups/legacy screens are either intentionally retained or safely removed in a separate verified change.
