import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

class TimerState {
  final int elapsedSeconds;
  final bool isRunning;
  final bool isPaused;

  TimerState({
    required this.elapsedSeconds,
    required this.isRunning,
    required this.isPaused,
  });

  TimerState copyWith({
    int? elapsedSeconds,
    bool? isRunning,
    bool? isPaused,
  }) {
    return TimerState(
      elapsedSeconds: elapsedSeconds ?? this.elapsedSeconds,
      isRunning: isRunning ?? this.isRunning,
      isPaused: isPaused ?? this.isPaused,
    );
  }
}

class TimerNotifier extends StateNotifier<TimerState> {
  Timer? _timer;

  TimerNotifier()
      : super(TimerState(elapsedSeconds: 0, isRunning: false, isPaused: false));

  void startTimer() {
    _timer?.cancel();
    state = state.copyWith(isRunning: true, isPaused: false);

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!state.isPaused) {
        state = state.copyWith(elapsedSeconds: state.elapsedSeconds + 1);
      }
    });
  }

  void stopTimer() {
    _timer?.cancel();
    state =
        state.copyWith(elapsedSeconds: 0, isRunning: false, isPaused: false);
  }

  void pauseTimer() {
    state = state.copyWith(isPaused: true);
  }

  void resumeTimer() {
    state = state.copyWith(isPaused: false);
  }
}

final timerProvider = StateNotifierProvider<TimerNotifier, TimerState>((ref) {
  return TimerNotifier();
});
