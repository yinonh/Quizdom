import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trivia/core/common_widgets/base_screen.dart';
import 'package:trivia/core/constants/app_constant.dart';
import 'package:trivia/core/constants/constant_strings.dart';
import 'package:trivia/core/utils/size_config.dart';
import 'package:trivia/features/profile_screen/view_modle/profile_screen_manager.dart';
import 'package:trivia/features/profile_screen/widgets/avatar_section.dart';
import 'package:trivia/features/profile_screen/widgets/profile_appbar.dart';
import 'package:trivia/features/profile_screen/widgets/profile_content.dart';
import 'package:trivia/features/profile_screen/widgets/statistics_section.dart';
import 'package:trivia/features/profile_screen/widgets/trophies_section.dart';

class ProfileScreen extends ConsumerWidget {
  static const routeName = Strings.profileRouteName;

  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userStatistics = ref.read(profileScreenManagerProvider).statistics;
    return BaseScreen(
      child: Scaffold(
        backgroundColor: AppConstant.primaryColor,
        body: SingleChildScrollView(
          child: Column(
            spacing: calcHeight(15),
            children: [
              const ProfileAppbar(),
              const Stack(
                children: [
                  ProfileContent(),
                  AvatarSection(),
                ],
              ),
              TrophiesSection(statistics: userStatistics),
              StatisticsSection(statistics: userStatistics),
            ],
          ),
        ),
      ),
    );
  }
}
