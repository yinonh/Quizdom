import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:Quizdom/core/common_widgets/app_bar_resource.dart';
import 'package:Quizdom/core/common_widgets/current_user_avatar.dart';
import 'package:Quizdom/core/constants/app_constant.dart';
import 'package:Quizdom/core/constants/constant_strings.dart';
import 'package:Quizdom/core/navigation/route_extensions.dart';
import 'package:Quizdom/core/utils/size_config.dart';
import 'package:Quizdom/data/providers/user_provider.dart';
import 'package:Quizdom/features/auth_screen/auth_screen.dart';
import 'package:Quizdom/features/avatar_screen/avatar_screen.dart';
import 'package:Quizdom/features/categories_screen/categories_screen.dart';
import 'package:Quizdom/features/profile_screen/profile_screen.dart';

import 'guest_logout_warning_dialog.dart';

class CustomDrawer extends ConsumerWidget {
  const CustomDrawer({super.key});

  Widget drawerOption({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    Color textColor = Colors.white,
    Color tileColor = AppConstant.primaryColor,
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

  Future<void> _performRegularLogout(BuildContext context) async {
    try {
      await FirebaseAuth.instance.signOut();
      await GoogleSignIn().signOut();

      if (context.mounted) {
        goRoute(AuthScreen.routeName);
      }
    } catch (e) {
      // Handle error
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error logging out: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userState = ref.watch(authProvider);
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
              pop();
              goRoute(CategoriesScreen.routeName);
            },
          ),
          drawerOption(
            icon: Icons.account_circle_rounded,
            title: Strings.profile,
            onTap: () {
              pop();
              goRoute(ProfileScreen.routeName);
            },
          ),
          drawerOption(
            icon: Icons.info,
            title: Strings.about,
            onTap: () {
              pop();
            },
          ),
          drawerOption(
            icon: Icons.logout_rounded,
            title: Strings.logout,
            onTap: () async {
              final user = FirebaseAuth.instance.currentUser;

              // Check if user is a guest (anonymous user)
              if (user != null && user.isAnonymous) {
                // Show warning dialog for guest users
                GuestLogoutWarningDialog.show(context);
              } else {
                // Regular logout for authenticated users
                await _performRegularLogout(context);
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
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                GestureDetector(
                  child: CurrentUserAvatar(
                    showProgress: true,
                    onTapOverride: () {
                      Scaffold.of(context).closeDrawer();
                      goRoute(AvatarScreen.routeName);
                    },
                  ),
                ),
                const AppBarResourceWidget(isVertical: true),
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
