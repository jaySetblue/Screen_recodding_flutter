import 'dart:developer';
import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:screen_recorder/data/model/video_info.dart';
import 'package:flutter_video_info/flutter_video_info.dart';
import 'package:get_thumbnail_video/index.dart';
import 'package:get_thumbnail_video/video_thumbnail.dart';
import 'package:screen_recorder/presentation/constants/constants.dart';
import 'package:screen_recorder/presentation/screens/editor/video_editor_screen.dart';
import 'package:screen_recorder/presentation/widgets/my_showcase_widget.dart';
import 'package:screen_recorder/presentation/widgets/recorded_video_tile.dart';
import 'package:screen_recorder/service/provider/recording_directory_provider.dart';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:showcaseview/showcaseview.dart';

class RecordedVideosScreen extends ConsumerStatefulWidget {
  const RecordedVideosScreen({super.key});

  @override
  ConsumerState<RecordedVideosScreen> createState() => _RecordedVideosState();
}

class _RecordedVideosState extends ConsumerState<RecordedVideosScreen> {
  final String folderName = 'ScreenRecorder';
  late String directory;
  List<VideoInfo> videos = [];
  double totalSizeMB = 0;
  int totalFiles = 0;
  bool isLoading = true;
  GlobalKey _recordedVideosKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _fetchVideoFiles();
    showHintsIfNecessary();
  }

  Future<bool> checkAndRequestPermissions({required bool skipIfExists}) async {
    if (!Platform.isAndroid && !Platform.isIOS) {
      return false; // Only Android and iOS platforms are supported
    }

    if (Platform.isAndroid) {
      final deviceInfo = await DeviceInfoPlugin().androidInfo;
      final sdkInt = deviceInfo.version.sdkInt;

      if (skipIfExists) {
        // Read permission is required to check if the file already exists
        return sdkInt >= 33
            ? await Permission.photos.request().isGranted
            : await Permission.storage.request().isGranted;
      } else {
        // No read permission required for Android SDK 29 and above
        return sdkInt >= 29
            ? true
            : await Permission.storage.request().isGranted;
      }
    } else if (Platform.isIOS) {
      // iOS permission for saving images to the gallery
      return skipIfExists
          ? await Permission.photos.request().isGranted
          : await Permission.photosAddOnly.request().isGranted;
    }

    return false; // Unsupported platforms
  }

  Future<String?> getDirectoryFromPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('selected_directory');
  }

  Future<void> _fetchVideoFiles() async {
    setState(() => isLoading = true);

    try {
      // Get the directory from SharedPreferences
      final dir = await getDirectoryFromPreferences();

      if (dir == null) return;

      final videoDirectory = Directory(dir);

      if (await videoDirectory.exists()) {
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
                  //date: videoTime ?? "unknown Date",
                  thumbnail: thumbnail,
                );
        }));

        setState(() {
          videos = tempVideos.whereType<VideoInfo>().toList();
          totalFiles = videos.length;
          totalSizeMB = videos.fold(0, (sum, video) => sum + (video.size ?? 0));
        });
      }
    } catch (e) {
      debugPrint("Error fetching video files: $e");
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

  Future<void> _deleteVideo(String path) async {
    try {
      final file = File(path);
      debugPrint("Attempting to delete file at path: $path");

      // Check if file exists
      if (!await file.exists()) {
        debugPrint("File does not exist: $path");
        return;
      }

      // Get appropriate directory based on platform
      final dir = Platform.isAndroid
          ? await getExternalStorageDirectory()
          : await getApplicationSupportDirectory();

      if (dir == null) {
        debugPrint("Could not determine the storage directory.");
        return;
      }

      // Define Deleted Videos folder path
      final deletedVideosDirectory = Directory("${dir.path}/DeletedVideos");

      // Create the DeletedVideos directory if it doesn't exist
      if (!await deletedVideosDirectory.exists()) {
        await deletedVideosDirectory.create(recursive: true);
      }

      // Define the new file path in the DeletedVideos folder
      final newFilePath =
          "${deletedVideosDirectory.path}/${file.uri.pathSegments.last}";

      // Copy the file to the DeletedVideos folder
      // final newFile = await file.copy(newFilePath);

      // After successfully copying, delete the original file
      await file.delete();

      // Update the state to remove the video from the list
      setState(() {
        videos.removeWhere((video) => video.path == path);
      });

      debugPrint("Video moved to DeletedVideos folder: $newFilePath");
    } catch (e) {
      debugPrint("Error deleting video: $e");
    }
  }

  void _editVideo(String path) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => VideoEditor(file: XFile(path))),
    );
  }

  Future<void> showHintsIfNecessary() async {
    final prefs = await SharedPreferences.getInstance();
    final areHintsDisabled = prefs.getBool('record_hints_disabled') ?? false;

    if (!areHintsDisabled) {
      // Start the showcase only if hints are not disabled
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ShowCaseWidget.of(context).startShowCase([
          _recordedVideosKey,
        ]);
      });
    }
  }

  Future<void> disableHints() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('record_hints_disabled', true);
  }

  @override
  Widget build(BuildContext context) {
    // final screenUtil = ScreenUtil(context);
    final directory = ref.watch(recordingDirectoryProvider);
    log(directory.toString());
    // WidgetsBinding.instance.addPostFrameCallback((_) {
    //   ShowCaseWidget.of(context).startShowCase([
    //     _recordedVideosKey,
    //   ]);
    // });

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: MyShowcaseWidget(
          showcaseKey: _recordedVideosKey,
          title: 'Recorded Videos Screen',
          description:
              'Shows your recorded screen videos in list format.\n Swipe left on video file in list to Delete,\n swipe right to edit and tap on the file to view the Recording',
          onCancel: () {
            disableHints();
            ShowCaseWidget.of(context).dismiss();
          },
          onNext: () {
            disableHints();
            ShowCaseWidget.of(context).dismiss();
          },
          onNextText: 'Got it!',
          onCancelText: 'Cancel',
          child: const Text(
            'My Recordings',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
          ),
        ),
        backgroundColor: Colors.transparent,
      ),
      body: Container(
        padding: const EdgeInsets.only(
          left: 8,
          right: 8,
          top: 16,
          bottom: kToolbarHeight,
        ),
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
            : videos.isEmpty
                ? const Center(
                    child: Text(
                      'No Recorded Videos',
                      style: TextStyle(color: Colors.white),
                    ),
                  )
                : ListView.builder(
                    itemCount: videos.length,
                    itemBuilder: (context, index) {
                      final video = videos[index];
                      return Dismissible(
                        key: Key(video.path),
                        direction: DismissDirection.horizontal,
                        onDismissed: (direction) {
                          if (direction == DismissDirection.startToEnd) {
                            _editVideo(video.path);
                          } else if (direction == DismissDirection.endToStart) {
                            _deleteVideo(video.path);
                          }
                        },
                        background: _buildSwipeBackground(
                          color: Colors.green,
                          icon: Icons.edit,
                          alignment: Alignment.centerLeft,
                        ),
                        secondaryBackground: _buildSwipeBackground(
                          color: Colors.red,
                          icon: Icons.delete,
                          alignment: Alignment.centerRight,
                        ),
                        child: GestureDetector(
                          onTap: () async {
                            OpenFile.open(video.path);
                          },
                          child: RecordedVideoTile(
                            videoInfo: video,
                            videoTime: extractLastTime(video.path) ?? 'error',
                          ),
                        ),
                      );
                    },
                  ),
      ),
    );
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
