import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';
import 'package:trivia/core/constants/app_constant.dart';
import 'package:trivia/core/constants/constant_strings.dart';
import 'package:trivia/core/utils/size_config.dart';
import 'package:trivia/features/categories_screen/view_model/categories_screen_manager.dart';
import 'package:trivia/features/intro_screen/intro_screen.dart';

class RecentCategories extends ConsumerWidget {
  final CategoriesState categoriesState;

  const RecentCategories({required this.categoriesState, super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: calcWidth(8)),
          child: const Text(
            Strings.recentPlayedCategories,
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        SizedBox(
          height: calcHeight(15),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: List.generate(categoriesState.userRecentCategories.length,
              (index) {
            final categoryIndex = categoriesState.userRecentCategories[index];
            return GestureDetector(
              onTap: () {
                ref
                    .read(categoriesScreenManagerProvider.notifier)
                    .setGeneralTriviaRoom("room_$categoryIndex");
                context.goNamed(TriviaIntroScreen.routeName);
              },
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(50.0),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withValues(alpha: 0.3),
                      spreadRadius: 1,
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(2.0),
                child: SvgPicture.asset(
                  AppConstant.categoryIcons[categoryIndex] ??
                      AppConstant.categoryIcons[-1]!,
                  height: calcHeight(40),
                ),
              ),
            );
          }),
        ),
        SizedBox(
          height: calcHeight(15),
        ),
      ],
    );
  }
}
