import 'dart:async';
import 'package:get/get.dart';
import 'package:image_compressor/services/reward_ad_service.dart';

class RewardController extends GetxController {
  RxInt imageLimit = 5.obs;
  RxBool hasWatchedAdThisSession = false.obs; // Track if ad was watched

  @override
  void onInit() {
    RewardAdService.loadRewardAd();
    super.onInit();
  }

  /// Returns true if user watched ad and reward was applied.
  Future<bool> increaseLimitByWatchingAd() async {
    final completer = Completer<bool>();

    final adShown = RewardAdService.showRewardAd(() {
      imageLimit.value = 10; // Temporarily increase to 10
      hasWatchedAdThisSession.value = true;
      Get.snackbar("Success", "🎉 Limit increased to ${imageLimit.value}");
      if (!completer.isCompleted) completer.complete(true);
    });

    if (!adShown) {
      // No ad was ready
      Get.snackbar("Info", "Reward ad not ready, please try again later");
      if (!completer.isCompleted) completer.complete(false);
    }

    return completer.future.timeout(Duration(seconds: 10), onTimeout: () {
      if (!completer.isCompleted) completer.complete(false);
      return false;
    });
  }

  /// Reset limit back to 5 after compression
  void resetLimit() {
    imageLimit.value = 5;
    hasWatchedAdThisSession.value = false;
  }
}
