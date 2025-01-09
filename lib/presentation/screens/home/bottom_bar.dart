import 'dart:async';
import 'dart:io';
import 'dart:isolate';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:overlay_pop_up/overlay_pop_up.dart';
import 'package:screen_recorder/presentation/screens/home/home_screen.dart';
import 'package:screen_recorder/presentation/screens/recorded_videos/recorded_videos_screen.dart';
import 'package:screen_recorder/presentation/screens/settings/settings_screen.dart';
import 'package:screen_recorder/presentation/widgets/countdown_dropdown.dart';
import 'package:screen_recorder/service/provider/audio_provider.dart';
import 'package:screen_recorder/service/provider/camera_provider.dart';
import 'package:screen_recorder/service/provider/overlay_provider.dart';
import 'package:screen_recorder/service/provider/overlay_size_provider.dart';
import 'package:screen_recorder/service/provider/recording_directory_provider.dart';
import 'package:screen_recorder/service/provider/screen_recording_provider.dart';
import 'package:screen_recorder/service/provider/show_stop_alert_provider.dart';
import 'package:screen_recorder/service/provider/timer_state_provider.dart';
import 'package:screen_recorder/service/provider/video_quality_provider.dart';
import 'package:screen_recorder/service/recording_functions.dart';
import 'package:screen_recorder/utils/screen_utils.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:showcaseview/showcaseview.dart';

class BottomBar extends ConsumerStatefulWidget {
  const BottomBar({super.key});

  @override
  ConsumerState<BottomBar> createState() => _BottomBarState();
}

class _BottomBarState extends ConsumerState<BottomBar> {
  int _page = 1;
  double bottomNavBarWidth = 42;
  double bottomNavBarBorderWidth = 5;
  static const String _mainAppPort = 'MainApp';
  final _receivePort = ReceivePort();
  Timer? _updateTimer;
  Timer? timer;
  int elapsedSeconds = 0;
  final RecordingFunctions recordingFunctions = RecordingFunctions();
  bool isFirstOpen = true; // Keep track of first open state

  bool isShowcased = false;

  Future<void> _checkFirstLaunch() async {
    final prefs = await SharedPreferences.getInstance();
    bool? isFirstLaunch = prefs.getBool('isFirstLaunch');

    if (isFirstLaunch == null || isFirstLaunch) {
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

  Future<void> showFolderSelection() async {
    final selectedDirectory = Directory('/storage/emulated/0/Download/BlueRec');

    if (!await selectedDirectory.exists()) {
      await selectedDirectory.create();
    }
    ref
        .read(recordingDirectoryProvider.notifier)
        .setDirectory(selectedDirectory.path);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('selected_directory', selectedDirectory.path);
    await setFolderSelected();
  }

  @override
  void initState() {
    super.initState();
    _checkFirstLaunch();
    _registerIsolateCommunication();
    _startOverlayUpdateLoop();
  }

  void startTimer() {
    timer = Timer.periodic(const Duration(seconds: 1), (Timer t) {
      if (!ref.read(screenRecordingProvider).isPaused) {
        setState(() {
          elapsedSeconds++;
        });
      }
    });
  }

  void stopTimer() {
    timer?.cancel();
    setState(() {
      elapsedSeconds = 0;
    });
  }

  void _registerIsolateCommunication() {
    IsolateNameServer.registerPortWithName(
      _receivePort.sendPort,
      _mainAppPort,
    );
    _receivePort.listen(_handleIsolateMessage);
  }

  void _startOverlayUpdateLoop() {
    _updateTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      // final recordingState = ref.read(screenRecordingProvider);
      // final elapsedTime = ref.read(timerProvider).elapsedSeconds;
      final overlaySize = ref.watch(overlaySizeProvider);
      OverlayPopUp.sendToOverlay({
        'time': ref.watch(timerProvider).elapsedSeconds,
        'isRecording': ref.watch(screenRecordingProvider).isRecording,
        'isPaused': ref.watch(screenRecordingProvider).isPaused,
        'width': overlaySize.width.toInt(),
        'height': overlaySize.height.toInt(),
      });
    });
  }

  void _handleIsolateMessage(dynamic message) async {
    if (message is Map) {
      final isAudioEnabled = ref.watch(audioProvider);

      switch (message['action']) {
        case 'startRecording':
          await recordingFunctions.startRecording(
              context,
              ScreenUtil(context),
              recordingFunctions,
              ref.read(screenRecordingProvider.notifier),
              ref.watch(recordingDirectoryProvider),
              isAudioEnabled,
              ref.watch(countdownDurationProvider),
              ref.read(timerProvider.notifier),
              showFolderSelection,
              ref.watch(videoSettingsProvider));
          break;
        case 'stopRecording':
          recordingFunctions.stopRecording(
              context,
              ref.read(timerProvider.notifier),
              ref.read(screenRecordingProvider.notifier),
              ScreenUtil(context),
              ref.watch(showStopAlertProvider));
          break;
        case 'pauseRecording':
          recordingFunctions.pauseRecording(
              ref.watch(screenRecordingProvider),
              ref.read(screenRecordingProvider.notifier),
              ref.read(timerProvider.notifier));
          break;
        case 'resumeRecording':
          recordingFunctions.resumeRecording(
              ref.watch(screenRecordingProvider),
              ref.read(screenRecordingProvider.notifier),
              ref.read(timerProvider.notifier));
          break;
        case 'cameraTapped':
          ref.read(cameraProvider.notifier).toggleCamera();
          break;
        case 'closeOverlay':
          OverlayPopUp.closeOverlay();
          ref.read(overlayProvider.notifier).toggleOverlay();
          break;
      }
    }
  }

  List<Widget> pages = [
    const RecordedVideosScreen(),
    const HomeScreen(),
    const SettingsScreen(),
  ];

  void updatePage(int page) {
    setState(() {
      _page = page;
    });
  }

  @override
  void dispose() {
    _updateTimer?.cancel();
    IsolateNameServer.removePortNameMapping(_mainAppPort);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      extendBody: true,
      body: ShowCaseWidget(
        disableBarrierInteraction: true,
        autoPlay: false,
        builder: (context) => pages[_page],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _page,
        elevation: 20,
        backgroundColor: Colors.transparent,
        selectedItemColor: Colors.amber,
        iconSize: 24,
        unselectedItemColor: Colors.white54,
        showUnselectedLabels: false,
        showSelectedLabels: true,
        onTap: updatePage,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.folder),
            label: 'Recorded Videos',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.radio_button_checked_rounded),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.settings,
            ),
            label: 'Settings',
          ),
        ],
      ),
    );
  }
}
