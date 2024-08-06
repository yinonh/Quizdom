import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:trivia/common_widgets/user_avater.dart';
import 'package:trivia/utility/app_constant.dart';
import 'package:trivia/utility/color_utility.dart';
import 'package:trivia/utility/size_config.dart';

class AvatarSection extends StatelessWidget {
  const AvatarSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: calcHeight(-10),
      left: 0,
      right: 0,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 25.0),
        child: Container(
          width: calcWidth(155),
          height: calcWidth(155),
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white,
          ),
          child: Center(
            child: Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: calcWidth(145),
                  height: calcWidth(145),
                  child: CircularProgressIndicator(
                    strokeWidth: 8.0,
                    value: 0.8,
                    color: AppConstant.onPrimary.toColor(),
                  ),
                ),
                const UserAvatar(
                  radius: 70,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
