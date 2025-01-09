import 'package:flutter/material.dart';

class VideoInfo {
  final String path;
  final String title;
  final double? size;
  final double? duration;
  final String date;
  final Image? thumbnail;

  VideoInfo({
    required this.path,
    required this.title,
    this.size,
    this.duration,
    required this.date,
    this.thumbnail,
  });
}
