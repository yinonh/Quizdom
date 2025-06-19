import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trivia/core/common_widgets/custom_when.dart';
import 'package:trivia/core/constants/app_routes.dart';
import 'package:trivia/core/utils/general_functions.dart';
import 'package:trivia/core/utils/size_config.dart';
import 'package:trivia/data/providers/trivia_provider.dart';
import 'package:trivia/features/results_screen/view_model/duel_screen_manager/duel_result_screen_manager.dart';
import 'package:trivia/features/results_screen/widgets/duel_widgets/duel_results_header.dart';
import 'package:trivia/features/results_screen/widgets/duel_widgets/player_stats_comparison.dart';
import 'package:trivia/features/results_screen/widgets/duel_widgets/results_action_buttons.dart';
import 'package:trivia/features/results_screen/widgets/duel_widgets/winner_announcement.dart';
import 'package:trivia/features/results_screen/widgets/total_score.dart';

class DuelResultsScreen extends ConsumerWidget {
  static const String routeName = AppRoutes.duelResultsRouteName;
  final String roomId;

  const DuelResultsScreen({
    super.key,
    required this.roomId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final resultsAsync = ref.watch(duelResultScreenManagerProvider(roomId));
    return Scaffold(
      body: resultsAsync.customWhen(
        data: (resultsState) {
          final triviaCategories = ref.read(triviaProvider).categories;
          String categoryName = 'Any';
          if (resultsState.room.categoryId != null &&
              triviaCategories != null) {
            try {
              final category = triviaCategories.triviaCategories?.firstWhere(
                (cat) => cat.id == resultsState.room.categoryId,
              );
              categoryName = category?.name ?? 'Any';
            } catch (e) {
              // Category not found, keep default
            }
          }
          return Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Theme.of(context).colorScheme.primaryContainer,
                  Theme.of(context).colorScheme.surface,
                ],
              ),
            ),
            child: SafeArea(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      DuelResultsHeader(
                        resultsState: resultsState,
                        categoryName: cleanCategoryName(categoryName),
                      ),
                      SizedBox(height: calcHeight(24)),
                      WinnerAnnouncement(resultsState: resultsState),
                      SizedBox(height: calcHeight(48)),
                      if (resultsState.room.userAchievements != null &&
                          resultsState.room.userAchievements![
                                  resultsState.currentUserId] !=
                              null)
                        TotalScore(
                            score: calculateTotalScore(
                                resultsState.room.userAchievements![
                                    resultsState.currentUserId]!)),
                      SizedBox(height: calcHeight(24)),
                      PlayerStatsComparison(resultsState: resultsState),
                      SizedBox(height: calcHeight(32)),
                      ResultsActionButtons(resultsState: resultsState),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
