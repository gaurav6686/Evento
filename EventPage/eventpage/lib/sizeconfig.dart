import 'package:flutter/material.dart';

class SizeConfig {
  static const double assumedScreenHeight = 747.0;
  static const double assumedScreenWidth = 375.0;
  static late MediaQueryData _mediaQueryData;
  static late double screenWidth;
  static late double screenHeight;
  static late double blockSizeHorizontal;
  static late double blockSizeVertical;

  void init(BuildContext context) {
    _mediaQueryData = MediaQuery.of(context);
    screenWidth = _mediaQueryData.size.width;
    screenHeight = _mediaQueryData.size.height;
    blockSizeHorizontal = screenWidth / 100;
    blockSizeVertical = screenHeight / 100;
  }

  static double _fitContext(assumedValue, currentValue, value) =>
      (value / assumedValue) * currentValue;

  static double fitToWidth(value) =>
      _fitContext(assumedScreenWidth, screenWidth, value);

  static double fitToHeight(value) =>
      _fitContext(assumedScreenHeight, screenHeight, value);
}

extension ReactiveSizeDouble on double {
  double get fh => SizeConfig.fitToHeight(this);

  double get fw => SizeConfig.fitToWidth(this);
}

extension ReactiveSizeInt on int {
  double get fh => SizeConfig.fitToHeight(this);

  double get fw => SizeConfig.fitToWidth(this);
}
