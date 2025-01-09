// import 'dart:developer';

// import 'package:easy_audience_network/easy_audience_network.dart';
// import 'package:flutter/material.dart';
// import 'package:screen_recorder/utils/screen_utils.dart';

// class FacebookAdHelper {
//   // static String get bannerAdUnitId => 'YOUR_BANNER_AD_UNIT_ID';
//   // static String get interstitialAdUnitId => 'YOUR_INTERSTITIAL_AD_UNIT_ID';
//   // static String get nativeAd => 'YOUR_NATIVE_AD_UNIT_ID';
//   // static String get rewardedAdUnitId => 'YOUR_REWARDED_AD_UNIT_ID';

//   static void init() {
//     // Initialize Facebook Audience Network
//     EasyAudienceNetwork.init(
//       testingId: '37b1da9d-b48c-4103-a393-2e095e734bd6',
//       testMode: true,
//       iOSAdvertiserTrackingEnabled: true,
//     );
//   }

//   static void showInterstitialAd(
//     VoidCallback onCompleted,
//   ) {
//     final interstitialAd = InterstitialAd(InterstitialAd.testPlacementId);
//     interstitialAd.listener = InterstitialAdListener(
//       onLoaded: () {
//         onCompleted();
//         interstitialAd.show();
//       },
//       onError: (code, message) {
//         log('Interstitial Ad Error: $message');
//         onCompleted();
//       },
//       onDismissed: () {
//         interstitialAd.destroy();
//         onCompleted();
//       },
//     );
//     interstitialAd.load();
//   }

//   static void showRewardedAd(VoidCallback onCompleted) {
//     final rewardedAd = RewardedAd(RewardedAd.testPlacementId);
//     rewardedAd.listener = RewardedAdListener(
//       onLoaded: () => rewardedAd.show(),
//       onError: (code, message) => log('Rewarded Ad Error: $message'),
//       onVideoComplete: onCompleted,
//       onVideoClosed: onCompleted,
//     );
//   }

//   static void showBannerAd() {
//     final bannerAd = BannerAd(
//       placementId: BannerAd.testPlacementId,
//       bannerSize: BannerSize.STANDARD,
//       listener: BannerAdListener(
//         onLoaded: () => log('Banner Ad Loaded'),
//         onError: (code, message) => log('Banner Ad Error: $message'),
//       ),
//     );
//   }

//   static NativeAd nativeAd(BuildContext context) {
//     return NativeAd(
//       placementId: NativeAd.testPlacementId,
//       height: ScreenUtil(context).screenHeight * 0.1,
//       listener: NativeAdListener(
//         onLoaded: () => log('Native Ad Loaded'),
//         onError: (code, message) => log('Native Ad Error: $message'),
//       ),
//       adType: NativeAdType.NATIVE_BANNER_AD,
//     );
//   }
// }
