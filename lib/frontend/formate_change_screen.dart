import 'dart:io';
import 'dart:ui';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:image_compressor/controllers/compressImageController.dart';
import 'package:image_compressor/models/compressImageModel.dart';
import '../adMob/bannerAdWidget.dart';
import '../controllers/format_change_view_controller.dart';

class ChangeFormatScreen extends StatefulWidget {
  const ChangeFormatScreen({super.key});

  @override
  State<ChangeFormatScreen> createState() => _ChangeFormatScreenState();
}

class _ChangeFormatScreenState extends State<ChangeFormatScreen>
    with TickerProviderStateMixin {
  bool isDarkMode = true;
  final List<CompressedImage> images = [];
  late AnimationController _pulseController;
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;
  late final AnimationController _borderController;
  late TabController _tabController;
  late FormatChangeController formatController;

  @override
  void initState() {
    super.initState();
    formatController = Get.put(FormatChangeController());

    _borderController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();

    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);

    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );

    _tabController = TabController(length: 2, vsync: this);
    _fadeController.forward();
  }

  ImageController imageController = Get.put(ImageController());

  @override
  void dispose() {
    _borderController.dispose();
    _pulseController.dispose();
    _fadeController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWeight = MediaQuery.of(context).size.width;
    final containerHeight = screenHeight * 0.40;
    isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return SafeArea(
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          child: Obx(() {
            RxBool hasOriginalImages = imageController
                .getOriginalList()
                .isNotEmpty
                .obs;

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 10),

                if (hasOriginalImages.value)
                  _buildImageCarousel(
                    imageController.getOriginalList(),
                    containerHeight,
                    hasOriginalImages,
                  )
                else
                  _buildDropZone(context, containerHeight, imageController),

                if (!hasOriginalImages.value) ...[
                  const SizedBox(height: 30),
                  _buildInstructions(context),
                  Spacer(),
                  Center(
                    child: BannerAdWidget(
                      adUnitId: "ca-app-pub-9176383426179540/4427910768",
                    ),
                  ),
                ],

                Column(
                  children: [
                    if (hasOriginalImages.value &&
                        !formatController.hasConvertedFiles.value)
                      Container(
                        width: double.infinity,
                        margin: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 10,
                        ),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Container(
                                    margin: const EdgeInsets.only(right: 5),
                                    child: Obx(
                                      () => ElevatedButton.icon(
                                        onPressed:
                                            hasOriginalImages.value &&
                                                !formatController
                                                    .isConverting
                                                    .value
                                            ? () => formatController
                                                  .convertToFormat('jpg')
                                            : null,
                                        icon:
                                            formatController
                                                    .isConverting
                                                    .value &&
                                                formatController
                                                        .selectedFormat
                                                        .value ==
                                                    'jpg'
                                            ? SizedBox(
                                                width: 16,
                                                height: 16,
                                                child:
                                                    CircularProgressIndicator(
                                                      strokeWidth: 2,
                                                      color: Colors.white,
                                                    ),
                                              )
                                            : FaIcon(
                                                FontAwesomeIcons.image,
                                                size: 16,
                                              ),
                                        label: Text('Convert to JPG'),
                                        style: ElevatedButton.styleFrom(
                                          padding: const EdgeInsets.symmetric(
                                            vertical: 15,
                                          ),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: Container(
                                    margin: const EdgeInsets.only(left: 5),
                                    child: Obx(
                                      () => ElevatedButton.icon(
                                        onPressed:
                                            hasOriginalImages.value &&
                                                !formatController
                                                    .isConverting
                                                    .value
                                            ? () => formatController
                                                  .convertToFormat('png')
                                            : null,
                                        icon:
                                            formatController
                                                    .isConverting
                                                    .value &&
                                                formatController
                                                        .selectedFormat
                                                        .value ==
                                                    'png'
                                            ? SizedBox(
                                                width: 16,
                                                height: 16,
                                                child:
                                                    CircularProgressIndicator(
                                                      strokeWidth: 2,
                                                      color: Colors.white,
                                                    ),
                                              )
                                            : FaIcon(
                                                FontAwesomeIcons.solidImage,
                                                size: 16,
                                              ),
                                        label: Text('Convert to PNG'),
                                        style: ElevatedButton.styleFrom(
                                          padding: const EdgeInsets.symmetric(
                                            vertical: 15,
                                          ),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            // Second Row - WEBP and BMP
                            Row(
                              children: [
                                Expanded(
                                  child: Container(
                                    margin: const EdgeInsets.only(right: 5),
                                    child: Obx(
                                      () => ElevatedButton.icon(
                                        onPressed:
                                            hasOriginalImages.value &&
                                                !formatController
                                                    .isConverting
                                                    .value
                                            ? () => formatController
                                                  .convertToFormat('webp')
                                            : null,
                                        icon:
                                            formatController
                                                    .isConverting
                                                    .value &&
                                                formatController
                                                        .selectedFormat
                                                        .value ==
                                                    'webp'
                                            ? SizedBox(
                                                width: 16,
                                                height: 16,
                                                child:
                                                    CircularProgressIndicator(
                                                      strokeWidth: 2,
                                                      color: Colors.white,
                                                    ),
                                              )
                                            : FaIcon(
                                                FontAwesomeIcons.imagePortrait,
                                                size: 16,
                                              ),
                                        label: Text('Convert to WEBP'),
                                        style: ElevatedButton.styleFrom(
                                          padding: const EdgeInsets.symmetric(
                                            vertical: 15,
                                          ),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                // Convert to BMP Button
                                Expanded(
                                  child: Container(
                                    margin: const EdgeInsets.only(left: 5),
                                    child: Obx(
                                      () => ElevatedButton.icon(
                                        onPressed:
                                            hasOriginalImages.value &&
                                                !formatController
                                                    .isConverting
                                                    .value
                                            ? () => formatController
                                                  .convertToFormat('bmp')
                                            : null,
                                        icon:
                                            formatController
                                                    .isConverting
                                                    .value &&
                                                formatController
                                                        .selectedFormat
                                                        .value ==
                                                    'bmp'
                                            ? SizedBox(
                                                width: 16,
                                                height: 16,
                                                child:
                                                    CircularProgressIndicator(
                                                      strokeWidth: 2,
                                                      color: Colors.white,
                                                    ),
                                              )
                                            : FaIcon(
                                                FontAwesomeIcons.fileImage,
                                                size: 16,
                                              ),
                                        label: Text('Convert to BMP'),
                                        style: ElevatedButton.styleFrom(
                                          padding: const EdgeInsets.symmetric(
                                            vertical: 15,
                                          ),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                    Padding(
                      padding: EdgeInsets.only(top: 12),
                      child: Obx(() {
                        if (formatController.hasConvertedFiles.value &&
                            formatController.convertedFiles.isNotEmpty) {
                          return Container(
                            margin: const EdgeInsets.symmetric(horizontal: 20),
                            child: Column(
                              children: [
                                Row(
                                  mainAxisSize: MainAxisSize.max,
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    // Download All Converted Files Button
                                    Container(
                                      width: screenWeight / 2.5,
                                      margin: const EdgeInsets.only(bottom: 10),
                                      child: ElevatedButton.icon(
                                        onPressed: () =>
                                            formatController.downloadAllFiles(),
                                        icon: FaIcon(
                                          FontAwesomeIcons.download,
                                          size: 16,
                                        ),
                                        label: Text(
                                          'Download (${formatController.convertedFiles.length})',
                                        ),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.green,
                                          foregroundColor: Colors.white,
                                          padding: const EdgeInsets.symmetric(
                                            vertical: 15,
                                          ),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),

                                    Container(
                                      width: screenWeight / 2.5,
                                      margin: const EdgeInsets.only(bottom: 10),
                                      child: ElevatedButton.icon(
                                        onPressed: () =>
                                            formatController.shareAllFiles(),
                                        icon: FaIcon(
                                          FontAwesomeIcons
                                              .arrowUpRightFromSquare,
                                          size: 16,
                                        ),
                                        label: Text('Share All'),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Theme.of(
                                            context,
                                          ).colorScheme.primary,
                                          foregroundColor: Colors.white,
                                          padding: const EdgeInsets.symmetric(
                                            vertical: 15,
                                          ),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                // Individual Converted File Actions
                                if (formatController.convertedFiles.length >=
                                    1) ...[
                                  const SizedBox(height: 10),
                                  Text(
                                    'Converted Images',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.onBackground,
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  SizedBox(
                                    height: screenHeight / 5.5,
                                    child: ListView.builder(
                                      scrollDirection: Axis.horizontal,
                                      itemCount: formatController
                                          .convertedFiles
                                          .length,
                                      itemBuilder: (context, index) {
                                        final file = formatController
                                            .convertedFiles[index];
                                        final fileName = file.path
                                            .split('/')
                                            .last;
                                        final extension = fileName
                                            .split('.')
                                            .last
                                            .toUpperCase();

                                        return Container(
                                          width: 200,
                                          margin: const EdgeInsets.only(
                                            right: 10,
                                          ),
                                          padding: const EdgeInsets.only(
                                            top: 12,
                                            left: 6,
                                            right: 6
                                          ),
                                          decoration: BoxDecoration(
                                            color: Theme.of(
                                              context,
                                            ).colorScheme.onPrimary,
                                            border: Border.all(
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .outline
                                                  .withOpacity(0.4),
                                            ),
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
                                          ),
                                          child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Icon(
                                                _getFileTypeIcon(extension),
                                                size: 30,
                                                color: _getFileTypeColor(
                                                  extension,
                                                ),
                                              ),
                                              const SizedBox(height: 5),
                                              Text(
                                                fileName,
                                                style: TextStyle(fontSize: 10),
                                                overflow: TextOverflow.ellipsis,
                                                maxLines: 2,
                                                textAlign: TextAlign.center,
                                              ),
                                              const SizedBox(height: 5),
                                              // File format badge
                                              Container(
                                                padding: EdgeInsets.symmetric(
                                                  horizontal: 8,
                                                  vertical: 2,
                                                ),
                                                decoration: BoxDecoration(
                                                  color: _getFileTypeColor(
                                                    extension,
                                                  ).withOpacity(0.1),
                                                  borderRadius:
                                                      BorderRadius.circular(8),
                                                ),
                                                child: Text(
                                                  extension,
                                                  style: TextStyle(
                                                    fontSize: 8,
                                                    fontWeight: FontWeight.bold,
                                                    color: _getFileTypeColor(
                                                      extension,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceEvenly,
                                                children: [
                                                  IconButton(
                                                    onPressed: () =>
                                                        formatController
                                                            .downloadFile(file),
                                                    icon: FaIcon(
                                                      FontAwesomeIcons.download,
                                                      size: 18,
                                                    ),
                                                    tooltip: 'Download',
                                                  ),
                                                  IconButton(
                                                    onPressed: () =>
                                                        formatController
                                                            .shareFile(file),
                                                    icon: FaIcon(
                                                      FontAwesomeIcons
                                                          .arrowUpRightFromSquare,
                                                      size: 17,
                                                    ),
                                                    tooltip: 'Share',
                                                  ),
                                                  IconButton(
                                                    onPressed: () =>
                                                        _showDeleteConfirmation(
                                                          file,
                                                        ),
                                                    icon: FaIcon(
                                                      FontAwesomeIcons.trashCan,
                                                      size: 18,
                                                    ),
                                                    tooltip: 'Delete',
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          );
                        }
                        return SizedBox.shrink();
                      }),
                    ),

                    // if (hasOriginalImages.value && formatController.hasConvertedFiles.value)
                    //   Container(
                    //     width: double.infinity,
                    //     margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    //     child: ElevatedButton.icon(
                    //       onPressed: () => _showClearAllDialog(),
                    //       icon: Icon(Icons.clear_all, color: Colors.white),
                    //       label: Text('Clear All Files', style: TextStyle(color: Colors.white)),
                    //       style: ElevatedButton.styleFrom(
                    //         backgroundColor: Colors.red,
                    //         padding: const EdgeInsets.symmetric(vertical: 15),
                    //         shape: RoundedRectangleBorder(
                    //           borderRadius: BorderRadius.circular(12),
                    //         ),
                    //       ),
                    //     ),
                    //   ),
                  ],
                ),
              ],
            );
          }),
        ),
      ),
    );
  }

  IconData _getFileTypeIcon(String extension) {
    switch (extension.toLowerCase()) {
      case 'jpg':
      case 'jpeg':
        return Icons.image;
      case 'png':
        return Icons.image_outlined;
      case 'webp':
        return Icons.web_asset;
      case 'bmp':
        return Icons.image_aspect_ratio;
      default:
        return Icons.insert_drive_file;
    }
  }

  Color _getFileTypeColor(String extension) {
    switch (extension.toLowerCase()) {
      case 'jpg':
      case 'jpeg':
        return Colors.orange;
      case 'png':
        return Colors.blue;
      case 'webp':
        return Colors.green;
      case 'bmp':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }

  void _showDeleteConfirmation(File file) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Delete File'),
          content: Text('Are you sure you want to delete this file?'),
          actions: [
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Delete', style: TextStyle(color: Colors.red)),
              onPressed: () {
                Navigator.of(context).pop();
                formatController.removeFile(file);
              },
            ),
          ],
        );
      },
    );
  }

  void _showRemoveConfirmation(int index, CompressedImage file) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Remove Image'),
          content: Text('Are you sure you want to remove this image?'),
          actions: [
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Remove', style: TextStyle(color: Colors.red)),
              onPressed: () {
                Navigator.of(context).pop();
                formatController.removeConvertedImageAtIndex(index);
                imageController.removeCompressImage(file);
                imageController.removeOriginalImage(file);
              },
            ),
          ],
        );
      },
    );
  }

  void _showClearAllDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Clear All Files'),
          content: Text(
            'Are you sure you want to clear all converted files? This action cannot be undone.',
          ),
          actions: [
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Clear All', style: TextStyle(color: Colors.red)),
              onPressed: () {
                Navigator.of(context).pop();
                _clearAllFiles();
              },
            ),
          ],
        );
      },
    );
  }

  void _clearAllFiles() {
    formatController.clearConvertedFiles();
    imageController.clearOriginalList();
  }

  Widget _buildDropZone(
    BuildContext context,
    double containerHeight,
    ImageController imageController,
  ) {
    return GestureDetector(
      onTap: () {
        imageController.pickImageFromGallery();
        formatController.convertedFiles.clear();
      },
      child: Container(
        height: containerHeight,
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: Theme.of(context).colorScheme.primary.withOpacity(0.5),
            width: 2,
          ),
          color: isDarkMode
              ? Theme.of(context).colorScheme.surface
              : const Color(0xFFFBF9FF),
          boxShadow: [
            BoxShadow(
              color: Theme.of(context).colorScheme.primary.withOpacity(0.05),
              blurRadius: 20,
              offset: const Offset(0, 8),
              spreadRadius: 0,
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: DottedBorder(
            options: RoundedRectDottedBorderOptions(
              radius: Radius.circular(18),
              padding: EdgeInsets.all(1),
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
              dashPattern: [7, 6],
              strokeWidth: 1,
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Icon(
                  //   Icons.image_outlined,
                  //   size: 120,
                  //   color: Theme.of(context).colorScheme.primary,
                  // ),
                  FaIcon(
                    FontAwesomeIcons.image,
                    size: 120,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Click here to add Images',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onBackground,
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surface,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: Theme.of(
                          context,
                        ).colorScheme.outline.withOpacity(0.3),
                      ),
                    ),
                    child: Text(
                      'JPG, PNG, WEBP, BMP supported',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurface,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
  //endregion

  //region METHOD FOR DISPLAYING IMAGES CARDS - Same as PDF screen
  Widget _buildImageCarousel(
    List<CompressedImage> files,
    double containerHeight,
    RxBool hasOriginalImages,
  ) {
    final double height = MediaQuery.sizeOf(context).height;
    final double width = MediaQuery.sizeOf(context).width;
    final CarouselController controller = CarouselController(initialItem: 0);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Selected Images',
              style: TextStyle(
                color: Theme.of(context).colorScheme.onBackground,
                fontSize: 20,
                fontWeight: FontWeight.w700,
              ),
            ),
            Spacer(),
            InkWell(
              splashColor: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(16),
              onTap: () => _showClearAllDialog(),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Theme.of(
                    context,
                  ).colorScheme.secondary.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  // '${files.length} ${files.length == 1 ? 'image' : 'images'}',
                  'Remove all',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.secondary,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),

        // Images display
        SizedBox(
          height: MediaQuery.of(context).size.height * 0.35,
          width: double.infinity,
          child: Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(maxHeight: height / 2),
              child: CarouselView.weighted(
                enableSplash: false,
                controller: controller,
                itemSnapping: true,
                flexWeights: const [1, 7, 1],
                children: files.asMap().entries.map((entry) {
                  final int index = entry.key;
                  final CompressedImage file = entry.value;
                  return Stack(
                    alignment: Alignment.center,
                    children: [
                      SizedBox(
                        width: width * 7 / 8,
                        height: height / 2,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.file(
                            File(file.filePath),
                            fit: BoxFit.cover,
                            width: double.infinity,
                            height: double.infinity,
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: 10,
                        left: 10,
                        right: 10,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(20),
                          child: BackdropFilter(
                            filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 18,
                                vertical: 5,
                              ),
                              decoration: BoxDecoration(
                                color: Theme.of(
                                  context,
                                ).colorScheme.onPrimary.withOpacity(0.5),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceAround,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    GestureDetector(
                                      onTap: () =>
                                          _showRemoveConfirmation(index, file),
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 12,
                                          vertical: 8,
                                        ),
                                        decoration: BoxDecoration(
                                          color: Colors.red.withOpacity(0.7),
                                          borderRadius: BorderRadius.circular(
                                            15,
                                          ),
                                        ),
                                        child: Row(
                                          children: [
                                            FaIcon(
                                              FontAwesomeIcons.trashCan,
                                              size: 16,
                                              color: Colors.white,
                                            ),
                                            SizedBox(width: 5),
                                            Text(
                                              "Remove",
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    SizedBox(width: width / 21),
                                    GestureDetector(
                                      onTap: () {
                                        imageController.clearOriginalList();
                                        imageController.pickImageFromGallery();
                                        formatController.convertedFiles.clear();
                                      },
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 12,
                                          vertical: 8,
                                        ),
                                        decoration: BoxDecoration(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .primary
                                              .withOpacity(0.7),
                                          borderRadius: BorderRadius.circular(
                                            15,
                                          ),
                                        ),
                                        child: Row(
                                          children: [
                                            FaIcon(
                                              FontAwesomeIcons.pen,
                                              size: 15,
                                              color: Colors.white,
                                            ),
                                            SizedBox(width: 5),
                                            Text(
                                              "Edit  ",
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                }).toList(),
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),

        // Tap to add more hint
        Center(
          child: Text(
            'Tap on images to add more',
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }
  //endregion

  //region METHOD FOR DISPLAYING INSTRUCTIONS
  Widget _buildInstructions(BuildContext context) {
    return Center(
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
          ),
        ),
        child: Column(
          children: [
            Icon(
              Icons.info_outline,
              color: Theme.of(context).colorScheme.primary,
              size: 24,
            ),
            const SizedBox(height: 6),
            Text(
              'How it works',
              style: TextStyle(
                color: Theme.of(context).colorScheme.onBackground,
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              '1. Select or drop your images\n'
              '2. Choose format (JPG, PNG, WEBP, BMP)\n'
              '3. Get converted images instantly',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurface,
                fontSize: 14,
                fontWeight: FontWeight.w500,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  //endregion
}
