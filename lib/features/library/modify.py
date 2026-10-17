import sys

filepath = 'library_screen.dart'
with open(filepath, 'r', encoding='utf-8') as f:
    lines = f.readlines()

target = '  };'
target_idx = None
for i, line in enumerate(lines):
    if line.rstrip('\n') == target:
        target_idx = i
        break

if target_idx is None:
    print('Target line not found')
    sys.exit(1)

methods = [
    '',
    '  Future<void> _exportLibrary() async {',
    '    if (_exportImportLoading) return;',
    '    setState(() => _exportImportLoading = true);',
    '    try {',
    '      final file = await _exportService.exportToZipFile();',
    '      if (!mounted) return;',
    '      final bytes = await file.readAsBytes();',
    '      final blob = html.Blob([bytes]);',
    '      final url = html.Url.createObjectUrlFromBlob(blob);',
    '      final anchor = html.AnchorElement(href: url)',
    '        ..setAttribute("download", "dandelion_backup.zip")',
    '        ..click();',
    '      html.Url.revokeObjectUrl(url);',
    '      if (!mounted) return;',
    '      ScaffoldMessenger.of(context).showSnackBar(',
    '        const SnackBar(content: Text("Library exported successfully")),',
    '      );',
    '    } catch (e) {',
    '      if (!mounted) return;',
    '      ScaffoldMessenger.of(context).showSnackBar(',
    '        SnackBar(content: Text("Export failed: $e")),',
    '      );',
    '    } finally {',
    '      if (mounted) setState(() => _exportImportLoading = false);',
    '    }',
    '  }',
    '',
    '  Future<void> _importLibrary() async {',
    '    if (_exportImportLoading) return;',
    '    setState(() => _exportImportLoading = true);',
    '    try {',
    '      final input = html.FileUploadInputElement()..',
    '        accept = ".zip,.json";',
    '      input.click();',
    '      await input.onChange.first;',
    '      final files = input.files;',
    '      if (files.isEmpty) return;',
    '      final file = files[0];',
    '      final reader = html.FileReader();',
    '      reader.readAsArrayBuffer(file);',
    '      await reader.onLoad.first;',
    '      final bytes = reader.result as List<int>;',
    '      final tempFile = File("${Directory.systemTemp.path}/dandelion_import.zip")',
    '        ..writeAsBytesSync(bytes);',
    '      if (!mounted) return;',
    '      final preview = await _importService.validateArchive(tempFile);',
    '      if (!mounted) return;',
    '      if (!preview.isValid) {',
    '        showDialog<bool>(context: context, builder: (_) => AlertDialog(',
    '          title: const Text("Import validation failed"),',
    '          content: SingleChildScrollView(',
    '            child: ListBody(',
    '              children: preview.errors.map((e) => Text(e)).toList(),',
    '            ),',
    '          ),',
    '          actions: [',
    '            TextButton(',
    '              onPressed: () => Navigator.of(context).pop(),',
    '              child: const Text("OK"),',
    '            ),',
    '          ],',
    '        );',
    '        return;',
    '      }',
    '      // Show preview dialog with options',
    '      final result = await showDialog<bool>(context: context, builder: (_) => StatefulBuilder(',
    '        (context, setState) => AlertDialog(',
    '          title: const Text("Import library"),',
    '          content: SingleChildScrollView(',
    '            child: Column(',
    '              mainAxisSize: MainAxisSize.min,',
    '              children: [',
    '                Text("Schema version: ${preview.schemaVersion}"),',
    '                if (preview.exportDate != null) Text("Export date: ${preview.exportDate!.toLocal()}"),',
    '                Text("Books: ${preview.booksCount}"),',
    '                Text("Reading records: ${preview.readingRecordsCount}"),',
    '                if (preview.warnings.isNotEmpty) ...[',
    '                  const SizedBox(height: 8),',
    '                  const Text("Warnings:", style: TextStyle(fontWeight: FontWeight.bold)),',
    '                  ...preview.warnings.map((w) => Text(w, style: TextStyle(color: Colors.orange))),',
    '                ],',
    '                if (preview.conflicts.isNotEmpty) ...[',
    '                  const SizedBox(height: 8),',
    '                  const Text("Conflicts:", style: TextStyle(fontWeight: FontWeight.bold)),',
    '                  ...preview.conflicts.map((c) => Text("${c.title} (${c.type.name})")),',
    '                ],',
    '              ],',
    '            ),',
    '          ),',
    '          actions: [',
    '            TextButton(',
    '              onPressed: () => Navigator.of(context).pop(false),',
    '              child: const Text("Cancel"),',
    '            ),',
    '            TextButton(',
    '              onPressed: () => Navigator.of(context).pop(true),',
    '              child: const Text("Import"),',
    '            ),',
    '          ],',
    '        ),',
    '      ));',
    '      if (result == true && mounted) {',
    '        // Perform import with skip conflicts (default)',
    '        await _importService.importArchive(tempFile, skipConflicts: true, overwrite: false);',
    '        if (!mounted) return;',
    '        ScaffoldMessenger.of(context).showSnackBar(',
    '          const SnackBar(content: Text("Library imported successfully")),',
    '        );',
    '        await _loadBooks();',
    '      }',
    '    } catch (e) {',
    '      if (!mounted) return;',
    '      ScaffoldMessenger.of(context).showSnackBar(',
    '        SnackBar(content: Text("Import failed: $e")),',
    '      );',
    '    } finally {',
    '      if (mounted) setState(() => _exportImportLoading = false);',
    '    }',
    '  }',
]

new_lines = []
new_lines.extend(lines[:target_idx])
for m in methods:
    new_lines.append(m + '\n')
new_lines.extend(lines[target_idx:])

with open(filepath, 'w', encoding='utf-8') as f:
    f.writelines(new_lines)

print('Done')
