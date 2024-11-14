import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trivia/core/common_widgets/background.dart';
import 'package:trivia/core/common_widgets/base_screen.dart';
import 'package:trivia/core/common_widgets/custom_drawer.dart';
import 'package:trivia/core/common_widgets/user_app_bar.dart';
import 'package:trivia/core/utils/size_config.dart';
import 'package:trivia/features/categories_screen/view_model/categories_screen_manager.dart';
import 'package:trivia/features/categories_screen/widgets/categories_screen_shimmer.dart';
import 'package:trivia/features/categories_screen/widgets/expandable_horizontal_list.dart';
import 'package:trivia/features/categories_screen/widgets/info_container.dart';
import 'package:trivia/features/categories_screen/widgets/recent_categories.dart';
import 'package:trivia/features/categories_screen/widgets/top_button.dart';
import 'package:trivia/core/constants/app_constant.dart';
import 'package:trivia/core/constants/constant_strings.dart';

class CategoriesScreen extends ConsumerWidget {
  static const routeName = Strings.categoriesRouteName;

  const CategoriesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categoriesState = ref.watch(categoriesScreenManagerProvider);

    return BaseScreen(
      child: Scaffold(
        appBar: UserAppBar(),
        drawer: const CustomDrawer(),
        extendBodyBehindAppBar: true,
        body: CustomBackground(
          child: categoriesState.when(
              data: (data) => SingleChildScrollView(
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
                                  // Handle create quiz tap
                                },
                              ),
                              TopButton(
                                icon: Icons.handshake_rounded,
                                label: Strings.soloMode,
                                color: AppConstant.secondaryColor,
                                onTap: () {
                                  // Handle solo mode tap
                                },
                              ),
                              TopButton(
                                icon: Icons.groups_2,
                                label: Strings.multiplayer,
                                color: AppConstant.onPrimary,
                                onTap: () {
                                  // Handle multiplayer tap
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
                            categories: data.categories.triviaCategories,
                            title: Strings.featuredCategories,
                          ),
                          const InfoContainer(
                              text: "Personal Rooms Information"),
                          const InfoContainer(
                              text: "Personal Rooms Information"),
                          const InfoContainer(
                              text: "Personal Rooms Information"),
                        ],
                      ),
                    ),
                  ),
              error: (error, _) => Center(child: Text(error.toString())),
              loading: () => const ShimmerLoadingScreen()),
        ),
      ),
    );
  }
}
