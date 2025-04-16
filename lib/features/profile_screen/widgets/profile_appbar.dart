import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:trivia/core/common_widgets/app_bar.dart';
import 'package:trivia/core/utils/size_config.dart';
import 'package:trivia/features/categories_screen/categories_screen.dart';
import 'package:trivia/core/constants/constant_strings.dart';

class ProfileAppbar extends StatelessWidget {
  const ProfileAppbar({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomAppBar(
      title: Strings.profile,
      leading: IconButton(
        icon: const Icon(
          Icons.arrow_back_ios_new_rounded,
          color: Colors.white,
        ),
        onPressed: () {
          context.goNamed(CategoriesScreen.routeName);
        },
      ),
      actions: [
        SizedBox(
          width: calcWidth(45),
        )
      ],
    );
  }
}
