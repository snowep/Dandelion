import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqlite3/sqlite3.dart';

String _targetName() {
  if (kIsWeb) return 'web';
  if (Platform.isWindows) return 'windows';
  if (Platform.isMacOS) return 'macos';
  if (Platform.isLinux) return 'linux';
  if (Platform.isAndroid) return 'android';
  if (Platform.isIOS) return 'ios';
  return 'unknown';
}

Future<Map<String, dynamic>> probeFts5Support() async {
  final target = _targetName();
  // Use in-memory DB for both web and native to avoid path_provider binding issues in tests
  final dbPath = ':memory:';

  final db = sqlite3.open(dbPath);
  try {
    final versionResult = db.select('SELECT sqlite_version() as v');
    final sqliteVersion = versionResult.first['v'] as String;

    bool fts5Available = false;
    String errorMsg = '';
    String fallbackMethod = 'LIKE';

    final stopwatch = Stopwatch()..start();
    try {
      db.execute('CREATE VIRTUAL TABLE IF NOT EXISTS fts5_probe USING fts5(content)');
      db.execute("INSERT INTO fts5_probe(rowid, content) VALUES (1, 'test content')");
      final match = db.select("SELECT * FROM fts5_probe WHERE fts5_probe MATCH 'test'");
      if (match.isNotEmpty) {
        fts5Available = true;
        fallbackMethod = 'none';
      }
      db.execute('DROP TABLE fts5_probe');
    } catch (e) {
      fts5Available = false;
      errorMsg = e.toString();
    }
    stopwatch.stop();

    final performanceNote = fts5Available
        ? 'FTS5 creation and query succeeded in ${stopwatch.elapsedMilliseconds}ms'
        : 'FTS5 creation failed, fallback to LIKE. Error: $errorMsg';

    return {
      'target': target,
      'fts5_available': fts5Available,
      'sqlite_version': sqliteVersion,
      'fallback_method': fallbackMethod,
      'error': errorMsg,
      'performance_note': performanceNote,
    };
  } finally {
    db.dispose();
  }
}

void main() {
  test('FTS5 support probe', () async {
    final result = await probeFts5Support();
    // For test visibility, print result
    debugPrint('FTS5 Probe Result: $result');
    // Basic sanity checks
    expect(result['target'], isNotNull);
    expect(result['sqlite_version'], isNotNull);
    expect(result['fts5_available'], isA<bool>());
  });
}
