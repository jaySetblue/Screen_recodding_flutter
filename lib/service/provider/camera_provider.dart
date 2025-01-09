import 'package:flutter_riverpod/flutter_riverpod.dart';

final cameraProvider = StateNotifierProvider<CameraNotifier, bool>((ref) {
  return CameraNotifier();
});

class CameraNotifier extends StateNotifier<bool> {
  CameraNotifier() : super(false);

  void toggleCamera() {
    state = !state;
  }
}
