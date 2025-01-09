import 'package:flutter_riverpod/flutter_riverpod.dart';

final recordingDirectoryProvider =
    StateNotifierProvider<RecordingDirectoryNotifier, String?>((ref) {
  return RecordingDirectoryNotifier();
});

class RecordingDirectoryNotifier extends StateNotifier<String?> {
  RecordingDirectoryNotifier() : super(null);

  void setDirectory(String directoryPath) {
    state = directoryPath;
  }

  void clearDirectory() {
    state = null;
  }
}
