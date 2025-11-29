import 'dart:io';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:image_compressor/controllers/compressImageController.dart';
import 'package:image_compressor/controllers/database_controller.dart';
import 'package:photo_manager/photo_manager.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}


class _HistoryScreenState extends State<HistoryScreen> {
  ImageController _imageController = Get.find<ImageController>();
  DatabaseController _databaseController = Get.find<DatabaseController>();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8.0),
      child: Obx(() {
        final _list = _databaseController.imageList;

        if(_databaseController.isLoading.value == true){
          return Center(
            child: CircularProgressIndicator(color: Theme.of(context).colorScheme.primary,),
          );
        }

        if (_list.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Icon(
                //   Icons.history,
                //   size: 48,
                //   color: Theme.of(context).colorScheme.primary,
                // ),
                FaIcon(FontAwesomeIcons.clockRotateLeft,size: 48,color: Theme.of(context).colorScheme.primary,),
                const SizedBox(height: 16),
                Text(
                  'No History Yet',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Start compressing images to see them here',
                  style: TextStyle(
                    fontSize: 16,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        }

        return Column(
          mainAxisSize: MainAxisSize.max,
          children: [
            const Text(
              "Long press the card to delete item",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8,),
            Expanded(
              child: ListView.separated(
                itemCount: _list.length,
                separatorBuilder: (context, index) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final item = _list[index];
                  final compressionRatio = ((item.originalSize - item.compressedSize) / item.originalSize * 100);
                  final fileName = item.filePath.split('/').last;
                  final fileFormat =  item.format.toString();


                  return InkWell(
                    // customBorder: BoxBorder.all(width: 0.5),
                    borderRadius: BorderRadius.circular(16),
                    splashColor: Colors.red.withOpacity(0.7),
                    onLongPress: () async{
                      Get.dialog(
                        AlertDialog(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          title: Text("Delete Item"),
                          content: Text("Do you really want to delete this item?"),
                          alignment: Alignment.center,
                          titleTextStyle: TextStyle(fontWeight: FontWeight.w500,fontSize: 23,color: Theme.of(context).colorScheme.onBackground),
                          clipBehavior: Clip.antiAlias,
                          actions: [
                            TextButton(
                              onPressed: () => Get.back(),
                              child: Text("Cancel"),
                            ),
                            ElevatedButton(
                              onPressed: () async{
                               await _databaseController.deleteImage(item);
                                Get.back();
                              },
                              child: Text("Delete",style: TextStyle(color: Theme.of(context).colorScheme.error),),
                            ),
                          ],
                        ),
                        barrierDismissible: false, // prevents closing by tapping outside
                      );

                    },
                    child: Padding(
                      padding: const EdgeInsets.all(2.0),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.surface,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Theme.of(context).colorScheme.shadow.withOpacity(0.08),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                          border: Border.all(
                            color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
                            width: 1,
                          ),
                        ),
                        child: Column(
                          children: [
                            // Main Content Section
                            Padding(
                              padding: const EdgeInsets.all(16),
                              child: Row(
                                children: [
                                  // Image Preview Section
                                  Container(
                                    width: 80,
                                    height: 80,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color: Theme.of(context).colorScheme.outline.withOpacity(0.9),
                                      ),
                                    ),
                                    child: Stack(
                                      children: [
                                        if (item.filePath.startsWith('content://'))
                                          FutureBuilder<File?>(
                                            future: resolveContentUriToFile(item.filePath),
                                            builder: (context, snapshot) {
                                              if (snapshot.connectionState == ConnectionState.waiting) {
                                                return const Center(child: CircularProgressIndicator(strokeWidth: 2));
                                              }
                                              if (snapshot.hasData && snapshot.data != null) {
                                                return ClipRRect(
                                                  borderRadius: BorderRadius.circular(11),
                                                  child: Image.file(
                                                    snapshot.data!,
                                                    width: 80,
                                                    height: 80,
                                                    fit: BoxFit.cover,
                                                  ),
                                                );
                                              }
                                              return const Icon(Icons.broken_image_outlined, size: 24);
                                            },
                                          )
                                        else
                                          ClipRRect(
                                            borderRadius: BorderRadius.circular(11),
                                            child: Image.file(
                                              File(item.filePath),
                                              width: 80,
                                              height: 80,
                                              fit: BoxFit.cover,
                                              errorBuilder: (context, error, stackTrace) {
                                                return Container(
                                                  color: Theme.of(context).colorScheme.surfaceVariant,
                                                  child: Center(
                                                    child: Icon(
                                                      Icons.broken_image_outlined,
                                                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                                                      size: 24,
                                                    ),
                                                  ),
                                                );
                                              },
                                            ),
                                          ),
                                      ],
                                    ),
                                  ),

                                  const SizedBox(width: 16),

                                  // Content Section
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                      children: [
                                        // File Name and Format Row
                                        Row(
                                          children: [
                                            Expanded(
                                              child: Text(
                                                fileName,
                                                style: TextStyle(
                                                  fontWeight: FontWeight.w600,
                                                  fontSize: 14,
                                                  color: Theme.of(context).colorScheme.onSurface,
                                                ),
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                            const SizedBox(width: 8),
                                            Container(
                                              padding: const EdgeInsets.symmetric(
                                                horizontal: 6,
                                                vertical: 2,
                                              ),
                                              decoration: BoxDecoration(
                                                color: Theme.of(context).colorScheme.secondaryContainer,
                                                borderRadius: BorderRadius.circular(6),
                                              ),
                                              child: Text(
                                                fileFormat,
                                                style: TextStyle(
                                                  fontSize: 10,
                                                  fontWeight: FontWeight.w600,
                                                  color: Theme.of(context).colorScheme.onSecondaryContainer,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),

                                        const SizedBox(height: 12),

                                        // Size Information
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    'Original',
                                                    style: TextStyle(
                                                      fontSize: 10,
                                                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                                                      fontWeight: FontWeight.w500,
                                                    ),
                                                  ),
                                                  const SizedBox(height: 1,),
                                                  Text(
                                                    '${(item.originalSize).toStringAsFixed(1)} KB',
                                                    style: TextStyle(
                                                      fontSize: 12,
                                                      fontWeight: FontWeight.w600,
                                                      color: Theme.of(context).colorScheme.onSurface,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            Expanded(
                                              child:
                                              Icon(
                                                Icons.arrow_forward_outlined,
                                                color: Theme.of(context).colorScheme.primary,
                                                size: 14,
                                              ),
                                            ),
                                            const SizedBox(width: 8),
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    'Compressed',
                                                    style: TextStyle(
                                                      fontSize: 10,
                                                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                                                      fontWeight: FontWeight.w500,
                                                    ),
                                                  ),
                                                  const SizedBox(height: 1,),
                                                  Text(
                                                    '${(item.compressedSize).toStringAsFixed(1)} KB',
                                                    style: TextStyle(
                                                      fontSize: 12,
                                                      fontWeight: FontWeight.w600,
                                                      color: Theme.of(context).colorScheme.primary,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            // Divider Line
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16),
                              child: Divider(
                                height: 1,
                                thickness: 0.5,
                                color: Theme.of(context).colorScheme.outline.withOpacity(0.9),
                              ),
                            ),

                            // Bottom Action Buttons (without container)
                            Padding(
                              padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: SizedBox(
                                      height: 34,
                                      child: TextButton.icon(
                                        onPressed: () => _handleDownload(item.filePath),
                                        icon:
                                        Icon(
                                          Icons.download_outlined,
                                          size: 16,
                                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                                        ),
                                        label: Text(
                                          'Download',
                                          style: TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w500,
                                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                                          ),
                                        ),
                                        style: TextButton.styleFrom(
                                          padding: const EdgeInsets.symmetric(horizontal: 8),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(8),
                                            side: BorderSide(
                                              color: Theme.of(context).colorScheme.outline,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: SizedBox(
                                      height: 34,
                                      child: ElevatedButton.icon(
                                        onPressed: () => _handleShare(item.filePath),
                                        icon: Icon(
                                          Icons.share,
                                          size: 14,
                                          color: Theme.of(context).colorScheme.onPrimary,
                                        ),
                                        label: Text(
                                          'Share',
                                          style: TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w500,
                                            color: Theme.of(context).colorScheme.onPrimary,
                                          ),
                                        ),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Theme.of(context).colorScheme.primary,
                                          elevation: 0,
                                          padding: const EdgeInsets.symmetric(horizontal: 8),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        );
      }),
    );
  }

  void _handleDownload(String filePath) {
    _imageController.downloadImage(filePath);
    print('Download: $filePath');
  }

  void _handleShare(String filePath) {
    _imageController.shareImage(filePath);
    print('Share: $filePath');
    Get.snackbar(
      '',
      '',
      titleText: Text(
        'Share',
        style: TextStyle(
          color: Theme.of(context).colorScheme.onPrimary,
          fontWeight: FontWeight.w600,
          fontSize: 16,
        ),
      ),
      messageText: Text(
        'Opening share dialog...',
        style: TextStyle(color: Theme.of(context).colorScheme.onPrimary),
      ),
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Theme.of(context).colorScheme.primary,
      borderRadius: 12,
      margin: const EdgeInsets.all(16),
      duration: const Duration(seconds: 2),
    );
  }
}

Future<File?> resolveContentUriToFile(String uri) async {
  try {
    final id = uri.split("/").last; // e.g. 1000070324
    final asset = await AssetEntity.fromId(id);
    return await asset?.file;
  } catch (e) {
    debugPrint("Error resolving content URI: $e");
    return null;
  }
}

