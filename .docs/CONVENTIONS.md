# Dandelion — Coding Conventions

These rules apply to humans and coding agents. Aim for the smallest complete implementation, not the fewest lines at any cost.

## 1. Decision order

1. Does the feature belong in the current phase?
2. Does existing code already solve it correctly?
3. Can Flutter, Dart, or the platform solve it directly?
4. Can an installed dependency solve it?
5. Otherwise, implement the smallest safe solution and test it.

Read the code and its callers before editing. Finish required caller, test, fixture, and config changes. Do not add features or abstractions “for later.”

## 2. Dart style

- Run `dart format`; satisfy `flutter analyze`.
- Use sound null safety. Avoid `dynamic`, unchecked casts, and `!` unless justified at an unavoidable boundary.
- Use clear names (`currentPage`, not `cp`; `searchBooks`, not `doStuff`).
- Prefer early returns, small functions, and simple control flow.
- Use `const` when useful and correct.
- Extract widgets when the extraction improves readability, reuse, or testing—not to make every handful of lines a class.
- Comment only the reason, constraint, or trade-off the code cannot show.
- Avoid generic base classes, factories, managers, registries, service locators, and configuration layers without a concrete requirement.
- Keep a focused change focused; do not reformat or refactor unrelated code.

## 3. Naming and structure

- File names: `snake_case.dart`.
- Types/enums: `UpperCamelCase`.
- Variables/methods/parameters: `lowerCamelCase`.
- Private implementation details start with `_`.
- Keep related small types together when it improves navigation. Avoid empty folders and premature layers.

Suggested starting shape (change only when the code earns it):

```text
lib/
  app/
    app.dart
    app_theme.dart
    app_shell.dart
  features/
    library/
      book.dart
      book_repository.dart
      book_database.dart
      library_screen.dart
      book_editor_screen.dart
    reading/
      reading_screen.dart
    catalog/
      catalog_service.dart
    recommendations/
      recommendation_engine.dart
  shared/
    widgets/
    formatting/
test/
  features/
```

## 4. Flutter UI rules

- Prefer standard Material 3 components over custom controls.
- Read colors/type from the active theme.
- Use `CustomScrollView` and lazy slivers for long or mixed-content screens.
- Do not nest scrollables without a reason; avoid `shrinkWrap: true` on large lists.
- Keep network/file/database work out of `build`.
- Use stable IDs/keys when item state needs to survive reorder.
- Use `LayoutBuilder` or constraints for adaptive layout, not platform-name guesses.
- Include semantics, keyboard behavior, loading/error/empty states, and text scaling while building the feature.

## 5. Database and catalog rules

- UI widgets never contain raw SQL or catalog response parsing.
- Repositories expose useful operations; database code owns SQL and migrations.
- Bind SQL values as parameters. Never interpolate raw user input.
- Every schema change includes a migration and migration test.
- Use transactions for atomic multi-record writes.
- Do not overwrite user-owned progress, ratings, or notes when applying imported metadata.
- Treat external responses as untrusted and incomplete. Validate field types, sizes, identifiers, image URLs, and archive paths.
- Catch network failures and allow manual entry to continue.
- Do not log private notes or full reading history unnecessarily.

## 6. Data safety

- Import: validate first, preview changes, then transact. Failed imports must not partly mutate the library.
- Export: include an explicit format version and make file/cover handling clear.
- Cover files: validate format/size; keep database rows referencing stable asset keys, not transient picker paths.
- Browser data may be cleared by the user/browser. Never describe local browser storage as a backup.
- Secrets do not belong in source code, logs, or ordinary preferences.

## 7. Tests required

For changed behavior, cover success and the relevant failure path. Changes to persisted data also test restart/reopen behavior.

- Progress: invalid page count, zero pages, finished date correction.
- Catalog: missing fields, duplicate ISBN, timeout, rate limit, malformed response, unavailable web request.
- Recommendation: empty history, missing metadata, tie ordering, dismissed items, and external candidates with fewer signals.
- Storage: each available target and each schema migration.
- Import/export: round trip with images and rejection of malformed/unsafe archives.

Run before declaring the task done:

```bash
dart format .
flutter analyze
flutter test
```

If a command cannot run, state which command and why. Do not claim tests passed without running them.

## 8. Coding-agent task format

Each task should state:
1. **Goal:** one observable result.
2. **Relevant files:** inspect these and callers first.
3. **Constraints:** data safety, platform support, and non-goals.
4. **Change:** the smallest complete implementation.
5. **Verification:** commands and tests actually run.

Agent rules:
- Make one bounded change at a time.
- Don't invent requirements or expand scope silently.
- Don't add a second catalog provider, backend, or state-management package without a concrete reason.
- Don't remove tests to make a build pass.
- Report errors with location, cause, and fix; no drama.
- If a choice risks data loss or makes a major platform architecture decision, ask one concise question.

## 9. Output style: Ponytail + i-have-adhd

- Lead with the action/result, not a preamble.
- Use numbered steps for multi-step work; keep lists short and instructions actionable.
- Prefer simple, well-tested code over cleverness or abstraction.
- State what changed, what was actually verified, and the remaining risk/omission.
- Do not hide a limitation behind confident wording. Keep explanation proportional to the task.
- The style guides affect communication and implementation discipline; they do not override validation, accessibility, security, or required tests.

References: [Ponytail](https://github.com/dietrichgebert/ponytail) · [i-have-adhd](https://github.com/ayghri/i-have-adhd)

## 10. Definition of done

- Requested behavior works across the applicable target(s).
- Relevant tests are added/updated and checks have run.
- Platform limitations are documented rather than ignored.
- Accessibility and error states are covered.
- No unrelated refactor, speculative abstraction, or unapproved dependency was added.
