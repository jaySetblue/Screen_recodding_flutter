import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:screen_recorder/service/provider/video_quality_provider.dart';

class FrameRateDropdown extends ConsumerWidget {
  const FrameRateDropdown({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Get the current countdown value from the provider
    final videoSettings = ref.watch(videoSettingsProvider);

    return DropdownButton<int>(
      value: videoSettings.frameRate,
      dropdownColor: Colors.black,
      items: const [
        DropdownMenuItem(
          value: 15,
          child: Text(
            '15',
            style: TextStyle(
              fontSize: 12,
              color: Colors.white,
            ),
          ),
        ),
        DropdownMenuItem(
          value: 24,
          child: Text(
            '24',
            style: TextStyle(
              fontSize: 12,
              color: Colors.white,
            ),
          ),
        ),
        DropdownMenuItem(
          value: 30,
          child: Text(
            '30',
            style: TextStyle(
              fontSize: 12,
              color: Colors.white,
            ),
          ),
        ),
        DropdownMenuItem(
          value: 60,
          child: Text(
            '60',
            style: TextStyle(
              fontSize: 12,
              color: Colors.white,
            ),
          ),
        ),
        DropdownMenuItem(
          value: 120,
          child: Text(
            '120',
            style: TextStyle(
              fontSize: 12,
              color: Colors.white,
            ),
          ),
        ),
      ],
      onChanged: (value) {
        if (value != null) {
          ref.read(videoSettingsProvider.notifier).setFrameRate(value);
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
