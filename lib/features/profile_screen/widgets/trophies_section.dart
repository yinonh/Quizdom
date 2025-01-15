import 'package:flutter/material.dart';
import 'package:trivia/core/constants/app_constant.dart';
import 'package:trivia/data/models/user_statistics.dart';

class TrophiesSection extends StatelessWidget {
  final UserStatistics statistics;

  const TrophiesSection({
    super.key,
    required this.statistics,
  });

  // Trophy thresholds for each category
  static const _loginStreakThresholds = {
    'bronze': 3,
    'silver': 7,
    'gold': 14,
    'platinum': 30,
    'diamond': 60,
    'ruby': 90,
  };

  static const _gamesPlayedThresholds = {
    'bronze': 10,
    'silver': 50,
    'gold': 100,
    'platinum': 200,
    'diamond': 500,
    'ruby': 1000,
  };

  static const _gamesWonThresholds = {
    'bronze': 5,
    'silver': 25,
    'gold': 50,
    'platinum': 100,
    'diamond': 250,
    'ruby': 500,
  };

  static const _correctAnswersThresholds = {
    'bronze': 50,
    'silver': 250,
    'gold': 500,
    'platinum': 1000,
    'diamond': 2500,
    'ruby': 5000,
  };

  static const _totalScoreThresholds = {
    'bronze': 1000,
    'silver': 5000,
    'gold': 10000,
    'platinum': 25000,
    'diamond': 50000,
    'ruby': 100000,
  };

  String _getTrophyLevel(Map<String, int> thresholds, int value) {
    if (value >= thresholds['ruby']!) return 'ruby';
    if (value >= thresholds['diamond']!) return 'diamond';
    if (value >= thresholds['platinum']!) return 'platinum';
    if (value >= thresholds['gold']!) return 'gold';
    if (value >= thresholds['silver']!) return 'silver';
    if (value >= thresholds['bronze']!) return 'bronze';
    return 'none';
  }

  Color _getTrophyColor(String level) {
    switch (level) {
      case 'ruby':
        return AppConstant.rubyColor;
      case 'diamond':
        return AppConstant.diamondColor;
      case 'platinum':
        return AppConstant.platinumColor;
      case 'gold':
        return AppConstant.goldColor;
      case 'silver':
        return AppConstant.silverColor;
      case 'bronze':
        return AppConstant.bronzeColor;
      default:
        return Colors.grey.withValues(alpha: 0.3);
    }
  }

  IconData _getTrophyIcon(String category) {
    switch (category) {
      case 'login':
        return Icons.calendar_today;
      case 'games':
        return Icons.sports_esports;
      case 'wins':
        return Icons.emoji_events;
      case 'answers':
        return Icons.check_circle;
      case 'score':
        return Icons.stars;
      default:
        return Icons.emoji_events;
    }
  }

  String _getNextThreshold(Map<String, int> thresholds, int currentValue) {
    for (var entry in thresholds.entries) {
      if (currentValue < entry.value) {
        return '${entry.value - currentValue} more to ${entry.key}';
      }
    }
    return 'Max level achieved!';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 10),
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 20),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.all(Radius.circular(35.0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          _buildTrophyGrid(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        const Expanded(
          child: Text(
            'Achievements',
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
    );
  }

  Widget _buildTrophyGrid() {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      mainAxisSpacing: 15, // Reduced from 20
      crossAxisSpacing: 15, // Reduced from 20
      childAspectRatio: 1.2, // Increased from 1.4 to give more vertical space
      children: [
        _buildTrophyItem(
          'Daily Streak',
          statistics.currentLoginStreak,
          _loginStreakThresholds,
          'login',
          'days',
        ),
        _buildTrophyItem(
          'Games Played',
          statistics.totalGamesPlayed,
          _gamesPlayedThresholds,
          'games',
          'games',
        ),
        _buildTrophyItem(
          'Victories',
          statistics.gamesWon,
          _gamesWonThresholds,
          'wins',
          'wins',
        ),
        _buildTrophyItem(
          'Correct Answers',
          statistics.totalCorrectAnswers,
          _correctAnswersThresholds,
          'answers',
          'answers',
        ),
        _buildTrophyItem(
          'Total Score',
          statistics.totalScore,
          _totalScoreThresholds,
          'points',
          'points',
        ),
      ],
    );
  }

  Widget _buildTrophyItem(
    String title,
    int value,
    Map<String, int> thresholds,
    String category,
    String unit,
  ) {
    final level = _getTrophyLevel(thresholds, value);
    final color = _getTrophyColor(level);
    final icon = _getTrophyIcon(category);
    final nextThreshold = _getNextThreshold(thresholds, value);

    return Container(
      padding: const EdgeInsets.symmetric(
          horizontal: 8, vertical: 10), // Reduced padding
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: color.withValues(alpha: 0.3),
          width: 2,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min, // Added to ensure minimal height
        children: [
          // Icon
          Icon(icon, color: color, size: 22), // Reduced size from 24
          const SizedBox(height: 4), // Reduced from 6
          // Title
          Text(
            title,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: Colors.grey[800],
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4), // Reduced from 6
          // Value
          Text(
            '$value $unit',
            style: TextStyle(
              fontSize: 16, // Reduced from 18
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 2), // Reduced from 4
          // Next threshold info
          Text(
            nextThreshold,
            style: TextStyle(
              fontSize: 10, // Reduced from 11
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
