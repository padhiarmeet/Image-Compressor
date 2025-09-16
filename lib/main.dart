import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_navigation/src/root/get_material_app.dart';
import 'package:get_storage/get_storage.dart';
import 'package:image_compressor/controllers/database_controller.dart';
import 'package:image_compressor/controllers/page_view_cntroller.dart';
import 'package:image_compressor/frontend/layout_page_screen.dart';
import 'package:image_compressor/theme/theme.dart';
import 'controllers/compressImageController.dart';
import 'controllers/themeController.dart';

void main() async{
  await GetStorage.init();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {

    final themeController = Get.put(ThemeController());
    final pageViewController = Get.put(PageViewController());
    final databaseController = Get.put(DatabaseController());
    final imageController = Get.put(ImageController());

    return GetMaterialApp(
      title: 'Flutter Demo',
      theme: lightMode,
      darkTheme: darkMode,
      themeMode: themeController.isDarkMode? ThemeMode.dark : ThemeMode.light ,
      home: LayoutScreen(),
      // home: CarouselExampleApp(),
    );
  }
}

