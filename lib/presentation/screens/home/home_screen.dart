import 'dart:async';
import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:ed_screen_recorder/ed_screen_recorder.dart';
import 'package:flutter/material.dart';

import 'package:overlay_pop_up/overlay_pop_up.dart';
import 'package:permission_handler/permission_handler.dart';

import 'package:screen_recorder/presentation/widgets/ads/interstitial_ads.dart';
import 'package:screen_recorder/presentation/widgets/facrbook_ads/facebook_ad_helper.dart';
import 'package:screen_recorder/presentation/widgets/my_showcase_widget.dart';
import 'package:screen_recorder/service/my_methods.dart';
import 'package:screen_recorder/service/provider/audio_provider.dart';
import 'package:screen_recorder/service/provider/camera_provider.dart';
import 'package:screen_recorder/service/provider/on_tap_countdown_provider.dart';
import 'package:screen_recorder/service/provider/overlay_provider.dart';
import 'package:screen_recorder/service/provider/overlay_size_provider.dart';
import 'package:screen_recorder/service/provider/recording_directory_provider.dart';
import 'package:screen_recorder/service/provider/screen_recording_provider.dart';
import 'package:screen_recorder/service/provider/show_stop_alert_provider.dart';

import 'package:screen_recorder/service/provider/timer_state_provider.dart';
import 'package:screen_recorder/service/provider/video_quality_provider.dart';
import 'package:screen_recorder/service/recording_functions.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:screen_recorder/presentation/constants/constants.dart';
import 'package:screen_recorder/presentation/constants/my_styles.dart';
import 'package:screen_recorder/presentation/widgets/storage_card.dart';
import 'package:screen_recorder/utils/screen_utils.dart';
import 'package:showcaseview/showcaseview.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

Future<bool> hasSelectedDirectory() async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getBool('folder_selected') ?? false;
}

// Method to set the flag that folder selection is done
Future<void> setFolderSelected() async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setBool('folder_selected', true);
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  final screenRecorder = EdScreenRecorder();
  Timer? timer;
  int elapsedSeconds = 0;
  bool isFirstOpen = true;
  final GlobalKey _one = GlobalKey();
  final GlobalKey _two = GlobalKey();
  final GlobalKey _three = GlobalKey();
  final GlobalKey _four = GlobalKey();

  final RecordingFunctions recordingFunctions = RecordingFunctions();

  @override
  void initState() {
    super.initState();
    checkPermission();
    checkFolderSelection();
    loadSavedDirectory();
    AdManager().loadInterstitialAd();
    showHintsIfNecessary();
  }

  void checkPermission() async {
    if (Platform.isAndroid) {
      final androidInfo = await DeviceInfoPlugin().androidInfo;
      if (androidInfo.version.sdkInt <= 33) {
        if (!await Permission.storage.isGranted &&
            !await Permission.manageExternalStorage.isGranted) {
          await Permission.storage.request();
          await Permission.manageExternalStorage.request();
        }
      }
    }
  }

  //load directory from shared_preference
  Future<void> loadSavedDirectory() async {
    final prefs = await SharedPreferences.getInstance();
    final savedDirectory = prefs.getString('selected_directory');

    if (savedDirectory != null) {
      ref
          .read(recordingDirectoryProvider.notifier)
          .setDirectory(savedDirectory);
    }
  }

