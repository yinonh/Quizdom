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
import 'package:trivia/features/profile_screen/widgets/link_account_section.dart'; // Import new widget

class ProfileScreen extends ConsumerWidget {
  static const routeName = AppRoutes.profileRouteName;

  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileState = ref.watch(profileScreenManagerProvider);
    final userStatistics = profileState.statistics;
    final currentUser = profileState.currentUser;
    final bool isAnonymous = currentUser?.isAnonymous ?? false;

    return BaseScreen(
      actionButton: const ResourceFloatingActionButton(),
      child: Scaffold(
        backgroundColor: AppConstant.primaryColor,
        body: SingleChildScrollView(
          child: Column(
            children: [
              const ProfileAppbar(), // AppBar should be fine for both
              SizedBox(height: calcHeight(15)),

              // Conditionally show LinkAccountSection or standard ProfileContent
              if (isAnonymous)
                const LinkAccountSection()
              else
                const Stack(
                  children: [
                    ProfileContent(), // Shows user details, edit functionality
                    AvatarSection(),
                  ],
                ),

              SizedBox(height: calcHeight(15)),
              TrophiesSection(statistics: userStatistics), // Trophies can be shown to guests
              SizedBox(height: calcHeight(15)),
              StatisticsSection(statistics: userStatistics), // Statistics can be shown to guests

              // Only show DeleteAccountSection if the user is NOT anonymous
              if (!isAnonymous)
                const DeleteAccountSection(),
            ],
          ),
        ),
      ),
    );
  }
}
