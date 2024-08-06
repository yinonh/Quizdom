import 'package:flutter/material.dart';
import 'package:trivia/utility/size_config.dart';
import 'package:trivia/common_widgets/user_avater.dart';

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
          child: const UserAvatar(radius: 70),
        ),
      ),
    );
  }
}
