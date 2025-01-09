import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:screen_recorder/service/provider/video_quality_provider.dart';

class VideoQualityDropdown extends ConsumerWidget {
  const VideoQualityDropdown({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Get the current countdown value from the provider
    final videoSettings = ref.watch(videoSettingsProvider);

    return DropdownButton<VideoQuality>(
      value: videoSettings.quality,
      dropdownColor: Colors.black,
      items: const [
        DropdownMenuItem(
          value: VideoQuality.low,
          child: Text(
            'Low',
            style: TextStyle(
              fontSize: 12,
              color: Colors.white,
            ),
          ),
        ),
        DropdownMenuItem(
          value: VideoQuality.medium,
          child: Text(
            'Medium',
            style: TextStyle(
              fontSize: 12,
              color: Colors.white,
            ),
          ),
        ),
        DropdownMenuItem(
          value: VideoQuality.high,
          child: Text(
            'High',
            style: TextStyle(
              fontSize: 12,
              color: Colors.white,
            ),
          ),
        ),
      ],
      onChanged: (value) {
        if (value != null) {
          ref.read(videoSettingsProvider.notifier).setQuality(value);
        }
      },
      underline: Container(), // Optional: Remove underline
      icon: const Icon(Icons.arrow_drop_down, color: Colors.white),
      style: const TextStyle(
        fontSize: 12,
        color: Colors.white,
      ),
    );
  }
}
