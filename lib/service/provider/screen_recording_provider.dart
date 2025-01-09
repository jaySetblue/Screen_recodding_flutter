import 'package:flutter_riverpod/flutter_riverpod.dart';

class RecordingState {
  final bool isRecording;
  final bool isPaused;
  final bool isAudioEnabled;

  RecordingState({
    required this.isRecording,
    required this.isPaused,
    required this.isAudioEnabled,
  });

  RecordingState copyWith({
    bool? isRecording,
    bool? isPaused,
    bool? isAudioEnabled,
  }) {
    return RecordingState(
      isRecording: isRecording ?? this.isRecording,
      isPaused: isPaused ?? this.isPaused,
      isAudioEnabled: isAudioEnabled ?? this.isAudioEnabled,
    );
  }
}

final screenRecordingProvider =
    StateNotifierProvider<ScreenRecordingNotifier, RecordingState>((ref) {
  return ScreenRecordingNotifier();
});

class ScreenRecordingNotifier extends StateNotifier<RecordingState> {
  ScreenRecordingNotifier()
      : super(RecordingState(
          isRecording: false,
          isPaused: false,
          isAudioEnabled: false,
        ));

  void startRecording() {
    state = state.copyWith(isRecording: true, isPaused: false);
  }

  void pauseRecording() {
    state = state.copyWith(isPaused: true);
  }

  void resumeRecording() {
    state = state.copyWith(isPaused: false);
  }

  void stopRecording() {
    state = state.copyWith(isRecording: false, isPaused: false);
  }

  void toggleAudio() {
    state = state.copyWith(isAudioEnabled: !state.isAudioEnabled);
  }
}
