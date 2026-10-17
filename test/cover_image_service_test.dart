import 'dart:io';
import 'dart:typed_data';
import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/widgets.dart';
// Use dart:io for temp directory to avoid path_provider binding issues in tests
import 'package:file_picker/file_picker.dart';
import 'package:file_picker_platform_interface/file_picker_platform_interface.dart';
import 'package:cross_file/cross_file.dart';
import 'package:uuid/uuid.dart';

import 'package:dandelion/shared/services/cover_image_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  group('CoverImageService', () {
    late FilePickerPlatform originalPlatform;

    setUp(() {
      originalPlatform = FilePickerPlatform.instance;
    });

    tearDown(() {
      FilePickerPlatform.instance = originalPlatform;
    });

    test('pickAndStoreImage returns null when no file selected', () async {
      // Create a fake platform that returns empty list
      final fakePlatform = FakeFilePickerPlatform(result: <PlatformFile>[]);
      FilePickerPlatform.instance = fakePlatform;
      
      final result = await CoverImageService.pickAndStoreImage();
      expect(result, isNull);
    });

    test('pickAndStoreImage throws exception for invalid file extension', () async {
      // Create a temporary file with invalid extension
      final tempDir = Directory.systemTemp;
      final tempFile = File('${tempDir.path}/test.txt');
      await tempFile.writeAsBytes([1, 2, 3]);
      
      try {
        // Create a fake platform that returns the invalid file
        final fakePlatform = FakeFilePickerPlatform(result: [
          TestPlatformFile(path: tempFile.path, name: 'test.txt', size: 3)
        ]);
        FilePickerPlatform.instance = fakePlatform;
        
        expect(() async => await CoverImageService.pickAndStoreImage(),
            throwsA(isException));
      } finally {
        await tempFile.delete();
      }
    });

    test('pickAndStoreImage throws exception for file size exceeding 5MB', () async {
      // Create a temporary file larger than 5MB
      final tempDir = Directory.systemTemp;
      final tempFile = File('${tempDir.path}/test.png');
      await tempFile.writeAsBytes(List.filled(6 * 1024 * 1024, 0)); // 6MB
      
      try {
        // Create a fake platform that returns the large file
        final fakePlatform = FakeFilePickerPlatform(result: [
          TestPlatformFile(path: tempFile.path, name: 'test.png', size: tempFile.lengthSync())
        ]);
        FilePickerPlatform.instance = fakePlatform;
        
        expect(() async => await CoverImageService.pickAndStoreImage(),
            throwsA(isException));
      } finally {
        await tempFile.delete();
      }
    });

    test('pickAndStoreImage returns key when valid image selected', () async {
      // Create a temporary PNG file (we'll use a 1x1 red PNG)
      final tempDir = Directory.systemTemp;
      final tempFile = File('${tempDir.path}/test.png');
      // This is a base64 encoded 1x1 red PNG
      const pngBase64 = 
          'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mP8z8BQDwAEhQGAhKmMIQAAAABJRU5ErkJggg==';
      final pngBytes = base64Decode(pngBase64);
      await tempFile.writeAsBytes(pngBytes);
      
      try {
        // Create a fake platform that returns the valid file
        final fakePlatform = FakeFilePickerPlatform(result: [
          TestPlatformFile(path: tempFile.path, name: 'test.png', size: tempFile.lengthSync())
        ]);
        FilePickerPlatform.instance = fakePlatform;
        
        final result = await CoverImageService.pickAndStoreImage();
        expect(result, startsWith('covers/'));
        expect(result, endsWith('.png'));
        
        // Verify the file was created in the application documents directory
        final appDocDir = await getApplicationDocumentsDirectory();
        final expectedFile = File('${appDocDir.path}/covers/${result}');
        expect(await expectedFile.exists(), isTrue);
        
        // Clean up the created file
        if (await expectedFile.exists()) {
          await expectedFile.delete();
        }
        // Also delete the covers directory if it's empty
        final coverDir = Directory('${appDocDir.path}/covers');
        if (await coverDir.exists()) {
          final contents = await coverDir.list().toList();
          if (contents.isEmpty) {
            await coverDir.delete();
          }
        }
      } finally {
        await tempFile.delete();
      }
    });

    test('loadImage returns null for invalid key format', () async {
      final result = await CoverImageService.loadImage('invalid_key');
      expect(result, isNull);
      
      final result2 = await CoverImageService.loadImage('cover_invalid.jpg');
      expect(result2, isNull);
      
      final result3 = await CoverImageService.loadImage('covers/invalid.jpg');
      expect(result3, isNull);
    });

    test('storeImage returns false for invalid key format', () async {
      final result = await CoverImageService.storeImage(Uint8List.fromList([1, 2, 3]), 
          key: 'invalid_key');
      expect(result, isFalse);
      
      final result2 = await CoverImageService.storeImage(Uint8List.fromList([1, 2, 3]), 
          key: 'cover_invalid.jpg');
      expect(result2, isFalse);
      
      final result3 = await CoverImageService.storeImage(Uint8List.fromList([1, 2, 3]), 
          key: 'covers/invalid.jpg');
      expect(result3, isFalse);
    });

    test('deleteImage returns false for invalid key format', () async {
      final result = await CoverImageService.deleteImage('invalid_key');
      expect(result, isFalse);
      
      final result2 = await CoverImageService.deleteImage('cover_invalid.jpg');
      expect(result2, isFalse);
      
      final result3 = await CoverImageService.deleteImage('covers/invalid.jpg');
      expect(result3, isFalse);
    });
  });
}

// Simple fake file picker platform for testing
class FakeFilePickerPlatform extends FilePickerPlatform {
  FakeFilePickerPlatform({required this.result});

  final List<PlatformFile> result;

  @override
  Future<PlatformFile?> pickFile({
    String? dialogTitle,
    String? initialDirectory,
    FileType? type,
    List<String>? allowedExtensions,
    Function(FilePickerStatus)? onFileLoading,
    int compressionQuality = 0,
    AndroidOptions? androidOptions,
    DarwinOptions? darwinOptions,
    WindowsOptions? windowsOptions,
    LinuxOptions? linuxOptions,
    WebOptions? webOptions,
  }) async {
    if (result.isNotEmpty) {
      return result.first;
    }
    return null;
  }

  @override
  Future<List<PlatformFile>> pickFiles({
    String? dialogTitle,
    String? initialDirectory,
    FileType? type,
    List<String>? allowedExtensions,
    Function(FilePickerStatus)? onFileLoading,
    int compressionQuality = 0,
    AndroidOptions? androidOptions,
    DarwinOptions? darwinOptions,
    WindowsOptions? windowsOptions,
    LinuxOptions? linuxOptions,
    WebOptions? webOptions,
  }) async {
    return result;
  }
}

// Test implementation of PlatformFile for unit tests
base class TestPlatformFile extends PlatformFile {
  TestPlatformFile({
    required String path,
    required String name,
    required int size,
  })  : _path = path,
        _name = name,
        _size = size,
        _uri = Uri.file(path),
        _xFile = XFile(path, name: name);

  final String _path;
  final String _name;
  final int _size;
  final Uri _uri;
  final XFile _xFile;

  @override
  String get name => _name;

  @override
  Uri get uri => _uri;

  @override
  String? get path => _path;

  @override
  XFile get xFile => _xFile;

  @override
  int? lengthSync() => _size;

  @override
  Future<int?> length() async => _size;

  @override
  Future<Uint8List> readAsBytes() async => _xFile.readAsBytes();

  @override
  Stream<Uint8List> readAsByteStream() => _xFile.openRead();
}
