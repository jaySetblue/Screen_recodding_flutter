import 'package:flutter/material.dart';

class ScreenUtil {
  final BuildContext context;

  ScreenUtil(this.context);

  double get screenWidth => MediaQuery.of(context).size.width;
  double get screenHeight => MediaQuery.of(context).size.height;
  double get devicePixelRatio => MediaQuery.of(context).devicePixelRatio;
  bool get isLandscape =>
      MediaQuery.of(context).orientation == Orientation.landscape;
  bool get isPortrait =>
      MediaQuery.of(context).orientation == Orientation.portrait;

  // Dynamic size based on percentage of screen width
  double width(double percentage) => screenWidth * percentage;

  // Dynamic size based on percentage of screen height
  double height(double percentage) => screenHeight * percentage;

  // Dynamic text size scaling (e.g., scaling based on width)
  double fontSize(double percentage) => screenWidth * percentage;

  //Vertical space
  SizedBox get smallVS => SizedBox(height: screenHeight * 0.03);
  SizedBox get mediumVS => SizedBox(height: screenHeight * 0.05);
  SizedBox get largeVS => SizedBox(height: screenHeight * 0.07);
  SizedBox get verySmallVS => SizedBox(height: screenHeight * 0.02);
  SizedBox get veryVerySmallVS => SizedBox(height: screenHeight * 0.01);

  //Horizontal space
  SizedBox get smallHS => SizedBox(width: screenWidth * 0.02);
  SizedBox get mediumHS => SizedBox(width: screenWidth * 0.04);
  SizedBox get largeHS => SizedBox(width: screenWidth * 0.06);
}
