import 'dart:io';
import 'dart:typed_data';
import 'dart:convert';

import 'package:flutter/foundation.dart' show kIsWeb;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:file_picker/file_picker.dart';

import '../../features/library/library_notifier.dart';
import '../../services/library_export_import_service.dart';
import 'theme_notifier.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        children: [
          _ThemeSection(themeMode: themeMode, ref: ref),
          const Divider(),
          const _ExportImportSection(),
        ],
      ),
    );
  }
}

class _ThemeSection extends ConsumerWidget {
  final ThemeMode themeMode;
  final WidgetRef ref;

  const _ThemeSection({required this.themeMode, required this.ref});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListTile(
      leading: const Icon(Icons.brightness_6),
      title: const Text('Theme Mode'),
      subtitle: Text(
        themeMode == ThemeMode.system
            ? 'System'
            : themeMode == ThemeMode.light
            ? 'Light'
            : 'Dark',
      ),
      trailing: DropdownButton<ThemeMode>(
        value: themeMode,
        items: const [
          DropdownMenuItem(value: ThemeMode.system, child: Text('System')),
          DropdownMenuItem(value: ThemeMode.light, child: Text('Light')),
          DropdownMenuItem(value: ThemeMode.dark, child: Text('Dark')),
        ],
        onChanged: (mode) {
          if (mode != null) {
            ref.read(themeModeProvider.notifier).setThemeMode(mode);
          }
        },
      ),
    );
  }
}

class _ExportImportSection extends ConsumerStatefulWidget {
  const _ExportImportSection();

  @override
  ConsumerState<_ExportImportSection> createState() =>
      _ExportImportSectionState();
}

class _ExportImportSectionState extends ConsumerState<_ExportImportSection> {
  bool _exporting = false;
  bool _importing = false;
  String? _message;

  Future<void> _export() async {
    if (!mounted) return;
    setState(() {
      _exporting = true;
      _message = null;
    });
    try {
      final repository = ref.read(bookRepositoryProvider);
      final exportService = ExportService(repository);

      if (!mounted) return;

      final data = await exportService.export();
      final bytes = utf8.encode(jsonEncode(data.toJson()));
      final Uri? fileUri = await FilePicker.saveFile(
        bytes: bytes,
        dialogTitle: 'Export Library',
        fileName: 'dandelion_library_export.zip',
        type: FileType.custom,
        allowedExtensions: ['zip'],
      );

      if (fileUri == null) {
        setState(() {
          _exporting = false;
          _message = 'Export cancelled';
        });
        return;
      }

      if (!kIsWeb) {
        final file = File(fileUri.path);
        await file.writeAsBytes(Uint8List.fromList(bytes));
      }

      if (!mounted) return;
      setState(() {
        _exporting = false;
        _message = 'Library exported successfully';
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _exporting = false;
        _message = 'Export failed: $e';
      });
    }
  }

  Future<void> _import() async {
    if (!mounted) return;
    setState(() {
      _importing = true;
      _message = null;
    });
    try {
      final List<PlatformFile>? result = await FilePicker.pickFiles(
        dialogTitle: 'Import Library',
        type: FileType.custom,
        allowedExtensions: ['zip'],
      );

      if (result == null || result.isEmpty) {
        setState(() {
          _importing = false;
          _message = 'Import cancelled';
        });
        return;
      }

      final bytes = await result.first.readAsBytes();

      final repository = ref.read(bookRepositoryProvider);
      final importService = ImportService(repository);
      final preview = await importService.validateArchive(bytes);

      if (!mounted) return;

      if (!preview.isValid) {
        setState(() {
          _importing = false;
          _message = 'Import failed: ${preview.errors.join(', ')}';
        });
        return;
      }

      final confirmed = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Confirm Import'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Books: ${preview.booksCount}'),
              Text('Reading Records: ${preview.readingRecordsCount}'),
              if (preview.conflicts.isNotEmpty) ...[
                const SizedBox(height: 8),
                const Text(
                  'Conflicts found (will be skipped):',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                ...preview.conflicts.take(5).map((c) => Text('• ${c.title}')),
                if (preview.conflicts.length > 5)
                  Text('... and ${preview.conflicts.length - 5} more'),
              ],
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Import'),
            ),
          ],
        ),
      );

      if (confirmed != true) {
        setState(() {
          _importing = false;
          _message = 'Import cancelled';
        });
        return;
      }

      await importService.importArchive(bytes, skipConflicts: true);

      if (!mounted) return;
      setState(() {
        _importing = false;
        _message = 'Library imported successfully';
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _importing = false;
        _message = 'Import failed: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Text('Data', style: TextStyle(fontWeight: FontWeight.bold)),
        ),
        ListTile(
          leading: const Icon(Icons.download),
          title: const Text('Export Library'),
          subtitle: const Text(
            'Save all books, reading records, and covers to a zip file',
          ),
          trailing: _exporting
              ? const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(),
                )
              : const Icon(Icons.chevron_right),
          onTap: _exporting ? null : _export,
        ),
        ListTile(
          leading: const Icon(Icons.upload),
          title: const Text('Import Library'),
          subtitle: const Text(
            'Load books, reading records, and covers from a zip file',
          ),
          trailing: _importing
              ? const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(),
                )
              : const Icon(Icons.chevron_right),
          onTap: _importing ? null : _import,
        ),
        if (_message != null)
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              _message!,
              style: TextStyle(
                color:
                    _message!.startsWith('Export failed') ||
                        _message!.startsWith('Import failed')
                    ? Theme.of(context).colorScheme.error
                    : Theme.of(context).colorScheme.primary,
              ),
            ),
          ),
      ],
    );
  }
}
