import 'dart:io';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_card_swiper/flutter_card_swiper.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:image_compressor/controllers/compressImageController.dart';
import 'package:image_compressor/models/compressImageModel.dart';

//Don't you dare to ignore Add this before converting String to File

// if (await File(path).exists()) {
// File file = File(path);
// }

class Homepage extends StatelessWidget {
  const Homepage({super.key});

  @override
  Widget build(BuildContext context) {

    final screenHeight = MediaQuery.of(context).size.height;
    final containerHeight = screenHeight * 0.6;

    ImageController imageController = Get.put(ImageController());

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(70),
        child: ClipRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
            child: AppBar(
              backgroundColor: Theme.of(
                context,
              ).colorScheme.surface.withOpacity(0.6),
              elevation: 0,
              centerTitle: false,
              title: Padding(
                padding: EdgeInsets.only(top: 10),
                child: Row(
                  children: [
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Theme.of(context).colorScheme.primary,
                            Theme.of(context).colorScheme.secondary,
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.compress,
                        color: Colors.white,
                        size: 18,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Compressor',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onBackground,
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.5,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
      // body: Column(
      //   mainAxisSize: MainAxisSize.max,
      //   mainAxisAlignment: MainAxisAlignment.center,
      //   children: [
      //     Text('Total Images here - '),
      //     ElevatedButton(
      //       onPressed: () {
      //         imageController.pickImageFromGallery();
      //       },
      //       child: Text('Add Image for Compression'),
      //     ),
      //     ElevatedButton(
      //       onPressed: () {
      //         imageController.compressImages();
      //       },
      //       child: Text('Compress File'),
      //     ),
      //     Obx(() {
      //       if (imageController.getCompressList().isEmpty)
      //         return Text('NO file to compress');
      //       else
      //         return imageDisplay(
      //           imageController.getCompressList(),
      //           'Compressed Images',
      //         );
      //     }),
      //   ],
      // ),
      body: SafeArea(
          child: Padding(
              padding: EdgeInsets.only(top: 10),
              child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 20,),

                //region Header "Compress Smart"
                RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: "Compress ",
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.onBackground,
                            fontSize: 32,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -1,
                          )
                        ),
                        TextSpan(
                          text: "Smart",
                          style: TextStyle(
                            foreground: Paint()..shader = LinearGradient(colors: [
                              Theme.of(context).colorScheme.primary,
                              Theme.of(context).colorScheme.secondary
                            ]).createShader(const Rect.fromLTWH(0, 0, 200, 70)),
                            fontSize: 32,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -1,
                          )
                        )
                      ]
                    )),
                //endregion
                SizedBox(height: 35,),
                Container(
                  height: containerHeight,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(28),
                    border: Border.all(
                      color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
                      width: 2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Theme.of(context).primaryColor.withOpacity(0.1),
                        blurRadius: 30,
                        offset: const Offset(0, 10),
                        spreadRadius: 0,
                      ),
                      // BoxShadow(
                      //   color:
                      //   (widget.isDarkMode
                      //       ? Colors.black
                      //       : Colors.grey.shade300)
                      //       .withOpacity(0.05),
                      //   blurRadius: 20,
                      //   offset: const Offset(0, 8),
                      // ),
                    ]
                  ),
                  child: Container(),
                )

              ],
          ),
          )),
      bottomNavigationBar: ClipRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaY: 20, sigmaX: 20),
          child: Container(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface.withOpacity(0.7),
              border: Border(
                top: BorderSide(
                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.2),
                  width: 1,
                ),
              ),
            ),
            child: BottomNavigationBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              // currentIndex: ,
              type: BottomNavigationBarType.fixed,
              selectedItemColor: Theme.of(context).colorScheme.primary,
              unselectedItemColor: Theme.of(context).colorScheme.onSurface,
              selectedLabelStyle: const TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 12,
              ),
              unselectedLabelStyle: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 12,
              ),
              onTap: (value) {

              },
              items: const[
                BottomNavigationBarItem(icon: Icon(Icons.home_sharp),label: 'Home'),
                BottomNavigationBarItem(icon: Icon(Icons.history_sharp),label: 'History'),
                BottomNavigationBarItem(icon: Icon(Icons.tune_sharp),label: 'Settings'),
                BottomNavigationBarItem(icon: Icon(Icons.person_4_sharp),label: 'Profile'),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

Widget imageDisplay(List<CompressedImage> files, String label) {
  return Obx(
    () => Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontWeight: FontWeight.bold)),
        SizedBox(
          height: 250,
          child: CardSwiper(
            cardsCount: files.length,
            maxAngle: 360,
            numberOfCardsDisplayed: 3,
            scale: 0.8,

            cardBuilder:
                (context, index, percentThresholdX, percentThresholdY) {
                  return Padding(
                    padding: EdgeInsets.only(
                      top: 4.0,
                      bottom: 4.0,
                      left: index * 20,
                    ),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.black,
                        borderRadius: BorderRadius.all(Radius.circular(15)),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(3.0),
                        child: Image.file(
                          File(files[index].filePath),
                          width: 200,
                          height: 250,
                          fit: BoxFit.fitHeight,
                        ),
                      ),
                    ),
                  );
                },
          ),
        ),
      ],
    ),
  );
}
