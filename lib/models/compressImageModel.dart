import 'dart:io';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:image_gallery_saver_plus/image_gallery_saver_plus.dart';
import 'package:path_provider/path_provider.dart' as path_provider;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:share_plus/share_plus.dart';

class CompressedImage {
  int? id;
  String filePath;
  double originalSize;
  double compressedSize;
  DateTime? compressedAt;
  String format;
  bool isCompressed;

  CompressedImage({
    this.id,
    required this.filePath,
    required this.originalSize,
    required this.compressedSize,
    this.compressedAt,
    required this.format,
    this.isCompressed = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'filePath': filePath,
      'originalSize': originalSize,
      'compressedSize': compressedSize,
      'compressedAt': compressedAt?.toIso8601String(),
      'format': format,
      'isCompressed': isCompressed,
    };
  }

  factory CompressedImage.fromMap(Map<String, dynamic> map) {
    return CompressedImage(
      id: map['id'],
      filePath: map['filePath'],
      originalSize: map['originalSize'],
      compressedSize: map['compressedSize'],
      compressedAt: map['compressedAt'] != null
          ? DateTime.parse(map['compressedAt'])
          : null,
      format: map['format'],
      isCompressed: map['isCompressed'] ?? false,
    );
  }
}

class ImageModel extends GetxController {

  final RxList<CompressedImage> _originalImages = <CompressedImage>[].obs;
  final RxList<CompressedImage> _compressImages = <CompressedImage>[].obs;

  //region Methods for Original Images
  void addOriginalImage(CompressedImage image) {
    _originalImages.add(image);
  }

  void removeOriginalImage(CompressedImage image) {
    _originalImages.remove(image);
  }

  List<CompressedImage> getOriginalImages() {
    return _originalImages;
  }

    void clearOriginalList() {
    _originalImages.clear();
  }
  //endregion

  //region Methods for CompressImages
  void addCompressImage(CompressedImage image) {
    _compressImages.add(image);
  }

  void removeCompressImage(CompressedImage image) {
    _compressImages.remove(image);
  }

  List<CompressedImage> getCompressImages() {
    return _compressImages;
  }

  void clearCompressedList() {
    _compressImages.clear();
  }
  //endregion

  //region Method to Clear all Lists and Getting Format
  void clearAll() {
    _compressImages.clear();
    _originalImages.clear();
  }

  String getImageFormat(String path) {
    final ext = path.split('.').last.toLowerCase();
    return ext; // png, jpg, jpeg, etc.
  }

  // New method to check if all images are already compressed
  bool areAllImagesCompressed() {
    if (_originalImages.isEmpty) return false;
    return _originalImages.every((image) => image.isCompressed);
  }

  // New method to get compression status summary
  Map<String, int> getCompressionStatus() {
    int compressed = _originalImages.where((image) => image.isCompressed).length;
    int total = _originalImages.length;
    int uncompressed = total - compressed;

    return {
      'total': total,
      'compressed': compressed,
      'uncompressed': uncompressed,
    };
  }
  //endregion

  //region Methods for Picking image from gallery
  final picker = ImagePicker();

