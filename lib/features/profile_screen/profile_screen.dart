import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trivia/core/constants/app_constant.dart';
import 'package:trivia/core/constants/constant_strings.dart';
import 'package:trivia/features/profile_screen/widgets/additional_content.dart';
import 'package:trivia/features/profile_screen/widgets/avatar_section.dart';
import 'package:trivia/features/profile_screen/widgets/profile_appbar.dart';
import 'package:trivia/features/profile_screen/widgets/profile_content.dart';
import 'package:trivia/core/common_widgets/base_screen.dart';

class ProfileScreen extends ConsumerWidget {
  static const routeName = Strings.profileRouteName;

  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return const BaseScreen(
      child: Scaffold(
        backgroundColor: AppConstant.primaryColor,
        body: SingleChildScrollView(
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
      ),
    );
  }
}
