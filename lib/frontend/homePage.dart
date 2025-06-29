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

    ImageController imageController = Get.put(ImageController());


    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar:PreferredSize(preferredSize: const Size.fromHeight(70),
          child: ClipRect(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 20,sigmaY: 20),
              child: AppBar(
                backgroundColor: Theme.of(context).colorScheme.surface.withOpacity(0.6),
                elevation: 0,
                centerTitle: false,
                title: Padding(padding: EdgeInsets.only(top: 10),
                child: Row(
                  children: [
                    Container(
                      width: 32,
                        height: 32,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(colors: [Theme.of(context).colorScheme.primary,Theme.of(context).colorScheme.secondary],begin: Alignment.topLeft,end:  Alignment.bottomRight),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.compress,color: Colors.white,size: 18,),
                    ),
                    const SizedBox(width: 12,),
                    Text('Compressor',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onBackground,
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.5
                    ),)
                  ],
                ),),
              ),
            ),
          )),
      body: Column(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('Total Images here - '),
          ElevatedButton(onPressed: () {
            imageController.pickImageFromGallery();
          }, child: Text('Add Image for Compression')),
          ElevatedButton(onPressed: () {
            imageController.compressImages();
          }, child: Text('Compress File')),
          Obx(() {
            if(imageController.getCompressList().isEmpty) return Text('NO file to compress');
            else return imageDisplay(imageController.getCompressList(),'Compressed Images');
          },)
        ],
      ),
    );
  }
}


Widget imageDisplay(List<CompressedImage> files, String label) {
  return Obx(() =>
    Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontWeight: FontWeight.bold)),
        SizedBox(
          height: 250,
          child: CardSwiper(
            cardsCount: files.length,
            maxAngle: 360,
            numberOfCardsDisplayed: 3,
            scale:0.8,

            cardBuilder: (context, index, percentThresholdX, percentThresholdY) {
              return Padding(
                padding: EdgeInsets.only(top: 4.0,bottom: 4.0,left: index * 20),
                child: Container(
                  decoration: BoxDecoration(
                      color: Colors.black,
                      borderRadius: BorderRadius.all(Radius.circular(15))
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
