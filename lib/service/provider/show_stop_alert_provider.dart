import 'package:flutter_riverpod/flutter_riverpod.dart';

final showStopAlertProvider =
    StateNotifierProvider<showStopAlertNotifier, bool>((ref) {
  return showStopAlertNotifier();
});

class showStopAlertNotifier extends StateNotifier<bool> {
  showStopAlertNotifier() : super(true);

  void toggleshowStopAlert() {
    state = !state;
  }
}
