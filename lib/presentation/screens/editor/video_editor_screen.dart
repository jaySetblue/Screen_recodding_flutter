import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get_thumbnail_video/video_thumbnail.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:screen_recorder/presentation/screens/editor/crop_screen.dart';
import 'package:screen_recorder/presentation/widgets/ads/interstitial_ads.dart';
import 'package:screen_recorder/presentation/widgets/facrbook_ads/facebook_ad_helper.dart';
import 'package:screen_recorder/service/video_editor/export_ffmpeg.dart';
import 'package:screen_recorder/service/video_editor/export_result.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:video_editor_2/domain/bloc/controller.dart';

import 'package:video_editor_2/domain/entities/file_format.dart';

import 'package:video_editor_2/ui/cover/cover_viewer.dart';
import 'package:video_editor_2/ui/crop/crop_grid.dart';
import 'package:video_editor_2/ui/trim/trim_slider.dart';
import 'package:video_editor_2/ui/trim/trim_timeline.dart';

class VideoEditor extends StatefulWidget {
  const VideoEditor({super.key, required this.file});

  final XFile file;

  @override
  State<VideoEditor> createState() => _VideoEditorState();
}

class _VideoEditorState extends State<VideoEditor> {
  final _exportingProgress = ValueNotifier<double>(0.0);
  final _isExporting = ValueNotifier<bool>(false);
  final double height = 60;

  int cropGridViewerKey = 0;

  late final _controller = VideoEditorController.file(
    widget.file,
    minDuration: const Duration(seconds: 1),
    maxDuration: const Duration(days: 36500),
  );

  @override
  void initState() {
    super.initState();
    AdManager().loadInterstitialAd();
    _controller.initialize(aspectRatio: 9 / 16).then((_) {
      if (mounted) {
        setState(() {});
      }
    }).catchError((error) {
      if (mounted) {
        Navigator.pop(context);
      }
    }, test: (e) => e is VideoMinDurationError);
  }

  @override
  void dispose() {
    _exportingProgress.dispose();
    _isExporting.dispose();
    _controller.dispose();
    super.dispose();
  }