  Future<void> pickImageFromGallery() async {
    PermissionStatus status = await Permission.photos.request();

    if (status.isDenied || status.isPermanentlyDenied) {
      Get.snackbar(
        'Storage permission Required',
        'Permission is denied',
        backgroundColor: Colors.red[300],
        colorText: Colors.black,
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    if (status.isGranted) {
      final List<XFile> images = await picker.pickMultiImage();

      //region Add Image in Original List
      if (images.isNotEmpty) {
        for (XFile oneImage in images) {
          addOriginalImage(
            CompressedImage(
              filePath: oneImage.path,
              originalSize: await oneImage.length() / 1024,
              compressedSize: 0,
              compressedAt: DateTime.now(),
              format: getImageFormat(oneImage.path),
              isCompressed: false, // New images are not compressed
            ),
          );
        }
        clearCompressedList();
      }
    }
  }
  //endregion

  //region Method for Compressing Image
  Future<void> compressImages() async {
    // Check if all images are already compressed
    if (areAllImagesCompressed()) {
      Get.snackbar(
        'Already Compressed',
        'All images have already been compressed',
        backgroundColor: Colors.orange[300],
        colorText: Colors.black,
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    _compressImages.clear();

    if (_originalImages.isEmpty) {
      Get.snackbar('Error', 'Please select images first',snackPosition: SnackPosition.BOTTOM);
      return;
    }

    final dir = await path_provider.getTemporaryDirectory();

    // Only compress images that haven't been compressed yet
    final uncompressedImages = _originalImages.where((image) => !image.isCompressed).toList();

    for (var image in uncompressedImages) {
      final originalFile = File(image.filePath);

      // Calculate original size in KB
      final originalBytes = await originalFile.readAsBytes();
      final originalSizeKB = originalBytes.length / 1024;

      // Create compressed path
      final targetPath =
          '${dir.path}/${DateTime.now().millisecondsSinceEpoch}_${image.filePath.split('/').last}';

      final XFile? result = await FlutterImageCompress.compressAndGetFile(
        image.filePath,
        targetPath,
        minHeight: 720,
        minWidth: 720,
        quality: 50,
      );

      if (result != null) {
        final compressedFile = File(result.path);
        final compressedBytes = await compressedFile.readAsBytes();
        final compressedSizeKB = compressedBytes.length / 1024;

        _compressImages.add(
          CompressedImage(
            filePath: result.path,
            originalSize: originalSizeKB,
            compressedSize: compressedSizeKB,
            compressedAt: DateTime.now(),
            format: image.format,
            isCompressed: true, // Mark as compressed
          ),
        );

        // Mark the original image as compressed
        image.isCompressed = true;
      }
    }

    if (_compressImages.isEmpty) {
      Get.snackbar('Compression Failed', 'All images failed to compress',snackPosition: SnackPosition.BOTTOM);
    } else {
      Get.snackbar('Success', 'Images compressed successfully',snackPosition: SnackPosition.BOTTOM);
    }
  }
  //endregion

  //region Method for compressing image to specific size
  Future<void> compressToTargetSize(int targetSizeKB) async {
    // Check if all images are already compressed
    if (areAllImagesCompressed()) {
      Get.snackbar(
        'Already Compressed',
        'All images have already been compressed',
        backgroundColor: Colors.orange[300],
        colorText: Colors.black,
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    _compressImages.clear();

    if (_originalImages.isEmpty) {
      Get.snackbar('Error', 'Please select images first',snackPosition: SnackPosition.BOTTOM);
      return;
    }

    final dir = await path_provider.getTemporaryDirectory();

    // Only compress images that haven't been compressed yet
    final uncompressedImages = _originalImages.where((image) => !image.isCompressed).toList();

    for (var image in uncompressedImages) {
      final originalFile = File(image.filePath);
      int quality = 95;
      XFile? result;

      while (quality > 10) {
        final targetPath =
            '${dir.path}/${DateTime.now().microsecondsSinceEpoch}_${image.filePath.split('/').last}';

        result = await FlutterImageCompress.compressAndGetFile(
          image.filePath,
          targetPath,
          quality: quality,
          minWidth: 720,
          minHeight: 720,
        );

        if (result == null) break;

        final compressedFile = File(result.path);
        final compressedBytes = await compressedFile.readAsBytes();
        final sizeKB = compressedBytes.length / 1024;

        if (sizeKB <= targetSizeKB) break;

        quality -= 3;
      }

      if (result != null) {
        final compressedFile = File(result.path);
        final compressedBytes = await compressedFile.readAsBytes();
        final compressedSizeKB = compressedBytes.length / 1024;

        _compressImages.add(
          CompressedImage(
            filePath: result.path,
            originalSize: await originalFile.length() / 1024,
            compressedSize: compressedSizeKB,
            compressedAt: DateTime.now(),
            format: image.format,
            isCompressed: true, // Mark as compressed
          ),
        );

        // Mark the original image as compressed
        image.isCompressed = true;
      }
    }

    if (_compressImages.isEmpty) {
      Get.snackbar('Compression Failed', 'Images could not be compressed to target size',snackPosition: SnackPosition.BOTTOM);
    } else {
      final compressedCount = _compressImages.length;
      Get.snackbar('Success', '$compressedCount images compressed to ≤ $targetSizeKB KB',snackPosition: SnackPosition.BOTTOM);
    }
  }
  //endregion

  //region Method for compressing image to specific Quality
  Future<void> compressToTargetQuality(int targetQuality) async {
    // Check if all images are already compressed
    if (areAllImagesCompressed()) {
      Get.snackbar(
        'Already Compressed',
        'All images have already been compressed',
        backgroundColor: Colors.orange[300],
        colorText: Colors.black,
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    _compressImages.clear();

    if (_originalImages.isEmpty) {
      Get.snackbar('Error', 'Please select images first', snackPosition: SnackPosition.BOTTOM);
      return;
    }

    // Validate quality range
    if (targetQuality < 1 || targetQuality > 100) {
      Get.snackbar('Invalid Quality', 'Quality must be between 1-100', snackPosition: SnackPosition.BOTTOM);
      return;
    }

    final dir = await path_provider.getTemporaryDirectory();

    // Only compress images that haven't been compressed yet
    final uncompressedImages = _originalImages.where((image) => !image.isCompressed).toList();

    for (var image in uncompressedImages) {
      final originalFile = File(image.filePath);

      final targetPath =
          '${dir.path}/${DateTime.now().microsecondsSinceEpoch}_${image.filePath.split('/').last}';

      // Compress with the specified quality directly
      final result = await FlutterImageCompress.compressAndGetFile(
        image.filePath,
        targetPath,
        quality: targetQuality,
        minWidth: 720,
        minHeight: 720,
      );

      if (result != null) {
        final compressedFile = File(result.path);
        final compressedBytes = await compressedFile.readAsBytes();
        final compressedSizeKB = compressedBytes.length / 1024;

        _compressImages.add(
          CompressedImage(
            filePath: result.path,
            originalSize: await originalFile.length() / 1024,
            compressedSize: compressedSizeKB,
            compressedAt: DateTime.now(),
            format: image.format,
            isCompressed: true, // Mark as compressed
          ),
        );

        // Mark the original image as compressed
        image.isCompressed = true;
      }
    }

    if (_compressImages.isEmpty) {
      Get.snackbar('Compression Failed', 'Images could not be compressed', snackPosition: SnackPosition.BOTTOM);
    } else {
      final compressedCount = _compressImages.length;
      Get.snackbar('Success', '$compressedCount images compressed at $targetQuality% quality', snackPosition: SnackPosition.BOTTOM);
    }
  }
  //endregion

  //region METHOD FOR DOWNLOADING IMAGES TO GALLERY
  Future<void> downloadImages() async {
    if (_compressImages.isEmpty) {
      Get.snackbar(
        'No Images',
        'No compressed images to download',
        backgroundColor: Colors.orange[300],
        colorText: Colors.black,
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    // Request storage permission
    PermissionStatus status = await Permission.photos.request();
    if (status.isDenied || status.isPermanentlyDenied) {
      Get.snackbar(
        'Storage Permission Required',
        'Permission is denied. Please enable storage permission in settings.',
        backgroundColor: Colors.red[300],
        colorText: Colors.black,
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    try {
      int successCount = 0;
      int failCount = 0;

      for (var image in _compressImages) {
        final file = File(image.filePath);
        final bytes = await file.readAsBytes();

        // Generate a unique filename
        final fileName = 'compressed_${DateTime.now().millisecondsSinceEpoch}.${image.format}';

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
        Get.snackbar(
          'Download Complete',
          '$successCount image${successCount == 1 ? '' : 's'} saved to gallery${failCount > 0 ? ' ($failCount failed)' : ''}',
          backgroundColor: Colors.green[300],
          colorText: Colors.black,
          snackPosition: SnackPosition.BOTTOM,
        );
      } else {
        Get.snackbar(
          'Download Failed',
          'Failed to save images to gallery',
          backgroundColor: Colors.red[300],
          colorText: Colors.black,
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to download images: $e',
        backgroundColor: Colors.red[300],
        colorText: Colors.black,
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }
  //endregion

  //region METHOD FOR SHARING IMAGES
  Future<void> shareImages(List<CompressedImage> files) async {
    final List<XFile> xFiles = files.map((file) => XFile(file.filePath)).toList();

    final params = ShareParams(
      files: xFiles,
    );

    final shareResult = await SharePlus.instance.share(params);

    if (shareResult.status == ShareResultStatus.success) {
      Get.snackbar('Success','Image shared successfully !',snackPosition: SnackPosition.BOTTOM);
    }
  }
//endregion
}