# Dandelion — Design Specification

## 1. Design direction

Use **Material 3 Expressive** with Material You principles: personal color, clear hierarchy, approachable shapes, purposeful motion, and layouts that adapt to the available space. Expressive does not mean every component should be animated or oversized. Reading content remains the focus.

## 2. Visual system

### Color

- Use Flutter's Material 3 `ColorScheme` generated from a seed color.
- Support light and dark themes.
- On Android, use dynamic system colors when available and when the user chooses **System colors**.
- Provide a Dandelion seed palette fallback on platforms without dynamic color.
- Never hard-code colors throughout widgets. Use `Theme.of(context).colorScheme` and `Theme.of(context).textTheme`.
- Check text and icon contrast for both themes. Do not assume generated color pairs always meet every use case.

Suggested seed direction: muted botanical green or warm golden yellow. Treat these as a starting point, not final locked brand colors.

### Type

- Use Material typography roles (`display`, `headline`, `title`, `body`, `label`) rather than arbitrary font sizes.
- Book titles should be prominent; metadata should remain readable and secondary.
- Respect system text scaling. Avoid fixed-height text containers that clip larger text.

### Shape and elevation

- Use rounded Material surfaces and cards where they clarify grouping.
- Prefer tonal surfaces and borders over stacks of shadows.
- Reserve strong emphasis for the primary action and the currently selected navigation destination.
- Keep book covers visually consistent with a fixed aspect ratio.

## 3. Navigation and screen structure

Primary destinations:
1. **Home** — current reading, activity, quick actions, and compact statistics.
2. **Library** — searchable collection with filters and sorting.
3. **Wishlist** — books the user wants to read or acquire.
4. **Discover** — explainable local recommendations.
5. **Insights** — reading history and statistics.

On compact windows, use `NavigationBar` with four or five destinations only if labels remain clear; otherwise move secondary destinations into a menu. On medium/expanded windows, use `NavigationRail` or a drawer/navigation panel. Do not create separate navigation implementations for each platform; adapt the shell.

## 4. Sliver-based screen patterns

Use `CustomScrollView` for dashboard and library pages where collapsing headers or mixed content are useful.

- `SliverAppBar`: title, search/filter actions, optional pinned behavior.
- `SliverToBoxAdapter`: small summary or filter region.
- `SliverPersistentHeader`: only for a filter row that genuinely needs to remain visible.
- `SliverList` / `SliverGrid`: lazy book cards or rows.
- `SliverFillRemaining`: empty, error, or first-run state.
- `SliverPadding`: consistent content margins.

Do not wrap a `ListView` inside another scrolling view when a single `CustomScrollView` can express the layout. Use `SliverChildBuilderDelegate` for large collections. Keep `shrinkWrap: true` out of long lists unless the list is genuinely small.

## 5. Adaptive layout

Use available width and layout constraints, not device names, to choose layout.

- **Compact:** one main content column, bottom navigation, compact book rows or two-column cover grid when covers are the main signal.
- **Medium:** navigation rail, wider content margins, two-pane library/detail layout when helpful.
- **Expanded:** persistent navigation, constrained reading-width content, optional list/detail split view.
- **Desktop:** support mouse, keyboard, hover, right-click only where useful, and resizable windows. Do not stretch text and forms edge-to-edge.

Use `LayoutBuilder` or `MediaQuery.sizeOf(context)` at the screen boundary. Define a small set of breakpoints in one place; do not scatter arbitrary width checks across widgets. Confirm layout behavior on Flutter web and desktop as well as mobile.

## 6. Interaction and motion

- Use standard Material interaction states, focus rings, ripples, and semantic controls.
- Animate only to communicate a state change, hierarchy, or continuity.
- Keep transitions short and interruptible. Respect reduced-motion settings where supported.
- Avoid continuously animated backgrounds, parallax, or expensive blur behind scrolling content.
- Save progress on explicit actions or with a small debounced update; do not rebuild the whole dashboard on each keystroke.
- Provide undo for reversible actions such as archive or remove-from-wishlist when practical.

## 7. Accessibility

- Every icon-only control needs a tooltip and semantic label.
- Do not communicate status by color alone; include text or an icon with a label.
- Support keyboard navigation, visible focus, screen readers, and system text scaling.
- Interactive targets should be comfortably tappable; aim for at least 48 logical pixels where practical.
- Use `Semantics` only where standard widgets do not provide correct semantics.
- Test with TalkBack, VoiceOver, keyboard-only navigation, and high text scaling.
- Use meaningful cover alt text when a cover conveys information; decorative images should not create redundant announcements.

## 8. Loading, empty, and error states

Every data-driven screen must define:
- **Loading:** small progress indicator or skeleton-like placeholder without large animated shimmer lists.
- **Empty:** one sentence explaining the state and one clear action.
- **No results:** preserve the query and offer a clear-filter action.
- **Error:** explain what failed and offer retry or export/recovery where relevant.
- **Offline:** core local features remain available; network-dependent features show their offline status.

## 9. Performance rules

- Use lazy sliver delegates for book collections.
- Keep list item widgets small and stable; use keys based on stable book IDs when state preservation requires them.
- Use thumbnail-sized cover images and a bounded image cache.
- Avoid large opacity, blur, and clipping effects over thousands of items.
- Keep database work off the UI thread when it becomes measurably expensive.
- Use DevTools to profile frame time, rebuilds, memory, and image cache before adding optimization layers.

## 10. Design acceptance checklist

- [ ] Light, dark, and system-color themes work.
- [ ] Layout adapts at compact, medium, and expanded widths.
- [ ] Library uses lazy list/grid construction.
- [ ] Large text does not clip primary actions or book titles.
- [ ] Keyboard focus is visible and logical on desktop/web.
- [ ] Empty, error, loading, and no-result states are designed.
- [ ] Motion is purposeful and does not block interaction.
