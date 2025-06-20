import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trivia/core/common_widgets/base_screen.dart';
import 'package:trivia/core/common_widgets/resource_floating_action_button.dart';
import 'package:trivia/core/constants/app_constant.dart';
import 'package:trivia/core/constants/app_routes.dart';
import 'package:trivia/core/utils/size_config.dart';
import 'package:trivia/features/profile_screen/view_modle/profile_screen_manager.dart';
import 'package:trivia/features/profile_screen/widgets/avatar_section.dart';
import 'package:trivia/features/profile_screen/widgets/delete_account_section.dart';
import 'package:trivia/features/profile_screen/widgets/profile_appbar.dart';
import 'package:trivia/features/profile_screen/widgets/profile_content.dart';
import 'package:trivia/features/profile_screen/widgets/statistics_section.dart';
import 'package:trivia/features/profile_screen/widgets/trophies_section.dart';

class ProfileScreen extends ConsumerWidget {
  static const routeName = AppRoutes.profileRouteName;

  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userStatistics = ref.read(profileScreenManagerProvider).statistics;
    return BaseScreen(
      actionButton: const ResourceFloatingActionButton(),
      child: Scaffold(
        backgroundColor: AppConstant.primaryColor,
        body: SingleChildScrollView(
          child: Column(
            children: [
              const ProfileAppbar(),
              SizedBox(
                height: calcHeight(15),
              ),
              const Stack(
                children: [
                  ProfileContent(),
                  AvatarSection(),
                ],
              ),
              SizedBox(
                height: calcHeight(15),
              ),
              TrophiesSection(statistics: userStatistics),
              SizedBox(
                height: calcHeight(15),
              ),
              StatisticsSection(statistics: userStatistics),
              const DeleteAccountSection(),
            ],
          ),
        ),
      ),
    );
  }
}
