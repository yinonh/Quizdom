import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:trivia/features/auth_screen/auth_screen.dart';
import 'package:trivia/features/avatar_screen/avatar_screen.dart';
import 'package:trivia/service/user_provider.dart';
import 'package:trivia/utility/app_constant.dart';
import 'package:trivia/utility/color_utility.dart';
import 'package:trivia/utility/size_config.dart';

class UserAppBar extends ConsumerWidget implements PreferredSizeWidget {
  @override
  final Size preferredSize;

  UserAppBar({super.key}) : preferredSize = Size.fromHeight(calcHeight(120));

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
                'assets/drop.svg',
                height: calcHeight(55),
                colorFilter: ColorFilter.mode(
                  AppConstant.primaryColor.toColor(),
                  BlendMode.srcIn,
                ),
              ),
            ),
          ),
        ),
        Positioned(
          top: 50.0,
          right: 1.0,
          child: Row(
            children: List.generate(
              3,
              (index) => const Icon(
                Icons.star,
                color: Colors.white,
              ),
            ),
          ),
        ),
        Positioned(
          top: 35.0,
          left: 10.0,
          child: IconButton(
            icon: const Icon(Icons.menu_rounded, color: Colors.white),
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              if (context.mounted) {
                Navigator.of(context)
                    .pushReplacementNamed(AuthScreen.routeName);
              }
            },
          ),
        ),
        userState.avatar != null
            ? Positioned(
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
                      tag: "userAvatar",
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          SizedBox(
                            width: calcWidth(90),
                            height: calcWidth(90),
                            child: CircularProgressIndicator(
                              strokeWidth: 5.0,
                              value: 0.8,
                              color: AppConstant.onPrimary.toColor(),
                            ),
                          ),
                          userState.userImage != null
                              ? CircleAvatar(
                                  backgroundImage:
                                      FileImage(userState.userImage!),
                                  radius: calcWidth(42),
                                )
                              : CircleAvatar(
                                  backgroundColor: Colors.white,
                                  radius: calcWidth(42),
                                  child: ClipOval(
                                    child: SvgPicture.string(
                                      userState.avatar!,
                                      fit: BoxFit.cover,
                                      height: calcWidth(80),
                                      width: calcWidth(80),
                                    ),
                                  ),
                                ),
                        ],
                      ),
                    ),
                  ),
                ),
              )
            : const SizedBox(
                height: 0,
              ),
      ],
    );
  }
}
