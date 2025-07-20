
import 'dart:io';
import 'package:path_provider/path_provider.dart'; 

import 'package:logger/logger.dart';
import 'package:path/path.dart' as p;

class ImageHelper {
  final Logger _logger = Logger();

  Future<String> saveImageToAppDirectory(String tempImagePath) async {
    try {
      final Directory appDocDir = await getApplicationDocumentsDirectory();
      final String appDocPath = appDocDir.path;

      // Create a unique file name
      final String fileName = p.basename(tempImagePath);
      final String newPath = p.join(appDocPath, 'product_images', fileName);

      // Ensure the directory exists
      final Directory imageDir = Directory(p.join(appDocPath, 'product_images'));
      if (!await imageDir.exists()) {
        await imageDir.create(recursive: true);
        _logger.d('Created image directory: ${imageDir.path}');
      }

      final File originalFile = File(tempImagePath);
      final File newFile = await originalFile.copy(newPath);
      _logger.i('Image saved from $tempImagePath to ${newFile.path}');
      return newFile.path;
    } catch (e, stack) {
      _logger.e('Error saving image to app directory: $e', error: e, stackTrace: stack);
      rethrow; 
    }
  }

  Future<void> deleteImage(String imagePath) async {
    try {
      final File file = File(imagePath);
      if (await file.exists()) {
        await file.delete();
        _logger.i('Image file deleted: $imagePath');
      } else {
        _logger.w('Attempted to delete non-existent image file: $imagePath');
      }
    } catch (e, stack) {
      _logger.e('Error deleting image file $imagePath: $e', error: e, stackTrace: stack);
  
    }
  }

  Future<bool> imageExists(String imagePath) async {
    try {
      final File file = File(imagePath);
      return await file.exists();
    } catch (e, stack) {
      _logger.e('Error checking image existence for $imagePath: $e', error: e, stackTrace: stack);
      return false;
    }
  }
  
}
