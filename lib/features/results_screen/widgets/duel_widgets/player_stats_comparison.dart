import 'package:flutter/material.dart';
import 'package:trivia/core/constants/app_constant.dart';
import 'package:trivia/core/constants/constant_strings.dart';
import 'package:trivia/core/utils/size_config.dart';
import 'package:trivia/data/models/trivia_achievements.dart';
import 'package:trivia/features/results_screen/view_model/duel_screen_manager/duel_result_screen_manager.dart';
import 'package:trivia/features/results_screen/widgets/duel_widgets/stat_comparison_bar.dart';

class PlayerStatsComparison extends StatelessWidget {
  final DuelResultState resultsState;

  const PlayerStatsComparison({
    super.key,
    required this.resultsState,
  });

  @override
  Widget build(BuildContext context) {
    final currentUserId = resultsState.currentUserId;
    final currentAchievements =
        resultsState.room.userAchievements?[currentUserId];

    // Get opponent ID
    final opponentId = resultsState.room.users.firstWhere(
      (id) => id != currentUserId,
      orElse: () => '',
    );
    final opponentAchievements =
        resultsState.room.userAchievements?[opponentId];

    // If achievements are null, return an empty container or loading indicator
    if (currentAchievements == null || opponentAchievements == null) {
      return const Center(
        child: Text(Strings.statisticsNotAvailable),
      );
    }

    // Calculate derived metrics
    final currentAccuracy = _calculateAccuracy(currentAchievements);
    final opponentAccuracy = _calculateAccuracy(opponentAchievements);

    final currentAvgResponseTime =
        _calculateAverageResponseTime(currentAchievements);
    final opponentAvgResponseTime =
        _calculateAverageResponseTime(opponentAchievements);

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.white,
              AppConstant.primaryColor.withValues(alpha: 0.05),
            ],
          ),
        ),
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              spacing: calcWidth(10),
              children: [
                const Icon(
                  Icons.analytics,
                  color: AppConstant.primaryColor,
                  size: 24,
                ),
                Text(
                  Strings.gamePerformance,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppConstant.primaryColor,
                      ),
                ),
              ],
            ),
            SizedBox(height: calcHeight(20)),
            StatComparisonBar(
              label: Strings.accuracy,
              leftValue: currentAccuracy,
              rightValue: opponentAccuracy,
              leftLabel: '${currentAccuracy.toInt()}%',
              rightLabel: '${opponentAccuracy.toInt()}%',
              primaryColor: AppConstant.primaryColor,
              secondaryColor: AppConstant.highlightColor,
              icon: Icons.precision_manufacturing_outlined,
            ),
            SizedBox(height: calcHeight(16)),
            StatComparisonBar(
              label: Strings.avgResponseTime,
              leftValue: currentAvgResponseTime,
              // Inverse because lower is better
              rightValue: opponentAvgResponseTime,
              // Inverse because lower is better
              leftLabel: '${currentAvgResponseTime.toStringAsFixed(1)}s',
              rightLabel: '${opponentAvgResponseTime.toStringAsFixed(1)}s',
              primaryColor: AppConstant.primaryColor,
              secondaryColor: AppConstant.highlightColor,
              lowerIsBetter: true,
              icon: Icons.timer_outlined,
            ),
            SizedBox(height: calcHeight(16)),
            _buildStatsSummary(context, currentAchievements,
                resultsState.room.userScores![currentUserId]!),
          ],
        ),
      ),
    );
  }

  double _calculateAccuracy(TriviaAchievements achievements) {
    final totalAttempted = achievements.correctAnswers +
        achievements.wrongAnswers +
        achievements.unanswered;
    if (totalAttempted == 0) return 0;
    return achievements.correctAnswers / totalAttempted * 100;
  }

  double _calculateAverageResponseTime(TriviaAchievements achievements) {
    final answeredQuestions = achievements.correctAnswers +
        achievements.wrongAnswers +
        achievements.unanswered;
    if (answeredQuestions == 0) return 0;
    return achievements.sumResponseTime / answeredQuestions;
  }

  Widget _buildStatsSummary(
    BuildContext context,
    TriviaAchievements achievements,
    int score,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            AppConstant.secondaryColor,
            AppConstant.primaryColor,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppConstant.primaryColor.withValues(alpha: 0.2),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildStatItem(
              context,
              title: Strings.correct,
              value: '${achievements.correctAnswers}',
              icon: Icons.emoji_events,
              iconColor: AppConstant.goldColor,
              isHighlighted:
                  resultsState.winnerId == resultsState.currentUserId,
            ),
          ),
          _verticalDivider(),
          Expanded(
            child: _buildStatItem(
              context,
              title: Strings.skipped,
              value: '${achievements.unanswered}',
              icon: Icons.help_outline,
              iconColor: Colors.white,
            ),
          ),
          _verticalDivider(),
          Expanded(
            child: _buildStatItem(
              context,
              title: Strings.wrong,
              value: '${achievements.wrongAnswers}',
              icon: Icons.close_rounded,
              iconColor: AppConstant.red.withValues(alpha: 0.8),
            ),
          ),
        ],
      ),
    );
  }

  Widget _verticalDivider() {
    return Container(
      width: 1,
      height: 40,
      color: Colors.white24,
    );
  }

  Widget _buildStatItem(
    BuildContext context, {
    required String title,
    required String value,
    required IconData icon,
    required Color iconColor,
    bool isHighlighted = false,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.15),
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            color: iconColor,
            size: 22,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          title,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 12,
          ),
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: isHighlighted ? AppConstant.goldColor : Colors.white,
          ),
        ),
      ],
    );
  }
}
