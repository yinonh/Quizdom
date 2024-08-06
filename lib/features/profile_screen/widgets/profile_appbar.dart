import 'package:flutter/material.dart';
import 'package:trivia/common_widgets/app_bar.dart';
import 'package:trivia/features/categories_screen/categories_screen.dart';

class ProfileAppbar extends StatelessWidget {
  const ProfileAppbar({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomAppBar(
      title: 'Profile',
      leading: IconButton(
        icon: const Icon(
          Icons.arrow_back_ios_new_rounded,
          color: Colors.white,
        ),
        onPressed: () {
          Navigator.pushReplacementNamed(context, CategoriesScreen.routeName);
        },
      ),
      actions: [
        IconButton(
          icon: const Icon(
            Icons.save_rounded,
            color: Colors.white,
          ),
          onPressed: () {},
        ),
      ],
    );
  }
}
