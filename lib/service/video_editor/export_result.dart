import 'dart:io';

import 'package:cross_file/cross_file.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart' as path;
import 'package:screen_recorder/presentation/widgets/ads/banner_ads.dart';
import 'package:screen_recorder/presentation/widgets/facrbook_ads/facebook_ad_helper.dart';
import 'package:screen_recorder/utils/screen_utils.dart';
import 'package:video_player/video_player.dart';

Future<Size> _getImageDimension(Uint8List bytes) async {
  var decodedImage = await decodeImageFromList(bytes);
  return Size(decodedImage.width.toDouble(), decodedImage.height.toDouble());
}

String _fileMBSize(Uint8List bytes) {
  return '${(bytes.lengthInBytes / (1024 * 1024)).toStringAsFixed(1)} MB';
}

class VideoResultPopup extends StatefulWidget {
  const VideoResultPopup({super.key, required this.video});

  final XFile video;

  @override
  State<VideoResultPopup> createState() => _VideoResultPopupState();
}

class _VideoResultPopupState extends State<VideoResultPopup> {
  VideoPlayerController? _controller;
  FileImage? _fileImage;
  Size _fileDimension = Size.zero;
  late final _isGif = kIsWeb
      ? widget.video.mimeType == 'image/gif'
      : path.extension(widget.video.path).toLowerCase() == ".gif";
  String? _fileMbSize;

  @override
  void initState() {
    super.initState();

    if (!_isGif) {
      _controller = kIsWeb
          ? VideoPlayerController.network(widget.video.path)
          : VideoPlayerController.file(File(widget.video.path))
        ..initialize().then((_) {
          _fileDimension = _controller!.value.size;
          setState(() {});
          _controller?.play();
          _controller?.setLooping(true);
        });
    }

    widget.video.readAsBytes().then((bytes) {
      if (_isGif) {
        _getImageDimension(bytes).then(
          (dimension) => setState(() => _fileDimension = dimension),
        );
      }

      _fileMbSize = _fileMBSize(bytes);
      setState(() {});
    });
  }

  @override
  void dispose() {
    if (_isGif) {
      _fileImage?.evict();
    } else {
      _controller?.pause();
      _controller?.dispose();
    }
    super.dispose();
  }

  // @override
  // Widget build(BuildContext context) {
  //   return Scaffold(
  //     appBar: AppBar(
  //       title: Text('Result Screen'),
  //       actions: [
  //         IconButton(
  //           onPressed: () {
  //             Navigator.of(context).popUntil((route) => route.isFirst);
  //           },
  //           icon: Icon(Icons.home),
  //         )
  //       ],
  //     ),
  //     body: Stack(
  //       children: [
  //         Padding(
  //           padding: EdgeInsets.only(
  //               left: 30,
  //               right: 30,
  //               top: 30,
  //               bottom: ScreenUtil(context).screenHeight * 0.15),
  //           child: Center(
  //             child: Stack(
  //               alignment: Alignment.bottomLeft,
  //               children: [
  //                 AspectRatio(
  //                   aspectRatio: _fileDimension.aspectRatio == 0
  //                       ? 1
  //                       : _fileDimension.aspectRatio,
  //                   child: _isGif
  //                       ? (kIsWeb
  //                           ? Image.network(widget.video.path)
  //                           : Image.file(File(widget.video.path)))
  //                       : VideoPlayer(_controller!),
  //                 ),
  //                 Positioned(
  //                   bottom:
  //                       0, // Move the description slightly higher to avoid overlap with the ad
  //                   left: 0,
  //                   right: 0,
  //                   child: FileDescription(
  //                     description: {
  //                       'Video path': widget.video.path,
  //                       if (!_isGif)
  //                         'Video duration':
  //                             '${((_controller?.value.duration.inMilliseconds ?? 0) / 1000).toStringAsFixed(2)}s',
  //                       'Video size': _fileMbSize,
  //                     },
  //                   ),
  //                 ),
  //               ],
  //             ),
  //           ),
  //         ),
  //         Positioned(
  //           bottom: 20,
  //           left: 0,
  //           right: 0,
  //           child: FacebookAdHelper.nativeAd(context),
  //         ),
  //       ],
  //     ),
  //   );
  // }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Result Screen'),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.of(context).popUntil((route) => route.isFirst);
            },
            icon: const Icon(Icons.home),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 30, vertical: 20),
              child: Center(
                child: _controller != null && _controller!.value.isInitialized
                    ? Stack(
                        alignment: Alignment.bottomLeft,
                        children: [
                          AspectRatio(
                            aspectRatio: (_fileDimension.aspectRatio > 0
                                ? _fileDimension.aspectRatio
                                : 1),
                            child: _isGif
                                ? (kIsWeb
                                    ? Image.network(widget.video.path)
                                    : Image.file(File(widget.video.path)))
                                : VideoPlayer(_controller!),
                          ),
                          Positioned(
                            bottom: 10,
                            left: 10,
                            right: 10,
                            child: FileDescription(
                              description: {
                                'Video path': widget.video.path,
                                if (!_isGif)
                                  'Video duration':
                                      '${((_controller?.value.duration.inMilliseconds ?? 0) / 1000).toStringAsFixed(2)}s',
                                'Video size': _fileMbSize,
                              },
                            ),
                          ),
                        ],
                      )
                    : const CircularProgressIndicator(),
              ),
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(height: 50, child: BannerAdWidget()
              // ?? FacebookAdHelper.nativeAd(context),
              ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}

class FileDescription extends StatelessWidget {
  const FileDescription({super.key, required this.description});

  final Map<String, String?> description;

  @override
  Widget build(BuildContext context) {
    return DefaultTextStyle(
      style: const TextStyle(fontSize: 11),
      child: Container(
        width: MediaQuery.of(context).size.width - 60,
        padding: const EdgeInsets.all(10),
        color: Colors.black.withOpacity(0.5),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: description.entries
              .map(
                (entry) => Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(
                        text: '${entry.key}: ',
                        style: const TextStyle(fontSize: 11),
                      ),
                      TextSpan(
                        text: entry.value,
                        style: TextStyle(
                          fontSize: 10,
                          color: Colors.white.withOpacity(0.8),
                        ),
                      ),
                    ],
                  ),
                ),
              )
              .toList(),
        ),
      ),
    );
  }
}
