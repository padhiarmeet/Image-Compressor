import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class BannerAdWidget extends StatefulWidget {
  final String adUnitId;

  const BannerAdWidget({super.key, required this.adUnitId});

  @override
  _BannerAdWidgetState createState() => _BannerAdWidgetState();
}

class _BannerAdWidgetState extends State<BannerAdWidget> {
  BannerAd? _bannerAd;
  bool _isLoaded = false;

  @override
  void initState() {
    super.initState();
    _loadAd();
  }

  void _loadAd() {
    _bannerAd = BannerAd(
      adUnitId: widget.adUnitId,
      request: const AdRequest(
        // Add your test device ID here (get it from logs)
        // Example: testDevices: ['YOUR_DEVICE_ID_HERE'],
      ),
      size: AdSize.banner,
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          debugPrint('Ad loaded successfully!');
          setState(() {
            _isLoaded = true;
          });
        },
        onAdFailedToLoad: (ad, error) {
          debugPrint('Ad failed to load: ${error.code} - ${error.message}');
          ad.dispose();
          // Optional: Retry loading after a delay
          Future.delayed(const Duration(seconds: 5), _loadAd);
        },
      ),
    );
    _bannerAd!.load();
  }

  @override
  void dispose() {
    _bannerAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _isLoaded
        ? SizedBox(
      height: _bannerAd!.size.height.toDouble(),
      width: _bannerAd!.size.width.toDouble(),
      child: AdWidget(ad: _bannerAd!),
    )
        : const SizedBox(child: Text('Ad is loading...'));
  }
}
