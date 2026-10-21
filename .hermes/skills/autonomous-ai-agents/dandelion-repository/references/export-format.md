# Export format

The Settings export previously encoded JSON bytes and named the file `dandelion_library_export.zip`, which was misleading — the file contained JSON, not a ZIP archive.

## Fix

Use `ExportService.exportToFile(File(await getApplicationDocumentsDirectory())..path)` which writes a genuine ZIP archive via `ZipEncoder`. The generated file begins with the ZIP file signature `PK` and a ZIP decoder can open it and find `library.json`.

## Details

- `ExportService.export()` returns `ExportData` (JSON map of books, reading records, and cover Base64 strings).
- `ExportService.exportToFile(File path)` creates a ZIP containing `library.json` (the UTF-8 encoded JSON), plus cover image files stored under a `covers/` directory.
- The ZIP uses the `ZipEncoder().encode(Archive())` pattern already present in `lib/services/library_export_import_service.dart`.

## Regression test checklist

- Output begins with ZIP file signature `PK`.
- A ZIP decoder can open it and find `library.json`.
- The archive contains all expected book and reading data plus cover data.
- The generated file can be imported on both web and native platforms.

## When to use which method

- Use `exportToFile` for a genuine archive backup (includes covers, valid ZIP).
- Use the JSON path (manual `utf8.encode(jsonEncode(data.toJson()))` + `.json` extension) only if the user explicitly requests a JSON file, and name it `dandelion_library_export.json` to avoid confusion.