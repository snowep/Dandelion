# Cover failure visibility

## Problem

`storeImage()` returns a boolean result, but import ignores it and can report success when covers were not saved.

## Fix

### Import checks cover write results

During `importArchive()`, after each book's cover is processed:

```dart
final coverSuccess = await CoverImageService.storeImage(coverBytes, key: key);
if (!coverSuccess) {
  errors.add('Failed to save cover for book ${book.title}');
  // Continue processing other books, but mark import as having cover failures
}
```

### Validation step

After all books are processed, if any cover writes failed:

```dart
if (errors.any((e) => e.contains('cover'))) {
  return ImportPreview(
    isValid: false,
    errors: errors,
    // ... other fields
  );
}
```

### Never report success when covers failed

The `ImportPreview.isValid` must be `false` whenever cover storage errors exist, regardless of whether the library data imported successfully.

### Regression test checklist

- A failed cover write cannot be reported as a successful import.
- Invalid keys are rejected, and storage errors are never reported as success.
- Dedicated cover tests pass on both native and web runtimes.

## Summary of all Phase 2 references

1. `references/export-format.md` — ZIP export format and `ExportService.exportToFile` API
2. `references/import-id-mapping.md` — source-to-destination ID mapping and conflict semantics
3. `references/atomic-rollback.md` — transaction boundaries and failure-injection test pattern
4. `references/cover-validation.md` — cover storage validation and failure modes on native and web