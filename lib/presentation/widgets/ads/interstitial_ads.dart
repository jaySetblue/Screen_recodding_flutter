import 'dart:developer';
import 'dart:io';
import 'dart:ui';

import 'package:google_mobile_ads/google_mobile_ads.dart';

class AdManager {
  static final AdManager _instance = AdManager._internal();
  late InterstitialAd _interstitialAd;
  bool isInterstitialAdLoaded = false;

  factory AdManager() {
    return _instance;
  }

  AdManager._internal();

  // Load Interstitial Ad
  void loadInterstitialAd() {
    InterstitialAd.load(
      adUnitId: Platform.isAndroid
          ? 'ca-app-pub-3940256099942544/1033173712'
          : 'ca-app-pub-3940256099942544/4411468910', // Replace with your own AdMob interstitial ad unit ID
      request: AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (InterstitialAd ad) {
          _interstitialAd = ad;
          isInterstitialAdLoaded = true;
        },
        onAdFailedToLoad: (LoadAdError error) {
          isInterstitialAdLoaded = false;
          log('Failed to load interstitial ad: $error');
        },
      ),
    );
  }

  // Show Interstitial Ad
  void showInterstitialAd(VoidCallback onAdDismissed) {
    if (isInterstitialAdLoaded) {
      _interstitialAd.fullScreenContentCallback = FullScreenContentCallback(
        onAdDismissedFullScreenContent: (Ad ad) {
          onAdDismissed();
          ad.dispose(); // Dispose the ad after it's dismissed
        },
        onAdFailedToShowFullScreenContent: (Ad ad, AdError error) {
          onAdDismissed();
          ad.dispose(); // Dispose the ad after it fails to show
        },
      );
      _interstitialAd.show();
    } else {
      log('Interstitial ad is not loaded');
    }
  }
}
