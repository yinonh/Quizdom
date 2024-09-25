import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trivia/features/profile_screen/widgets/additional_content.dart';
import 'package:trivia/features/profile_screen/widgets/avatar_section.dart';
import 'package:trivia/features/profile_screen/widgets/profile_appbar.dart';
import 'package:trivia/features/profile_screen/widgets/profile_content.dart';
import 'package:trivia/utility/app_constant.dart';
import 'package:trivia/utility/color_utility.dart';
import 'package:trivia/utility/constant_strings.dart';

class ProfileScreen extends ConsumerWidget {
  static const routeName = Strings.profileRouteName;

  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: AppConstant.primaryColor.toColor(),
      body: const SingleChildScrollView(
        child: Column(
          children: [
            ProfileAppbar(),
            Stack(
              children: [
                ProfileContent(),
                AvatarSection(),
              ],
            ),
            AdditionalContent(),
          ],
        ),
      ),
    );
  }
}
