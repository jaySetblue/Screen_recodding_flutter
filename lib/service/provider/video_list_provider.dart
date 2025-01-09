import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:screen_recorder/data/model/video_info.dart';
import 'package:screen_recorder/service/provider/video_list_notifier.dart';

final videoListProvider =
    StateNotifierProvider<VideoListNotifier, List<VideoInfo>>(
  (ref) => VideoListNotifier(),
);
