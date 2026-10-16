import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:file_picker/file_picker.dart';
import 'package:image/image.dart' as img;
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

class CoverImageService {
  static const int maxFileSizeBytes = 5 * 1024 * 1024;
  static const List<String> allowedExtensions = ['png', 'jpg', 'jpeg'];

  static Future<Uint8List?> loadImage(String key) async {
    if (kIsWeb) return null;
    try {
      final dir = await getApplicationDocumentsDirectory();
      final file = File(p.join(dir.path, key));
      if (await file.exists()) {
        return await file.readAsBytes();
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  static Future<String?> pickAndStoreImage() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: allowedExtensions,
      withData: true,
    );
    if (result == null || result.files.isEmpty) return null;
    final file = result.files.first;

    Uint8List? bytes;
    String? extension;

    if (file.bytes != null) {
      bytes = file.bytes!;
      extension = p.extension(file.name).toLowerCase().replaceFirst('.', '');
    } else if (file.path != null && !kIsWeb) {
      final f = File(file.path!);
      bytes = await f.readAsBytes();
      extension = p.extension(file.path!).toLowerCase().replaceFirst('.', '');
    } else {
      return null;
    }

    if (!_isValidExtension(extension)) {
      throw ArgumentError('Unsupported file type: $extension');
    }
    if (bytes.length > maxFileSizeBytes) {
      throw ArgumentError('File size exceeds 5 MB');
    }
    if (!_isDecodable(bytes)) {
      throw ArgumentError('Invalid image data');
    }

    final thumb = await generateThumbnail(bytes) ?? bytes;
    final key = await _storeBytes(thumb, extension!);
    return key;
  }

  static Future<String?> storeImage(File source) async {
    if (kIsWeb) return null;
    if (!await validateImageFile(source.path)) {
      throw ArgumentError('Invalid image file');
    }
    final bytes = await source.readAsBytes();
    final thumb = await generateThumbnail(bytes) ?? bytes;
    final ext = p.extension(source.path).toLowerCase().replaceFirst('.', '');
    final key = await _storeBytes(thumb, ext);
    return key;
  }

  static Future<bool> validateImageFile(String path) async {
    if (kIsWeb) return false;
    final file = File(path);
    if (!await file.exists()) return false;
    final stat = await file.stat();
    if (stat.size > maxFileSizeBytes) return false;
    final ext = p.extension(path).toLowerCase().replaceFirst('.', '');
    if (!_isValidExtension(ext)) return false;
    try {
      final bytes = await file.readAsBytes();
      return _isDecodable(bytes);
    } catch (_) {
      return false;
    }
  }

  static bool _isValidExtension(String? ext) {
    if (ext == null) return false;
    return allowedExtensions.contains(ext);
  }

  static bool _isDecodable(Uint8List bytes) {
    try {
      return img.decodeImage(bytes) != null;
    } catch (_) {
      return false;
    }
  }

  static Future<Uint8List?> generateThumbnail(Uint8List bytes) async {
    try {
      final decoded = img.decodeImage(bytes);
      if (decoded == null) return null;
      final resized = img.copyResize(
        decoded,
        width: 256,
        height: 256,
        maintainAspect: true,
      );
      return Uint8List.fromList(img.encodePng(resized));
    } catch (_) {
      return null;
    }
  }

  static Future<String> _storeBytes(Uint8List bytes, String extension) async {
    if (kIsWeb) throw UnsupportedError('Local storage not supported on web');
    final dir = await getApplicationDocumentsDirectory();
    final coversDir = Directory(p.join(dir.path, 'covers'));
    if (!await coversDir.exists()) {
      await coversDir.create(recursive: true);
    }
    final fileName = '${DateTime.now().millisecondsSinceEpoch}.$extension';
    final filePath = p.join(coversDir.path, fileName);
    await File(filePath).writeAsBytes(bytes);
    return p.relative(filePath, from: dir.path);
  }
}