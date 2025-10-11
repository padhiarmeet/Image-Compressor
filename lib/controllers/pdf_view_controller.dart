import 'dart:io';
import 'package:get/get.dart';
import 'package:image_compressor/controllers/compressImageController.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:permission_handler/permission_handler.dart';
import 'package:share_plus/share_plus.dart';
import '../models/compressImageModel.dart';

class PdfController extends GetxController{
  RxList pdfFiles = [].obs;
  var hasPdf = false.obs;
  var isDownloading = false.obs;

  Future<List<dynamic>> generatePdf() async{


    pdfFiles.clear();

    final output = await getExternalStorageDirectory();
    final imageController = Get.find<ImageController>();

    for(CompressedImage imageFile in imageController.getOriginalList()){
      final pdf = pw.Document();
      final file = File(imageFile.filePath);

      final image = pw.MemoryImage(await file.readAsBytes());

      pdf.addPage(
          pw.Page(
            pageFormat: PdfPageFormat.a4,
            build:(pw.Context context) => pw.Center(
                child: pw.Image(image,fit: pw.BoxFit.contain)
            ), )
      );

      final pdfFile = File("${output!.path}/compressed_${imageFile.id ?? DateTime.now().millisecondsSinceEpoch}.pdf");
      await pdfFile.writeAsBytes(await pdf.save());

      pdfFiles.add(pdfFile);
    }
    print("################# pdf files - $pdfFiles");
    hasPdf.value = true;
    return pdfFiles;
  }

  Future<void> downloadPdf(File pdfFile) async {
    try {
      isDownloading.value = true;

      var status = await Permission.storage.request();
      if (status.isDenied) {
        Get.snackbar(
          "Permission Denied",
          "Storage permission is required to download files",
          snackPosition: SnackPosition.BOTTOM,
        );
        isDownloading.value = false;
        return;
      }

      Directory? downloadsDirectory;
      if (Platform.isAndroid) {
        downloadsDirectory = Directory('/storage/emulated/0/Download');
        if (!await downloadsDirectory.exists()) {
          downloadsDirectory = await getExternalStorageDirectory();
        }
      } else {
        downloadsDirectory = await getApplicationDocumentsDirectory();
      }

      if (downloadsDirectory != null) {
        final fileName = pdfFile.path.split('/').last;
        final newPath = '${downloadsDirectory.path}/$fileName';

        await pdfFile.copy(newPath);

        Get.snackbar(
          "Success",
          "PDF downloaded to Downloads folder",
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } catch (e) {
      Get.snackbar(
        "Error",
        "Failed to download PDF: $e",
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isDownloading.value = false;
    }
  }

  Future<void> downloadAllPdfs() async {
    try {
      isDownloading.value = true;

      var status = await Permission.storage.request();
      if (status.isDenied) {
        Get.snackbar(
          "Permission Denied",
          "Storage permission is required to download files",
          snackPosition: SnackPosition.BOTTOM,
        );
        isDownloading.value = false;
        return;
      }

      Directory? downloadsDirectory;
      if (Platform.isAndroid) {
        downloadsDirectory = Directory('/storage/emulated/0/Download');
        if (!await downloadsDirectory.exists()) {
          downloadsDirectory = await getExternalStorageDirectory();
        }
      } else {
        downloadsDirectory = await getApplicationDocumentsDirectory();
      }

      if (downloadsDirectory != null) {
        int downloadCount = 0;
        for (File pdfFile in pdfFiles) {
          final fileName = pdfFile.path.split('/').last;
          final newPath = '${downloadsDirectory.path}/$fileName';

          await pdfFile.copy(newPath);
          downloadCount++;
        }

        Get.snackbar(
          "Success",
          "$downloadCount PDFs downloaded to Downloads folder",
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } catch (e) {
      Get.snackbar(
        "Error",
        "Failed to download PDFs: $e",
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isDownloading.value = false;
    }
  }

  Future<void> sharePdf(File pdfFile) async {
    try {
      await SharePlus.instance.share(
        ShareParams(files: [XFile(pdfFile.path)],text: 'Sharing PDF file'),
      );
    } catch (e) {
      Get.snackbar(
        "Error",
        "Failed to share PDF: $e",
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  // Share all PDFs
  Future<void> shareAllPdfs() async {
    try {
      List<XFile> xFiles = pdfFiles.map((file) => XFile(file.path)).toList();
      await SharePlus.instance.share(
        ShareParams(files: xFiles,text: 'Sharing PDF file'),
      );
    } catch (e) {
      Get.snackbar(
        "Error",
        "Failed to share PDFs: $e",
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  List<dynamic> getPdfList(){
    return pdfFiles;
  }
  void removePdf(int index){

    print(index);


    if (index >= 0 && index <= pdfFiles.length) {
      pdfFiles.removeAt(index);
      if (pdfFiles.isEmpty) {
        hasPdf.value = false;
      }
    }
  }
}