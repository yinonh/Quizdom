import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:trivia/utility/constant_strings.dart';

class CustomProgressIndicator extends StatelessWidget {
  const CustomProgressIndicator({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        height: 100,
        width: 150,
        child: Lottie.asset(Strings.loadingAnimation),
      ),
    );
  }
}