  Future<String?> getDirectoryFromPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('selected_directory');
  }

  Future<String> ioOutputPath(String filePath, FileFormat format) async {
    const folderName = 'ScreenRecorder';
    Directory? tempPath;
    final baseDir = Platform.isAndroid
        ? await getExternalStorageDirectory()
        : await getApplicationSupportDirectory();
    final dir = await getDirectoryFromPreferences();
    if (dir == null) {
      tempPath = Directory('${baseDir!.path}/$folderName');
      if (!await tempPath.exists()) {
        await tempPath.create(
            recursive: true); // Ensure the entire path is created
      }
    } else {
      tempPath = Directory(dir);
    }

    final name = '(Edited)${path.basenameWithoutExtension(filePath)}';
    final epoch = DateTime.now().millisecondsSinceEpoch;
    return "${tempPath.path}/${name}_$epoch.${format.extension}";
  }

  Future<XFile> exportVideo({
    void Function(FFmpegStatistics)? onStatistics,
    VideoExportFormat outputFormat = VideoExportFormat.mp4,
    double scale = 1.0,
    String customInstruction = '',
    VideoExportPreset preset = VideoExportPreset.none,
    bool isFiltersEnabled = true,
  }) async {
    final inputPath = _controller.file.path;
    final outputPath = await ioOutputPath(inputPath, outputFormat);

    final config = _controller.createVideoFFmpegConfig();
    final execute = config.createExportCommand(
      inputPath: inputPath,
      outputPath: outputPath,
      outputFormat: outputFormat,
      scale: scale,
      customInstruction: customInstruction,
    );

    debugPrint('run export video command : [$execute]');

    return const FFmpegExport().executeFFmpegIO(
      execute: execute,
      outputPath: outputPath,
      outputMimeType: outputFormat.mimeType,
      onStatistics: onStatistics,
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      child: Scaffold(
        appBar: PreferredSize(
          preferredSize: const Size(double.infinity, kToolbarHeight),
          child: _topNavBar(),
        ),
        backgroundColor: Colors.black,
        body: _controller.initialized
            ? SafeArea(
                child: Stack(
                  children: [
                    Column(
                      children: [
                        Expanded(
                          child: DefaultTabController(
                            length: 2,
                            child: Column(
                              children: [
                                Expanded(
                                  child: TabBarView(
                                    physics:
                                        const NeverScrollableScrollPhysics(),
                                    children: [
                                      Stack(
                                        alignment: Alignment.center,
                                        children: [
                                          CropGridViewer.preview(
                                            key: ValueKey(cropGridViewerKey),
                                            controller: _controller,
                                          ),
                                          AnimatedBuilder(
                                            animation: _controller.video,
                                            builder: (_, __) => AnimatedOpacity(
                                              opacity: !_controller.isPlaying
                                                  ? 1.0
                                                  : 0.0,
                                              duration:
                                                  const Duration(seconds: 1),
                                              child: GestureDetector(
                                                onTap: _controller.video.play,
                                                child: Container(
                                                  width: 40,
                                                  height: 40,
                                                  decoration:
                                                      const BoxDecoration(
                                                    color: Colors.white,
                                                    shape: BoxShape.circle,
                                                  ),
                                                  child: const Icon(
                                                    Icons.play_arrow,
                                                    color: Colors.black,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      CoverViewer(controller: _controller)
                                    ],
                                  ),
                                ),
                                Container(
                                  height: 200,
                                  margin: const EdgeInsets.only(top: 10),
                                  child: Column(
                                    children: [
                                      const Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Padding(
                                            padding: EdgeInsets.all(5),
                                            child: Icon(
                                              Icons.content_cut,
                                              color: Colors.deepPurple,
                                            ),
                                          ),
                                          Text(
                                            'Trim',
                                            style: TextStyle(
                                              color: Colors.deepPurple,
                                            ),
                                          )
                                        ],
                                      ),
                                      Expanded(
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: _trimSlider(),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )
                      ],
                    )
                  ],
                ),
              )
            : const Center(child: CircularProgressIndicator()),
      ),
    );
  }

  Widget _topNavBar() {
    return SafeArea(
      child: SizedBox(
        height: height,
        child: Row(
          children: [
            Expanded(
              child: IconButton(
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(Icons.exit_to_app),
                tooltip: 'Leave editor',
              ),
            ),
            const VerticalDivider(endIndent: 22, indent: 22),
            Expanded(
              child: IconButton(
                onPressed: () =>
                    _controller.rotate90Degrees(RotateDirection.left),
                icon: const Icon(Icons.rotate_left),
                tooltip: 'Rotate unclockwise',
              ),
            ),
            Expanded(
              child: IconButton(
                onPressed: () =>
                    _controller.rotate90Degrees(RotateDirection.right),
                icon: const Icon(Icons.rotate_right),
                tooltip: 'Rotate clockwise',
              ),
            ),
            Expanded(
              child: IconButton(
                onPressed: () async {
                  await Navigator.push(
                    context,
                    MaterialPageRoute<void>(
                      builder: (context) => CropScreen(controller: _controller),
                    ),
                  );
                },
                icon: const Icon(Icons.crop),
                tooltip: 'Open crop screen',
              ),
            ),
            const VerticalDivider(endIndent: 22, indent: 22),
            Expanded(
              child: IconButton(
                onPressed: () async {
                  // Show a loading dialog

                  showDialog(
                    context: context,
                    barrierDismissible:
                        false, // Prevent dismissal of the dialog
                    builder: (BuildContext context) {
                      return AlertDialog(
                        content: Row(
                          children: const [
                            CircularProgressIndicator(),
                            SizedBox(width: 16),
                            Text("Exporting video..."),
                          ],
                        ),
                      );
                    },
                  );

                  try {
                    // Perform the export video operation
                    var file = await exportVideo();

                    // Close the loading dialog
                    Navigator.of(context).pop();

                    // FacebookAdHelper.showInterstitialAd(() {
                    //   Navigator.push(
                    //     context,
                    //     MaterialPageRoute(
                    //       builder: (context) => VideoResultPopup(video: file),
                    //     ),
                    //   );
                    // });

                    // Navigate to the result popup
                    if (AdManager().isInterstitialAdLoaded) {
                      AdManager().showInterstitialAd(() {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => VideoResultPopup(video: file),
                          ),
                        );
                      });
                    } else {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => VideoResultPopup(video: file),
                        ),
                      );
                    }
                  } catch (e) {
                    // Close the loading dialog in case of an error
                    Navigator.of(context).pop();

                    // Optionally, handle the error and show a message
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: const Text("Error"),
                          content: Text("An error occurred: $e"),
                          actions: [
                            TextButton(
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                              child: const Text("OK"),
                            ),
                          ],
                        );
                      },
                    );
                  }
                },
                icon: const Icon(Icons.save),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String formatter(Duration duration) => [
        duration.inMinutes.remainder(60).toString().padLeft(2, '0'),
        duration.inSeconds.remainder(60).toString().padLeft(2, '0')
      ].join(":");

  List<Widget> _trimSlider() {
    return [
      AnimatedBuilder(
        animation: Listenable.merge([
          _controller,
          _controller.video,
        ]),
        builder: (_, __) {
          final duration = _controller.videoDuration.inSeconds;
          final pos = _controller.trimPosition * duration;

          return Padding(
            padding: EdgeInsets.symmetric(horizontal: height / 4),
            child: Row(children: [
              if (pos.isFinite) Text(formatter(Duration(seconds: pos.toInt()))),
              const Expanded(child: SizedBox()),
              AnimatedOpacity(
                opacity: _controller.isTrimming ? 1.0 : 0.0,
                duration: const Duration(seconds: 1),
                child: Row(mainAxisSize: MainAxisSize.min, children: [
                  Text(formatter(_controller.startTrim)),
                  const SizedBox(width: 10),
                  Text(formatter(_controller.endTrim)),
                ]),
              ),
            ]),
          );
        },
      ),
      Container(
        width: MediaQuery.of(context).size.width,
        margin: EdgeInsets.symmetric(vertical: height / 4),
        child: TrimSlider(
          controller: _controller,
          height: height,
          horizontalMargin: height / 4,
          child: TrimTimeline(
            controller: _controller,
            padding: const EdgeInsets.only(top: 10),
          ),
        ),
      )
    ];
  }
}
