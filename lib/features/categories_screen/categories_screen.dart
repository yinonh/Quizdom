import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shimmer/shimmer.dart';
import 'package:Quizdom/core/common_widgets/background.dart';
import 'package:Quizdom/core/common_widgets/base_screen.dart';
import 'package:Quizdom/core/common_widgets/custom_drawer.dart';
import 'package:Quizdom/core/common_widgets/custom_when.dart';
import 'package:Quizdom/core/common_widgets/resource_floating_action_button.dart';
import 'package:Quizdom/core/common_widgets/under_construction_dialog.dart';
import 'package:Quizdom/core/common_widgets/user_app_bar.dart';
import 'package:Quizdom/core/constants/app_constant.dart';
import 'package:Quizdom/core/constants/app_routes.dart';
import 'package:Quizdom/core/constants/constant_strings.dart';
import 'package:Quizdom/core/navigation/route_extensions.dart';
import 'package:Quizdom/core/utils/size_config.dart';
import 'package:Quizdom/data/models/trivia_user.dart';
import 'package:Quizdom/features/categories_screen/view_model/categories_screen_manager.dart';
import 'package:Quizdom/features/categories_screen/widgets/categories_screen_shimmer.dart';
import 'package:Quizdom/features/categories_screen/widgets/expandable_horizontal_list.dart';
import 'package:Quizdom/features/categories_screen/widgets/recent_categories.dart';
import 'package:Quizdom/features/categories_screen/widgets/top_button.dart';
import 'package:Quizdom/features/categories_screen/widgets/top_players.dart';
import 'package:Quizdom/features/categories_screen/widgets/wheel_of_fortune_banner.dart';
import 'package:Quizdom/features/intro_screen/intro_screen.dart';

class CategoriesScreen extends ConsumerWidget {
  static const routeName = AppRoutes.categoriesRouteName;

  const CategoriesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categoriesState = ref.watch(categoriesScreenManagerProvider);
    final categoriesNotifier =
        ref.read(categoriesScreenManagerProvider.notifier);

    return BaseScreen(
      actionButton: const ResourceFloatingActionButton(),
      child: Scaffold(
        appBar: UserAppBar(),
        drawer: const CustomDrawer(),
        extendBodyBehindAppBar: true,
        body: CustomBackground(
          child: categoriesState.customWhen(
              data: (data) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (data.showRowLogin) {
                    categoriesNotifier.onClaim(AppConstant.loginAwards[
                        data.daysInRow % AppConstant.loginAwards.length]);

                    // Use router navigation instead of showDialog
                    context.go(
                        '${AppRoutes.categoriesRouteName}${AppRoutes.dailyLoginRouteName}',
                        extra: {
                          'streakDays':
                              data.daysInRow % AppConstant.loginAwards.length,
                          'startDay': 1,
                          'rewards': AppConstant.loginAwards,
                          'onClaim': () {
                            // This will be called when the user claims the reward
                            pop();
                          },
                        });
                  }
                });
                return SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(1),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          height: calcHeight(160),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            TopButton(
                              icon: Icons.add_rounded,
                              label: Strings.createQuiz,
                              color: AppConstant.highlightColor,
                              onTap: () {
                                UnderConstructionDialog.show(context);
                              },
                            ),
                            TopButton(
                              icon: Icons.handshake_rounded,
                              label: Strings.soloMode,
                              color: AppConstant.secondaryColor,
                              onTap: () {
                                categoriesNotifier.setTriviaRoom();
                                goRoute(TriviaIntroScreen.routeName);
                              },
                            ),
                            TopButton(
                              icon: Icons.groups_2,
                              label: Strings.multiplayer,
                              color: AppConstant.onPrimaryColor,
                              onTap: () {
                                UnderConstructionDialog.show(context);
                                // categoriesNotifier.setGroupTriviaRoom();
                                // context.goNamed(TriviaIntroScreen.routeName);
                              },
                            ),
                          ],
                        ),
                        SizedBox(
                          height: calcHeight(30),
                        ),
                        data.userRecentCategories.length >= 3
                            ? RecentCategories(
                                categoriesState: data,
                              )
                            : const SizedBox.shrink(),
                        ExpandableHorizontalList(
                          triviaRoom: data.triviaRooms,
                          title: Strings.featuredCategories,
                        ),
                        const WheelOfFortuneBanner(),
                        FutureBuilder<Map<TriviaUser, int>>(
                          future: categoriesNotifier.getTopUsers(),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return Shimmer.fromColors(
                                baseColor: AppConstant.shimmerBaseColor,
                                highlightColor:
                                    AppConstant.shimmerHighlightColor,
                                child: Container(
                                  height: calcHeight(200),
                                  width: double.infinity,
                                  decoration: BoxDecoration(
                                    color: AppConstant.white,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                              ); // Show shimmer effect while loading
                            } else if (snapshot.hasError) {
                              return Center(
                                  child: Text('Error: ${snapshot.error}'));
                            } else if (!snapshot.hasData ||
                                snapshot.data!.isEmpty) {
                              return const Center(child: Text(Strings.error));
                            }

                            return ExpandableHighScorePlayersList(
                                topUsers: snapshot.data!);
                          },
                        ),
                      ],
                    ),
                  ),
                );
              },
              loading: () => const ShimmerLoadingScreen()),
        ),
      ),
    );
  }
}
