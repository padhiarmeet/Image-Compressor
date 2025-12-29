import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_compressor/controllers/compressImageController.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:permission_handler/permission_handler.dart';
import 'package:share_plus/share_plus.dart';
import '../models/compressImageModel.dart';
import '../utils/permission_helper.dart';

class PdfController extends GetxController{
  RxList pdfFiles = [].obs;
  var hasPdf = false.obs;
  var isDownloading = false.obs;


  void _showStyledSnackbar({
    required String title,
    required String message,
    required SnackbarType type,
  }) {
    Color iconColor;
    IconData icon;

    switch (type) {
      case SnackbarType.success:
        iconColor = Colors.green;
        icon = Icons.check_circle_outline;
        break;
      case SnackbarType.error:
        iconColor = Colors.red;
        icon = Icons.error_outline;
        break;
      case SnackbarType.warning:
        iconColor = Colors.orange;
        icon = Icons.warning_amber_rounded;
        break;
      case SnackbarType.info:
        iconColor = Get.theme.colorScheme.primary;
        icon = Icons.info_outline;
        break;
    }

    Get.snackbar(
      title,
      message,
      backgroundColor: Get.theme.colorScheme.surface,
      colorText: Get.theme.colorScheme.onSurface,
      snackPosition: SnackPosition.BOTTOM,
      margin: const EdgeInsets.all(16),
      borderRadius: 12,
      icon: Icon(icon, color: iconColor, size: 28),
      shouldIconPulse: true,
      boxShadows: [
        BoxShadow(
          color: Colors.black.withOpacity(0.1),
          blurRadius: 10,
          offset: const Offset(0, 4),
        ),
      ],
      duration: const Duration(seconds: 3),
      isDismissible: true,
      forwardAnimationCurve: Curves.easeOutBack,
    );
  }

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
            pageFormat: PdfPageFormat.a4.applyMargin(left: 0, top: 0, right: 0, bottom: 0),
            build:(pw.Context context) =>
                 pw.Image(
                image,
                fit: pw.BoxFit.cover,
              ),
          )
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

      if (!await pdfFile.exists()) {
        _showStyledSnackbar(
          title: 'Error',
          message: 'Source PDF not found: ${pdfFile.path}',
          type: SnackbarType.error,
        );
        isDownloading.value = false;
        return;
      }

      // var status = await Permission.storage.request();
      PermissionStatus status = await PermissionHelper.requestStoragePermission();
      if (!status.isGranted) {
        if (Platform.isAndroid) {
          var manageStatus = await Permission.manageExternalStorage.request();
          if (!manageStatus.isGranted) {
            _showStyledSnackbar(
              title: 'Permission Denied',
              message: 'Storage permission is required to download files',
              type: SnackbarType.error,
            );
            isDownloading.value = false;
            return;
          }
        } else {
          _showStyledSnackbar(
            title: 'Permission Denied',
            message: 'Storage permission is required to download files',
            type: SnackbarType.error,
          );
          isDownloading.value = false;
          return;
        }
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

        try {
          final copied = await pdfFile.copy(newPath);
          _showStyledSnackbar(
            title: 'Success',
            message: 'PDF downloaded to: ${copied.path}',
            type: SnackbarType.success,
          );
        } catch (e) {
          _showStyledSnackbar(
            title: 'Error',
            message: 'Failed to save PDF: $e',
            type: SnackbarType.error,
          );
        }
      }
    } catch (e) {
      _showStyledSnackbar(
        title: 'Error',
        message: 'Failed to save PDF: $e',
        type: SnackbarType.error,
      );
    } finally {
      isDownloading.value = false;
    }
  }

  Future<void> downloadAllPdfs() async {
    try {
      isDownloading.value = true;

      if (pdfFiles.isEmpty) {

        _showStyledSnackbar(
          title: 'Info',
          message: 'No PDFs to download',
          type: SnackbarType.info,
        );
        isDownloading.value = false;
        return;
      }

      PermissionStatus status = await PermissionHelper.requestStoragePermission();
      if (!status.isGranted) {
        if (Platform.isAndroid) {
          var manageStatus = await Permission.manageExternalStorage.request();
          if (!manageStatus.isGranted) {
            _showStyledSnackbar(
              title: 'Permission Denied',
              message: 'Storage permission is required to download files',
              type: SnackbarType.error,
            );
            isDownloading.value = false;
            return;
          }
        } else {
          _showStyledSnackbar(
            title: 'Permission Denied',
            message: 'Storage permission is required to download files',
            type: SnackbarType.error,
          );
          isDownloading.value = false;
          return;
        }
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
        int failCount = 0;
        for (var f in pdfFiles) {
          try {
            final File pdfFile = f as File;
            if (!await pdfFile.exists()) {
              failCount++;
              continue;
            }
            final fileName = pdfFile.path.split('/').last;
            final newPath = '${downloadsDirectory.path}/$fileName';
            await pdfFile.copy(newPath);
            downloadCount++;
          } catch (e) {
            failCount++;
          }
        }

        _showStyledSnackbar(
          title: 'Success',
          message: '$downloadCount PDFs downloaded. $failCount failed.',
          type: SnackbarType.success,
        );
      }
    } catch (e) {
      _showStyledSnackbar(
        title: 'Error',
        message: 'Failed to download PDFs: $e',
        type: SnackbarType.error,
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
      _showStyledSnackbar(
        title: 'Error',
        message: 'Failed to share PDF: $e',
        type: SnackbarType.error,
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
      _showStyledSnackbar(
        title: 'Error',
        message: 'Failed to share PDF: $e',
        type: SnackbarType.error,
      );
    }
  }

  List<dynamic> getPdfList(){
    return pdfFiles;
  }
  void removePdf(int index){

    print(index);


    if (index >= 0 && index < pdfFiles.length) {
      pdfFiles.removeAt(index);
      if (pdfFiles.isEmpty) {
        hasPdf.value = false;
      }
    }
  }
}