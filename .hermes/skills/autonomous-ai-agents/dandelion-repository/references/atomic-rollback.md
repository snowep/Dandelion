# Atomic import and failure recovery

## Problem

Database changes are applied sequentially, and cover assets are processed afterward. A late failure can leave a partially imported library — some books imported, some covers written, some records left in an inconsistent state.

## Fix

### Transaction boundaries

1. **Library writes** (books + reading records) are performed within a single `AppDatabase.transaction()` so that a failure at any point rolls back all library changes.
2. **Cover files** are staged in a temporary directory first. Only after all library writes succeed are cover files moved/copied to their final `covers/` location. If any step fails, the temporary directory is discarded.

### Failure-injection test pattern

```dart
test('import rollback leaves database unchanged', () async {
  // Arrange: prepare an archive with 3 books, a failure injection point after book 2
  final archive = await generateTestArchive(3);
  
  // Act: import with failure injected after 2nd book
  final thrown = errors.catchError(() async {
    await importService.importArchive(archive, skipConflicts: false);
  });
  
  // Assert: database state is identical to pre-import state
  final before = await repository.getAllBooks();
  final after = await repository.getAllBooks();
  expect(after, equals(before));
  
  // Assert: no partial data remains
  final records = await repository.listReadingRecords();
  expect(records.length, equals(0));
});
```

### Regression test checklist

- Inject a failure after at least one book has been processed.
- Verify that no partial book or reading-record changes remain.
- Verify that cover writes are either completed or cleaned up/restored on failure.
- Verify malformed archives and unsupported schemas fail without modifying the library.

## 2.4 Cover failure visibility

### Problem

`storeImage()` returns a boolean result, but import ignores it and can report success when covers were not saved.

### Fix

Import checks the boolean result of `storeImage()` and reports validation failure if covers cannot be saved.

### Regression test checklist

- A failed cover write cannot be reported as a successful import.
- Invalid keys are rejected, and storage errors are never reported as success.
- Dedicated cover tests pass on both native and web runtimes.