import 'package:flutter/material.dart';
import 'package:trivia/core/constants/constant_strings.dart';
import 'package:trivia/core/utils/size_config.dart';
import 'package:trivia/features/wheel_spin_screen/wheel_spin_screen.dart';

class WheelOfFortuneBanner extends StatelessWidget {
  const WheelOfFortuneBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: GestureDetector(
        onTap: () {
          Navigator.of(context).pushNamed(WheelSpinScreen.routeName);
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 16.0,
            vertical: 20,
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: SizedBox(
              height: calcHeight(170),
              child: Image.asset(
                Strings.wheelOfFortune,
                fit: BoxFit.fill,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
