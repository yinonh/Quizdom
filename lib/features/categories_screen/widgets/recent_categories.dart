import 'package:flutter/material.dart';
import 'package:trivia/core/utils/size_config.dart';
import 'package:trivia/features/categories_screen/view_model/categories_screen_manager.dart';
import 'package:trivia/core/constants/app_constant.dart';
import 'package:trivia/core/constants/constant_strings.dart';

class RecentCategories extends StatelessWidget {
  final CategoriesState categoriesState;

  const RecentCategories({required this.categoriesState, super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          Strings.recentPlayedCategories,
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        SizedBox(
          height: calcHeight(15),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: List.generate(categoriesState.userRecentCategories.length,
              (index) {
            final categoryIndex = categoriesState.userRecentCategories[index];
            return Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(50.0),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.3),
                    spreadRadius: 1,
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              padding: const EdgeInsets.all(8.0),
              child: Icon(
                AppConstant.categoryIcons[categoryIndex] ?? Icons.category,
                color:
                    AppConstant.categoryColors[categoryIndex] ?? Colors.black,
                size: 24.0,
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
