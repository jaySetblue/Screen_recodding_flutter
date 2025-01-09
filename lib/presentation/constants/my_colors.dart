import 'package:flutter/material.dart';
import 'package:screen_recorder/presentation/constants/constants.dart';

class MyColors {
  final splashGradient = const LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xff341853),
      Color(0xff000000),
    ],
  );

  final imageDeco = DecorationImage(
    image: AssetImage(Constants.homeBackground),
    fit: BoxFit.cover,
  );
}
