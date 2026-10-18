import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:image/image.dart' as img;
import 'package:path_provider/path_provider.dart';
import 'package:file_picker/file_picker.dart';
import 'package:uuid/uuid.dart';

/// Service for picking and storing cover images.
class CoverImageService {
  static final _uuid = Uuid();

  /// Picks an image file, validates it, generates a thumbnail (max 256x256),
  /// stores it in the app's document directory, and returns the storage key.
  static Future<String?> pickAndStoreImage() async {
    try {
      final List<PlatformFile> result = await FilePicker.pickFiles(
        type: FileType.image,
      );

      if (result.isEmpty) {
        return null;
      }

      final PlatformFile file = result.first;
      if (file.name.isEmpty) {
        throw Exception('Selected file has no name');
      }
      final path = file.path;
      if (path == null || path.isEmpty) {
        throw Exception('Selected file has no path');
      }
      final allowedExtensions = ['.png', '.jpg', '.jpeg'];
      if (!allowedExtensions.any(
        (ext) => file.name.toLowerCase().endsWith(ext),
      )) {
        throw Exception('Selected file is not an image');
      }
      // Validate file size (max 5MB)
      final length = await File(path).length();
      if (length > 5 * 1024 * 1024) {
        throw Exception('File size exceeds 5MB');
      }
      // Read the image bytes from the file.
      final bytes = await File(path).readAsBytes();

      // Decode and validate the image using the image package.
      final image = img.decodeImage(bytes);
      if (image == null) {
        throw Exception('Invalid or corrupted image file');
      }

      // Generate thumbnail (max 256x256 while maintaining aspect ratio).
      final thumbnail = _generateThumbnail(image, 256, 256);

      // Encode thumbnail as PNG.
      final thumbnailBytes = Uint8List.fromList(img.encodePng(thumbnail));

      // Generate a unique key for storage (in covers/ subdirectory).
      final fileName = 'cover_${_uuid.v4()}.png';
      final key = 'covers/$fileName';

      // Get storage directory and save the thumbnail.
      final directory = await getApplicationDocumentsDirectory();
      final coversDir = Directory('${directory.path}/covers');
      if (!await coversDir.exists()) {
        await coversDir.create(recursive: true);
      }
      final filePath = '${coversDir.path}/$fileName';
      final thumbnailFile = File(filePath);
      await thumbnailFile.writeAsBytes(thumbnailBytes);

      return key;
    } catch (e) {
      debugPrint('Error picking and storing image: $e');
      rethrow;
    }
  }

  /// Loads an image from storage by its key.
  static Future<Uint8List?> loadImage(String key) async {
    try {
      // Validate key format to prevent path traversal.
      if (key.contains('..') ||
          !RegExp(r'^covers/cover_[0-9a-fA-F-]{36}\.png$').hasMatch(key)) {
        return null;
      }

      final directory = await getApplicationDocumentsDirectory();
      final filePath = '${directory.path}/$key';
      final file = File(filePath);

      if (!await file.exists()) {
        return null;
      }

      return await file.readAsBytes();
    } catch (e) {
      debugPrint('Error loading image: $e');
      return null;
    }
  }

  /// Stores the image bytes from [bytes] at the given [key].
  /// Returns true if successful, false otherwise.
  static Future<bool> storeImage(Uint8List bytes, {required String key}) async {
    try {
      // Validate key format to prevent path traversal
      if (key.contains('..') ||
          !RegExp(r'^covers/cover_[0-9a-fA-F-]{36}\.png$').hasMatch(key)) {
        return false;
      }

      final directory = await getApplicationDocumentsDirectory();
      final filePath = '${directory.path}/$key';
      final file = File(filePath);

      await file.writeAsBytes(bytes);
      return true;
    } catch (e) {
      debugPrint('Error storing image: $e');
      return false;
    }
  }

  /// Generates a thumbnail maintaining aspect ratio within maxWidth and maxHeight.
  static img.Image _generateThumbnail(
    img.Image image,
    int maxWidth,
    int maxHeight,
  ) {
    int width = image.width;
    int height = image.height;

    // Calculate scaling factor to fit within bounds while maintaining aspect ratio
    double scaleX = maxWidth / width;
    double scaleY = maxHeight / height;
    double scale = scaleX < scaleY ? scaleX : scaleY;

    // If image is already smaller than max dimensions, no need to scale up
    if (scale > 1.0) {
      scale = 1.0;
    }

    int newWidth = (width * scale).round();
    int newHeight = (height * scale).round();

    // Ensure minimum dimensions
    newWidth = newWidth.clamp(1, maxWidth);
    newHeight = newHeight.clamp(1, maxHeight);

    return img.copyResize(image, width: newWidth, height: newHeight);
  }

  /// Deletes an image from storage by its key.
  static Future<bool> deleteImage(String key) async {
    try {
      // Validate key format to prevent path traversal
      if (key.contains('..') ||
          !RegExp(r'^covers/cover_[0-9a-fA-F-]{36}\.png$').hasMatch(key)) {
        return false;
      }

      final directory = await getApplicationDocumentsDirectory();
      final filePath = '${directory.path}/$key';
      final file = File(filePath);

      if (await file.exists()) {
        await file.delete();
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('Error deleting image: $e');
      return false;
    }
  }
}
