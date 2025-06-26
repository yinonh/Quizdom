import 'package:flutter/material.dart';
import 'package:Quizdom/core/common_widgets/current_user_avatar.dart';
import 'package:Quizdom/core/navigation/route_extensions.dart';
import 'package:Quizdom/core/utils/size_config.dart';
import 'package:Quizdom/features/avatar_screen/avatar_screen.dart';

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
                goRoute(AvatarScreen.routeName);
              },
              child: CurrentUserAvatar(
                showProgress: true,
                radius: 70,
                onTapOverride: () {
                  Scaffold.of(context).closeDrawer();
                  goRoute(AvatarScreen.routeName);
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}
