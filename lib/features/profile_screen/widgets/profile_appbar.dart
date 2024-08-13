import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trivia/common_widgets/app_bar.dart';
import 'package:trivia/features/categories_screen/categories_screen.dart';
import 'package:trivia/utility/constant_strings.dart';
import 'package:trivia/utility/size_config.dart';

class ProfileAppbar extends ConsumerWidget {
  const ProfileAppbar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return CustomAppBar(
      title: Strings.profile,
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
        SizedBox(
          width: calcWidth(45),
        )
      ],
    );
  }
}