// Method to check and show folder selection if necessary
  void checkFolderSelection() async {
    bool folderSelected = await hasSelectedDirectory();
    if (!folderSelected) {
      await showFolderSelection(); // Show folder selection only if not selected before
    }
  }

  Future<void> showFolderSelection() async {
    final selectedDirectory = Directory('/storage/emulated/0/Download/BlueRec');

    if (!await selectedDirectory.exists()) {
      await selectedDirectory.create();
    }

    ref
        .read(recordingDirectoryProvider.notifier)
        .setDirectory(selectedDirectory.path);

    // Save the selected directory and flag
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('selected_directory', selectedDirectory.path);
    await setFolderSelected(); // Set the flag after successful folder selection
  }

  Future<void> showHintsIfNecessary() async {
    final prefs = await SharedPreferences.getInstance();
    final areHintsDisabled = prefs.getBool('home_hints_disabled') ?? false;

    if (!areHintsDisabled) {
      // Start the showcase only if hints are not disabled
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ShowCaseWidget.of(context).startShowCase([
          _one,
          _two,
          _three,
          _four,
        ]);
      });
    }
  }

  Future<void> disableHints() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('home_hints_disabled', true);
  }

  @override
  Widget build(BuildContext context) {
    final screenUtil = ScreenUtil(context);
    final overlaySize = ref.watch(overlaySizeProvider);
    final recordingState = ref.watch(screenRecordingProvider);
    final recordingNotifier = ref.read(screenRecordingProvider.notifier);
    final recordingDirectory = ref.watch(recordingDirectoryProvider);
    final isAudioEnabled = ref.watch(audioProvider);
    final timerNotifier = ref.read(timerProvider.notifier);
    final showStopAlert = ref.watch(showStopAlertProvider);
    int selectedDuration = ref.watch(ontapCountdownProvider);
    final videoQualitySettings = ref.watch(videoSettingsProvider);
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(
          'BlueRec - Screen Recorder',
          style: MyStyles().subHeaderTextStyle.copyWith(color: Colors.white),
        ),
        actions: [
          MyShowcaseWidget(
            showcaseKey: _three,
            description: 'Tap to toggle audio recording.',
            title: 'Microphone',
            onCancel: () {
              ShowCaseWidget.of(context).previous();
            },
            onNext: () {
              ShowCaseWidget.of(context).next();
            },
            onNextText: 'Next',
            onCancelText: 'Back',
            child: IconButton(
              onPressed: () => ref.read(audioProvider.notifier).toggleAudio(),
              icon: Icon(
                Icons.mic,
                color: ref.watch(audioProvider) ? Colors.white : Colors.grey,
              ),
            ),
          ),
          MyShowcaseWidget(
            description:
                'Tap to toggle Floating Button/camera overlay.\nUser can switch between front and back \ncamera using 🔁 on topleft of overlay screen.\nYou can close camera using ❌ on topright \nof overlay screen.\nTap on floating button(timer button) in \noverlay screen to see recording tools.',
            title: 'Overlay helper',
            showcaseKey: _four,
            onCancel: () {
              ShowCaseWidget.of(context).previous();
            },
            onNext: () {
              disableHints();
              ShowCaseWidget.of(context).dismiss();
            },
            onNextText: 'Got it!',
            onCancelText: 'Back',
            child: IconButton(
              onPressed: () async {
                final overlayNotifier = ref.read(overlayProvider.notifier);
                ref.read(cameraProvider.notifier).toggleCamera();
                if (!await OverlayPopUp.checkPermission()) {
                  final status = await OverlayPopUp.requestPermission();
                  if (!status) {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: Text(
                          'Overlay Permission denied, please give overlay permission to use this feature'),
                      action: SnackBarAction(
                        label: 'Open Settings',
                        onPressed: () {
                          openAppSettings();
                        },
                      ),
                    ));
                  }
                } else if (!await Permission.camera.request().isGranted) {
                  await Permission.camera.request();
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text(
                        'Camera Permission is required to properly use Overlay.'),
                    action: SnackBarAction(
                        label: 'Open Settings',
                        onPressed: () {
                          openAppSettings();
                        }),
                  ));
                } else {
                  if (ref.watch(overlayProvider)) {
                    OverlayPopUp.closeOverlay();
                  } else {
                    OverlayPopUp.showOverlay(
                      backgroundBehavior: OverlayFlag.focusable,
                      height: overlaySize.height.toInt(),
                      width: overlaySize.width.toInt(),
                      entryPointMethodName: 'overlayMain',
                      isDraggable: true,
                    );
                  }
                  overlayNotifier.toggleOverlay();
                }
              },
              icon: Image.asset(
                Constants.tooltipIcon,
                width: 24,
                height: 24,
                color: ref.watch(overlayProvider) ? Colors.white : Colors.grey,
              ),
            ),
          )
        ],
        backgroundColor: Colors.transparent,
      ),
      floatingActionButton: recordingState.isRecording
          ? Container(
              width: screenUtil.screenWidth * 0.4,
              height: screenUtil.screenHeight * 0.05,
              padding: EdgeInsets.all(screenUtil.screenHeight * 0.005),
              margin: EdgeInsets.only(
                right: 10,
                bottom: screenUtil.screenHeight * 0.1,
              ),
              decoration: BoxDecoration(
                color: Colors.amber.shade700,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Container(
                    height: screenUtil.screenHeight * 0.05,
                    width: screenUtil.screenWidth * 0.1,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(30),
                      color: Colors.white.withOpacity(0.5),
                    ),
                    child: Text(
                      MyMethods()
                          .formatTime(ref.watch(timerProvider).elapsedSeconds),
                      style: TextStyle(fontSize: screenUtil.screenWidth * 0.02),
                    ),
                  ),
                  GestureDetector(
                    onTap: () async {
                      if (recordingState.isPaused) {
                        recordingFunctions.resumeRecording(
                          recordingState,
                          recordingNotifier,
                          timerNotifier,
                        );
                      } else {
                        recordingFunctions.pauseRecording(
                          recordingState,
                          recordingNotifier,
                          timerNotifier,
                        );
                      }
                    },
                    child: CircleAvatar(
                      backgroundColor: Colors.white.withOpacity(0.5),
                      child: Icon(
                        recordingState.isPaused
                            ? Icons.play_arrow
                            : Icons.pause,
                        color: Colors.red,
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      recordingFunctions.stopRecording(context, timerNotifier,
                          recordingNotifier, screenUtil, showStopAlert);
                    },
                    child: CircleAvatar(
                      backgroundColor: Colors.white.withOpacity(0.5),
                      child: Icon(
                        Icons.stop,
                        color: Colors.red,
                      ),
                    ),
                  ),
                ],
              ),
            )
          : null,
      body: Container(
        padding: EdgeInsets.symmetric(
          horizontal: 16,
          vertical: screenUtil.screenHeight * 0.1,
        ),
        height: screenUtil.screenHeight,
        width: screenUtil.screenWidth,
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage(Constants.homeBackground),
            fit: BoxFit.cover,
          ),
        ),
        child: Column(
          children: [
            screenUtil.smallVS,
            MyShowcaseWidget(
                showcaseKey: _one,
                title: 'Storage Card',
                description:
                    'Shows storage information of the device.\nUpdates on page Change',
                onCancel: () {
                  disableHints();
                  ShowCaseWidget.of(context).dismiss();
                },
                onNext: () {
                  ShowCaseWidget.of(context).next();
                },
                onNextText: 'Next',
                onCancelText: 'Skip',
                child: StorageCard()),
            screenUtil.largeVS,
            !recordingState.isRecording
                ? Container(
                    height: screenUtil.screenWidth * 0.5,
                    width: screenUtil.screenWidth * 0.5,
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image: AssetImage(
                          Constants.startRecord,
                        ),
                      ),
                    ),
                    child: MyShowcaseWidget(
                      showcaseKey: _two,
                      title: 'Start Recording Button',
                      description: 'Tap to start recording',
                      onCancel: () {
                        ShowCaseWidget.of(context).previous();
                      },
                      onNext: () {
                        ShowCaseWidget.of(context).next();
                      },
                      onNextText: 'Next',
                      onCancelText: 'Back',
                      child: GestureDetector(
                        onTap: () {
                          recordingFunctions.startRecording(
                              context,
                              screenUtil,
                              recordingFunctions,
                              recordingNotifier,
                              recordingDirectory,
                              isAudioEnabled,
                              selectedDuration,
                              timerNotifier,
                              showFolderSelection,
                              videoQualitySettings);
                        },
                        child: CircleAvatar(
                          backgroundColor: Colors.transparent,
                        ),
                      ),
                    ),
                  )
                : screenUtil.verySmallVS,
            screenUtil.verySmallVS,
            !recordingState.isRecording
                ? Text(
                    'Tap to start recording',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.5),
                    ),
                  )
                : screenUtil.smallVS,
            // Spacer(),
            // !recordingState.isRecording
            //     ? Align(
            //         alignment: Alignment.bottomCenter,
            //         child: FacebookAdHelper.nativeAd(context))
            //     : screenUtil.smallVS,
          ],
        ),
      ),
    );
  }
}
