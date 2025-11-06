import 'package:google_mobile_ads/google_mobile_ads.dart';

class RewardAdService {
  static RewardedAd? _rewardedAd;

  static Future<void> loadRewardAd() async {
    await RewardedAd.load(
      adUnitId: "ca-app-pub-3940256099942544/5224354917", // TEST ID
      request: AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (RewardedAd ad) {
          _rewardedAd = ad;
          print("✅ Reward Ad Loaded");
        },
        onAdFailedToLoad: (LoadAdError error) {
          print("❌ Failed to load Reward ad: $error");
          _rewardedAd = null;
        },
      ),
    );
  }

  static void showRewardAd(Function onRewardEarned) {
    if (_rewardedAd == null) {
      print("⚠️ Reward ad not ready");
      return;
    }

    _rewardedAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        loadRewardAd(); // auto load next ad
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        print('❌ Reward ad failed to show: $error');
        loadRewardAd();
      },
    );

    _rewardedAd!.show(
      onUserEarnedReward: (AdWithoutView ad, RewardItem reward) {
        try {
          onRewardEarned();
        } catch (e) {
          print('Error running reward callback: $e');
        }
      },
    );

    _rewardedAd = null;
  }
}
