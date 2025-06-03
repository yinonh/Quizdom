import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trivia/core/constants/app_constant.dart';
import 'package:trivia/core/constants/constant_strings.dart';
import 'package:trivia/core/navigation/route_extensions.dart';
import 'package:trivia/core/utils/size_config.dart';
import 'package:trivia/features/categories_screen/categories_screen.dart';
import 'package:trivia/features/results_screen/view_model/duel_screen_manager/duel_result_screen_manager.dart';

class ResultsActionButtons extends ConsumerWidget {
  final DuelResultState resultsState;

  const ResultsActionButtons({
    super.key,
    required this.resultsState,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SizedBox(
      width: double.infinity,
      height: calcHeight(55),
      child: OutlinedButton.icon(
        onPressed: () {
          // Return to home screen
          goRoute(CategoriesScreen.routeName);
        },
        style: OutlinedButton.styleFrom(
          side: const BorderSide(
            color: AppConstant.secondaryColor,
            width: 2,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          foregroundColor: AppConstant.secondaryColor,
        ),
        icon: const Icon(Icons.home, size: 22),
        label: const Text(
          Strings.returnHome,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
