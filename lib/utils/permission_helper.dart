import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:permission_handler/permission_handler.dart';

/// A helper class for handling storage permissions across different Android versions.
///
/// Android permission requirements:
/// - Android 13+ (API 33+): Use READ_MEDIA_IMAGES (Permission.photos)
/// - Android 10-12 (API 29-32): Use READ_EXTERNAL_STORAGE (Permission.storage)
/// - Android 9 and below (API ≤28): Use READ/WRITE_EXTERNAL_STORAGE (Permission.storage)
class PermissionHelper {
  static final DeviceInfoPlugin _deviceInfo = DeviceInfoPlugin();

  /// Requests the appropriate storage permission based on the Android version.
  /// Returns the permission status after the request.
  static Future<PermissionStatus> requestStoragePermission() async {
    if (!Platform.isAndroid) {
      return PermissionStatus.granted;
    }

    try {
      final androidInfo = await _deviceInfo.androidInfo;
      final sdkInt = androidInfo.version.sdkInt;

      if (sdkInt >= 33) {

        final status = await Permission.photos.request();
        return status;
      } else {

        final status = await Permission.storage.request();
        return status;
      }
    } catch (e) {

      var status = await Permission.storage.request();
      if (status.isDenied) {
        status = await Permission.photos.request();
      }
      return status;
    }
  }

  /// Checks if storage permission is granted without requesting it.
  static Future<bool> hasStoragePermission() async {
    if (!Platform.isAndroid) {
      return true;
    }

    try {
      final androidInfo = await _deviceInfo.androidInfo;
      final sdkInt = androidInfo.version.sdkInt;

      if (sdkInt >= 33) {
        return await Permission.photos.isGranted;
      } else {
        return await Permission.storage.isGranted;
      }
    } catch (e) {
      return await Permission.storage.isGranted ||
          await Permission.photos.isGranted;
    }
  }

  /// Checks if permission is permanently denied and user needs to go to settings.
  static Future<bool> isPermissionPermanentlyDenied() async {
    if (!Platform.isAndroid) {
      return false;
    }

    try {
      final androidInfo = await _deviceInfo.androidInfo;
      final sdkInt = androidInfo.version.sdkInt;

      if (sdkInt >= 33) {
        return await Permission.photos.isPermanentlyDenied;
      } else {
        return await Permission.storage.isPermanentlyDenied;
      }
    } catch (e) {
      return false;
    }
  }
}
