import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum VideoQuality { low, medium, high }

class VideoSettings {
  final VideoQuality quality;
  final int frameRate;

  VideoSettings({
    required this.quality,
    required this.frameRate,
  });

  VideoSettings copyWith({
    VideoQuality? quality,
    int? frameRate,
  }) {
    return VideoSettings(
      quality: quality ?? this.quality,
      frameRate: frameRate ?? this.frameRate,
    );
  }
}

class VideoSettingsNotifier extends StateNotifier<VideoSettings> {
  static const _qualityKey = 'video_quality';
  static const _frameRateKey = 'video_frame_rate';

  VideoSettingsNotifier()
      : super(VideoSettings(quality: VideoQuality.medium, frameRate: 30)) {
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    final qualityIndex = prefs.getInt(_qualityKey) ?? 1; // Default: medium
    final frameRate = prefs.getInt(_frameRateKey) ?? 30;

    state = VideoSettings(
      quality: VideoQuality.values[qualityIndex],
      frameRate: frameRate,
    );
  }

  Future<void> _saveSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_qualityKey, state.quality.index);
    await prefs.setInt(_frameRateKey, state.frameRate);
  }

  void setQuality(VideoQuality quality) {
    state = state.copyWith(quality: quality);
    _saveSettings();
  }

  void setFrameRate(int frameRate) {
    state = state.copyWith(frameRate: frameRate);
    _saveSettings();
  }
}

// Define the provider
final videoSettingsProvider =
    StateNotifierProvider<VideoSettingsNotifier, VideoSettings>(
        (ref) => VideoSettingsNotifier());
