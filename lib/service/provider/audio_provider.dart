import 'package:flutter_riverpod/flutter_riverpod.dart';

final audioProvider = StateNotifierProvider<AudioNotifier, bool>((ref) {
  return AudioNotifier();
});

class AudioNotifier extends StateNotifier<bool> {
  AudioNotifier() : super(false);

  void toggleAudio() {
    state = !state;
  }
}
