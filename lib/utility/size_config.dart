import 'dart:ui' as ui;

import 'package:flutter/material.dart';

const double minFontSize = 14.0;

class SizeConfig {
  static late double screenWidth;
  static late double screenHeight;
  static late Orientation orientation;
  static const double designHeight = 926;
  static const double designWidth = 428;

  void init(BuildContext context) {
    screenWidth = MediaQuery.sizeOf(context).width;
    screenHeight = MediaQuery.sizeOf(context).height;
    orientation = MediaQuery.orientationOf(context);
  }
}

// Get the proportionate height as per screen size
double calcHeight(double height) {
  return (height / SizeConfig.designHeight) * SizeConfig.screenHeight;
}

double calcFontSize(double width) {
  double scaleRatio = 1;
  double fontSize =
      (width / SizeConfig.designWidth) * SizeConfig.screenWidth * scaleRatio;
  if (fontSize < minFontSize) {
    return minFontSize;
  }
  return fontSize;
}

// Get the proportionate height as per screen size
double calcWidth(double width) {
  return (width / SizeConfig.designWidth) * SizeConfig.screenWidth;
}

Size textSize(String text, TextStyle style) {
  final TextPainter textPainter = TextPainter(
      text: TextSpan(text: text, style: style),
      maxLines: 1,
      textDirection: ui.TextDirection.ltr)
    ..layout(minWidth: 0, maxWidth: double.infinity);
  return textPainter.size;
}

double adjustFontSize({
  required double initialFontSize,
  required double maxFontSize,
  required double minFontSize,
  required double externalHeight,
  required double externalWidth,
  required String? text,
  required TextStyle textStyle,
}) {
  double fontSize = initialFontSize;
  bool fitsWithinBounds = _checkFitsWithinBounds(
    fontSize,
    text,
    textStyle,
    externalHeight,
    externalWidth,
  );

  while (fontSize < maxFontSize && fitsWithinBounds) {
    fontSize++;
    fitsWithinBounds = _checkFitsWithinBounds(
      fontSize,
      text,
      textStyle,
      externalHeight,
      externalWidth,
    );
    if (!fitsWithinBounds) {
      fontSize--;
      break;
    }
  }

  while (fontSize > minFontSize && !fitsWithinBounds) {
    fontSize--;
    fitsWithinBounds = _checkFitsWithinBounds(
      fontSize,
      text,
      textStyle,
      externalHeight,
      externalWidth,
    );
  }

  return fontSize;
}

bool _checkFitsWithinBounds(
  double fontSize,
  String? text,
  TextStyle textStyle,
  double externalHeight,
  double externalWidth,
) {
  final TextPainter textPainter = TextPainter(
    text: TextSpan(text: text, style: textStyle.copyWith(fontSize: fontSize)),
    maxLines: null,
    textDirection: ui.TextDirection.rtl,
  )..layout(minWidth: 0, maxWidth: externalWidth);

  return textPainter.size.height <= externalHeight;
}
