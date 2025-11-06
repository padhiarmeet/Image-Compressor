import 'package:get/get.dart';
import 'package:image_compressor/services/reward_ad_service.dart';

class RewardController extends GetxController {
  RxInt imageLimit = 5.obs; // default limit is 5

  @override
  void onInit() {
    RewardAdService.loadRewardAd();
    super.onInit();
  }

  void increaseLimitByWatchingAd() {
    RewardAdService.showRewardAd(() {
      imageLimit.value += 5; // increase limit by 5
      Get.snackbar("Success", "🎉 Limit increased to ${imageLimit.value}");
    });
  }
}
