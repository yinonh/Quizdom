import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:trivia/common_widgets/user_avater.dart';
import 'package:trivia/features/avatar_screen/avatar_screen.dart';
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
              clipBehavior: Clip.none,
              alignment: Alignment.bottomCenter,
              children: [
                Hero(
                  tag: "userAvatar",
                  child: Stack(
                    children: [
                      GestureDetector(
                        onTap: () {
                          Navigator.pushNamed(context, AvatarScreen.routeName);
                        },
                        child: const UserAvatar(
                          radius: 70,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
