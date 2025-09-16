import 'dart:io';
import 'dart:typed_data';
import 'package:get/get.dart';
import 'package:image/image.dart' as img;
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:share_plus/share_plus.dart';
import 'package:image_compressor/controllers/compressImageController.dart';
import 'package:image_compressor/models/compressImageModel.dart';

class FormatChangeController extends GetxController {
  RxList<File> convertedFiles = <File>[].obs;
  RxBool hasConvertedFiles = false.obs;
  RxBool isConverting = false.obs;
  RxString selectedFormat = 'jpg'.obs;

  // Supported formats
  final List<String> supportedFormats = ['jpg', 'png', 'webp', 'bmp'];

  // Convert images to selected format
  Future<void> convertToFormat(String targetFormat) async {
    try {
      isConverting.value = true;
      convertedFiles.clear();

      final imageController = Get.find<ImageController>();
      final images = imageController.getOriginalList();

      if (images.isEmpty) {
        Get.snackbar(
          'No Images',
          'Please select images first',
          snackPosition: SnackPosition.BOTTOM,
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
          Get.snackbar(
            'Error',
            'Failed to decode image: ${file.path.split('/').last}',
            snackPosition: SnackPosition.BOTTOM,
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
            Get.snackbar(
              'Error',
              'Unsupported format: $targetFormat',
              snackPosition: SnackPosition.BOTTOM,
            );
            continue;
        }

        // Save the converted file
        final timestamp = DateTime.now().millisecondsSinceEpoch;
        final fileName = 'converted_${timestamp}_${imageFile.id ?? timestamp}.$extension';
        final convertedFile = File('${output.path}/$fileName');

        await convertedFile.writeAsBytes(encodedBytes);
        convertedFiles.add(convertedFile);
      }

      if (convertedFiles.isNotEmpty) {
        hasConvertedFiles.value = true;
        Get.snackbar(
          'Success',
          '${convertedFiles.length} images converted to $targetFormat',
          snackPosition: SnackPosition.BOTTOM,
        );
      } else {
        Get.snackbar(
          'Error',
          'No images were converted',
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to convert images: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isConverting.value = false;
    }
  }

  // Download single converted file
  Future<void> downloadFile(File file) async {
    try {
      var status = await Permission.storage.request();
      if (status.isDenied) {
        Get.snackbar(
          'Permission Denied',
          'Storage permission is required to download files',
          snackPosition: SnackPosition.BOTTOM,
        );
        return;
      }

      Directory? downloadsDirectory;
      if (Platform.isAndroid) {
        downloadsDirectory = Directory('/storage/emulated/0/Download');
        if (!await downloadsDirectory.exists()) {
          downloadsDirectory = await getExternalStorageDirectory();
        }
      } else {
        downloadsDirectory = await getApplicationDocumentsDirectory();
      }

      if (downloadsDirectory != null) {
        final fileName = file.path.split('/').last;
        final newPath = '${downloadsDirectory.path}/$fileName';

        await file.copy(newPath);

        Get.snackbar(
          'Success',
          'File downloaded to Downloads folder',
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to download file: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  // Download all converted files
  Future<void> downloadAllFiles() async {
    try {
      var status = await Permission.storage.request();
      if (status.isDenied) {
        Get.snackbar(
          'Permission Denied',
          'Storage permission is required to download files',
          snackPosition: SnackPosition.BOTTOM,
        );
        return;
      }

      Directory? downloadsDirectory;
      if (Platform.isAndroid) {
        downloadsDirectory = Directory('/storage/emulated/0/Download');
        if (!await downloadsDirectory.exists()) {
          downloadsDirectory = await getExternalStorageDirectory();
        }
      } else {
        downloadsDirectory = await getApplicationDocumentsDirectory();
      }

      if (downloadsDirectory != null) {
        int downloadCount = 0;
        for (File file in convertedFiles) {
          final fileName = file.path.split('/').last;
          final newPath = '${downloadsDirectory.path}/$fileName';

          await file.copy(newPath);
          downloadCount++;
        }

        Get.snackbar(
          'Success',
          '$downloadCount files downloaded to Downloads folder',
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to download files: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  // Share single file
  Future<void> shareFile(File file) async {
    try {
      await SharePlus.instance.share(
        ShareParams(
          files: [XFile(file.path)],
          text: 'Sharing converted image',
        ),
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to share file: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  // Share all converted files
  Future<void> shareAllFiles() async {
    try {
      List<XFile> xFiles = convertedFiles.map((file) => XFile(file.path)).toList();
      await SharePlus.instance.share(
        ShareParams(
          files: xFiles,
          text: 'Sharing converted images',
        ),
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to share files: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  // Remove single file
  void removeFile(File file) {
    convertedFiles.remove(file);
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