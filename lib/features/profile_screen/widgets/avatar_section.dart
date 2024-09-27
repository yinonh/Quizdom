import 'package:flutter/material.dart';
import 'package:trivia/core/common_widgets/user_avater.dart';
import 'package:trivia/core/utils/size_config.dart';
import 'package:trivia/features/avatar_screen/avatar_screen.dart';

class AvatarSection extends StatelessWidget {
  const AvatarSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: calcHeight(-10),
      left: 0,
      right: 0,
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: calcHeight(25)),
        child: Container(
          width: calcWidth(155),
          height: calcWidth(155),
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white,
          ),
          child: Center(
            child: GestureDetector(
              onTap: () {
                Navigator.pushNamed(context, AvatarScreen.routeName);
              },
              child: const UserAvatar(
                showProgress: true,
                radius: 70,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
