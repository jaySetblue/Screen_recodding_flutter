import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OverlaySizeNotifier extends StateNotifier<Size> {
  OverlaySizeNotifier() : super(Size(100, 100)) {
    _loadOverlaySize(); // Load overlay size when the provider initializes
  }

  static const String _widthKey = 'overlay_width';
  static const String _heightKey = 'overlay_height';

  /// Save overlay size to SharedPreferences
  Future<void> _saveOverlaySize(Size size) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_widthKey, size.width);
    await prefs.setDouble(_heightKey, size.height);
  }

  /// Load overlay size from SharedPreferences
  Future<void> _loadOverlaySize() async {
    final prefs = await SharedPreferences.getInstance();
    final width = prefs.getDouble(_widthKey) ?? 400; // Default width
    final height = prefs.getDouble(_heightKey) ?? 400; // Default height
    state = Size(width, height);
  }

  /// Update and save overlay size
  void setSize(Size newSize) {
    state = newSize;
    _saveOverlaySize(newSize);
  }
}

// Define the provider
final overlaySizeProvider = StateNotifierProvider<OverlaySizeNotifier, Size>(
  (ref) => OverlaySizeNotifier(),
);
