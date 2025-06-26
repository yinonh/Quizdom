import 'package:flutter/material.dart';
import 'package:Quizdom/core/common_widgets/app_bar.dart';
import 'package:Quizdom/core/constants/constant_strings.dart';
import 'package:Quizdom/core/navigation/route_extensions.dart';
import 'package:Quizdom/core/utils/size_config.dart';
import 'package:Quizdom/features/categories_screen/categories_screen.dart';

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
          goRoute(CategoriesScreen.routeName);
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
