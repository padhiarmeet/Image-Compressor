import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image/image.dart' as img;
import 'package:image_gallery_saver_plus/image_gallery_saver_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:share_plus/share_plus.dart';
import 'package:image_compressor/controllers/compressImageController.dart';
import 'package:image_compressor/models/compressImageModel.dart';
import 'package:image_compressor/utils/permission_helper.dart';

enum SnackbarType { success, error, warning, info }

class FormatChangeController extends GetxController {
  RxList<File> convertedFiles = <File>[].obs;
  RxBool hasConvertedFiles = false.obs;
  RxBool isConverting = false.obs;
  RxString selectedFormat = 'jpg'.obs;

  // Supported formats
  final List<String> supportedFormats = ['jpg', 'png', 'webp', 'bmp'];

  void _showStyledSnackbar({
    required String title,
    required String message,
    required SnackbarType type,
  }) {
    Color iconColor;
    IconData icon;

    switch (type) {
      case SnackbarType.success:
        iconColor = Colors.green;
        icon = Icons.check_circle_outline;
        break;
      case SnackbarType.error:
        iconColor = Colors.red;
        icon = Icons.error_outline;
        break;
      case SnackbarType.warning:
        iconColor = Colors.orange;
        icon = Icons.warning_amber_rounded;
        break;
      case SnackbarType.info:
        iconColor = Get.theme.colorScheme.primary;
        icon = Icons.info_outline;
        break;
    }

    Get.snackbar(
      title,
      message,
      backgroundColor: Get.theme.colorScheme.surface,
      colorText: Get.theme.colorScheme.onSurface,
      snackPosition: SnackPosition.BOTTOM,
      margin: const EdgeInsets.all(16),
      borderRadius: 12,
      icon: Icon(icon, color: iconColor, size: 28),
      shouldIconPulse: true,
      boxShadows: [
        BoxShadow(
          color: Colors.black.withOpacity(0.1),
          blurRadius: 10,
          offset: const Offset(0, 4),
        ),
      ],
      duration: const Duration(seconds: 3),
      isDismissible: true,
      forwardAnimationCurve: Curves.easeOutBack,
    );
  }

  // Convert images to selected format
  Future<void> convertToFormat(String targetFormat) async {
    try {
      isConverting.value = true;
      convertedFiles.clear();

      final imageController = Get.find<ImageController>();
      final images = imageController.getOriginalList();

      if (images.isEmpty) {
        _showStyledSnackbar(
          title: 'No Images',
          message: 'Please select images first',
          type: SnackbarType.warning,
        );
        return;
      }

      final output = await getTemporaryDirectory();

      for (CompressedImage imageFile in images) {
        final file = File(imageFile.filePath);

        if (!await file.exists()) {
          continue;
        }

        // Read and decode the image
        final bytes = await file.readAsBytes();
        final image = img.decodeImage(bytes);

        if (image == null) {
          _showStyledSnackbar(
            title: 'Error',
            message: 'Failed to decode image: ${file.path.split('/').last}',
            type: SnackbarType.error,
          );
          continue;
        }

        // Encode to target format
        Uint8List? encodedBytes;
        String extension;

        switch (targetFormat.toLowerCase()) {
          case 'jpg':
          case 'jpeg':
            encodedBytes = img.encodeJpg(image, quality: 90);
            extension = 'jpg';
            break;
          case 'png':
            encodedBytes = img.encodePng(image);
            extension = 'png';
            break;
          case 'webp':
            encodedBytes = img.encodePng(image);
            extension = 'webp';
            break;
          case 'bmp':
            encodedBytes = img.encodeBmp(image);
            extension = 'bmp';
            break;
          default:
            _showStyledSnackbar(
              title: 'Error',
              message: 'Unsupported format: $targetFormat',
              type: SnackbarType.error,
            );
            continue;
        }

        // Save the converted file
        final timestamp = DateTime.now().millisecondsSinceEpoch;
        final fileName =
            'converted_${timestamp}_${imageFile.id ?? timestamp}.$extension';
        final convertedFile = File('${output.path}/$fileName');

        await convertedFile.writeAsBytes(encodedBytes);
        convertedFiles.add(convertedFile);
      }

      if (convertedFiles.isNotEmpty) {
        hasConvertedFiles.value = true;
        _showStyledSnackbar(
          title: 'Success',
          message: '${convertedFiles.length} images converted to $targetFormat',
          type: SnackbarType.success,
        );
      } else {
        _showStyledSnackbar(
          title: 'Error',
          message: 'No images were converted',
          type: SnackbarType.error,
        );
      }
    } catch (e) {
      _showStyledSnackbar(
        title: 'Error',
        message: 'Failed to convert images: $e',
        type: SnackbarType.error,
      );
    } finally {
      isConverting.value = false;
    }
  }

