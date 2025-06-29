import 'package:get/get.dart';
import 'package:image_compressor/models/compressImageModel.dart';

class ImageController{

  ImageModel _imageModel = ImageModel();

  //region Methods for Original Images
  void addOriginalImage(CompressedImage image){
    _imageModel.addOriginalImage(image);
  }
  void removeOriginalImage(CompressedImage image) {
    _imageModel.removeOriginalImage(image);
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
  RxList<CompressedImage> getCompressList() =>_imageModel.getCompressImages().obs;
  //endregion

  //region Methods to clear all Lists
  void clearImages(){
    _imageModel.clearAll();
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

}