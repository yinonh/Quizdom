import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:trivia/features/avatar_screen/avatar_screen.dart';
import 'package:trivia/service/user_provider.dart';

class UserAppBar extends ConsumerWidget implements PreferredSizeWidget {
  @override
  final Size preferredSize;

  const UserAppBar({super.key}) : preferredSize = const Size.fromHeight(100.0);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userState = ref.watch(userProvider);
    return Stack(
      children: [
        AppBar(
          backgroundColor: Theme.of(context).primaryColor,
        ),
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: Container(
            color: Theme.of(context).scaffoldBackgroundColor,
            child: Center(
              child: SvgPicture.asset(
                'assets/drop.svg',
                height: 40,
                colorFilter: ColorFilter.mode(
                  Theme.of(context).primaryColor,
                  BlendMode.srcIn,
                ),
              ),
            ),
          ),
        ),
        userState.avatar != null
            ? Positioned(
                bottom: 0,
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
                          const SizedBox(
                            width: 80,
                            height: 80,
                            child: CircularProgressIndicator(
                              strokeWidth: 5.0,
                              value: 0.8,
                              color: Colors.blue,
                            ),
                          ),
                          CircleAvatar(
                            radius: 35,
                            child: ClipOval(
                              child: SvgPicture.string(
                                userState.avatar!,
                                fit: BoxFit.cover,
                                height: 70,
                                width: 70,
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
