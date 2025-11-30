import 'dart:io';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:image_compressor/controllers/database_controller.dart';
import 'package:image_gallery_saver_plus/image_gallery_saver_plus.dart';
import 'package:path_provider/path_provider.dart' as path_provider;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:share_plus/share_plus.dart';
import 'package:image_compressor/controllers/reward_controller.dart';
import 'package:path/path.dart' as path;

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
      'isCompressed': isCompressed ? 1 : 0,
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
      isCompressed: (map['isCompressed'] == 1 ? true : false) ?? false,
    );
  }
}

enum SnackbarType { success, error, warning, info }

class ImageModel extends GetxController {
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

  final RxList<CompressedImage> _originalImages = <CompressedImage>[].obs;
  final RxList<CompressedImage> _compressImages = <CompressedImage>[].obs;

  final databaseController = Get.find<DatabaseController>();

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
    return ext; // png, jpg, jpeg.
  }

  // New method to check if all images are already compressed
  bool areAllImagesCompressed() {
    // if (_originalImages.isEmpty) return false;
    return _originalImages.every((image) => image.isCompressed);
  }

  // New method to get compression status summary
  Map<String, int> getCompressionStatus() {
    int compressed = _originalImages
        .where((image) => image.isCompressed)
        .length;
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
      _showStyledSnackbar(
        title: 'Storage permission Required',
        message: 'Permission is denied',
        type: SnackbarType.error,
      );
      return;
    }

    if (status.isGranted) {
      ThemeData theme = Get.theme;

      Get.bottomSheet(
        Container(
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
          ),
          padding: EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Choose Image Source (Max 5 Images)',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.onSurface,
                ),
              ),
              SizedBox(height: 24),
              //Buttons for selecting image sources
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  // Camera Button
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ElevatedButton(
                        onPressed: () async {
                          final XFile? pickedImage = await picker.pickImage(
                            source: ImageSource.camera,
                          );

                          if (pickedImage != null) {
                            addOriginalImage(
                              CompressedImage(
                                filePath: pickedImage.path,
                                originalSize: await pickedImage.length() / 1024,
                                compressedSize: 0,
                                compressedAt: DateTime.now(),
                                format: getImageFormat(pickedImage.path),
                                isCompressed: false,
                              ),
                            );
                            clearCompressedList();
                            Get.back();
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Get.theme.colorScheme.primary
                              .withOpacity(0.1),
                          shape: RoundedRectangleBorder(
                            side: BorderSide(
                              color: theme.primaryColor.withOpacity(0.15),
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: EdgeInsets.all(16),
                        ),
                        child: Icon(
                          Icons.camera_alt_outlined,
                          size: 28,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text('Camera', style: TextStyle(fontSize: 14)),
                    ],
                  ),

                  // Gallery Button
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ElevatedButton(
                        onPressed: () async {
                          final List<XFile> images = await picker
                              .pickMultiImage();
                          if (images.isNotEmpty) {
                            int maxImages = 5;
                            try {
                              maxImages =
                                  Get.find<RewardController>().imageLimit.value;
                            } catch (e) {
                              maxImages = 5;
                            }

                            List<XFile> selectedImages = images;

                            if (images.length > maxImages) {
                              Get.back(); // Close bottom sheet first

                              // Show dialog and wait for result
                              final watchAd = await Get.dialog<bool>(
                                AlertDialog(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(15),
                                  ),
                                  title: Row(
                                    children: [
                                      Icon(
                                        Icons.image_outlined,
                                        color: Colors.blue,
                                        size: 24,
                                      ),
                                      SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          'Image Limit Reached',
                                          style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                            color:
                                                theme.colorScheme.onBackground,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  content: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'You\'ve selected ${images.length} images but your current limit is $maxImages.',
                                        style: TextStyle(
                                          fontWeight: FontWeight.w600,
                                          fontSize: 15,
                                          color: theme.colorScheme.onSurface,
                                        ),
                                      ),
                                      SizedBox(height: 12),
                                      Container(
                                        padding: EdgeInsets.all(12),
                                        decoration: BoxDecoration(
                                          color: theme.colorScheme.primary
                                              .withOpacity(0.1),
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                          border: Border.all(
                                            color: theme.colorScheme.primary,
                                          ),
                                        ),
                                        child: Row(
                                          children: [
                                            Icon(
                                              Icons.card_giftcard,
                                              color: Colors.blue,
                                              size: 20,
                                            ),
                                            SizedBox(width: 8),
                                            Expanded(
                                              child: Text(
                                                'Watch a short ad to unlock up to ${maxImages + 5} images!',
                                                style: TextStyle(
                                                  fontSize: 13,
                                                  color:
                                                      theme.colorScheme.primary,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                  actions: [
                                    Row(
                                      mainAxisSize: MainAxisSize.max,
                                      children: [
                                        TextButton(
                                          onPressed: () {
                                            Get.back(result: false);
                                          },
                                          child: Text(
                                            'Maybe Later',
                                            style: TextStyle(
                                              color: Colors.grey[600],
                                            ),
                                          ),
                                        ),
                                        Spacer(),
                                        ElevatedButton.icon(
                                          onPressed: () {
                                            Get.back(result: true);
                                          },
                                          icon: Icon(
                                            Icons.play_circle_filled,
                                            size: 20,
                                          ),
                                          label: Text('Watch Ad'),
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.blue,
                                            foregroundColor: Colors.white,
                                            padding: EdgeInsets.symmetric(
                                              horizontal: 20,
                                              vertical: 12,
                                            ),
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                barrierDismissible: false,
                              );

                              if (watchAd == true) {
                                // User chose to watch ad
                                bool rewarded = false;
                                try {
                                  final rc = Get.find<RewardController>();
                                  rewarded = await rc
                                      .increaseLimitByWatchingAd();
                                } catch (e) {
                                  final rc = Get.put(RewardController());
                                  rewarded = await rc
                                      .increaseLimitByWatchingAd();
                                }

                                if (rewarded) {
                                  // Get updated limit after watching ad
                                  int newLimit = 10;
                                  try {
                                    newLimit = Get.find<RewardController>()
                                        .imageLimit
                                        .value;
                                  } catch (e) {
                                    newLimit = 10;
                                  }
                                  selectedImages = images
                                      .take(newLimit)
                                      .toList();
                                } else {
                                  // Ad failed, use original limit
                                  selectedImages = images
                                      .take(maxImages)
                                      .toList();
                                }
                              } else {
                                // User chose "Maybe Later", use current limit
                                selectedImages = images
                                    .take(maxImages)
                                    .toList();
                              }

                              // Add images after dialog handling is complete
                              for (XFile oneImage in selectedImages) {
                                addOriginalImage(
                                  CompressedImage(
                                    filePath: oneImage.path,
                                    originalSize:
                                        await oneImage.length() / 1024,
                                    compressedSize: 0,
                                    compressedAt: DateTime.now(),
                                    format: getImageFormat(oneImage.path),
                                    isCompressed: false,
                                  ),
                                );
                              }
                              clearCompressedList();
                            } else {
                              // Within limit, add all images directly
                              Get.back(); // Close bottom sheet

                              for (XFile oneImage in selectedImages) {
                                addOriginalImage(
                                  CompressedImage(
                                    filePath: oneImage.path,
                                    originalSize:
                                        await oneImage.length() / 1024,
                                    compressedSize: 0,
                                    compressedAt: DateTime.now(),
                                    format: getImageFormat(oneImage.path),
                                    isCompressed: false,
                                  ),
                                );
                              }
                              clearCompressedList();
                            }
                          }
                        },

                        style: ElevatedButton.styleFrom(
                          backgroundColor: Get.theme.colorScheme.primary
                              .withOpacity(0.1),
                          shape: RoundedRectangleBorder(
                            side: BorderSide(
                              color: theme.primaryColor.withOpacity(0.15),
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: EdgeInsets.all(16),
                        ),
                        child: Icon(
                          Icons.image_outlined,
                          size: 28,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text('Gallery', style: TextStyle(fontSize: 14)),
                    ],
                  ),
                ],
              ),
              SizedBox(height: 16),
              Text(
                '* You can increase the image limit by watching an Ad',
                style: TextStyle(
                  fontSize: 12,
                  color: theme.colorScheme.onTertiary.withOpacity(0.6),
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
        backgroundColor: Colors.transparent,
      );
    }
  }
  //endregion

  //region Method for Compressing Image
  Future<void> compressImages() async {
    // Check if all images are already compressed
    if (areAllImagesCompressed()) {
      _showStyledSnackbar(
        title: "Already Compressed",
        message: "All images have already been compressed",
        type: SnackbarType.warning,
      );
      return;
    }

    _compressImages.clear();

    if (_originalImages.isEmpty) {
      _showStyledSnackbar(
        title: "Error",
        message: "Please select images first",
        type: SnackbarType.error,
      );
      return;
    }

    final dir = await path_provider.getTemporaryDirectory();

    // Only compress images that haven't been compressed yet
    final uncompressedImages = _originalImages
        .where((image) => !image.isCompressed)
        .toList();

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

        var oneImage = CompressedImage(
          filePath: result.path,
          originalSize: originalSizeKB,
          compressedSize: compressedSizeKB,
          compressedAt: DateTime.now(),
          format: image.format,
          isCompressed: true,
        );

        _compressImages.add(oneImage);
        // Mark the original image as compressed
        image.isCompressed = true;
      }
    }

    if (_compressImages.isEmpty) {
      _showStyledSnackbar(
        title: "Compression Failed",
        message: "All images failed to compress",
        type: SnackbarType.error,
      );
    } else {
      _showStyledSnackbar(
        title: "Success",
        message: "Images compressed successfully",
        type: SnackbarType.success,
      );
    }

    // Reset the limit back to 5 after compression
    try {
      Get.find<RewardController>().resetLimit();
    } catch (e) {
      // Controller not found, skip reset
    }
  }

  //endregion

  //region Method for compressing image to specific size
  Future<void> compressToTargetSize(int targetSizeKB) async {
    // Check if all images are already compressed
    if (areAllImagesCompressed()) {
      _showStyledSnackbar(
        title: 'Already Compressed',
        message: 'All images have already been compressed',
        type: SnackbarType.warning,
      );
      return;
    }

    _compressImages.clear();

    if (_originalImages.isEmpty) {
      _showStyledSnackbar(
        title: 'Error',
        message: 'Please select images first',
        type: SnackbarType.error,
      );
      return;
    }

    final dir = await path_provider.getTemporaryDirectory();

    // Only compress images that haven't been compressed yet
    final uncompressedImages = _originalImages
        .where((image) => !image.isCompressed)
        .toList();

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

        print(
          "FilePath : ${result.path}, \noriginalSize : ${await originalFile.length() / 1024} \ncompressedSize: $compressedSizeKB\ncompressedAt: ${DateTime.now()}\nformat: ${image.format}",
        );

        var oneImage = CompressedImage(
          filePath: result.path,
          originalSize: await originalFile.length() / 1024,
          compressedSize: compressedSizeKB,
          compressedAt: DateTime.now(),
          format: image.format,
          isCompressed: true, // Mark as compressed
        );

        _compressImages.add(oneImage);

        // Mark the original image as compressed
        image.isCompressed = true;
      }
    }

    if (_compressImages.isEmpty) {
      _showStyledSnackbar(
        title: 'Compression Failed',
        message: 'Images could not be compressed to target size',
        type: SnackbarType.error,
      );
    } else {
      final compressedCount = _compressImages.length;
      _showStyledSnackbar(
        title: 'Success',
        message: '$compressedCount images compressed to ≤ $targetSizeKB KB',
        type: SnackbarType.success,
      );
    }
    try {
      Get.find<RewardController>().resetLimit();
    } catch (e) {
      print(e);
    }
  }
  //endregion

  //region Method for compressing image to specific Quality
  Future<void> compressToTargetQuality(int targetQuality) async {
    // Check if all images are already compressed
    if (areAllImagesCompressed()) {
      _showStyledSnackbar(
        title: 'Already Compressed',
        message: 'All images have already been compressed',
        type: SnackbarType.warning,
      );
      return;
    }

    _compressImages.clear();

    if (_originalImages.isEmpty) {
      _showStyledSnackbar(
        title: 'Error',
        message: 'Please select images first',
        type: SnackbarType.error,
      );
      return;
    }

    // Validate quality range
    if (targetQuality < 1 || targetQuality > 100) {
      _showStyledSnackbar(
        title: 'Invalid Quality',
        message: 'Quality must be between 1-100',
        type: SnackbarType.warning,
      );
      return;
    }

    final dir = await path_provider.getTemporaryDirectory();

    // Only compress images that haven't been compressed yet
    final uncompressedImages = _originalImages
        .where((image) => !image.isCompressed)
        .toList();

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

        var oneImage = CompressedImage(
          filePath: result.path,
          originalSize: await originalFile.length() / 1024,
          compressedSize: compressedSizeKB,
          compressedAt: DateTime.now(),
          format: image.format,
          isCompressed: true, // Mark as compressed
        );

        _compressImages.add(oneImage);

        await databaseController.addImage(oneImage);

        // Mark the original image as compressed
        image.isCompressed = true;
      }
    }

    if (_compressImages.isEmpty) {
      _showStyledSnackbar(
        title: 'Compression Failed',
        message: 'Images could not be compressed',
        type: SnackbarType.error,
      );
    } else {
      final compressedCount = _compressImages.length;
      _showStyledSnackbar(
        title: 'Success',
        message:
            '$compressedCount images compressed at $targetQuality% quality',
        type: SnackbarType.success,
      );
    }
    try {
      Get.find<RewardController>().resetLimit();
    } catch (e) {
      // Controller not found, skip reset
    }
  }
  //endregion

  //region METHOD FOR DOWNLOADING MULTIPLE IMAGES TO GALLERY
  Future<void> downloadImages() async {
    if (_compressImages.isEmpty) {
      _showStyledSnackbar(
        title: 'No Images',
        message: 'No compressed images to download',
        type: SnackbarType.warning,
      );
      return;
    }

    // Request storage permission
    PermissionStatus status = await Permission.photos.request();
    if (status.isDenied || status.isPermanentlyDenied) {
      _showStyledSnackbar(
        title: 'Storage Permission Required',
        message:
            'Permission is denied. Please enable storage permission in settings.',
        type: SnackbarType.error,
      );
      return;
    }

    try {
      int successCount = 0;
      int failCount = 0;

      for (var image in _compressImages) {
        File? file;

        if (image.filePath.startsWith('content://')) {
          try {
            final id = image.filePath.split("/").last;
            final asset = await AssetEntity.fromId(id);
            file = await asset?.file;
          } catch (e) {
            debugPrint("Error resolving content URI: $e");
            failCount++;
            continue;
          }
        } else {
          file = File(image.filePath);
        }

        if (file == null || !(await file.exists())) {
          failCount++;
          continue;
        }

        final bytes = await file.readAsBytes();

        // Generate a unique filename
        final fileName =
            'compressed_${DateTime.now().millisecondsSinceEpoch}.${image.format}';

        final result = await ImageGallerySaverPlus.saveImage(
          bytes,
          name: fileName,
          quality: 100,
        );

        if (result['isSuccess'] == true) {
          Map<String, dynamic> newData = image.toMap();
          newData['filePath'] = result['filePath'];
          await databaseController.addImage(CompressedImage.fromMap(newData));
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
      print(e);
      _showStyledSnackbar(
        title: 'Error',
        message: 'Failed to download images: $e',
        type: SnackbarType.error,
      );
    }
  }
  //endregion

  //region METHOD FOR DOWNLOADING IMAGE TO GALLERY {HISTORY PAGE}
  Future<void> downloadImage(String filePath) async {
    // Request storage permission
    PermissionStatus status = await Permission.photos.request();
    if (status.isDenied || status.isPermanentlyDenied) {
      _showStyledSnackbar(
        title: 'Storage Permission Required',
        message:
            'Permission is denied. Please enable storage permission in settings.',
        type: SnackbarType.error,
      );
      return;
    }

    try {
      File? file;

      if (filePath.startsWith('content://')) {
        final id = filePath.split("/").last;
        final asset = await AssetEntity.fromId(id);
        file = await asset?.file;
      } else {
        file = File(filePath);
      }

      if (file == null || !(await file.exists())) {
        _showStyledSnackbar(
          title: 'Error',
          message: 'File not found!',
          type: SnackbarType.error,
        );
        return;
      }

      final bytes = await file.readAsBytes();

      final fileName =
          'compressed_${DateTime.now().millisecondsSinceEpoch}${path.extension(file.path)}';

      final result = await ImageGallerySaverPlus.saveImage(
        bytes,
        name: fileName,
        quality: 100,
      );

      if (result['isSuccess']) {
        _showStyledSnackbar(
          title: 'Download Complete',
          message: 'Image saved to gallery successfully!',
          type: SnackbarType.success,
        );
      } else {
        _showStyledSnackbar(
          title: 'Download Failed',
          message: 'Failed to save image to gallery',
          type: SnackbarType.error,
        );
      }
    } catch (e) {
      _showStyledSnackbar(
        title: 'Error',
        message: 'Failed to download image: $e',
        type: SnackbarType.error,
      );
    }
  }
  //endregion

  //region METHOD FOR SHARING MULTIPLE IMAGES
  Future<void> shareImages(List<CompressedImage> files) async {
    final List<XFile> xFiles = files
        .map((file) => XFile(file.filePath))
        .toList();

    final params = ShareParams(files: xFiles);

    final shareResult = await SharePlus.instance.share(params);

    if (shareResult.status == ShareResultStatus.success) {
      _showStyledSnackbar(
        title: 'Success',
        message: 'Image shared successfully !',
        type: SnackbarType.success,
      );
    }
  }
  //endregion

  //region METHOD FOR SHARING ONE IMAGES {HISTORY PAGE}
  Future<void> shareImage(String filePath) async {
    File? file;

    if (filePath.startsWith('content://')) {
      try {
        final id = filePath.split("/").last;
        final asset = await AssetEntity.fromId(id);
        file = await asset?.file;
      } catch (e) {
        debugPrint("Error resolving content URI for sharing: $e");
        _showStyledSnackbar(
          title: 'Error',
          message: 'Unable to share this file',
          type: SnackbarType.error,
        );
        return;
      }
    } else {
      file = File(filePath);
    }

    if (file == null || !(await file.exists())) {
      _showStyledSnackbar(
        title: 'Error',
        message: 'File not found',
        type: SnackbarType.error,
      );
      return;
    }

    final xfile = XFile(file.path);

    final params = ShareParams(files: [xfile]);

    final shareResult = await SharePlus.instance.share(params);

    if (shareResult.status == ShareResultStatus.success) {
      _showStyledSnackbar(
        title: 'Success',
        message: 'Image shared successfully!',
        type: SnackbarType.success,
      );
    }
  }

  //endregion
}
