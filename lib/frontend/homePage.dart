import 'dart:io';
import 'dart:ui';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter_card_swiper/flutter_card_swiper.dart';
import 'package:get/get.dart';
import 'package:image_compressor/controllers/compressImageController.dart';
import 'package:image_compressor/controllers/themeController.dart';
import 'package:image_compressor/models/compressImageModel.dart';

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

  //region METHOD FOR TAB VIEW
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

  // Compress Tab Content
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Choose Compression Size',
            style: TextStyle(
              color: Theme.of(context).colorScheme.onBackground,
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
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
                () => imageController.compressToTargetSize(100),
              ),
              _buildCompressionButton(
                context,
                '200 KB',
                Icons.compress,
                () => imageController.compressToTargetSize(200),
              ),
              _buildCompressionButton(
                context,
                '500 KB',
                Icons.compress,
                () => imageController.compressToTargetSize(500),
              ),
              _buildCompressionButton(
                context,
                '1 MB',
                Icons.compress,
                () => imageController.compressToTargetSize(1000),
              ),
            ],
          ),

          const SizedBox(height: 10),

          // Custom compression option
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(5),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Theme.of(
                  context,
                ).colorScheme.primary.withOpacity(0.3),
              ),
            ),
            child: Column(
              children: [
                Icon(
                  Icons.download_sharp,
                  color: Theme.of(context).colorScheme.primary,
                  size: 20,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Advanced Tab Content
  Widget _buildAdvancedTab(BuildContext context) {
    return Stack(
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(16),
              bottomRight: Radius.circular(16),
            ),
            border: BoxBorder.fromLTRB(
              left: BorderSide(
                color: Theme.of(context).colorScheme.primary.withOpacity(0.5),
                width: 1,
              ),
              bottom: BorderSide(
                color: Theme.of(context).colorScheme.primary.withOpacity(0.5),
                width: 1,
              ),
              right: BorderSide(
                color: Theme.of(context).colorScheme.primary.withOpacity(0.5),
                width: 1,
              ),
            ),
          ),
          child: Column(
            children: [
              Icon(
                Icons.construction,
                color: Theme.of(context).colorScheme.primary,
                size: 48,
              ),
              const SizedBox(height: 16),
              Text(
                'Advanced Settings',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onBackground,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Coming Soon',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurface,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
        Positioned(
          top: 0,
          left: 0,
          child: Container(
            height: 1,
            width: MediaQuery.of(context).size.width / 2 - 15,
            color: Theme.of(context).colorScheme.primary.withOpacity(0.5),
          ),
        ),
      ],
    );
  }

  // Helper method for compression buttons
  Widget _buildCompressionButton(
    BuildContext context,
    String label,
    IconData icon,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 55,
        width: 70,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primary,
          borderRadius: BorderRadius.circular(10),

        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white, size: 20),
            const SizedBox(height: 4),
            Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
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

            SizedBox(width: 5),

            if (hasCompressImage.value)
              GestureDetector(
                onTap: () {
                  imageController.shareImages(
                    imageController.getCompressList(),
                  );
                },
                child: Container(
                  height: 30,
                  width: 30,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.onBackground,
                    borderRadius: BorderRadius.all(Radius.circular(25)),
                  ),
                  child: Center(
                    child: Icon(
                      Icons.share,
                      size: 20,
                      color: Theme.of(context).colorScheme.primary,
                    ),
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
