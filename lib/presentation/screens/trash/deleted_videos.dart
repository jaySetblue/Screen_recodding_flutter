import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_video_info/flutter_video_info.dart';
import 'package:get_thumbnail_video/index.dart';
import 'package:get_thumbnail_video/video_thumbnail.dart';
import 'package:path_provider/path_provider.dart';
import 'package:screen_recorder/data/model/video_info.dart';
import 'package:screen_recorder/presentation/constants/constants.dart';
import 'package:screen_recorder/presentation/widgets/recorded_video_tile.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DeletedVideos extends StatefulWidget {
  const DeletedVideos({super.key});

  @override
  State<DeletedVideos> createState() => _DeletedVideosState();
}

class _DeletedVideosState extends State<DeletedVideos> {
  final String folderName = 'DeletedVideos';
  List<VideoInfo> deletedVideos = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchDeletedVideos();
  }

  Future<void> _fetchDeletedVideos() async {
    setState(() => isLoading = true);

    try {
      final dir = Platform.isAndroid
          ? await getExternalStorageDirectory()
          : await getApplicationSupportDirectory();

      if (dir == null) return;

      final deletedVideosDirectory = Directory("${dir.path}/$folderName");

      if (await deletedVideosDirectory.exists()) {
        final videoInfo = FlutterVideoInfo();
        final files = deletedVideosDirectory.listSync().whereType<File>();

        final now = DateTime.now();
        final tempVideos = await Future.wait(files.map((file) async {
          final lastModified = await file.lastModified();
          final ageInHours = now.difference(lastModified).inHours;

          // Delete file if older than 24 hours
          if (ageInHours > 24) {
            await file.delete();
            return null;
          }

          // Fetch video info and thumbnail
          final videoData = await videoInfo.getVideoInfo(file.path);
          final thumbnail = await _generateThumbnail(file.path);

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

        setState(() {
          deletedVideos = tempVideos.whereType<VideoInfo>().toList();
        });
      }
    } catch (e) {
      debugPrint("Error fetching deleted videos: $e");
    } finally {
      setState(() => isLoading = false);
    }
  }

  String? extractLastTime(String filePath) {
    // Regular expression to match time in the format HH-MM-SS
    RegExp timeRegex = RegExp(r"(\d{2}-\d{2}-\d{2})");

    // Find all matches
    Iterable<Match> matches = timeRegex.allMatches(filePath);

    // Get the last match if available
    if (matches.isNotEmpty) {
      String lastMatch = matches.last
          .group(1)!; // Get the last matched time in HH-MM-SS format
      return lastMatch.replaceAll('-', ':'); // Return the last matched time
    }
    return null; // Return null if no time is found
  }

  Future<void> _deleteVideo(String path) async {
    try {
      final file = File(path);
      if (await file.exists()) {
        await file.delete();
        setState(() {
          deletedVideos.removeWhere((video) => video.path == path);
        });
      }
    } catch (e) {
      debugPrint("Error deleting video: $e");
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
      return Image.file(File(thumbnailPath.path), fit: BoxFit.cover);
    } catch (e) {
      debugPrint("Error generating thumbnail: $e");
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          'Deleted Videos',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
        ),
        backgroundColor: Colors.transparent,
      ),
      body: Container(
        padding: const EdgeInsets.all(16.0),
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage(Constants.homeBackground),
            fit: BoxFit.cover,
          ),
        ),
        child: isLoading
            ? const Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : deletedVideos.isEmpty
                ? const Center(
                    child: Text(
                      'No Deleted Videos',
                      style: TextStyle(color: Colors.white),
                    ),
                  )
                : ListView.builder(
                    itemCount: deletedVideos.length,
                    itemBuilder: (context, index) {
                      final deletedVideo = deletedVideos[index];
                      return Dismissible(
                        onDismissed: (direction) {
                          _deleteVideo(deletedVideo.path);
                        },
                        background: _buildSwipeBackground(
                          color: Colors.red,
                          icon: Icons.delete,
                          alignment: Alignment.centerRight,
                        ),
                        secondaryBackground: _buildSwipeBackground(
                          color: Colors.red,
                          icon: Icons.delete,
                          alignment: Alignment.centerRight,
                        ),
                        key: Key(deletedVideo.path),
                        child: GestureDetector(
                          onTap: () => _restoreVideo(deletedVideo, index),
                          child: RecordedVideoTile(
                            videoInfo: deletedVideos[index],
                            videoTime:
                                extractLastTime(deletedVideos[index].path) ??
                                    'error',
                          ),
                        ),
                      );
                    },
                  ),
      ),
    );
  }

  Future<String?> getDirectoryFromPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('selected_directory');
  }

  Future<void> _restoreVideo(VideoInfo video, int index) async {
    try {
      final file = File(video.path);

      // Fetch the directory from preferences
      final dir = await getDirectoryFromPreferences();
      if (dir == null) {
        throw Exception("Directory not found in preferences.");
      }

      final restorePath = '${dir}/${file.uri.pathSegments.last}';

      // Check if the file exists at the source
      if (!await file.exists()) {
        throw Exception("File does not exist at source path.");
      }

      // Check if the restore path already exists (in case a video with the same name exists)
      final restoreFile = File(restorePath);
      if (await restoreFile.exists()) {
        throw Exception(
            "A video with the same name already exists in the target directory.");
      }

      // Copy the file to the new location
      await file.copy(restorePath);

      // Delete the original file from the deleted videos directory
      await file.delete();

      setState(() {
        deletedVideos.removeAt(index);
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${video.title} has been restored!')),
      );
    } catch (e) {
      debugPrint("Error restoring video: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to restore video: $e")),
      );
    }
  }

  Widget _buildSwipeBackground({
    required Color color,
    required IconData icon,
    required Alignment alignment,
  }) {
    return Container(
      alignment: alignment,
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      margin: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: color,
      ),
      child: Icon(icon, color: Colors.white),
    );
  }
}
