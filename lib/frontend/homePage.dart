import 'dart:io';
import 'dart:ui';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter_card_swiper/flutter_card_swiper.dart';
import 'package:get/get.dart';
import 'package:image_compressor/controllers/compressImageController.dart';
import 'package:image_compressor/controllers/themeController.dart';

class Homepage extends StatefulWidget {
  const Homepage({super.key});

  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> with TickerProviderStateMixin {
  bool isDarkMode = true;

  late AnimationController _pulseController;
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;
  late final AnimationController _borderController;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();

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
  ThemeController themeController = Get.find<ThemeController>();
  RxDouble _currentSliderValue = (100.0).obs;

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
    final containerHeight = screenHeight * 0.40;
    isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,

      //region APP BAR
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(65),
        child: ClipRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
            child: AppBar(
              backgroundColor: Theme.of(
                context,
              ).colorScheme.surface.withOpacity(0.8),
              elevation: 0,
              centerTitle: false,
              title: Padding(
                padding: const EdgeInsets.only(top: 10),
                child: Row(
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primary,
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: [
                          BoxShadow(
                            color: Theme.of(
                              context,
                            ).colorScheme.primary.withOpacity(0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.compress,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Compressor',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onBackground,
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.5,
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                Padding(
                  padding: const EdgeInsets.only(top: 10, right: 16),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Theme.of(
                        context,
                      ).colorScheme.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Obx(
                      () => IconButton(
                        onPressed: () {
                          themeController.toggleTheme();
                        },
                        icon: Icon(
                          themeController.isDarkMode
                              ? Icons.wb_sunny_rounded
                              : Icons.nightlight_round,
                          key: ValueKey(themeController.isDarkMode),
                          color: Theme.of(context).colorScheme.primary,
                          size: 20,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),

      //endregion
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Obx(() {
              RxBool hasOriginalImages = imageController
                  .getOriginalList()
                  .isNotEmpty
                  .obs;
              RxBool hasCompressedImages = imageController
                  .getCompressList()
                  .isNotEmpty
                  .obs;

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 10),
                  //////////////////////////////////////////////////////////////Enable this for Header///////
                  // if (!hasOriginalImages.value) ...[
                  //   _buildHeader(context),
                  //   const SizedBox(height: 30),
                  // ],
                  // ],
                  //////////////////////////////////////////////////////////////////////

                  // Image Display Section
                  if (hasCompressedImages.value)
                    _buildImageCarousel(
                      imageController.getCompressList(),
                      containerHeight,
                      hasCompressedImages,
                    )
                  else if (hasOriginalImages.value)
                    _buildImageCarousel(
                      imageController.getOriginalList(),
                      containerHeight,
                      hasCompressedImages,
                    )
                  else
                    _buildDropZone(context, containerHeight, imageController),

                  // TabView Section - Show when images are selected
                  if (hasOriginalImages.value) ...[
                    const SizedBox(height: 10),
                    Expanded(child: _buildTabView(context, imageController)),
                  ],

                  // Instructions when no images
                  if (!hasOriginalImages.value) ...[
                    const SizedBox(height: 30),
                    _buildInstructions(context),
                  ],
                ],
              );
            }),
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomNavigationBar(context),
    );
  }

  //region WIDGET FOR TAB BAR
  Widget _buildTabView(BuildContext context, ImageController imageController) {
    return Column(
      children: [
        // Tab Bar
        Container(
            height: 52,
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: Theme.of(context).colorScheme.secondary.withOpacity(0.1),
                )
              ),
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.only(
                topRight: Radius.circular(12),
                topLeft: Radius.circular(12),
              ),
            ),
            child: TabBar(
              indicatorWeight: 0,
              padding: EdgeInsets.all(0),
              indicatorPadding: EdgeInsets.all(0),
              dividerHeight: 0,
              controller: _tabController,
              indicator: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: Theme.of(context).colorScheme.primary.withOpacity(0.2),
                border: Border.all(
                  color: Theme.of(context).colorScheme.primary.withOpacity(0.2),
                  width: 1,
                ),
              ),
              indicatorSize: TabBarIndicatorSize.tab,
              labelColor:Theme.of(context).colorScheme.onBackground,
              unselectedLabelColor: Theme.of(context).colorScheme.onBackground.withOpacity(0.6),
              labelStyle: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
              unselectedLabelStyle: const TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 14,
              ),
              tabs: const [
                Tab(icon: Icon(Icons.compress, size: 18), text: 'Compress'),
                Tab(icon: Icon(Icons.tune, size: 18), text: 'Advanced'),
              ],
            ),
          ),
        // Tab Content
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              _buildCompressTab(context, imageController),
              _buildAdvancedTab(context),
            ],
          ),
        ),
      ],
    );
  }
  //endregion


  //region  WIDGET FOR COMPRESS TAB
  Widget _buildCompressTab(
      BuildContext context,
      ImageController imageController,
      ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.only(
          bottomRight: Radius.circular(16),
          bottomLeft: Radius.circular(16),
        ),
      ),
      child: Obx(() {
        bool allCompressed = imageController.shouldDisableCompressionButtons();
        bool hasCompressedImages = imageController.getCompressList().isNotEmpty;
        Map<String, int> status = imageController.getCompressionStatus();

        return SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Status header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Choose Compression Size',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onBackground,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  if (status['total']! > 0)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: allCompressed
                            ? Colors.green.withOpacity(0.1)
                            : Theme.of(context).colorScheme.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: allCompressed
                              ? Colors.green.withOpacity(0.3)
                              : Theme.of(context).colorScheme.primary.withOpacity(0.3),
                        ),
                      ),
                      child: Text(
                        allCompressed
                            ? 'All Compressed ✓'
                            : '${status['uncompressed']}/${status['total']} pending',
                        style: TextStyle(
                          color: allCompressed
                              ? Colors.green
                              : Theme.of(context).colorScheme.primary,
                          fontSize: 8,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                ],
              ),
          
              const SizedBox(height: 16),
          
              // Compression buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildCompressionButton(
                    context,
                    '100 KB',
                    Icons.compress,
                    allCompressed ? null : () {
                      imageController.compressToTargetSize(100);
                      // imageController.clearOriginalList();
                      },
                    isDisabled: allCompressed,
                  ),
                  _buildCompressionButton(
                    context,
                    '200 KB',
                    Icons.compress,
                    allCompressed ? null : () => imageController.compressToTargetSize(200),
                    isDisabled: allCompressed,
                  ),
                  _buildCompressionButton(
                    context,
                    '500 KB',
                    Icons.compress,
                    allCompressed ? null : () => imageController.compressToTargetSize(500),
                    isDisabled: allCompressed,
                  ),
                  _buildCompressionButton(
                    context,
                    'Custom',
                    Icons.edit,
                    allCompressed ? null : () => _showCustomSizeDialog(context),
                    isDisabled: allCompressed,
                  ),
          
                ],
              ),
              const SizedBox(height: 12),
          
              // Download section
              Row(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: hasCompressedImages ? () => imageController.downloadImages() : null,
                      child: Container(
                        padding: const EdgeInsets.all(7),
                        decoration: BoxDecoration(
                          color: hasCompressedImages
                              ? Theme.of(context).colorScheme.primary.withOpacity(0.1)
                              : Theme.of(context).colorScheme.surface,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: hasCompressedImages
                                ? Theme.of(context).colorScheme.primary.withOpacity(0.3)
                                : Theme.of(context).colorScheme.outline.withOpacity(0.3),
                          ),
                        ),
                        child: Column(
                          children: [
                            Icon(
                              Icons.save_alt_rounded,
                              color: hasCompressedImages
                                  ? Theme.of(context).colorScheme.primary
                                  : Theme.of(context).colorScheme.outline.withOpacity(0.5),
                              size: 20,
                            ),
                            Text(
                              'Download',
                              style: TextStyle(
                                color: hasCompressedImages
                                    ? Theme.of(context).colorScheme.primary
                                    : Theme.of(context).colorScheme.outline.withOpacity(0.5),
                                fontWeight: FontWeight.w500,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: GestureDetector(
                      onTap: hasCompressedImages ? () {
                        imageController.shareImages(
                          imageController.getCompressList(),
                        );
                      } : null,
                      child: Container(
                        padding: const EdgeInsets.all(7),
                        decoration: BoxDecoration(
                          color: hasCompressedImages
                              ? Theme.of(context).colorScheme.secondary.withOpacity(0.9)
                              : Theme.of(context).colorScheme.surface,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: hasCompressedImages
                                ? Theme.of(context).colorScheme.secondary.withOpacity(0.9)
                                : Theme.of(context).colorScheme.outline.withOpacity(0.3),
                          ),
                        ),
                        child: Column(
                          children: [
                            Icon(
                              Icons.share_rounded,
                              color: hasCompressedImages
                                  ? Theme.of(context).colorScheme.onBackground
                                  : Theme.of(context).colorScheme.outline.withOpacity(0.5),
                              size: 20,
                            ),
                            Text(
                              'Share',
                              style: TextStyle(
                                color: hasCompressedImages
                                    ? Theme.of(context).colorScheme.onBackground
                                    : Theme.of(context).colorScheme.outline.withOpacity(0.5),
                                fontWeight: FontWeight.w500,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      }),
    );
  }
  //endregion

  //region METHOD FOR CUSTOM DILOG
  void _showCustomSizeDialog(BuildContext context) {
    final TextEditingController sizeController = TextEditingController();
    final GlobalKey<FormState> formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Custom Compression Size'),
          content: SingleChildScrollView(
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Enter the target size for image compression:'),
                  const SizedBox(height: 16),
                  TextFormField(
                    
                    controller: sizeController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Target Size (KB)',
                      border: OutlineInputBorder(),
                      hintText: 'e.g., 1000',
                      suffixText: 'KB',
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter a size';
                      }
                      final int? size = int.tryParse(value.trim());
                      if (size == null || size <= 0) {
                        return 'Please enter a valid positive number';
                      }
                      return null;
                    },
                    autofocus: true,
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                if (formKey.currentState!.validate()) {
                  final int targetSize = int.parse(sizeController.text.trim());
                  Navigator.of(context).pop();
                  imageController.compressToTargetSize(targetSize);
                }
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }
  //endregion


  //region WIDGET FOR COMPRESSION BUTTON
  Widget _buildCompressionButton(
      BuildContext context,
      String label,
      IconData icon,
      VoidCallback? onTap, {
        bool isDisabled = false,
      }) {
    return GestureDetector(
      onTap: isDisabled ? null : onTap,
      child: Container(
        height: 55,
        width: 70,
        decoration: BoxDecoration(
          color: isDisabled
              ? Theme.of(context).colorScheme.surface
              : Theme.of(context).colorScheme.primary,
          borderRadius: BorderRadius.circular(10),
          border: isDisabled
              ? Border.all(
            color: Theme.of(context).colorScheme.outline.withOpacity(0.3),
          )
              : null,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: isDisabled
                  ? Theme.of(context).colorScheme.outline.withOpacity(0.5)
                  : Colors.white,
              size: 20,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: isDisabled
                    ? Theme.of(context).colorScheme.outline.withOpacity(0.5)
                    : Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
  //endregion

  //region WIDGET FOR ADVANCE TAB
  Widget _buildAdvancedTab(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(16),
          bottomRight: Radius.circular(16),
        ),
      ),
      child: Obx(() {
        // Move all reactive variables to the single Obx scope
        bool allCompressed = imageController.shouldDisableCompressionButtons();
        bool hasCompressedImages = imageController.getCompressList().isNotEmpty;
        Map<String, int> status = imageController.getCompressionStatus();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Choose Compression Quality',
              style: TextStyle(
                color: Theme.of(context).colorScheme.onBackground,
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("${_currentSliderValue.value.toStringAsFixed(0)}%",style: TextStyle(fontSize: 14,fontWeight: FontWeight.w500),),
                Expanded(
                  child: Slider(
                    activeColor: Theme.of(context).colorScheme.primary,
                    year2023: false,
                    label: _currentSliderValue.value.toString(),
                    allowedInteraction: SliderInteraction.slideThumb,
                    // Removed deprecated year2023 property
                    max: 100,
                    min: 0,
                    divisions: 10,
                    inactiveColor: Theme.of(context).colorScheme.primary.withOpacity(0.2),
                    thumbColor: Theme.of(context).colorScheme.primary,
                    value: _currentSliderValue.value,
                    onChanged: (value) {
                      _currentSliderValue.value = value;
                    },
                  ),
                ),
              ],
            ),
            SizedBox(height: 8,),
            GestureDetector(
              onTap: () {
                imageController.compressToTargetQuality(_currentSliderValue.value.toInt());
              },
              child: Center(
                child: Container(
                  height: 40,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color:Theme.of(context).colorScheme.primary,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.compress,
                        color: Colors.white,
                        size: 20,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Compress',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12), // Added spacing
            Row(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                GestureDetector(
                  onTap: hasCompressedImages ? () => imageController.downloadImages() : null,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 25,vertical: 4),
                    decoration: BoxDecoration(
                      color: hasCompressedImages
                          ? Theme.of(context).colorScheme.primary.withOpacity(0.1)
                          : Theme.of(context).colorScheme.surface,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: hasCompressedImages
                            ? Theme.of(context).colorScheme.primary.withOpacity(0.3)
                            : Theme.of(context).colorScheme.outline.withOpacity(0.3),
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.save_alt_rounded,
                          color: hasCompressedImages
                              ? Theme.of(context).colorScheme.primary
                              : Theme.of(context).colorScheme.outline.withOpacity(0.5),
                          size: 20,
                        ),
                        Text(
                          'Download',
                          style: TextStyle(
                            color: hasCompressedImages
                                ? Theme.of(context).colorScheme.primary
                                : Theme.of(context).colorScheme.outline.withOpacity(0.5),
                            fontWeight: FontWeight.w500,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: hasCompressedImages ? () {
                    imageController.shareImages(
                      imageController.getCompressList(),
                    );
                  } : null,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 37,vertical: 4),
                    decoration: BoxDecoration(
                      color: hasCompressedImages
                          ? Theme.of(context).colorScheme.primary.withOpacity(0.1)
                          : Theme.of(context).colorScheme.surface,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: hasCompressedImages
                            ? Theme.of(context).colorScheme.primary.withOpacity(0.3)
                            : Theme.of(context).colorScheme.outline.withOpacity(0.3),
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.share_rounded,
                          color: hasCompressedImages
                              ? Theme.of(context).colorScheme.primary
                              : Theme.of(context).colorScheme.outline.withOpacity(0.5),
                          size: 20,
                        ),
                        Text(
                          'Share',
                          style: TextStyle(
                            color: hasCompressedImages
                                ? Theme.of(context).colorScheme.primary
                                : Theme.of(context).colorScheme.outline.withOpacity(0.5),
                            fontWeight: FontWeight.w500,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        );
      }),
    );
  }
  //endregion


  ///////////////////////////////////////////////enable this region for Header/////////////////////
  //region METHOD FOR HEADING
  // Widget _buildHeader(BuildContext context) {
  //   return Column(
  //     crossAxisAlignment: CrossAxisAlignment.start,
  //     children: [
  //       RichText(
  //         text: TextSpan(
  //           children: [
  //             TextSpan(
  //               text: "Compress ",
  //               style: TextStyle(
  //                 color: Theme.of(context).colorScheme.onBackground,
  //                 fontSize: 32,
  //                 fontWeight: FontWeight.w800,
  //                 letterSpacing: -1,
  //               ),
  //             ),
  //             TextSpan(
  //               text: "Smart",
  //               style: TextStyle(
  //                 color: Theme.of(context).colorScheme.primary,
  //                 fontSize: 32,
  //                 fontWeight: FontWeight.w800,
  //                 letterSpacing: -1,
  //               ),
  //             ),
  //           ],
  //         ),
  //       ),
  //       const SizedBox(height: 8),
  //       Text(
  //         'Reduce image size without losing quality',
  //         style: TextStyle(
  //           color: Theme.of(context).colorScheme.onSurface,
  //           fontSize: 12,
  //           fontWeight: FontWeight.w500,
  //         ),
  //       ),
  //     ],
  //   );
  // }
  //endregion

  //region METHOD FOR MAIN DROPPING CONTAINER
  Widget _buildDropZone(
    BuildContext context,
    double containerHeight,
    ImageController imageController,
  ) {
    return GestureDetector(
      onTap: () => imageController.pickImageFromGallery(),
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
                  Container(
                    child: isDarkMode
                        ? Image.asset(
                            'assets/darkAddFileAnimation.gif',
                            width: 210,
                          )
                        : Image.asset(
                            'assets/addFileAnimation.gif',
                            width: 210,
                          ),
                  ),
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
        Container(
          height: MediaQuery.of(context).size.height * 0.35,
          width: double.infinity,
          child: files.length == 1
              ? GestureDetector(
                  onTap: () =>
                      Get.find<ImageController>().pickImageFromGallery(),
                  child: Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.15),
                          blurRadius: 15,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: Stack(
                        children: [
                          Image.file(
                            File(files[0].filePath),
                            fit: BoxFit.cover,
                            width: double.infinity,
                            height: double.infinity,
                          ),
                          SizedBox(
                            child: IconButton(
                              onPressed: () {
                                imageController.removeCompressImage(files[0]);
                                imageController.removeOriginalImage(files[0]);
                              },
                              icon: Icon(
                                Icons.cancel_sharp,
                                size: 20,
                                color: Colors.black,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                )
              : CardSwiper(
                  cardsCount: files.length,
                  maxAngle: 30,
                  numberOfCardsDisplayed: files.length >= 3 ? 3 : files.length,
                  scale: 0.85,
                  cardBuilder:
                      (context, index, percentThresholdX, percentThresholdY) {
                        return Stack(
                          children: [
                            GestureDetector(
                              onTap: () => Get.find<ImageController>()
                                  .pickImageFromGallery(),
                              child: Container(
                                margin: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(20),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.15),
                                      blurRadius: 15,
                                      offset: const Offset(0, 5),
                                    ),
                                  ],
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(20),
                                  child: Image.file(
                                    File(files[index].filePath),
                                    fit: BoxFit.cover,
                                    width: double.infinity,
                                    height: double.infinity,
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(
                              child: IconButton(
                                onPressed: () {
                                  imageController.removeCompressImage(
                                    files[index],
                                  );
                                  imageController.removeOriginalImage(
                                    files[index],
                                  );
                                },
                                icon: Icon(
                                  Icons.cancel_sharp,
                                  size: 20,
                                  color: Colors.black,
                                ),
                              ),
                            ),
                          ],
                        );
                      },
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
              '2. Choose compression settings\n'
              '3. Get optimized images instantly',
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

  //region METHOD FOR DISPLAYING BOTTOM NAVIGATION BAR
  Widget _buildBottomNavigationBar(BuildContext context) {
    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaY: 15, sigmaX: 15),
        child: Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface.withOpacity(0.8),
            border: Border(
              top: BorderSide(
                color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
                width: 1,
              ),
            ),
          ),
          child: BottomNavigationBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            type: BottomNavigationBarType.fixed,
            selectedItemColor: Theme.of(context).colorScheme.primary,
            unselectedItemColor: Theme.of(context).colorScheme.onSurface,
            selectedLabelStyle: const TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 12,
            ),
            unselectedLabelStyle: const TextStyle(
              fontWeight: FontWeight.w500,
              fontSize: 12,
            ),
            onTap: (value) {
              // Handle navigation
            },
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.home_rounded),
                label: 'Home',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.history_rounded),
                label: 'History',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.tune_rounded),
                label: 'Settings',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.person_rounded),
                label: 'Profile',
              ),
            ],
          ),
        ),
      ),
    );
  }
  //endregion
}

