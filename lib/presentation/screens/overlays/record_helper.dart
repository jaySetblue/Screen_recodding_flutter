import 'dart:async';
import 'dart:developer';
import 'dart:isolate';
import 'dart:ui';

import 'package:camera_bg/camera.dart';
import 'package:fab_circular_menu_plus/fab_circular_menu_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:overlay_pop_up/overlay_pop_up.dart';
import 'package:screen_recorder/utils/screen_utils.dart';

class RecordHelper extends ConsumerStatefulWidget {
  const RecordHelper({super.key});

  @override
  ConsumerState<RecordHelper> createState() => _RecordHelperState();
}

class _RecordHelperState extends ConsumerState<RecordHelper> {
  static const String _mainAppPort = 'MainApp';
  final receivePort = ReceivePort();
  CameraController? _cameraController;
  bool isRecording = false;
  bool isPaused = false;
  int elapsedTime = 0;
  bool isCameraActive = false;
  bool isFrontCamera = false; // Track if the current camera is front or back
  List<CameraDescription> cameras = []; // List of available cameras
  int height = 100;
  int width = 100;
  final GlobalKey<FabCircularMenuPlusState> fabKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _initializeCamera();
    OverlayPopUp.dataListener?.listen((onData) {
      if (onData['time'] != null) {
        setState(() {
          elapsedTime = (onData['time']);
          isRecording = onData['isRecording'];
          isPaused = onData['isPaused'];
          height = onData['height'];
          width = onData['width'];
          // isCameraActive = onData['cameraActive'];
        });
      }
    });
  }

  // Initialize camera
  void _initializeCamera() async {
    cameras = await availableCameras();
    if (cameras.length > 1) {
      _setCamera(cameras[isFrontCamera ? 1 : 0]);
    } else if (cameras.isNotEmpty) {
      _setCamera(cameras[0]);
    } else {
      log("No cameras available");
    }
  }

  // Set camera based on index (front or rear)
  void _setCamera(CameraDescription camera) async {
    _cameraController = CameraController(
      camera,
      ResolutionPreset.high,
      enableAudio: false, // Disable audio for the camera (optional)
    );

    // Initialize the camera
    try {
      await _cameraController!.initialize();
      if (mounted) {
        // Ensure widget is still mounted
        setState(() {
          isCameraActive = true;
        });
      }
    } catch (e) {
      // Handle error (e.g., permission issue, camera unavailable)
      log("Error initializing camera: $e");
    }
  }

  // Switch between front and rear cameras
  void _switchCamera() {
    // _setCamera(cameras[isFrontCamera ? 1 : 0]);
    isFrontCamera = !isFrontCamera;
    _setCamera(cameras[isFrontCamera ? 1 : 0]); // Switch to the other camera
  }

  // Close camera
  void _closeCamera() {
    // _cameraController?.dispose();

    setState(() {
      isCameraActive = false;
    });
  }

  /// Sends an action to the main application isolate.
  ///
  /// This method looks up the main application port by name and sends the specified action
  /// to it. If the port is not found, it logs an error message.
  ///
  /// Parameters:
  /// - action: A string representing the action to be sent to the main application.
  void sendActionToMain(String action) {
    final mainAppPort = IsolateNameServer.lookupPortByName(_mainAppPort);
    if (mainAppPort != null) {
      mainAppPort.send({'action': action});
    } else {
      log('MainApp port not found');
    }
  }

  Stream<dynamic>? getOverlayData() {
    return OverlayPopUp.dataListener;
  }

  void _reopenCamera() {
    setState(() {
      isCameraActive = true;
    });
    if (_cameraController == null) {
      _initializeCamera();
    }
  }

  @override
  void dispose() {
    IsolateNameServer.removePortNameMapping(_mainAppPort);
    _cameraController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenUtil = ScreenUtil(context);

    return Scaffold(
      backgroundColor: Colors.transparent,
      floatingActionButton: FabCircularMenuPlus(
        key: fabKey,
        fabMargin: EdgeInsets.all(0),
        fabSize: 36,
        ringDiameter: 150,
        ringColor: Colors.transparent,
        fabOpenColor: Colors.transparent,
        fabCloseColor: Colors.transparent,
        alignment: Alignment.bottomRight,
        animationCurve: Curves.ease,
        fabOpenIcon: Text(
          formatDuration(Duration(seconds: elapsedTime)),
          style: TextStyle(
            fontSize: 10,
            color: Colors.white,
          ),
        ),
        fabCloseIcon: Text(
          formatDuration(Duration(seconds: elapsedTime)),
          style: TextStyle(
            fontSize: 10,
            color: Colors.white,
          ),
        ),
        children: [
          !isRecording
              ? IconButton(
                  splashColor: Colors.white,
                  iconSize: 14,
                  enableFeedback: true,
                  onPressed: () {
                    sendActionToMain('startRecording');
                  },
                  padding: const EdgeInsets.all(10.0),
                  icon:
                      const Icon(Icons.radio_button_checked, color: Colors.red),
                )
              : IconButton(
                  splashColor: Colors.white,
                  iconSize: 14,
                  enableFeedback: true,
                  onPressed: () {
                    FlutterForegroundTask.launchApp('/home');
                    sendActionToMain('stopRecording');
                  },
                  padding: const EdgeInsets.all(10.0),
                  icon: const Icon(Icons.stop, color: Colors.red),
                ),
          !isPaused
              ? IconButton(
                  splashColor: Colors.white,
                  iconSize: 14,
                  enableFeedback: true,
                  onPressed: isRecording
                      ? () {
                          sendActionToMain('pauseRecording');
                        }
                      : () {},
                  padding: const EdgeInsets.all(10.0),
                  icon: const Icon(Icons.pause, color: Colors.red),
                )
              : IconButton(
                  splashColor: Colors.white,
                  iconSize: 14,
                  enableFeedback: true,
                  onPressed: () {
                    sendActionToMain('resumeRecording');
                  },
                  padding: const EdgeInsets.all(10.0),
                  icon: const Icon(Icons.play_arrow_rounded, color: Colors.red),
                ),
          IconButton(
            splashColor: Colors.white,
            iconSize: 14,
            enableFeedback: true,
            onPressed: _reopenCamera,
            padding: const EdgeInsets.all(10.0),
            icon: Icon(
              !isCameraActive ? Icons.camera_alt_outlined : Icons.camera_alt,
              color: Colors.red,
            ),
          ),
          IconButton(
            splashColor: Colors.white,
            iconSize: 14,
            enableFeedback: true,
            onPressed: () {
              sendActionToMain('closeOverlay');
            },
            padding: const EdgeInsets.all(10.0),
            icon: const Icon(Icons.close_sharp, color: Colors.red),
          ),
        ],
      ),
      body: isCameraActive
          ? Container(
              width: screenUtil.screenWidth,
              height: screenUtil.screenHeight,
              decoration:
                  BoxDecoration(borderRadius: BorderRadius.circular(20)),
              child: Stack(
                children: [
                  _cameraController != null &&
                          _cameraController!.value.isInitialized &&
                          mounted
                      ? Container(
                          height: screenUtil.screenHeight,
                          width: screenUtil.screenWidth,
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20)),
                          child: ClipRRect(
                              borderRadius: BorderRadius.circular(20),
                              child: CameraPreview(_cameraController!)),
                        )
                      : Container(),
                  Positioned(
                    top: 0,
                    right: 0,
                    child: IconButton(
                      icon: Icon(
                        Icons.close,
                        color: Colors.black.withOpacity(0.5),
                      ),
                      onPressed: _closeCamera,
                    ),
                  ),
                  Positioned(
                    top: 0,
                    left: 0,
                    child: IconButton(
                      icon: Icon(
                        Icons.cameraswitch_sharp,
                        color: Colors.black.withOpacity(0.5),
                      ),
                      onPressed: _switchCamera,
                    ),
                  ),
                  // Positioned(
                  //   bottom: 0,
                  //   left: 0,
                  //   child: IconButton(
                  //     icon: Icon(Icons.mic),
                  //     onPressed: _switchCamera,
                  //   ),
                  // ),
                ],
              ),
            )
          : null,
    );
  }

  // Format the elapsed time in minutes and seconds
  String formatDuration(Duration duration) {
    final minutes = duration.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }
}
