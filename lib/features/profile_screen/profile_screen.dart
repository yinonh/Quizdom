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
    final asyncProfileState = ref.watch(profileScreenManagerProvider);

    return asyncProfileState.when(
      data: (profileState) {
        final userStatistics = profileState.statistics;
        // final currentUser = profileState.currentUser; // TriviaUser
        final bool shouldShowLink = profileState.shouldShowAccountLinkForm;

        return BaseScreen(
          actionButton: const ResourceFloatingActionButton(),
          child: Scaffold(
            backgroundColor: AppConstant.primaryColor,
            body: SingleChildScrollView(
              child: Column(
                children: [
                  const ProfileAppbar(),
                  SizedBox(height: calcHeight(15)),
                  if (shouldShowLink)
                    const LinkAccountSection()
                  else
                    const Stack(
                      children: [
                        ProfileContent(),
                        AvatarSection(),
                      ],
                    ),
                  SizedBox(height: calcHeight(15)),
                  TrophiesSection(statistics: userStatistics),
                  SizedBox(height: calcHeight(15)),
                  StatisticsSection(statistics: userStatistics),
                  if (!shouldShowLink) // If not showing link form, user is considered registered
                    const DeleteAccountSection(),
                ],
              ),
            ),
          ),
        );
      },
      loading: () => const BaseScreen(
        child: Scaffold(
          backgroundColor: AppConstant.primaryColor,
          body: Center(child: CircularProgressIndicator()),
        ),
      ),
      error: (err, stack) => BaseScreen(
        child: Scaffold(
          backgroundColor: AppConstant.primaryColor,
          body: Center(child: Text('Error: $err')),
        ),
      ),
    );
  }
}
