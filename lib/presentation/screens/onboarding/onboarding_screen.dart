import 'package:flutter/material.dart';
import 'package:overlay_pop_up/overlay_pop_up.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:screen_recorder/presentation/constants/constants.dart';
import 'package:screen_recorder/presentation/constants/my_styles.dart';
import 'package:screen_recorder/presentation/screens/home/bottom_bar.dart';
import 'package:screen_recorder/utils/screen_utils.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  bool isFirstOpen = false;

  @override
  void initState() {
    super.initState();
    _checkFirstLaunch();
  }

  // Method to check if it is the first launch
  Future<void> _checkFirstLaunch() async {
    final prefs = await SharedPreferences.getInstance();
    bool isFirstLaunch = prefs.getBool('isFirstLaunch') ?? true;

    if (isFirstLaunch) {
      setState(() {
        isFirstOpen = true;
      });

      // Update the flag after the first launch
      await prefs.setBool('isFirstLaunch', false);
    } else {
      setState(() {
        isFirstOpen = false;
      });
    }
  }

  // Method to request overlay permission
  Future<void> _requestPermissions(BuildContext context) async {
    _showLoadingDialog(context);

    final status = await Permission.systemAlertWindow.request();

    if (Navigator.canPop(context)) {
      Navigator.of(context, rootNavigator: true).pop();
    }

    if (status == PermissionStatus.granted) {
      _navigateToBottomBar();
    }
  }

  // Show a loading dialog while requesting permissions
  void _showLoadingDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return const AlertDialog(
          content: SizedBox(
            height: 50,
            width: 50,
            child: Center(
              child: CircularProgressIndicator(strokeWidth: 3),
            ),
          ),
        );
      },
    );
  }

  // Navigate to the BottomBar
  void _navigateToBottomBar() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => const BottomBar(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenUtil = ScreenUtil(context);

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: _buildAppBar(context),
      body: _buildBody(screenUtil),
    );
  }

  AppBar _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.transparent,
      actions: [
        IconButton(
          onPressed: _navigateToBottomBar,
          icon: const Icon(Icons.close_sharp, color: Colors.white),
        ),
      ],
    );
  }

  Widget _buildBody(ScreenUtil screenUtil) {
    return Container(
      height: screenUtil.screenHeight,
      width: screenUtil.screenWidth,
      padding: EdgeInsets.symmetric(
        horizontal: 16,
        vertical: screenUtil.screenHeight * 0.12,
      ),
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage(Constants.homeBackground),
          fit: BoxFit.cover,
        ),
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildPermissionCard(screenUtil),
          ],
        ),
      ),
    );
  }

  Widget _buildPermissionCard(ScreenUtil screenUtil) {
    return Container(
      height: screenUtil.screenHeight * 0.75,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.4),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          screenUtil.veryVerySmallVS,
          _buildChecklist(),
          screenUtil.mediumVS,
          _buildImage(screenUtil),
          screenUtil.mediumVS,
          _buildActionButtons(screenUtil),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Floating button preparation',
          style: MyStyles().subHeaderTextStyle.copyWith(color: Colors.white),
        ),
        const Text(
          'Allow the overlay permission to enable floating Icon',
          style: TextStyle(color: Colors.amber, fontSize: 12),
        ),
        const Text(
          'What can you get:',
          style: TextStyle(color: Colors.white, fontSize: 12),
        ),
      ],
    );
  }

  Widget _buildChecklist() {
    return Column(
      children: [
        _buildChecklistItem('Fast start/stop recording'),
        _buildChecklistItem('Pause/resume recording'),
      ],
    );
  }

  Widget _buildChecklistItem(String text) {
    return Row(
      children: [
        const Icon(Icons.check, size: 12, color: Colors.white),
        const SizedBox(width: 8),
        Text(text, style: const TextStyle(color: Colors.white, fontSize: 10)),
      ],
    );
  }

  Widget _buildImage(ScreenUtil screenUtil) {
    return Container(
      height: screenUtil.screenHeight * 0.3,
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage(Constants.onboardingImage),
        ),
      ),
    );
  }

  Widget _buildActionButtons(ScreenUtil screenUtil) {
    return Column(
      children: [
        _buildActionButton(
          screenUtil: screenUtil,
          label: 'Enable Floating Icon',
          color: Colors.amber,
          onPressed: () async {
            if (!await OverlayPopUp.checkPermission()) {
              _requestPermissions(context);
            } else {
              _navigateToBottomBar();
            }
          },
        ),
        _buildActionButton(
          screenUtil: screenUtil,
          label: 'Maybe Later',
          color: Colors.transparent,
          textColor: Colors.white.withOpacity(0.6),
          onPressed: _navigateToBottomBar,
        ),
      ],
    );
  }

  Widget _buildActionButton({
    required ScreenUtil screenUtil,
    required String label,
    required Color color,
    Color? textColor,
    required VoidCallback onPressed,
  }) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        height: screenUtil.screenHeight * 0.07,
        margin: EdgeInsets.symmetric(horizontal: screenUtil.screenWidth * 0.15),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: textColor ?? Colors.black,
            ),
          ),
        ),
      ),
    );
  }
}
