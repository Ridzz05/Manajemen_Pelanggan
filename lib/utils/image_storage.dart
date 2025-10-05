import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart';

class ImageStorage {
  static const String _profileFolder = 'profile_images';

  /// Get the profile images directory
  static Future<Directory> getProfileImagesDirectory() async {
    final appDir = await getApplicationDocumentsDirectory();
    final profileDir = Directory('${appDir.path}/$_profileFolder');

    if (!await profileDir.exists()) {
      await profileDir.create(recursive: true);
    }

    return profileDir;
  }

  /// Save image to profile directory
  static Future<String?> saveProfileImage(File imageFile, String fileName) async {
    try {
      final profileDir = await getProfileImagesDirectory();
      final fileExtension = extension(imageFile.path);
      final newFileName = '${fileName}_profile$fileExtension';
      final newPath = '${profileDir.path}/$newFileName';

      // Copy the file to our profile directory
      final savedFile = await imageFile.copy(newPath);

      return savedFile.path;
    } catch (e) {
      print('Error saving profile image: $e');
      return null;
    }
  }

  /// Delete profile image
  static Future<bool> deleteProfileImage(String imagePath) async {
    try {
      final file = File(imagePath);
      if (await file.exists()) {
        await file.delete();
        return true;
      }
      return false;
    } catch (e) {
      print('Error deleting profile image: $e');
      return false;
    }
  }

  /// Get all profile images
  static Future<List<File>> getAllProfileImages() async {
    try {
      final profileDir = await getProfileImagesDirectory();
      final files = await profileDir.list().where((entity) => entity is File).cast<File>().toList();
      return files;
    } catch (e) {
      print('Error getting profile images: $e');
      return [];
    }
  }

  /// Get the most recent profile image
  static Future<File?> getLatestProfileImage() async {
    try {
      final images = await getAllProfileImages();
      if (images.isEmpty) return null;

      // Sort by modified date (most recent first)
      images.sort((a, b) => b.lastModifiedSync().compareTo(a.lastModifiedSync()));
      return images.first;
    } catch (e) {
      print('Error getting latest profile image: $e');
      return null;
    }
  }

  /// Check if profile image exists
  static Future<bool> profileImageExists(String imagePath) async {
    try {
      final file = File(imagePath);
      return await file.exists();
    } catch (e) {
      return false;
    }
  }

  /// Get file size in bytes
  static Future<int?> getImageSize(String imagePath) async {
    try {
      final file = File(imagePath);
      if (await file.exists()) {
        return await file.length();
      }
      return null;
    } catch (e) {
      print('Error getting image size: $e');
      return null;
    }
  }
}
