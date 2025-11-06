import 'dart:io';
import 'dart:ui';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter_card_swiper/flutter_card_swiper.dart';
import 'package:get/get.dart';
import 'package:image_compressor/controllers/compressImageController.dart';
import 'package:image_compressor/controllers/pdf_view_controller.dart';
import 'package:image_compressor/models/compressImageModel.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../adMob/bannerAdWidget.dart';


class PdfScreen extends StatefulWidget {
  const PdfScreen({super.key});

  @override
  State<PdfScreen> createState() => _PdfScreenState();
}

class _PdfScreenState extends State<PdfScreen> with TickerProviderStateMixin {
  bool isDarkMode = true;

  final List<CompressedImage> images = [];

  late AnimationController _pulseController;
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;
  late final AnimationController _borderController;
  late TabController _tabController;
  
  late PdfController pdfController;

  @override
  void initState() {
    super.initState();

    pdfController = Get.put(PdfController());

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
  RxDouble _currentSliderValue = (100.0).obs;

  @override
  void dispose() {
    _borderController.dispose();
    _pulseController.dispose();
    _fadeController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  void clearImage(CompressedImage file){
    imageController.removeCompressImage(file);
    pdfController.removePdf(imageController.getOriginalList().indexOf(file));
    imageController.removeOriginalImage(file);
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWeght = MediaQuery.of(context).size.width;
    final containerHeight = screenHeight * 0.40;
    isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return SafeArea(
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          child: Obx(() {
            RxBool hasOriginalImages = imageController.getOriginalList().isNotEmpty.obs;

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 10),

                // // Image Display Section
                // if (pdfController.hasPdf.value)
                //   _buildImageCarousel(imageController.getOriginalList(), containerHeight, pdfController.hasPdf)
                if (hasOriginalImages.value)
                  _buildImageCarousel(
                    imageController.getOriginalList(),
                    containerHeight,
                    hasOriginalImages,
                  )
                else
                  _buildDropZone(context, containerHeight, imageController),

                // Instructions when no images
                if (!hasOriginalImages.value) ...[
                  const SizedBox(height: 30),
                  _buildInstructions(context),
                ],
                Column(
                  children: [
                    // Convert to PDF Button
                   if(hasOriginalImages.value && !pdfController.pdfFiles.isNotEmpty) Container(
                     width: double.infinity,
                     margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                     child: ElevatedButton.icon(
                       onPressed: hasOriginalImages.value
                           ? () => pdfController.generatePdf()
                           : null,
                       icon: Icon(Icons.picture_as_pdf),
                       label: Text('Convert to PDF'),
                       style: ElevatedButton.styleFrom(
                         padding: const EdgeInsets.symmetric(vertical: 15),
                         shape: RoundedRectangleBorder(
                           borderRadius: BorderRadius.circular(12),
                         ),
                       ),
                     ),
                   ),

                    // Download Buttons (only shows when PDFs are generated)
                    Padding(
                      padding: EdgeInsets.only(top: 12),
                      child: Obx(() {
                        if (pdfController.hasPdf.value && pdfController.pdfFiles.isNotEmpty && imageController.getOriginalList().isNotEmpty) {
                          return Container(
                            margin: const EdgeInsets.symmetric(horizontal: 20),
                            child: Column(
                              children: [
                               Row(
                                 mainAxisSize: MainAxisSize.max,
                                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                 children: [
                                   // Download All PDFs Button
                                   Container(
                                     width: screenWeght / 2.5,
                                     margin: const EdgeInsets.only(bottom: 10),
                                     child: Obx(() => ElevatedButton.icon(
                                       onPressed: pdfController.isDownloading.value
                                           ? null
                                           : () => pdfController.downloadAllPdfs(),
                                       icon: pdfController.isDownloading.value
                                           ? SizedBox(
                                         width: 20,
                                         height: 20,
                                         child: CircularProgressIndicator(strokeWidth: 2),
                                       )
                                           : Icon(Icons.download),
                                       label: Text(
                                           pdfController.isDownloading.value
                                               ? 'Downloading...'
                                               : 'Download (${pdfController.pdfFiles.length})'
                                       ),
                                       style: ElevatedButton.styleFrom(
                                         backgroundColor: Colors.green,
                                         foregroundColor: Colors.white,
                                         padding: const EdgeInsets.symmetric(vertical: 15),
                                         shape: RoundedRectangleBorder(
                                           borderRadius: BorderRadius.circular(12),
                                         ),
                                       ),
                                     )),
                                   ),

                                   // Share All PDFs Button
                                   Container(
                                     width: screenWeght / 2.5,
                                     margin: const EdgeInsets.only(bottom: 10),
                                     child: ElevatedButton.icon(
                                       onPressed: () => pdfController.shareAllPdfs(),
                                       icon: Icon(Icons.share),
                                       label: Text('Share All PDFs'),
                                       style: ElevatedButton.styleFrom(
                                         backgroundColor: Theme.of(context).colorScheme.primary,
                                         foregroundColor: Colors.white,
                                         padding: const EdgeInsets.symmetric(vertical: 15),
                                         shape: RoundedRectangleBorder(
                                           borderRadius: BorderRadius.circular(12),
                                         ),
                                       ),
                                     ),
                                   ),
                                 ],
                               ),

                                // Individual PDF Actions
                                if (pdfController.pdfFiles.length >= 1) ...[
                                  const SizedBox(height: 10),
                                  Text(
                                    'Individual PDF Actions',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: Theme.of(context).colorScheme.onBackground,
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  SizedBox(
                                    height: screenHeight / 5.5,
                                    child: ListView.builder(
                                      scrollDirection: Axis.horizontal,
                                      itemCount: pdfController.pdfFiles.length,
                                      itemBuilder: (context, index) {
                                        final pdfFile = pdfController.pdfFiles[index];
                                        final fileName = pdfFile.path.split('/').last;
                                    
                                        return Container(
                                          width: 200,
                                          margin: const EdgeInsets.only(right: 10),
                                          padding: const EdgeInsets.only(top: 12),
                                          decoration: BoxDecoration(
                                            color: Theme.of(context).colorScheme.onPrimary,
                                            border: Border.all(
                                              color: Theme.of(context).colorScheme.outline.withOpacity(0.4),
                                            ),
                                            borderRadius: BorderRadius.circular(12),
                                          ),
                                          child: Column(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: [
                                              Icon(
                                                Icons.picture_as_pdf,
                                                size: 30,
                                                color: Colors.red,
                                              ),
                                              const SizedBox(height: 5),
                                              Text(
                                                fileName,
                                                style: TextStyle(fontSize: 10),
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                              const SizedBox(height: 10),
                                              Row(
                                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                                children: [
                                                  IconButton(
                                                    onPressed: () => pdfController.downloadPdf(pdfFile),
                                                    icon: Icon(Icons.download, size: 20),
                                                    tooltip: 'Download',
                                                  ),
                                                  IconButton(
                                                    onPressed: () => pdfController.sharePdf(pdfFile),
                                                    icon: Icon(Icons.share, size: 20),
                                                    tooltip: 'Share',
                                                  ),
                                                  IconButton(
                                                    onPressed: (){
                                                      
                                                      final originals = imageController.getOriginalList();
                                                      if (index >= 0 && index < originals.length) {
                                                        clearImage(originals[index]);
                                                      } else {
                                                        
                                                        pdfController.removePdf(index);
                                                      }
                                                    },
                                                    icon: Icon(Icons.delete, size: 20, color: Colors.red),
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
                                if (pdfController.pdfFiles.length < 1) ...[
                                  Spacer(),
                                  Center(
                                      child: BannerAdWidget(adUnitId: "ca-app-pub-3940256099942544/6300978111")
                                  ),
                                ]
                              ],
                            ),
                          );
                        }
                        return SizedBox.shrink();
                      }),
                    ),
                  ],
                ),
              ],
            );
          }),
        ),
      ),
    );
  }

  //region METHOD FOR MAIN DROPPING CONTAINER
  Widget _buildDropZone(
      BuildContext context,
      double containerHeight,
      ImageController imageController,
      ) {
    return GestureDetector(
      onTap: () {
        imageController.pickImageFromGallery();
        pdfController.pdfFiles.clear();
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
          color: isDarkMode ? Theme.of(context).colorScheme.surface : const Color(0xFFFBF9FF),
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
            animation: _borderController,
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
                mainAxisSize: MainAxisSize.max,
                children: [
                  Image.asset('assets/pdf_screen/pdf_icon_1.png',height: 120,color: Theme.of(context).colorScheme.primary,),
                  const SizedBox(height: 10),
                  Text(
                    'Click here to add Image',
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
                      'JPG, PNG, WEBP supported',
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



  //region METHOD FOR DISPLAYING IMAGES CARDS
  Widget _buildImageCarousel(
      List<dynamic> files,
      double containerHeight,
      RxBool hasCompressImage,
      ) {

    final double height = MediaQuery.sizeOf(context).height;
    final double width = MediaQuery.sizeOf(context).width;
    final CarouselController controller = CarouselController(initialItem: 2);
    int currentIndex = 0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header with image count
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
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.secondary.withOpacity(0.2),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                  '${files.length} ${files.length == 1 ? 'image' : 'images'}',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.secondary,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
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
                    flexWeights: const <int>[1, 7, 1],
                    children: files.map((file) {
                      currentIndex = controller.initialItem;
                      return Stack(
                        alignment: Alignment.center,
                        children: [
                          // Image Display
                          SizedBox(
                            width: width * 7 / 8,
                            height: height / 2,
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(1),
                              // clipBehavior: Clip.antiAlias,
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
                                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 5),
                                  decoration: BoxDecoration(
                                    color: Theme.of(context).colorScheme.onPrimary.withOpacity(0.5), // Slightly more transparent
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: SingleChildScrollView(
                                    scrollDirection: Axis.horizontal,
                                    child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      GestureDetector(
                                        onTap: () {
                                          clearImage(file);
                                        },
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                          decoration: BoxDecoration(
                                            color: Colors.red.withOpacity(0.7),
                                            borderRadius: BorderRadius.circular(15),
                                          ),
                                          child: Row(
                                            children: [
                                              Icon(
                                                Icons.delete_outline,
                                                size: 20,
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
                                      SizedBox(width: width / 21,),
                                      GestureDetector(
                                        onTap: () {
                                          imageController.clearOriginalList();
                                          imageController.pickImageFromGallery();
                                          pdfController.pdfFiles.clear();
                                        },
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                          decoration: BoxDecoration(
                                            color: Theme.of(context).colorScheme.primary.withOpacity(0.7), // Theme color
                                            borderRadius: BorderRadius.circular(15),
                                          ),
                                          child: Row(
                                            children: [
                                              Icon(
                                                Icons.edit_outlined, // Changed icon
                                                size: 20,
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
                )
            )
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
                  '2. Click on convert to PDF button\n'
                  '3. Get PDF instantly',
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

