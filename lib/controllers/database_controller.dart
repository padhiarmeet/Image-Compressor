import 'package:get/get.dart';
import 'package:image_compressor/models/compressImageModel.dart';
import '../backend/services/databaseHelper.dart';

class DatabaseController extends GetxController {
  final DatabaseHelper databaseHelper = DatabaseHelper();

  // List of compressed images (Reactive)
  var imageList = <CompressedImage>[].obs;
  var isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchImages();
  }

  // Fetch from database and update list
  Future<void> fetchImages() async {
    isLoading.value = true;
    final res = await databaseHelper.fetchImagesfromDatabase();
    imageList.value = res;
    isLoading.value = false;
  }

  // Add image to database
  Future<void> addImage(CompressedImage image) async {
    await databaseHelper.addImage(image);
    // fetchImages();
    imageList.add(image);
  }

  // Delete image
  Future<void> deleteImage(CompressedImage image) async {
    await databaseHelper.deleteImage(image.filePath);
    // await fetchImages();
    //if something is wrong in delete uncomment upper code and comment lower code
    imageList.remove(image);
  }
}
