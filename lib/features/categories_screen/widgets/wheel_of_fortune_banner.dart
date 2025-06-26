import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:Quizdom/core/constants/constant_strings.dart';
import 'package:Quizdom/core/navigation/route_extensions.dart';
import 'package:Quizdom/core/utils/size_config.dart';
import 'package:Quizdom/features/wheel_spin_screen/wheel_spin_screen.dart';

class WheelOfFortuneBanner extends StatelessWidget {
  const WheelOfFortuneBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: GestureDetector(
        onTap: () {
          goRoute(WheelSpinScreen.routeName);
        },
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: calcWidth(16),
            vertical: calcHeight(20),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: SizedBox(
              height: calcHeight(200),
              child: SvgPicture.asset(
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
