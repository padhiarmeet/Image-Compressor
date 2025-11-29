import 'package:get/get.dart';
import 'package:image_compressor/models/compressImageModel.dart';

class ImageController extends GetxController{

  ImageModel _imageModel = ImageModel();

  //region Methods for Original Images
  void addOriginalImage(CompressedImage image){
    _imageModel.addOriginalImage(image);
  }
  void removeOriginalImage(CompressedImage image){
    _imageModel.removeOriginalImage(image);
  }
  void clearOriginalList() {
    _imageModel.clearOriginalList();
  }
  RxList<CompressedImage> getOriginalList() =>_imageModel.getOriginalImages().obs;
  //endregion

  //region Methods for CompressImages
  void addCompressImage(CompressedImage image){
    _imageModel.addCompressImage(image);
  }
  void removeCompressImage(CompressedImage image) {
    _imageModel.removeCompressImage(image);
  }

  void clearCompressList() {
    _imageModel.clearCompressedList();
  }
  RxList<CompressedImage> getCompressList() =>_imageModel.getCompressImages().obs;
  //endregion

  //region Methods to clear all Lists
  void clearImages(){
    _imageModel.clearAll();
  }
  //endregion

  //region Methods for compression state tracking
  bool areAllImagesCompressed() {
    return _imageModel.areAllImagesCompressed();
  }

  Map<String, int> getCompressionStatus() {
    return _imageModel.getCompressionStatus();
  }

  // Method to check if compression buttons should be disabled
  bool shouldDisableCompressionButtons() {
    return areAllImagesCompressed();
  }
  //endregion

  Future<void> pickImageFromGallery() async{
    await _imageModel.pickImageFromGallery();
  }

  Future<void> compressImages() async{
    await _imageModel.compressImages();
  }

  Future<void> compressToTargetSize(int size) async{
    await _imageModel.compressToTargetSize(size);
  }

  Future<void> compressToTargetQuality(int quality) async{
    await _imageModel.compressToTargetQuality(quality);
  }

  Future<void> shareImages(List<CompressedImage> data) async{
    await _imageModel.shareImages(data);
  }

  Future<void> shareImage(String filePath) async{
    await _imageModel.shareImage(filePath);
  }

  Future<void> downloadImages() async {
    await _imageModel.downloadImages();
  }

  Future<void> downloadImage(String filePath) async {
    await _imageModel.downloadImage(filePath);
  }
}