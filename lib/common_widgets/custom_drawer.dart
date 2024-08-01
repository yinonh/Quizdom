import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trivia/common_widgets/user_avater.dart';
import 'package:trivia/features/auth_screen/auth_screen.dart';
import 'package:trivia/service/user_provider.dart';
import 'package:trivia/utility/app_constant.dart';
import 'package:trivia/utility/color_utility.dart';

class CustomDrawer extends ConsumerWidget {
  const CustomDrawer({super.key});

  Widget drawerOption({
    required Icon icon,
    required String title,
    required VoidCallback onTap,
    Color textColor = Colors.white,
    Color tileColor = const Color(0xFF00AFFF),
  }) {
    return ListTile(
      leading: icon,
      title: Text(title, style: TextStyle(color: textColor)),
      tileColor: tileColor,
      onTap: onTap,
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userState = ref.watch(userProvider);
    return Drawer(
      backgroundColor: AppConstant.primaryColor.toColor(),
      child: Column(
        children: <Widget>[
          UserAccountsDrawerHeader(
            accountName: Text(
              userState.name ?? "First Name",
              style: TextStyle(
                color: AppConstant.highlightColor.toColor(),
              ),
            ),
            accountEmail: Text(
              userState.email ?? "",
              style: TextStyle(
                color: AppConstant.highlightColor.toColor(),
              ),
            ),
            otherAccountsPicturesSize: const Size.square(75),
            otherAccountsPictures: [
              Row(
                children: List.generate(
                  3,
                  (index) => const Icon(
                    Icons.star,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
            currentAccountPicture: const UserAvatar(),
            decoration: BoxDecoration(
              color: AppConstant.secondaryColor.toColor(),
            ),
          ),
          drawerOption(
            icon: Icon(Icons.home, color: AppConstant.onPrimary.toColor()),
            title: 'Home',
            onTap: () {
              Navigator.of(context).pop();
            },
          ),
          drawerOption(
            icon: Icon(Icons.settings, color: AppConstant.onPrimary.toColor()),
            title: 'Settings',
            onTap: () {
              Navigator.of(context).pop();
            },
          ),
          drawerOption(
            icon: Icon(Icons.info, color: AppConstant.onPrimary.toColor()),
            title: 'About',
            onTap: () {
              Navigator.of(context).pop();
            },
          ),
          drawerOption(
            icon: Icon(Icons.logout_rounded,
                color: AppConstant.onPrimary.toColor()),
            title: 'Logout',
            onTap: () async {
              await FirebaseAuth.instance.signOut();
              if (context.mounted) {
                Navigator.of(context)
                    .pushReplacementNamed(AuthScreen.routeName);
              }
            },
          ),
        ],
      ),
    );
  }
}
