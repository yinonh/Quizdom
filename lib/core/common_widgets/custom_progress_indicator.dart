import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:Quizdom/core/constants/constant_strings.dart';
import 'package:Quizdom/core/utils/size_config.dart';

class CustomProgressIndicator extends StatelessWidget {
  const CustomProgressIndicator({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        height: calcHeight(100),
        width: calcWidth(150),
        child: Lottie.asset(Strings.loadingAnimation),
      ),
    );
  }
}
