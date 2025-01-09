import 'package:flutter/material.dart';
import 'package:screen_recorder/presentation/constants/my_styles.dart';
import 'package:screen_recorder/presentation/screens/feedback/feedback_screen.dart';
import 'package:screen_recorder/presentation/screens/privacy_policy/privacy_policy_screen.dart';
import 'package:screen_recorder/presentation/screens/terms_conditions/terms_and_conditions_screen.dart';
import 'package:screen_recorder/presentation/screens/trash/deleted_videos.dart';
import 'package:screen_recorder/utils/screen_utils.dart';
import 'package:share_plus/share_plus.dart';

class OtherSettings extends StatefulWidget {
  const OtherSettings({super.key});

  @override
  State<OtherSettings> createState() => _ControlSettingsState();
}

class _ControlSettingsState extends State<OtherSettings> {
  bool isOtherTapped = false;
  bool showStopAlert = false;
  bool showFloat = false;

  void _shareApp() {
    const appUrl =
        'https://drive.google.com/drive/folders/1sbT3GzrzYtbyS-5w0-1S8v83AjI5fSQQ?usp=share_link';

    Share.share('Check out this Screen Recorder App: $appUrl');
  }

  @override
  Widget build(BuildContext context) {
    final screenUtil = ScreenUtil(context);
    return Column(
      children: [
        GestureDetector(
          onTap: () {
            setState(() {
              isOtherTapped = !isOtherTapped;
            });
          },
          child: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(10), topRight: Radius.circular(10)),
              color: Colors.white.withOpacity(0.4),
              border: Border.all(color: Colors.grey, width: 1),
            ),
            child: GestureDetector(
              onTap: () {
                setState(() {
                  isOtherTapped = !isOtherTapped;
                });
              },
              child: Row(
                children: [
                  Text(
                    'Others',
                    style: MyStyles().subHeaderTextStyle.copyWith(
                          color: Colors.black,
                          fontSize: 15,
                        ),
                  ),
                  const Spacer(),
                  !isOtherTapped
                      ? const Icon(Icons.arrow_drop_down)
                      : const Icon(Icons.arrow_drop_up),
                ],
              ),
            ),
          ),
        ),
        if (isOtherTapped)
          Container(
            padding: const EdgeInsets.only(left: 10, right: 10),
            decoration: BoxDecoration(
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(10),
                  bottomRight: Radius.circular(10),
                ),
                color: Colors.black.withOpacity(0.3)),
            child: Column(
              children: [
                screenUtil.veryVerySmallVS,
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const DeletedVideos(),
                      ),
                    );
                  },
                  child: Row(
                    children: [
                      const Icon(
                        Icons.delete,
                        color: Colors.white,
                        size: 18,
                      ),
                      screenUtil.smallHS,
                      const Text(
                        'Trash',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.white,
                        ),
                      )
                    ],
                  ),
                ),

                //screenUtil.verySmallVS,
                // Row(
                //   children: [
                //     const Icon(
                //       Icons.dark_mode_rounded,
                //       color: Colors.white,
                //       size: 18,
                //     ),
                //     screenUtil.smallHS,
                //     const Text('Dark Mode'),
                //     const Spacer(),
                //     Checkbox(
                //         value: showFloat,
                //         onChanged: (bool) {
                //           setState(() {
                //             showFloat = !showFloat;
                //           });
                //         })
                //   ],
                // ),
                // const Divider(),
                // //screenUtil.verySmallVS,
                // Row(
                //   children: [
                //     const Icon(
                //       Icons.feedback,
                //       color: Colors.white,
                //     ),
                //     screenUtil.smallHS,
                //     const Text('Feedback')
                //   ],
                // ),
                const Divider(),
                //screenUtil.verySmallVS,
                GestureDetector(
                  onTap: _shareApp,
                  child: Row(
                    children: [
                      const Icon(
                        Icons.share,
                        color: Colors.white,
                        size: 18,
                      ),
                      screenUtil.smallHS,
                      const Text(
                        'Share',
                        style: TextStyle(fontSize: 12, color: Colors.white),
                      )
                    ],
                  ),
                ),
                // const Divider(),
                // //screenUtil.verySmallVS,
                // Row(
                //   children: [
                //     const Icon(
                //       Icons.visibility_off,
                //       color: Colors.white,
                //     ),
                //     screenUtil.smallHS,
                //     const Text('Privacy Policy')
                //   ],
                // ),
                const Divider(),
                //screenUtil.verySmallVS,
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => FeedbackScreen()));
                  },
                  child: Row(
                    children: [
                      const Icon(
                        Icons.feedback_outlined,
                        color: Colors.white,
                        size: 18,
                      ),
                      screenUtil.smallHS,
                      const Text(
                        'Feedback',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.white,
                        ),
                      )
                    ],
                  ),
                ),
                const Divider(),
                //screenUtil.verySmallVS,
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => TermsAndConditionsScreen()));
                  },
                  child: Row(
                    children: [
                      const Icon(
                        Icons.horizontal_split,
                        color: Colors.white,
                        size: 18,
                      ),
                      screenUtil.smallHS,
                      const Text(
                        'Terms & conditions',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.white,
                        ),
                      )
                    ],
                  ),
                ),
                Divider(),
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => PrivacyPolicyScreen()));
                  },
                  child: Row(
                    children: [
                      const Icon(
                        Icons.visibility_off_outlined,
                        color: Colors.white,
                        size: 18,
                      ),
                      screenUtil.smallHS,
                      const Text(
                        'Privacy policy',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.white,
                        ),
                      )
                    ],
                  ),
                ),

                screenUtil.veryVerySmallVS
              ],
            ),
          )
      ],
    );
  }
}
