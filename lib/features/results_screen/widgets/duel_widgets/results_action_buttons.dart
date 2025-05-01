import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:trivia/core/constants/app_constant.dart';
import 'package:trivia/core/constants/constant_strings.dart';
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
    // Get opponent ID
    final opponentId = resultsState.room.users.firstWhere(
      (id) => id != resultsState.currentUserId,
      orElse: () => '',
    );

    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          height: calcHeight(55),
          child: ElevatedButton.icon(
            onPressed: () {
              // Play again with the same opponent and settings
              ref
                  .read(
                      duelResultScreenManagerProvider(resultsState.room.roomId!)
                          .notifier)
                  .playAgain(resultsState.room.roomId!, opponentId);
            },
            style: ElevatedButton.styleFrom(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 5,
              shadowColor: AppConstant.primaryColor.withValues(alpha: 0.5),
              backgroundColor: AppConstant.primaryColor,
              foregroundColor: Colors.white,
            ),
            icon: const Icon(Icons.refresh, size: 22),
            label: const Text(
              Strings.playAgain,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        SizedBox(height: calcHeight(16)),
        SizedBox(
          width: double.infinity,
          height: calcHeight(55),
          child: OutlinedButton.icon(
            onPressed: () {
              // Return to home screen
              context.goNamed(CategoriesScreen.routeName);
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
        ),
      ],
    );
  }
}
