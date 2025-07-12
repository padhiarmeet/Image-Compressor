import 'dart:io';
import 'package:flutter_image_compress/flutter_image_compress.dart';
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

  CompressedImage({
    this.id,
    required this.filePath,
    required this.originalSize,
    required this.compressedSize,
    this.compressedAt,
    required this.format,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'filePath': filePath,
      'originalSize': originalSize,
      'compressedSize': compressedSize,
      'compressedAt': compressedAt?.toIso8601String(),
      'format': format,
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
    _compressImages.clear();

    if (_originalImages.isEmpty) {
      Get.snackbar('Error', 'Please select images first',snackPosition: SnackPosition.BOTTOM);
      return;
    }

    final dir = await path_provider.getTemporaryDirectory();

    for (var image in _originalImages) {
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
          ),
        );
      }
    }

    if (_compressImages.isEmpty) {
      Get.snackbar('Compression Failed', 'All images failed to compress');
    } else {
      Get.snackbar('Success', 'Images compressed successfully');
    }
  }
  //endregion

  //region Method for compressing image to specific size
  Future<void> compressToTargetSize(int targetSizeKB) async {
    _compressImages.clear();

    if (_originalImages.isEmpty) {
      Get.snackbar('Error', 'Please select images first',snackPosition: SnackPosition.BOTTOM);
      return;
    }

    final dir = await path_provider.getTemporaryDirectory();

    for (var image in _originalImages) {
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
          ),
        );
      }
    }

    if (_compressImages.isEmpty) {
      Get.snackbar('Compression Failed', 'Images could not be compressed to target size');
    } else {
      Get.snackbar('Success', 'Images compressed to ≤ $targetSizeKB KB');
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
