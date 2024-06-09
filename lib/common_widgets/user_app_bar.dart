import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:trivia/features/avatar_screen/avatar_screen.dart';
import 'package:trivia/features/categories_screen/view_model/categories_screen_manager.dart';

class UserAppBar extends ConsumerWidget implements PreferredSizeWidget {
  @override
  final Size preferredSize;

  const UserAppBar({Key? key})
      : preferredSize = const Size.fromHeight(80.0),
        super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categoriesNotifier =
        ref.read(categoriesScreenManagerProvider.notifier);
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
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: FutureBuilder<String?>(
            future: categoriesNotifier.fetchAvatar(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const CircleAvatar(
                  radius: 40,
                  child: CircularProgressIndicator(),
                );
              } else if (snapshot.hasError) {
                return const Center(child: Text('Error fetching avatar'));
              } else if (!snapshot.hasData || snapshot.data == null) {
                return const Center(child: Text('No avatar found'));
              } else {
                final avatarSvg = snapshot.data!;
                return Center(
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
                                avatarSvg,
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
                );
              }
            },
          ),
        ),
        // const Positioned(
        //   top: 0.5,
        //   left: 0,
        //   right: 0,
        //   child: Text(
        //     "Yinon Hadad",
        //     style: TextStyle(color: Colors.white, fontSize: 15),
        //   ),
        // )
      ],
    );
  }
}
