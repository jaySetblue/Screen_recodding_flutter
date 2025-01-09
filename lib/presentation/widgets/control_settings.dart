import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:overlay_pop_up/overlay_pop_up.dart';
import 'package:screen_recorder/presentation/constants/my_styles.dart';
import 'package:screen_recorder/presentation/widgets/countdown_dropdown.dart';
import 'package:screen_recorder/service/provider/overlay_size_provider.dart';
import 'package:screen_recorder/service/provider/show_stop_alert_provider.dart';
import 'package:screen_recorder/utils/screen_utils.dart';

class ControlSettings extends ConsumerStatefulWidget {
  const ControlSettings({super.key});

  @override
  ConsumerState<ControlSettings> createState() => _ControlSettingsState();
}

class _ControlSettingsState extends ConsumerState<ControlSettings> {
  bool isControlTapped = false;

  void updateOverlaySize(int h, int w) async {
    final isoverlayActive = await OverlayPopUp.isActive();

    if (isoverlayActive) {
      OverlayPopUp.updateOverlaySize(
        height: h,
        width: w,
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              "Floating overlay is inactive, can't change size of inactive overlay"),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    bool showStopAlert = ref.watch(showStopAlertProvider);
    final screenUtil = ScreenUtil(context);
    return Column(
      children: [
        GestureDetector(
          onTap: () {
            setState(() {
              isControlTapped = !isControlTapped;
            });
          },
          child: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(10), topRight: Radius.circular(10)),
              color: Colors.white.withOpacity(0.4),
              border: Border.all(color: Colors.grey, width: 1),
            ),
            child: GestureDetector(
              onTap: () {
                setState(() {
                  isControlTapped = !isControlTapped;
                });
              },
              child: Row(
                children: [
                  Text(
                    'Control Settings',
                    style: MyStyles()
                        .subHeaderTextStyle
                        .copyWith(color: Colors.black, fontSize: 15),
                  ),
                  const Spacer(),
                  !isControlTapped
                      ? const Icon(Icons.arrow_drop_down)
                      : const Icon(Icons.arrow_drop_up),
                ],
              ),
            ),
          ),
        ),
        if (isControlTapped)
          Container(
            padding: const EdgeInsets.only(left: 10, right: 10),
            decoration: BoxDecoration(
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(10),
                  bottomRight: Radius.circular(10),
                ),
                color: Colors.black.withOpacity(0.3)),
            child: Column(
              children: [
                screenUtil.veryVerySmallVS,
                Container(
                  height: screenUtil.screenHeight * 0.03,
                  padding: const EdgeInsets.only(right: 10),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.timer_outlined,
                        color: Colors.white,
                        size: 18,
                      ),
                      screenUtil.smallHS,
                      const Text(
                        'Countdown before start',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.white,
                        ),
                      ),
                      const Spacer(),
                      const CountdownDropdown(),
                    ],
                  ),
                ),
                const Divider(),
                //screenUtil.verySmallVS,
                SizedBox(
                  height: screenUtil.screenHeight * 0.03,
                  child: Row(
                    children: [
                      const Icon(
                        Icons.camera_outlined,
                        color: Colors.white,
                        size: 18,
                      ),
                      screenUtil.smallHS,
                      const Text(
                        'Camera overlay size',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.white,
                        ),
                      ),
                      Spacer(),
                      GestureDetector(
                          onTap: () {
                            ref.read(overlaySizeProvider.notifier).setSize(
                                  Size(
                                    (screenUtil.screenWidth),
                                    (screenUtil.screenWidth),
                                  ),
                                );
                            updateOverlaySize(
                                (screenUtil.screenWidth * 1).toInt(),
                                (screenUtil.screenWidth * 1).toInt());
                          },
                          child: CircleAvatar(
                            child: Text(
                              'S',
                              style: TextStyle(fontSize: 12),
                            ),
                          )),
                      GestureDetector(
                          onTap: () {
                            ref.read(overlaySizeProvider.notifier).setSize(
                                  Size(
                                    (screenUtil.screenWidth * 1.5),
                                    (screenUtil.screenWidth * 1.5),
                                  ),
                                );
                            updateOverlaySize(
                                (screenUtil.screenWidth * 1.5).toInt(),
                                (screenUtil.screenWidth * 1.5).toInt());
                          },
                          child: CircleAvatar(
                              child: Text(
                            'M',
                            style: TextStyle(fontSize: 12),
                          ))),
                      GestureDetector(
                          onTap: () {
                            ref.read(overlaySizeProvider.notifier).setSize(
                                  Size(
                                    (screenUtil.screenWidth * 2),
                                    (screenUtil.screenWidth * 2),
                                  ),
                                );
                            updateOverlaySize(
                                (screenUtil.screenWidth * 2).toInt(),
                                (screenUtil.screenWidth * 2).toInt());
                          },
                          child: CircleAvatar(
                              child: Text(
                            'L',
                            style: TextStyle(fontSize: 12),
                          )))
                    ],
                  ),
                ),
                const Divider(),
                SizedBox(
                  height: screenUtil.screenHeight * 0.03,
                  child: Row(
                    children: [
                      const Icon(
                        Icons.image_not_supported_rounded,
                        color: Colors.white,
                        size: 18,
                      ),
                      screenUtil.smallHS,
                      const Text(
                        'Alert on stopping video',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.white,
                        ),
                      ),
                      const Spacer(),
                      Checkbox(
                          value: showStopAlert,
                          materialTapTargetSize:
                              MaterialTapTargetSize.shrinkWrap,
                          activeColor: Colors.amber,
                          checkColor: Colors.black,
                          onChanged: (bool) {
                            ref
                                .read(showStopAlertProvider.notifier)
                                .toggleshowStopAlert();
                          }),
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
