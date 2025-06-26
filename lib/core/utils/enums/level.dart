import 'package:flutter/material.dart';
import 'package:Quizdom/core/constants/app_constant.dart';

enum Level {
  none,
  bronze,
  silver,
  gold,
  platinum,
  diamond,
  ruby;

  // Get the color associated with the level
  Color get color {
    switch (this) {
      case Level.ruby:
        return AppConstant.rubyColor;
      case Level.diamond:
        return AppConstant.diamondColor;
      case Level.platinum:
        return AppConstant.platinumColor;
      case Level.gold:
        return AppConstant.darkGoldColor;
      case Level.silver:
        return AppConstant.silverColor;
      case Level.bronze:
        return AppConstant.bronzeColor;
      case Level.none:
        return AppConstant.defaultColor;
    }
  }
}
