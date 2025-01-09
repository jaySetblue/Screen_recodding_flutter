import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_timer_countdown/flutter_timer_countdown.dart';
import 'package:get_thumbnail_video/index.dart';
import 'package:get_thumbnail_video/video_thumbnail.dart';
import 'package:path_provider/path_provider.dart';
import 'package:screen_recorder/utils/screen_utils.dart';

class MyMethods {
  void showCountdownDialog(BuildContext context,
      {required int countdownValue, required VoidCallback onCountdownEnd}) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Container(
        alignment: Alignment.center,
        child: TimerCountdown(
          secondsDescription: '',
          timeTextStyle: TextStyle(
            backgroundColor: Colors.transparent,
            color: Colors.amber,
            fontSize: ScreenUtil(context).screenWidth * 0.2,
          ),
          format: CountDownTimerFormat.secondsOnly,
          endTime: DateTime.now().add(Duration(seconds: countdownValue)),
          onEnd: () {
            Navigator.pop(context);
            onCountdownEnd();
          },
        ),
      ),
    );
  }

  String formatTime(int seconds) {
    final minutes = (seconds ~/ 60).toString().padLeft(2, '0');
    final remainingSeconds = (seconds % 60).toString().padLeft(2, '0');
    return '$minutes:$remainingSeconds';
  }

  Future<Image?> generateThumbnail(String filePath) async {
    try {
      final tempDir = await getTemporaryDirectory();
      final thumbnailPath = await VideoThumbnail.thumbnailFile(
        video: filePath,
        thumbnailPath: tempDir.path,
        imageFormat: ImageFormat.PNG,
        maxHeight: 300,
        quality: 100,
      );
      return Image.file(File(thumbnailPath.path), fit: BoxFit.cover);
    } catch (e) {
      debugPrint("Error generating thumbnail: $e");
      return null;
    }
  }
}
