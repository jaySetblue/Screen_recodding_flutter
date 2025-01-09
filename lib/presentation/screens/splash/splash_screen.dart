import 'dart:io';

import 'package:flutter/material.dart';
import 'package:overlay_pop_up/overlay_pop_up.dart';
import 'package:screen_recorder/presentation/constants/constants.dart';
import 'package:screen_recorder/presentation/constants/my_colors.dart';
import 'package:screen_recorder/presentation/constants/my_styles.dart';
import 'package:screen_recorder/presentation/screens/home/bottom_bar.dart';
import 'package:screen_recorder/presentation/screens/onboarding/onboarding_screen.dart';
import 'package:screen_recorder/presentation/widgets/ads/banner_ads.dart';
import 'package:screen_recorder/presentation/widgets/ads/interstitial_ads.dart';
import 'package:screen_recorder/presentation/widgets/facrbook_ads/facebook_ad_helper.dart';
import 'package:screen_recorder/utils/screen_utils.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  bool isFirstOpen = true;

  @override
  void initState() {
    super.initState();

    // Load interstitial ad
    // AdManager().loadInterstitialAd();
    _checkFirstLaunch();
    _initiateSplashFlow();
  }

  // Method to check if it is the first launch
  Future<void> _checkFirstLaunch() async {
    final prefs = await SharedPreferences.getInstance();
    bool isFirstLaunch = prefs.getBool('isFirstLaunch') ?? true;

    setState(() {
      isFirstOpen = isFirstLaunch;
    });

    // Update the flag after the first launch
    if (isFirstLaunch) {
      await prefs.setBool('isFirstLaunch', false);
    }
  }

  // Method to initiate the splash flow
  Future<void> _initiateSplashFlow() async {
    await Future.delayed(
        const Duration(seconds: 2)); // Delay before checking permissions

    bool? overlayPermission;
    if (Platform.isIOS) {
      overlayPermission = true;
    } else {
      overlayPermission = await OverlayPopUp.checkPermission();
    }

    if (AdManager().isInterstitialAdLoaded) {
      AdManager()
          .showInterstitialAd(() => navigateToNextScreen(overlayPermission));
    } else {
      await Future.delayed(
          const Duration(seconds: 2)); // Extra delay if no ad is loaded
      navigateToNextScreen(overlayPermission);
    }

    // FacebookAdHelper.showInterstitialAd(() {
    //   navigateToNextScreen(overlayPermission);
    // });
  }

  // Method to navigate to the next screen based on permission
  void navigateToNextScreen(bool? overlayPermission) {
    final nextScreen = overlayPermission == true
        ? const BottomBar()
        : const OnboardingScreen();

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => nextScreen),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenUtil = ScreenUtil(context);

    return Scaffold(
      body: Container(
        width: screenUtil.screenWidth,
        height: screenUtil.screenHeight,
        decoration: BoxDecoration(gradient: MyColors().splashGradient),
        child: Stack(
          children: [
            _buildMainContent(screenUtil),
            _buildBannerAd(),
          ],
        ),
      ),
    );
  }

  // Builds the main content of the splash screen
  Widget _buildMainContent(ScreenUtil screenUtil) {
    return Align(
      alignment: Alignment.center,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            "BlueRec",
            style: MyStyles().headerTextStyle,
          ),
          const SizedBox(height: 10),
          _buildAppIcon(screenUtil),
          screenUtil.smallVS,
          _buildLoadingIndicator(screenUtil),
          screenUtil.largeVS,
        ],
      ),
    );
  }

  // Builds the app icon widget
  Widget _buildAppIcon(ScreenUtil screenUtil) {
    return Container(
      width: screenUtil.screenWidth * 0.3,
      height: screenUtil.screenWidth * 0.3,
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(20)),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Image.asset(
          Constants.appIcon,
          fit: BoxFit.cover,
        ),
      ),
    );
  }

  // Builds the loading indicator widget
  Widget _buildLoadingIndicator(ScreenUtil screenUtil) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      width: screenUtil.screenWidth * 0.5,
      child: const LinearProgressIndicator(
        backgroundColor: Colors.white38,
        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
      ),
    );
  }

  // Builds the banner ad widget
  Widget _buildBannerAd() {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 20.0),
        child:
            //  FacebookAdHelper.nativeAd(context) ??
            BannerAdWidget(),
      ),
    );
  }
}
