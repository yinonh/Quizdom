import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:trivia/core/common_widgets/current_user_avatar.dart';
import 'package:trivia/core/constants/app_constant.dart';
import 'package:trivia/core/constants/constant_strings.dart';
import 'package:trivia/core/navigation/route_extensions.dart';
import 'package:trivia/core/utils/size_config.dart';
import 'package:trivia/features/avatar_screen/avatar_screen.dart';

import 'app_bar_resource.dart';

class UserAppBar extends ConsumerWidget implements PreferredSizeWidget {
  @override
  final Size preferredSize;
  final Widget? prefix;
  final bool isEditable;

  UserAppBar({this.prefix, this.isEditable = true, super.key})
      : preferredSize = Size.fromHeight(calcHeight(120));

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Stack(
      children: [
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: Container(
            height: calcHeight(95),
            width: double.infinity,
            color: AppConstant.primaryColor,
          ),
        ),
        Positioned(
          top: calcHeight(93),
          left: 0,
          right: 0,
          child: Container(
            color: Colors.transparent,
            child: Center(
              child: SvgPicture.asset(
                Strings.appBarDrop,
                height: calcHeight(55),
                colorFilter: const ColorFilter.mode(
                  AppConstant.primaryColor,
                  BlendMode.srcIn,
                ),
              ),
            ),
          ),
        ),
        Positioned(
          top: calcHeight(50),
          right: 0,
          child: const AppBarResourceWidget(),
        ),
        Positioned(
          top: calcHeight(45),
          left: calcWidth(10),
          child: prefix ??
              IconButton(
                icon: const Icon(Icons.menu_rounded, color: Colors.white),
                onPressed: () async {
                  Scaffold.of(context).openDrawer();
                },
              ),
        ),
        Positioned(
          bottom: calcHeight(6.0),
          left: 0,
          right: 0,
          child: Center(
            child: GestureDetector(
              onTap: isEditable
                  ? () {
                      goRoute(AvatarScreen.routeName);
                    }
                  : null,
              child: Hero(
                transitionOnUserGestures: true,
                tag: Strings.userAvatarTag,
                child: CurrentUserAvatar(
                  showProgress: true,
                  onTapOverride: () {
                    Scaffold.of(context).closeDrawer();
                    goRoute(AvatarScreen.routeName);
                  },
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
