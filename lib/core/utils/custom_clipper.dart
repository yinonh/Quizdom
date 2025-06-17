import 'dart:math' show pi;

import 'package:flutter/material.dart';

class HalfCircleClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final Path path = Path();

    // Start from the middle of the left side
    path.moveTo(0, size.height / 2);

    // Draw line to top-left corner
    path.lineTo(0, 0);

    // Draw line across top
    path.lineTo(size.width, 0);

    // Draw line down right side to middle
    path.lineTo(size.width, size.height / 2);

    // Draw arc for bottom half of circle
    path.addArc(
      Rect.fromLTWH(0, 0, size.width, size.height),
      0,
      pi,
    );

    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
