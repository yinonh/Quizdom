import 'package:flutter/material.dart';

extension ColorExtension on String {
  Color toColor() {
    var hexColor = replaceAll("#", "");
    if (hexColor.length == 6) {
      hexColor = "FF$hexColor";
    }
    if (hexColor.length == 8) {
      hexColor = "0x$hexColor";
    }
    return Color(int.parse(hexColor));
  }
}
