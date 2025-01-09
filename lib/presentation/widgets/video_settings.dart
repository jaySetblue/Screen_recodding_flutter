import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:screen_recorder/presentation/constants/my_styles.dart';
import 'package:screen_recorder/presentation/widgets/frame_rate_dropdown.dart';
import 'package:screen_recorder/presentation/widgets/video_quality_dropdown.dart';
import 'package:screen_recorder/service/provider/audio_provider.dart';

import 'package:screen_recorder/utils/screen_utils.dart';
import 'package:shared_preferences/shared_preferences.dart';

class VideoSettings extends ConsumerStatefulWidget {
  const VideoSettings({super.key});

  @override
  ConsumerState<VideoSettings> createState() => _VideoSettingsState();
}

class _VideoSettingsState extends ConsumerState<VideoSettings> {
  bool isVideoTapped = false;
  double videoSegment = 10.0;

  String? dir;

  Future<String?> getDirectoryFromPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('selected_directory');
  }

  Future<void> getDirectory() async {
    final direcrory = await getDirectoryFromPreferences();
    setState(() {
      dir = direcrory;
    });
  }

  @override
  void initState() {
    super.initState();
    getDirectory();
  }

  @override
  Widget build(
    BuildContext context,
  ) {
    final screenUtil = ScreenUtil(context);
    bool isAudioEnabled = ref.watch(audioProvider);

    //final isCameraEnabled = ref.watch(cameraProvider);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: () {
            setState(() {
              isVideoTapped = !isVideoTapped;
            });
          },
          child: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(10),
                topRight: Radius.circular(10),
              ),
              color: Colors.white.withOpacity(0.4),
              border: Border.all(color: Colors.grey, width: 1),
            ),
            child: GestureDetector(
              onTap: () {
                setState(() {
                  isVideoTapped = !isVideoTapped;
                });
              },
              child: Row(
                children: [
                  Text(
                    'Video Settings',
                    style: MyStyles()
                        .subHeaderTextStyle
                        .copyWith(color: Colors.black, fontSize: 15),
                  ),
                  const Spacer(),
                  !isVideoTapped
                      ? const Icon(Icons.arrow_drop_down)
                      : const Icon(Icons.arrow_drop_up),
                ],
              ),
            ),
          ),
        ),
        if (isVideoTapped)
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
                SizedBox(
                  height: screenUtil.screenHeight * 0.03,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.mic,
                        color: Colors.white,
                        size: 18,
                      ),
                      screenUtil.smallHS,
                      const Text(
                        'Audio Settings',
                        style: TextStyle(color: Colors.white, fontSize: 12),
                      ),
                      const Spacer(),
                      !isAudioEnabled
                          ? IconButton(
                              onPressed: () {
                                ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                        content: Text('Audio Enabled')));

                                ref.read(audioProvider.notifier).toggleAudio();
                              },
                              icon: const Icon(
                                Icons.mic,
                                color: Colors.white,
                                size: 18,
                              ),
                            )
                          : IconButton(
                              onPressed: () {
                                ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                        content: Text('Audio Disabled')));
                                ref.read(audioProvider.notifier).toggleAudio();
                              },
                              icon: const Icon(
                                Icons.mic_off,
                                color: Colors.white,
                                size: 18,
                              ),
                            )
                    ],
                  ),
                ),
                Divider(),
                SizedBox(
                  height: screenUtil.screenHeight * 0.03,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.hd_outlined,
                        color: Colors.white,
                        size: 18,
                      ),
                      screenUtil.smallHS,
                      const Text(
                        'Video Quality',
                        style: TextStyle(color: Colors.white, fontSize: 12),
                      ),
                      const Spacer(),
                      VideoQualityDropdown()
                    ],
                  ),
                ),
                Divider(),
                SizedBox(
                  height: screenUtil.screenHeight * 0.03,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.recent_actors_outlined,
                        color: Colors.white,
                        size: 18,
                      ),
                      screenUtil.smallHS,
                      const Text(
                        'Frame Rate',
                        style: TextStyle(color: Colors.white, fontSize: 12),
                      ),
                      const Spacer(),
                      FrameRateDropdown()
                    ],
                  ),
                ),
                // screenUtil.verySmallVS,
                // const Divider(),
                // Container(
                //   height: screenUtil.screenHeight * 0.03,
                //   child: Row(
                //     crossAxisAlignment: CrossAxisAlignment.center,
                //     children: [
                //       const Icon(
                //         Icons.camera_alt,
                //         color: Colors.white,
                //         size: 18,
                //       ),
                //       screenUtil.smallHS,
                //       const Text(
                //         'Camera Settings',
                //         style: TextStyle(color: Colors.white, fontSize: 12),
                //       ),
                //       const Spacer(),
                //       !isAudioEnabled
                //           ? IconButton(
                //               onPressed: () {
                //                 ScaffoldMessenger.of(context).showSnackBar(
                //                     const SnackBar(
                //                         content: Text('Camera Enabled')));
                //                 ref
                //                         .read(isAudioEnabledProvider.notifier)
                //                         .state =
                //                     !ref
                //                         .read(isAudioEnabledProvider.notifier)
                //                         .state;
                //               },
                //               icon: const Icon(
                //                 Icons.camera_alt,
                //                 color: Colors.white,
                //                 size: 18,
                //               ),
                //             )
                //           : IconButton(
                //               onPressed: () {
                //                 ScaffoldMessenger.of(context).showSnackBar(
                //                     const SnackBar(
                //                         content: Text('Camera Disabled')));
                //                 ref
                //                         .read(isAudioEnabledProvider.notifier)
                //                         .state =
                //                     !ref
                //                         .read(isAudioEnabledProvider.notifier)
                //                         .state;
                //               },
                //               icon: const Icon(
                //                 Icons.camera,
                //                 color: Colors.white,
                //                 size: 18,
                //               ),
                //             )
                //     ],
                //   ),
                // ),
                Divider(),
                SizedBox(
                  height: screenUtil.screenHeight * 0.07,
                  child: Row(
                    children: [
                      const Icon(
                        Icons.folder,
                        color: Colors.white,
                        size: 18,
                      ),
                      screenUtil.smallHS,
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Save Location',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.white,
                            ),
                          ),
                          Text(
                            // '/storage/emulated/0/Android/data/com.example.screen_recorder\n/files/ScreenRecorder/',
                            dir ?? 'Not available',
                            softWrap: true,
                            maxLines: 2,
                            style: const TextStyle(
                              fontSize: 8,
                              color: Colors.white,
                            ),
                          )
                        ],
                      ),
                    ],
                  ),
                ),
                screenUtil.veryVerySmallVS,
              ],
            ),
          )
      ],
    );
  }
}
