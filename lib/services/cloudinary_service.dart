import 'dart:io';
import 'package:cloudinary_public/cloudinary_public.dart';

class CloudinaryService {
  static final cloudinary = CloudinaryPublic(
    'dkmnhtlew',
    'MarineGuard',
    cache: false,
  );

  static Future<String> uploadFile(File file, String folder) async {
    try {
      if (!await file.exists()) {
        throw Exception('File does not exist');
      }

      final bytes = await file.length();
      final extension = file.path.split('.').last.toLowerCase();

      final maxSize =
          _isVideoFile(extension) ? 1024 * 1024 * 1024 : 100 * 1024 * 1024;

      if (bytes > maxSize) {
        throw Exception(_isVideoFile(extension)
            ? 'Video size exceeds 1GB limit'
            : 'Image size exceeds 100MB limit');
      }

      final resourceType = _getResourceType(extension);

      CloudinaryResponse response = await cloudinary.uploadFile(
          CloudinaryFile.fromFile(file.path,
              folder: folder, resourceType: resourceType));

      if (response.secureUrl.isEmpty) {
        throw Exception('Upload Failed: No URL returned');
      }
      return response.secureUrl;
    } on CloudinaryException catch (e) {
      print('Cloudinary error: ${e.message}');
      throw Exception('cloudinary upload failed: ${e.message}');
    } catch (e) {
      print('Upload error $e');
      throw Exception('Failed to upload file: $e');
    }
  }

  static CloudinaryResourceType _getResourceType(String extension) {
    switch (extension) {
      case 'jpg':
      case 'jpeg':
      case 'png':
      case 'gif':
      case 'webp':
        return CloudinaryResourceType.Image;
      case 'mp4':
      case 'mov':
      case 'avi':
      case 'wmv':
        return CloudinaryResourceType.Video;
      case 'pdf':
      case 'doc':
      case 'docx':
      case 'txt':
        return CloudinaryResourceType.Raw;
      default:
        return CloudinaryResourceType.Auto;
    }
  }

  static Future<List<String>> uploadFiles(
      List<File> files, String folder) async {
    if (files.isEmpty) {
      throw Exception('No files provided for upload');
    }

    List<String> urls = [];
    List<String> errors = [];

    // Create a copy of the list to avoid concurrent modification
    final filesToUpload = List<File>.from(files);

    for (File file in filesToUpload) {
      try {
        String url = await uploadFile(file, folder);
        urls.add(url);
      } catch (e) {
        errors.add('Failed to upload ${file.path}: $e');
      }
    }

    if (errors.isNotEmpty) {
      throw Exception('Some files failed to upload:\n${errors.join('\n')}');
    }

    return urls;
  }

  static bool isValidFileType(String filePath) {
    final extension = filePath.split('.').last.toLowerCase();
    final validExtensions = [
      'jpg',
      'jpeg',
      'png',
      'gif',
      'webp',
      'mp4',
      'mov',
      'avi',
      'wmv',
      'pdf',
      'doc',
      'docx',
      'txt'
    ];

    return validExtensions.contains(extension);
  }

  static bool _isVideoFile(String extension) {
    return ['mp4', 'mov', 'avi', 'wmv'].contains(extension);
  }
}