  // Download single converted file
  Future<void> downloadFile(File file) async {
    // Request storage permission based on Android version
    PermissionStatus status = await PermissionHelper.requestStoragePermission();
    if (status.isDenied || status.isPermanentlyDenied) {
      _showStyledSnackbar(
        title: 'Permission Denied',
        message: 'Storage permission is required to download files',
        type: SnackbarType.error,
      );
      return;
    }

    try {
      if (!await file.exists()) {
        _showStyledSnackbar(
          title: 'Error',
          message: 'File not found',
          type: SnackbarType.error,
        );
        return;
      }

      final bytes = await file.readAsBytes();
      final fileName =
          'converted_${DateTime.now().millisecondsSinceEpoch}_${file.path.split('/').last}';

      final result = await ImageGallerySaverPlus.saveImage(
        bytes,
        name: fileName,
        quality: 100,
      );

      if (result['isSuccess'] == true) {
        _showStyledSnackbar(
          title: 'Success',
          message: 'Image saved to gallery',
          type: SnackbarType.success,
        );
      } else {
        _showStyledSnackbar(
          title: 'Error',
          message: 'Failed to save image to gallery',
          type: SnackbarType.error,
        );
      }
    } catch (e) {
      _showStyledSnackbar(
        title: 'Error',
        message: 'Failed to download file: $e',
        type: SnackbarType.error,
      );
    }
  }

  // Download all converted files
  Future<void> downloadAllFiles() async {
    // Request storage permission based on Android version
    PermissionStatus status = await PermissionHelper.requestStoragePermission();
    if (status.isDenied || status.isPermanentlyDenied) {
      _showStyledSnackbar(
        title: 'Permission Denied',
        message: 'Storage permission is required to download files',
        type: SnackbarType.error,
      );
      return;
    }

    try {
      int successCount = 0;
      int failCount = 0;

      for (File file in convertedFiles) {
        if (!await file.exists()) {
          failCount++;
          continue;
        }

        final bytes = await file.readAsBytes();
        final fileName =
            'converted_${DateTime.now().millisecondsSinceEpoch}_${file.path.split('/').last}';

        final result = await ImageGallerySaverPlus.saveImage(
          bytes,
          name: fileName,
          quality: 100,
        );

        if (result['isSuccess'] == true) {
          successCount++;
        } else {
          failCount++;
        }
      }

      if (successCount > 0) {
        _showStyledSnackbar(
          title: 'Download Complete',
          message:
              '$successCount image${successCount == 1 ? '' : 's'} saved to gallery${failCount > 0 ? ' ($failCount failed)' : ''}',
          type: SnackbarType.success,
        );
      } else {
        _showStyledSnackbar(
          title: 'Download Failed',
          message: 'Failed to save images to gallery',
          type: SnackbarType.error,
        );
      }
    } catch (e) {
      _showStyledSnackbar(
        title: 'Error',
        message: 'Failed to download files: $e',
        type: SnackbarType.error,
      );
    }
  }

  // Share single file
  Future<void> shareFile(File file) async {
    try {
      await SharePlus.instance.share(
        ShareParams(files: [XFile(file.path)], text: 'Sharing converted image'),
      );
    } catch (e) {
      _showStyledSnackbar(
        title: 'Error',
        message: 'Failed to share file: $e',
        type: SnackbarType.error,
      );
    }
  }

  // Share all converted files
  Future<void> shareAllFiles() async {
    try {
      List<XFile> xFiles = convertedFiles
          .map((file) => XFile(file.path))
          .toList();
      await SharePlus.instance.share(
        ShareParams(files: xFiles, text: 'Sharing converted images'),
      );
    } catch (e) {
      _showStyledSnackbar(
        title: 'Error',
        message: 'Failed to share files: $e',
        type: SnackbarType.error,
      );
    }
  }

  // Remove single file and corresponding original image
  void removeFile(File file) {
    // Get the index of the converted file being removed
    int index = convertedFiles.indexOf(file);

    // Remove the converted file
    convertedFiles.remove(file);

    // Also remove the corresponding original image at the same index
    if (index >= 0) {
      try {
        final imageController = Get.find<ImageController>();
        final originalImages = imageController.getOriginalList();
        if (index < originalImages.length) {
          imageController.removeOriginalImage(originalImages[index]);
        }
      } catch (e) {
        // ImageController not found, skip
      }
    }

    if (convertedFiles.isEmpty) {
      hasConvertedFiles.value = false;
    }
  }

  // Clear all converted files
  void clearConvertedFiles() {
    convertedFiles.clear();
    hasConvertedFiles.value = false;
  }
}
