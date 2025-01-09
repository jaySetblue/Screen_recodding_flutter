import 'package:flutter/material.dart';
import 'package:screen_recorder/presentation/constants/constants.dart';
import 'package:screen_recorder/presentation/constants/my_styles.dart';
import 'package:screen_recorder/presentation/widgets/control_settings.dart';
import 'package:screen_recorder/presentation/widgets/faq.dart';
import 'package:screen_recorder/presentation/widgets/other_settings.dart';
import 'package:screen_recorder/presentation/widgets/video_settings.dart';
import 'package:screen_recorder/utils/screen_utils.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsState();
}

class _SettingsState extends State<SettingsScreen> {
  @override
  Widget build(BuildContext context) {
    final screenUtil = ScreenUtil(context);

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: const Text(
          'Settings',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
        ),
      ),
      body: Container(
        width: screenUtil.screenWidth,
        height: screenUtil.screenHeight,
        padding: EdgeInsets.only(
          top: screenUtil.screenHeight * 0.12,
          bottom: kToolbarHeight,
          left: 16,
          right: 16,
        ),
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage(Constants.homeBackground),
            fit: BoxFit.cover,
          ),
        ),
        child: Stack(
          children: [
            SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionHeader('Frequently Asked Questions'),
                  SizedBox(
                    height: screenUtil.screenHeight * 0.2,
                    child: const Faq(),
                  ),
                  _verticalSpacing(screenUtil),
                  const VideoSettings(),
                  _verticalSpacing(screenUtil),
                  const ControlSettings(),
                  _verticalSpacing(screenUtil),
                  const OtherSettings(),
                  _verticalSpacing(screenUtil),
                  _buildVersionInfo(screenUtil),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.all(10),
      child: Text(
        title,
        style: MyStyles().subHeaderTextStyle.copyWith(
              color: Colors.white.withOpacity(0.6),
              fontSize: 14,
            ),
      ),
    );
  }

  Widget _buildVersionInfo(ScreenUtil screenUtil) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(Icons.info_outline, color: Colors.white),
        screenUtil.smallHS,
        const Text(
          'Version: 1.0.0',
          style: TextStyle(
            fontSize: 12,
            color: Colors.white,
          ),
        ),
      ],
    );
  }

  Widget _verticalSpacing(ScreenUtil screenUtil) => screenUtil.smallVS;
}
