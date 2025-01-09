import 'package:flutter_riverpod/flutter_riverpod.dart';

final overlayProvider = StateNotifierProvider<OverlayNotifier, bool>((ref) {
  return OverlayNotifier();
});

class OverlayNotifier extends StateNotifier<bool> {
  OverlayNotifier() : super(false);

  void toggleOverlay() {
    state = !state;
  }
}
