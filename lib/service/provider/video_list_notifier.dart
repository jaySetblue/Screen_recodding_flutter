import 'dart:io';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter_video_info/flutter_video_info.dart';
import 'package:get_thumbnail_video/index.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get_thumbnail_video/video_thumbnail.dart';
import 'package:screen_recorder/data/model/video_info.dart';

class VideoListNotifier extends StateNotifier<List<VideoInfo>> {
  VideoListNotifier() : super([]);

  bool isLoading = false;

  Future<void> fetchVideos(String directoryPath) async {
    isLoading = true;

    try {
      final videoDirectory = Directory(directoryPath);

      if (!await videoDirectory.exists()) return;

      final videoInfo = FlutterVideoInfo();
      final files = videoDirectory.listSync().whereType<File>();

      final tempVideos = await Future.wait(files.map((file) async {
        final videoData = await videoInfo.getVideoInfo(file.path);
        final thumbnail = await _generateThumbnail(file.path);
        // final videoTime = extractLastTime(file.path);

        return videoData == null
            ? null
            : VideoInfo(
                path: file.path,
                title: videoData.title ?? "Unknown",
                size: (videoData.filesize ?? 0) / (1024 * 1024),
                duration: (videoData.duration ?? 0) / 1000,
                date: videoData.date ?? "Unknown Date",
                thumbnail: thumbnail,
              );
      }));

      state = tempVideos.whereType<VideoInfo>().toList();
    } catch (e) {
      log("Error fetching video files: $e");
    } finally {
      isLoading = false;
    }
  }

  Future<Image?> _generateThumbnail(String filePath) async {
    try {
      final tempDir = await getTemporaryDirectory();
      final thumbnailPath = await VideoThumbnail.thumbnailFile(
        video: filePath,
        thumbnailPath: tempDir.path,
        imageFormat: ImageFormat.PNG,
        maxHeight: 300,
        quality: 100,
      );
      return Image.file(File(thumbnailPath.path));
    } catch (e) {
      log("Error generating thumbnail: $e");
      return null;
    }
  }

  String? extractLastTime(String filePath) {
    RegExp timeRegex = RegExp(r"(\d{2}-\d{2}-\d{2})");
    final matches = timeRegex.allMatches(filePath);
    if (matches.isNotEmpty) {
      return matches.last.group(1)!.replaceAll('-', ':');
    }
    return null;
  }

  void deleteVideo(String path) async {
    try {
      final file = File(path);
      if (await file.exists()) {
        await file.delete();
        state = state.where((video) => video.path != path).toList();
      }
    } catch (e) {
      log("Error deleting video: $e");
    }
  }
}
