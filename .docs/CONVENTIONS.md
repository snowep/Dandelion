# Dandelion — Coding Conventions

These rules apply to humans and coding agents. Prefer readable, ordinary Dart over clever abstractions.

## 1. The decision ladder

Before writing code, work through this order:

1. Does the feature need to exist now?
2. Does the project already solve it?
3. Can Dart, Flutter, or the platform solve it directly?
4. Can an installed dependency solve it?
5. If none apply, implement the smallest complete solution.

Read the existing flow before editing it. Reuse code when it is correct. Do not preserve a bad abstraction merely because it exists.

## 2. Code style

- Follow `dart format` and `flutter analyze`.
- Use sound null safety. Avoid `dynamic`, `!`, and broad `Object` casts unless the boundary genuinely requires them.
- Use descriptive names: `currentPage`, not `cp`; `loadBooks`, not `doStuff`.
- Prefer small functions with one clear job.
- Prefer early returns over deeply nested conditionals.
- Keep widget build methods readable. Extract a widget when it clarifies a real reusable or independently testable unit, not to make every few lines a class.
- Use `const` constructors and widgets when possible.
- Avoid comments that restate the code. Comment on intent, constraints, or non-obvious trade-offs.
- Do not add generic base classes, managers, factories, registries, or service layers without a concrete need.
- Do not rewrite unrelated files during a focused task.

## 3. File and naming conventions

- File names: `snake_case.dart`.
- Types and enums: `UpperCamelCase`.
- Variables, methods, and named parameters: `lowerCamelCase`.
- Constants: `lowerCamelCase` unless the repository's established lint configuration says otherwise.
- Private implementation details begin with `_`.
- Keep one main public type per file when that improves navigation; small closely related types may share a file.
- Use feature-oriented folders, then separate data/UI only where it helps locate changes.

Suggested structure:

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
      reading_repository.dart
    recommendations/
      recommendation_engine.dart
      recommendation_engine_test.dart
  shared/
    widgets/
    formatting/
test/
  features/
```

Keep the structure flexible. Do not create empty folders for future features.

## 4. Flutter UI rules

- Use Material 3 components before custom controls.
- Read colors and typography from the active theme.
- Use slivers for mixed, large, or collapsing scroll content.
- Use lazy builders for large collections.
- Do not nest scrollables without a clear reason.
- Avoid `shrinkWrap: true` on large lists.
- Give stateful list items stable keys when their state must survive reorder.
- Do not perform database queries, image decoding, or expensive recommendation calculations directly in `build`.
- Keep expensive work out of animation callbacks.
- Use `LayoutBuilder` or screen constraints for adaptive behavior.
- Add semantics and keyboard behavior as part of the component, not as a late cleanup.

## 5. Data and database rules

- UI code must not contain raw SQL.
- Repositories expose meaningful operations such as `searchBooks()` and `updateProgress()`.
- Bind SQL values as parameters. Never build SQL by concatenating user input.
- Use transactions for logically atomic multi-step changes.
- Every schema change gets a migration and a migration test.
- Store stable IDs and explicit timestamps.
- Validate imported data before writing it. A failed import must not leave half the library updated.
- Never silently discard conflicting progress or notes.
- Do not store secrets in source code, logs, or ordinary preferences.

## 6. State and errors

- Keep transient form/UI state close to the widget that owns it.
- Share state only when multiple screens genuinely need it.
- Represent loading, success, empty, and failure states explicitly.
- Catch errors at a boundary that can respond usefully; do not blanket-catch and ignore exceptions.
- User-facing errors should state what failed and what the user can do next.
- Avoid global mutable state.

## 7. Testing rules

Test behavior and failure cases, not private implementation details.

Required coverage for a feature that changes data:
- normal success;
- invalid input;
- empty or missing data;
- persistence after reopening;
- failure/rollback when relevant.

Recommendation changes must include tests for missing metadata, no reading history, ties, dismissed books, and stable ranking. Database changes must include migration coverage.

Run before declaring a task complete:

```bash
dart format .
flutter analyze
flutter test
```

If a command cannot run, state which command failed and why. Do not claim tests passed when they were not run.

## 8. Coding-agent task format

Every coding task should contain:
1. **Goal:** one observable result.
2. **Relevant files:** inspect before editing.
3. **Constraints:** compatibility, data safety, and non-goals.
4. **Implementation:** smallest complete change.
5. **Verification:** exact commands and tests.

Agent behavior:
- Make one bounded change at a time.
- Do not invent requirements or silently expand scope.
- Do not add dependencies without explaining the concrete need.
- Do not remove tests to make a build pass.
- Do not mark a task complete until the relevant checks run.
- If a requirement is ambiguous and affects data loss, security, or architecture, ask one concise question.
- End status reports with changed behavior, tests run, and known limitations.

## 9. Definition of done

- The requested behavior works.
- Relevant tests are added or updated.
- Formatting, analysis, and tests pass—or failures are explicitly reported.
- Accessibility and adaptive behavior are considered.
- No unrelated refactor or dependency was added.
- Documentation is updated only where it helps the next person act correctly.
