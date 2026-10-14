# Dandelion — Design Specification

## 1. Design direction

Use **Material 3 Expressive** and Material You principles: personal color, clear hierarchy, approachable shapes, purposeful motion, and responsive layouts. Keep the reading content primary; don't animate every component.

## 2. Visual system

### Color

- Use Flutter Material 3 `ColorScheme` generated from a seed color.
- Support light, dark, and system theme modes.
- On Android, offer dynamic system color when available; also provide a Dandelion seed palette for every platform.
- Read colors and typography from `Theme.of(context)`, not hard-coded widget colors.
- Test contrast in both themes. Generated palettes do not remove the need to check important text/icon pairings.

Suggested seed direction: muted botanical green or warm dandelion yellow. These are proposals, not locked brand colors.

### Type, shape, and surfaces

- Prefer Material typography roles over arbitrary font sizes.
- Keep book title prominent and metadata secondary but readable.
- Respect text scaling; don't use fixed-height boxes that clip large text.
- Use rounded surfaces, tonal elevation, and clear grouping. Avoid heavy shadows and blur.
- Keep cover aspect ratios consistent and display a neutral fallback when no cover is available.

## 3. Navigation

Primary destinations:
1. **Home** — currently reading, recently updated, quick actions, and compact statistics.
2. **Library** — local collection, search, status and genre filters.
3. **Wishlist** — wanted books and simple status changes.
4. **Discover** — recommendations from local data and optional online catalog results.
5. **Insights** — finished count and other basic statistics.

Use `NavigationBar` on compact layouts, `NavigationRail` or a navigation panel at medium/expanded widths. Keep the same navigation model; adapt its presentation rather than creating per-platform versions.

## 4. Add-book and lookup experience

- Make **Enter manually** and **Look up by title/ISBN** obvious choices.
- Catalog lookup is optional and must have a visible progress, offline, empty, rate-limited, and error state.
- Show result title, author, edition/ISBN when available, publication year, and cover thumbnail.
- Before saving a result, show a preview/edit form. The user controls imported fields.
- Never overwrite reading status, progress, rating, or personal notes from catalog metadata.
- Show a source link/attribution when metadata comes from a provider.
- Cover actions: choose local image, use a provider cover, remove cover. On web, file selection and persistent image storage use browser-compatible APIs.

## 5. Sliver patterns

Use `CustomScrollView` where pages combine headers, filters, summaries, and large lists.

- `SliverAppBar`: page title and search/filter actions; pinned only when useful.
- `SliverToBoxAdapter`: small summaries or an add-book prompt.
- `SliverPersistentHeader`: only for a filter/sort row that benefits from staying visible.
- `SliverList` / `SliverGrid`: lazy book cards and rows.
- `SliverFillRemaining`: empty, error, or first-run states.
- `SliverPadding`: consistent page margins.

Don't nest a `ListView` inside another scrolling view when slivers can model the page directly. Use lazy builders and avoid `shrinkWrap: true` for large lists.

## 6. Adaptive layout

Use available width, not a device-name check.

- **Compact:** one main content column, bottom navigation, book rows or a two-column cover grid.
- **Medium:** navigation rail, wider margins, optional list/detail split.
- **Expanded:** persistent navigation, constrained content width, list/detail split where useful.
- **Desktop:** support keyboard navigation, focus indicators, pointer/hover behavior, and resizable windows. Don't stretch forms across the whole screen.

Define breakpoints in one place and use `LayoutBuilder` or `MediaQuery.sizeOf(context)` at screen boundaries.

## 7. Motion and interaction

- Use Material interaction states and standard controls first.
- Animate meaningful changes only; keep transitions short and interruptible.
- Respect reduced-motion settings where supported.
- Avoid animated backgrounds, parallax, and repeated expensive blur in scrolling regions.
- Update reading progress on explicit save or a small debounced interaction, not by rebuilding the whole dashboard on every keystroke.
- Offer undo for reversible actions such as archive when practical.

## 8. Accessibility

- Icon-only actions need semantic labels and tooltips.
- Don't communicate status through color alone.
- Support screen readers, keyboard navigation, visible focus, and system text scaling.
- Aim for 48 logical-pixel interaction targets where practical.
- Use `Semantics` when built-in widgets do not already provide accurate labels.
- Test TalkBack, VoiceOver, keyboard-only use, high text scaling, and light/dark contrast.

## 9. States every data screen must handle

- **Loading:** concise indicator or static placeholder; no large animated shimmer lists.
- **Empty:** explain the state and show one clear action.
- **No results:** preserve the query and offer clear filters.
- **Lookup unavailable:** state that catalog lookup needs a connection; keep manual entry available.
- **Lookup failure:** show the cause when known and offer retry/manual entry.
- **Offline:** local collection stays available; only online features are disabled.
- **Import/export failure:** do not imply success; preserve the source data and offer retry.

## 10. Performance checklist

- Lazy slivers for large collections.
- Bounded database queries and stable IDs/keys.
- Thumbnail-sized cover images and bounded image cache.
- No queries, file reads, or expensive recommendation ranking inside `build`.
- Avoid expensive clipping/opacity effects across long lists.
- Profile frame time, rebuilds, and memory using Flutter DevTools before optimizing further.

## 11. Acceptance checklist

- [ ] Light, dark, and system color modes work.
- [ ] Layout adapts to compact, medium, and expanded widths.
- [ ] Library list uses lazy sliver construction.
- [ ] Manual entry works without internet.
- [ ] Lookup has loading, empty, error, rate-limit, and manual fallback states.
- [ ] Both locally selected and provider-sourced covers render with a fallback.
- [ ] Large text does not clip controls.
- [ ] Keyboard focus and screen-reader labels are logical.
