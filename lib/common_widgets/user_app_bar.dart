import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:trivia/common_widgets/stars.dart';
import 'package:trivia/common_widgets/user_avater.dart';
import 'package:trivia/features/avatar_screen/avatar_screen.dart';
import 'package:trivia/service/user_provider.dart';
import 'package:trivia/utility/app_constant.dart';
import 'package:trivia/utility/color_utility.dart';
import 'package:trivia/utility/constant_strings.dart';
import 'package:trivia/utility/size_config.dart';

class UserAppBar extends ConsumerWidget implements PreferredSizeWidget {
  @override
  final Size preferredSize;
  final Widget? prefix;

  UserAppBar({this.prefix, super.key})
      : preferredSize = Size.fromHeight(calcHeight(120));

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userState = ref.watch(userProvider);

    return Stack(
      children: [
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: Container(
            height: calcHeight(95),
            width: double.infinity,
            color: AppConstant.primaryColor.toColor(),
          ),
        ),
        Positioned(
          bottom: 1,
          left: 0,
          right: 0,
          child: Container(
            color: Colors.transparent,
            child: Center(
              child: SvgPicture.asset(
                Strings.appBarDrop,
                height: calcHeight(55),
                colorFilter: ColorFilter.mode(
                  AppConstant.primaryColor.toColor(),
                  BlendMode.srcIn,
                ),
              ),
            ),
          ),
        ),
        const Positioned(
          top: 50.0,
          right: 1.0,
          child: UserStars(),
        ),
        Positioned(
          top: 35.0,
          left: 10.0,
          child: prefix ??
              IconButton(
                icon: const Icon(Icons.menu_rounded, color: Colors.white),
                onPressed: () async {
                  Scaffold.of(context).openDrawer();
                },
              ),
        ),
        Positioned(
          bottom: 6.0,
          left: 0,
          right: 0,
          child: Center(
            child: GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  PageRouteBuilder(
                    transitionDuration: const Duration(milliseconds: 700),
                    pageBuilder: (_, __, ___) => const AvatarScreen(),
                  ),
                );
              },
              child: Hero(
                transitionOnUserGestures: true,
                tag: Strings.userAvatarTag,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox(
                      width: calcWidth(90),
                      height: calcWidth(90),
                      child: CircularProgressIndicator(
                        strokeWidth: 5.0,
                        value: userState.currentUser.userXp / 100,
                        color: AppConstant.onPrimary.toColor(),
                      ),
                    ),
                    const UserAvatar(),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
