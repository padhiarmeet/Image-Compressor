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
      isCompressed: (map['isCompressed'] == 1 ?true : false) ?? false,
    );
  }
}

class ImageModel extends GetxController {

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
    return ext; // png, jpg, jpeg, etc.
  }

  // New method to check if all images are already compressed
  bool areAllImagesCompressed() {
    // if (_originalImages.isEmpty) return false;
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
                  color: theme.colorScheme.onSurface
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
                          final XFile? pickedImage = await picker.pickImage(source: ImageSource.camera);

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
                          backgroundColor: Get.theme.colorScheme.primary.withOpacity(0.1),
                          shape: RoundedRectangleBorder(side: BorderSide(color: theme.primaryColor.withOpacity(0.15)),borderRadius: BorderRadius.circular(12)),
                          padding: EdgeInsets.all(16),
                        ),
                        child: Icon(Icons.camera_alt_outlined, size: 28,color: theme.colorScheme.primary,),
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
                          final List<XFile> images = await picker.pickMultiImage();

                          if (images.isNotEmpty) {
                            const int maxImages = 5;
                            List<XFile> selectedImages = images;

                            // Check if more than 5 images were selected
                            if (images.length > maxImages) {
                              Get.back();
                              selectedImages = images.take(maxImages).toList();
                              print('YOUR IMAGE LIMIT IS ONY % YOU !!');

                              // Show warning snackbar
                              Get.dialog(
                                AlertDialog(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(15),
                                  ),
                                  title: Row(
                                    children: [
                                      Icon(Icons.image_outlined, color: Colors.blue, size: 24),
                                      SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          'Image Limit Reached',
                                          style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                            color: theme.colorScheme.onBackground
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  content: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'You\'ve reached the free limit of 5 images.',
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
                                          color: theme.colorScheme.primary.withOpacity(0.1),
                                          borderRadius: BorderRadius.circular(8),
                                          border: Border.all(color: theme.colorScheme.primary),
                                        ),
                                        child: Row(
                                          children: [
                                            Icon(Icons.card_giftcard, color: Colors.blue, size: 20),
                                            SizedBox(width: 8),
                                            Expanded(
                                              child: Text(
                                                'Watch a short ad to unlock up to 15 images!',
                                                style: TextStyle(
                                                  fontSize: 13,
                                                  color: theme.colorScheme.primary,
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
                                           Get.back();
                                         },
                                         child: Text(
                                           'Maybe Later',
                                           style: TextStyle(color: Colors.grey[600]),
                                         ),
                                       ),
                                       ElevatedButton.icon(
                                         onPressed: () {
                                           Get.back();
                                           // Show AdMob rewarded ad
                                           // _showRewardedAd();
                                         },
                                         icon: Icon(Icons.play_circle_filled, size: 20),
                                         label: Text('Watch Ad'),
                                         style: ElevatedButton.styleFrom(
                                           backgroundColor: Colors.blue,
                                           foregroundColor: Colors.white,
                                           padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                                           shape: RoundedRectangleBorder(
                                             borderRadius: BorderRadius.circular(8),
                                           ),
                                         ),
                                       ),
                                     ],
                                   )
                                  ],
                                ),
                                barrierDismissible: false,
                              );

                              // Get.snackbar(
                              //   'Image Limit Exceeded',
                              //   'Only the first $maxImages images have been selected',
                              //   backgroundColor: Colors.orange[300],
                              //   colorText: Colors.black,
                              //   snackPosition: SnackPosition.BOTTOM,
                              //   duration: Duration(seconds: 3),
                              // );
                            }
                            else{
                              Get.back();
                            }

                            // Add selected images
                            for (XFile oneImage in selectedImages) {
                              addOriginalImage(
                                CompressedImage(
                                  filePath: oneImage.path,
                                  originalSize: await oneImage.length() / 1024,
                                  compressedSize: 0,
                                  compressedAt: DateTime.now(),
                                  format: getImageFormat(oneImage.path),
                                  isCompressed: false,
                                ),
                              );
                            }

                            clearCompressedList();
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Get.theme.colorScheme.primary.withOpacity(0.1),
                          shape: RoundedRectangleBorder(side: BorderSide(color: theme.primaryColor.withOpacity(0.15)),borderRadius: BorderRadius.circular(12)),
                          padding: EdgeInsets.all(16),
                        ),
                        child: Icon(Icons.image_outlined, size: 28,color: theme.colorScheme.primary,),
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

        var oneImage = CompressedImage(
          filePath: result.path,
          originalSize: originalSizeKB,
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

        print("FilePath : ${result.path}, \noriginalSize : ${await originalFile.length() / 1024} \ncompressedSize: $compressedSizeKB\ncompressedAt: ${DateTime.now()}\nformat: ${image.format}");

        var oneImage =  CompressedImage(
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

        var oneImage =  CompressedImage(
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
      Get.snackbar('Compression Failed', 'Images could not be compressed', snackPosition: SnackPosition.BOTTOM);
    } else {
      final compressedCount = _compressImages.length;
      Get.snackbar('Success', '$compressedCount images compressed at $targetQuality% quality', snackPosition: SnackPosition.BOTTOM);
    }
  }
  //endregion

  //region METHOD FOR DOWNLOADING MULTIPLE IMAGES TO GALLERY
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
      print(e);
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

  //region METHOD FOR DOWNLOADING IMAGE TO GALLERY {HISTORY PAGE}
  Future<void> downloadImage(String filePath) async {
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
      File? file;


      if (filePath.startsWith('content://')) {
        final id = filePath.split("/").last;
        final asset = await AssetEntity.fromId(id);
        file = await asset?.file;
      } else {
        file = File(filePath);
      }

      if (file == null || !(await file.exists())) {
        Get.snackbar(
          'Error',
          'File not found!',
          backgroundColor: Colors.red[300],
          colorText: Colors.black,
          snackPosition: SnackPosition.BOTTOM,
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
        Get.snackbar(
          'Download Complete',
          'Image saved to gallery successfully!',
          backgroundColor: Colors.green[300],
          colorText: Colors.black,
          snackPosition: SnackPosition.BOTTOM,
        );
      } else {
        Get.snackbar(
          'Download Failed',
          'Failed to save image to gallery',
          backgroundColor: Colors.red[300],
          colorText: Colors.black,
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to download image: $e',
        backgroundColor: Colors.red[300],
        colorText: Colors.black,
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }
  //endregion

  //region METHOD FOR SHARING MULTIPLE IMAGES
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
        Get.snackbar('Error', 'Unable to share this file',
            snackPosition: SnackPosition.BOTTOM);
        return;
      }
    } else {
      file = File(filePath);
    }

    if (file == null || !(await file.exists())) {
      Get.snackbar('Error', 'File not found',
          snackPosition: SnackPosition.BOTTOM);
      return;
    }

    final xfile = XFile(file.path);

    final params = ShareParams(
      files: [xfile],
    );

    final shareResult = await SharePlus.instance.share(params);

    if (shareResult.status == ShareResultStatus.success) {
      Get.snackbar('Success', 'Image shared successfully!',
          snackPosition: SnackPosition.BOTTOM);
    }
  }

//endregion
}