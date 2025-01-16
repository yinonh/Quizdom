import 'package:flutter/material.dart';
import 'package:trivia/core/constants/app_constant.dart';
import 'package:trivia/core/constants/constant_strings.dart';
import 'package:trivia/core/utils/enums/trophy_type.dart';
import 'package:trivia/core/utils/size_config.dart';
import 'package:trivia/data/models/user_statistics.dart';
import 'package:trivia/features/profile_screen/widgets/trophy_item.dart';

class TrophiesSection extends StatelessWidget {
  final UserStatistics statistics;

  const TrophiesSection({
    super.key,
    required this.statistics,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: calcWidth(10)),
      padding: EdgeInsets.symmetric(
          horizontal: calcWidth(15), vertical: calcHeight(10)),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.all(Radius.circular(35.0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(
                child: Text(
                  Strings.achievements,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppConstant.primaryColor,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppConstant.primaryColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: const Icon(
                  Icons.emoji_events,
                  color: AppConstant.primaryColor,
                  size: 28,
                ),
              ),
            ],
          ),
          _buildTrophyGrid(),
        ],
      ),
    );
  }

  Widget _buildTrophyGrid() {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      mainAxisSpacing: 25,
      crossAxisSpacing: 15,
      childAspectRatio: 1,
      children: [
        TrophyItem(
          title: Strings.dailyStreak,
          value: statistics.currentLoginStreak,
          thresholds: AppConstant.loginStreakThresholds,
          category: TrophyType.login,
        ),
        TrophyItem(
          title: Strings.gamesPlayed,
          value: statistics.totalGamesPlayed,
          thresholds: AppConstant.gamesPlayedThresholds,
          category: TrophyType.games,
        ),
        TrophyItem(
          title: Strings.victories,
          value: statistics.gamesWon,
          thresholds: AppConstant.gamesWonThresholds,
          category: TrophyType.wins,
        ),
        TrophyItem(
          title: Strings.totalScore,
          value: statistics.totalScore,
          thresholds: AppConstant.totalScoreThresholds,
          category: TrophyType.points,
        ),
      ],
    );
  }
}
