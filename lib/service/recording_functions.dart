import 'dart:async';
import 'dart:developer';
import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:ed_screen_recorder/ed_screen_recorder.dart';
import 'package:flutter/material.dart';
import 'package:open_file/open_file.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:screen_recorder/presentation/constants/my_styles.dart';
import 'package:screen_recorder/presentation/screens/editor/video_editor_screen.dart';
import 'package:screen_recorder/presentation/screens/home/home_screen.dart';
import 'package:screen_recorder/presentation/widgets/ads/banner_ads.dart';
import 'package:screen_recorder/presentation/widgets/facrbook_ads/facebook_ad_helper.dart';
import 'package:screen_recorder/service/my_methods.dart';
import 'package:screen_recorder/service/provider/screen_recording_provider.dart';
import 'package:screen_recorder/service/provider/timer_state_provider.dart';
import 'package:screen_recorder/service/provider/video_quality_provider.dart';
import 'package:screen_recorder/utils/screen_utils.dart';
import 'package:share_plus/share_plus.dart';
import 'package:uuid/uuid.dart';

class RecordingFunctions {
  Timer? timer;
  int elapsedSeconds = 0;
  int selectedDuration = 5;
  final screenRecorder = EdScreenRecorder();

  //Stop recording
  Future<void> stopRecording(
    BuildContext context,
    TimerNotifier timerNotifier,
    ScreenRecordingNotifier recordingNotifier,
    ScreenUtil screenUtil,
    bool stopAlert,
  ) async {
    try {
      // Show loading indicator
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(child: CircularProgressIndicator()),
      );

      // Stop recording
      final stopResponse = await screenRecorder.stopRecord();

      if (!stopResponse.success) {
        throw Exception("Error stopping the recording.");
      }

      timerNotifier.stopTimer();

      recordingNotifier.stopRecording();

      // Generate thumbnail
      Image? img;
      try {
        img = await MyMethods().generateThumbnail(stopResponse.file.path);
      } catch (e) {
        throw Exception("Error generating thumbnail: $e");
      }

      // Dismiss loading indicator
      Navigator.of(context).pop();

      // Show dialog with recording information
      !stopAlert
          ? ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text('Recording Saved at: ${stopResponse.file.path}'),
              action: SnackBarAction(
                  label: 'Open Video',
                  onPressed: () {
                    OpenFile.open(stopResponse.file.path);
                  }),
            ))
          : showDialog(
              context: context,
              builder: (context) => AlertDialog(
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Recording Saved',
                            style: MyStyles().subHeaderTextStyle),
                        IconButton(
                          onPressed: () => Navigator.of(context).pop(),
                          icon: Icon(Icons.close),
                        ),
                      ],
                    ),
                    Text(
                      'File Location: ${stopResponse.file.absolute.path}',
                      softWrap: true,
                      maxLines: 3,
                      style: TextStyle(fontSize: 10),
                      textAlign: TextAlign.justify,
                    ),
                    screenUtil.smallVS,
                    SizedBox(
                      height: 300,
                      width: 200,
                      child: Stack(
                        children: [
                          Center(child: img),
                          Center(
                            child: CircleAvatar(
                              backgroundColor: Colors.white12,
                              child: IconButton(
                                onPressed: () =>
                                    OpenFile.open(stopResponse.file.path),
                                icon: Icon(Icons.play_arrow,
                                    size: 22,
                                    color: Colors.red.withOpacity(0.7)),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                actions: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => VideoEditor(
                                  file: XFile(stopResponse.file.path)),
                            ),
                          );
                        },
                        child: const Column(
                          children: [
                            Icon(Icons.cut),
                            Text('Edit'),
                          ],
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          Share.shareXFiles(
                            [XFile(stopResponse.file.path)],
                            text: 'Hey, check out this video!',
                          );
                        },
                        child: const Column(
                          children: [
                            Icon(Icons.share),
                            Text('Share'),
                          ],
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: const Text('Confirm Delete'),
                              content: const Text(
                                  'Are you sure you want to delete this file?'),
                              actions: [
                                TextButton(
                                  onPressed: () {
                                    File(stopResponse.file.path).deleteSync();
                                    Navigator.of(context)
                                        .pop(); // Close confirmation dialog
                                    Navigator.of(context)
                                        .pop(); // Close main dialog
                                  },
                                  child: const Text('Delete'),
                                ),
                                TextButton(
                                  onPressed: () => Navigator.of(context).pop(),
                                  child: const Text('Cancel'),
                                ),
                              ],
                            ),
                          );
                        },
                        child: const Column(
                          children: [
                            Icon(Icons.delete),
                            Text('Delete'),
                          ],
                        ),
                      ),
                    ],
                  ),
                  screenUtil.smallVS,
                  // FacebookAdHelper.nativeAd(context),
                ],
              ),
            );
    } catch (e) {
      // Show error message
      Navigator.of(context).pop(); // Dismiss loading dialog
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    }
  }

  int _getBitRate(VideoQuality quality) {
    switch (quality) {
      case VideoQuality.high:
        return 5000000;
      case VideoQuality.medium:
        return 3000000;
      case VideoQuality.low:
        return 1000000;
    }
  }

  Future<void> startRecording(
    BuildContext context,
    ScreenUtil screenUtil,
    RecordingFunctions recordingFunctions,
    ScreenRecordingNotifier recordingNotifier,
    String? recordingDirectory,
    bool isAudioEnabled,
    int selectedDuration,
    TimerNotifier timerNotifier,
    Future<void> Function() showFolderSelection,
    VideoSettings videoQualitySettings,
  ) async {
    final bitRate = _getBitRate(videoQualitySettings.quality);
    // Ensure the folder is selected
    if (recordingDirectory == null) {
      if (!await _ensureFolderSelected(
          context, recordingDirectory, showFolderSelection)) {
        return; // Exit if directory is not selected
      }
    }
    if (Platform.isAndroid) {
      if (!await _isAndroid13OrHigher()) {
        log('Android <13');
        // Check permissions concurrently
        if (!await Permission.storage.isGranted &&
            !await Permission.manageExternalStorage.isGranted) {
          if (Platform.isAndroid && !await _isAndroid13OrHigher()) {
            Permission.storage.request();
          }
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text('Storage and Media Permissions are required'),
              action: SnackBarAction(
                  label: 'Open Settings',
                  onPressed: () {
                    openAppSettings();
                  }),
            ));
          }
          return;
        }

        if (isAudioEnabled) {
          if (!await Permission.audio.isGranted &&
              !await Permission.microphone.isGranted) {
            await Permission.audio.request();
            await Permission.microphone.request();
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: Text('Audio Permission is required to record audio'),
                action: SnackBarAction(
                    label: 'open Settings',
                    onPressed: () {
                      openAppSettings();
                    }),
              ));
            }
            return;
          }
          // Exit if permissions are not granted
        }
      }
    }

    final fileName = 'Record_${Uuid().v4()}';
    final startResponse = await screenRecorder.startRecordScreen(
        fileName: fileName,
        dirPathToSave: recordingDirectory!,
        width: screenUtil.screenWidth.toInt(),
        height: screenUtil.screenHeight.toInt(),
        audioEnable: isAudioEnabled,
        videoFrame: videoQualitySettings.frameRate,
        videoBitrate: bitRate);
    if (startResponse.success) {
      if (context.mounted) {
        showDialog(
            context: context,
            barrierDismissible: true,
            barrierColor: Colors.transparent,
            builder: (BuildContext context) {
              return AlertDialog(
                content: Container(
                    width: 100,
                    height: 50,
                    alignment: Alignment.center,
                    decoration:
                        BoxDecoration(color: Colors.white.withAlpha(25)),
                    child: Row(
                      children: [
                        Text(
                          'Waiting for recording to start ....',
                          style: TextStyle(fontSize: 10),
                        ),
                        CircularProgressIndicator(),
                      ],
                    )),
              );
            });
      }
      screenRecorder.pauseRecord();
      if (context.mounted) {
        Navigator.pop(context);
      }
      MyMethods().showCountdownDialog(context, countdownValue: selectedDuration,
          onCountdownEnd: () {
        screenRecorder.resumeRecord();

        recordingNotifier.startRecording();
        timerNotifier.startTimer();
      });
    } else {
      return;
    }
  }

  /// Ensure the user has selected a folder for saving recordings
  Future<bool> _ensureFolderSelected(
      BuildContext context,
      String? recordingDirectory,
      Future<void> Function() showFolderSelection) async {
    if (recordingDirectory == null || !await hasSelectedDirectory()) {
      if (recordingDirectory == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Please select a directory before recording.'),
            action: SnackBarAction(
              label: 'Select Folder',
              onPressed: () async {
                await showFolderSelection();
              },
            ),
          ),
        );
        return false;
      }
    }
    return true;
  }

  // /// Check if the Android version is SDK 33 (Android 13) or above
  Future<bool> _isAndroid13OrHigher() async {
    return Platform.isAndroid && (await _getSdkVersion()) >= 33;
  }

  /// Helper function to get the SDK version of the device
  Future<int> _getSdkVersion() async {
    final androidInfo = await DeviceInfoPlugin().androidInfo;

    return androidInfo.version.sdkInt;
  }

  Future<void> pauseRecording(
      RecordingState recordingState,
      ScreenRecordingNotifier recordingNotifier,
      TimerNotifier timerNotifier) async {
    await screenRecorder.pauseRecord();
    recordingNotifier.pauseRecording();
    timerNotifier.pauseTimer();
  }

  Future<void> resumeRecording(
      RecordingState recordingState,
      ScreenRecordingNotifier recordingNotifier,
      TimerNotifier timerNotifier) async {
    await screenRecorder.resumeRecord();
    recordingNotifier.resumeRecording();
    timerNotifier.resumeTimer();
  }
}
