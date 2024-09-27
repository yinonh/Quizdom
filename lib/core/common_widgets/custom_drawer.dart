import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trivia/core/common_widgets/stars.dart';
import 'package:trivia/core/common_widgets/user_avater.dart';
import 'package:trivia/core/utils/size_config.dart';
import 'package:trivia/data/service/user_provider.dart';
import 'package:trivia/features/auth_screen/auth_screen.dart';
import 'package:trivia/features/avatar_screen/avatar_screen.dart';
import 'package:trivia/features/categories_screen/categories_screen.dart';
import 'package:trivia/features/profile_screen/profile_screen.dart';
import 'package:trivia/core/constants/app_constant.dart';
import 'package:trivia/core/constants/constant_strings.dart';

class CustomDrawer extends ConsumerWidget {
  const CustomDrawer({super.key});

  Widget drawerOption({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    Color textColor = Colors.white,
    Color tileColor = const Color(0xFF00AFFF),
  }) {
    return ListTile(
      leading: Icon(icon, color: textColor),
      title: Text(
        title,
        style: TextStyle(
          color: textColor,
          fontWeight: FontWeight.bold,
        ),
      ),
      tileColor: tileColor,
      onTap: onTap,
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userState = ref.watch(userProvider);
    return Drawer(
      width: MediaQuery.of(context).size.width * 0.7,
      backgroundColor: AppConstant.primaryColor,
      child: Column(
        children: <Widget>[
          CustomDrawerHeader(userState: userState),
          drawerOption(
            icon: Icons.home,
            title: Strings.home,
            onTap: () {
              Navigator.pushReplacementNamed(
                  context, CategoriesScreen.routeName);
            },
          ),
          drawerOption(
            icon: Icons.account_circle_rounded,
            title: Strings.profile,
            onTap: () {
              Navigator.of(context)
                  .pushReplacementNamed(ProfileScreen.routeName);
            },
          ),
          drawerOption(
            icon: Icons.info,
            title: Strings.about,
            onTap: () {
              Navigator.of(context).pop();
            },
          ),
          drawerOption(
            icon: Icons.logout_rounded,
            title: Strings.logout,
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

class CustomDrawerHeader extends StatelessWidget {
  final UserState userState;

  const CustomDrawerHeader({
    super.key,
    required this.userState,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        color: AppConstant.primaryColor,
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                GestureDetector(
                  child: const UserAvatar(
                    showProgress: true,
                  ),
                  onTap: () {
                    Scaffold.of(context).closeDrawer();
                    Navigator.pushNamed(context, AvatarScreen.routeName);
                  },
                ),
                SizedBox(
                  width: calcWidth(20),
                ),
                const UserStars(),
              ],
            ),
            const SizedBox(height: 8.0),
            Text(
              "${Strings.hello} ${userState.currentUser.name ?? ""}",
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            Padding(
              padding: EdgeInsets.only(top: calcHeight(5)),
              child: const Divider(height: 8.0),
            ),
          ],
        ),
      ),
    );
  }
}
