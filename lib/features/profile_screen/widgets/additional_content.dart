import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:trivia/core/constants/app_constant.dart';
import 'package:trivia/data/models/user_statistics.dart';

class AdditionalContent extends StatelessWidget {
  final UserStatistics statistics;

  const AdditionalContent({
    super.key,
    required this.statistics,
  });

  // Calculate additional statistics
  double get _winRate =>
      (statistics.gamesWon / statistics.totalGamesPlayed) * 100;
  double get _accuracyRate =>
      (statistics.totalCorrectAnswers /
          (statistics.totalCorrectAnswers +
              statistics.totalWrongAnswers +
              statistics.totalUnanswered)) *
      100;
  double get _avgScorePerGame =>
      statistics.totalScore / statistics.totalGamesPlayed;
  double get _multiplayerParticipation =>
      (statistics.gamesPlayedAgainstPlayers / statistics.totalGamesPlayed) *
      100;
  int get _totalAnswers =>
      statistics.totalCorrectAnswers +
      statistics.totalWrongAnswers +
      statistics.totalUnanswered;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 15),
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 25),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.all(Radius.circular(35.0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          const SizedBox(height: 25),
          _buildCurrentStreak(),
          const SizedBox(height: 20),
          _buildAnswersPieChart(),
          const SizedBox(height: 25),
          _buildOverallProgress(),
          const SizedBox(height: 25),
          _buildDetailedStats(),
          const SizedBox(height: 25),
          _buildGameModes(),
          const SizedBox(height: 25),
          _buildTimeAnalysis(),
        ],
      ),
    );
  }

  Widget _buildAnswersPieChart() {
    final total = statistics.totalCorrectAnswers +
        statistics.totalWrongAnswers +
        statistics.totalUnanswered;

    return SizedBox(
      height: 200,
      child: PieChart(
        PieChartData(
          sections: [
            PieChartSectionData(
              color: AppConstant.secondaryColor,
              value: statistics.totalCorrectAnswers.toDouble(),
              title:
                  '${(statistics.totalCorrectAnswers / total * 100).round()}%',
              radius: 60,
              titleStyle: const TextStyle(color: Colors.white, fontSize: 16),
            ),
            PieChartSectionData(
              color: AppConstant.onPrimaryColor,
              value: statistics.totalWrongAnswers.toDouble(),
              title: '${(statistics.totalWrongAnswers / total * 100).round()}%',
              radius: 60,
              titleStyle: const TextStyle(color: Colors.white, fontSize: 16),
            ),
            PieChartSectionData(
              color: AppConstant.highlightColor,
              value: statistics.totalUnanswered.toDouble(),
              title: '${(statistics.totalUnanswered / total * 100).round()}%',
              radius: 60,
              titleStyle: const TextStyle(color: Colors.white, fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Gaming Profile",
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: AppConstant.primaryColor,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                "${statistics.totalGamesPlayed} Games Played",
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppConstant.primaryColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(15),
          ),
          child: const Icon(
            Icons.auto_awesome,
            color: AppConstant.primaryColor,
            size: 28,
          ),
        ),
      ],
    );
  }

  Widget _buildCurrentStreak() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppConstant.primaryColor, AppConstant.secondaryColor],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: AppConstant.primaryColor.withValues(alpha: 0.3),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStreakColumn(
            "Current Streak",
            statistics.currentLoginStreak,
            Icons.local_fire_department,
          ),
          Container(
            width: 2,
            height: 70,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(1),
            ),
          ),
          _buildStreakColumn(
            "Best Streak",
            statistics.longestLoginStreak,
            Icons.emoji_events,
            isHighlight: true,
          ),
        ],
      ),
    );
  }

  Widget _buildStreakColumn(String label, int value, IconData icon,
      {bool isHighlight = false}) {
    return Column(
      children: [
        Icon(
          icon,
          color: isHighlight ? AppConstant.goldColor : Colors.white,
          size: 32,
        ),
        const SizedBox(height: 12),
        Text(
          value.toString(),
          style: const TextStyle(
            color: Colors.white,
            fontSize: 28,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.9),
            fontSize: 14,
          ),
        ),
      ],
    );
  }

  Widget _buildOverallProgress() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        // color: AppConstant.onPrimaryColor.withValues(alpha:0.1),
        gradient: LinearGradient(
          colors: [
            AppConstant.onPrimaryColor.withValues(alpha: 0.4),
            AppConstant.goldColor.withValues(alpha: 0.2),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(25),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Overall Progress",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppConstant.highlightColor,
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: _buildProgressItem(
                  "Accuracy",
                  _accuracyRate,
                  AppConstant.secondaryColor,
                  suffix: "%",
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: _buildProgressItem(
                  "Win Rate",
                  _winRate,
                  AppConstant.onPrimaryColor,
                  suffix: "%",
                ),
              ),
            ],
          ),
          const SizedBox(height: 15),
          Row(
            children: [
              Expanded(
                child: _buildProgressItem(
                  "Avg Score",
                  _avgScorePerGame,
                  AppConstant.primaryColor,
                  decimals: 0,
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: _buildProgressItem(
                  "Total Score",
                  statistics.totalScore.toDouble(),
                  AppConstant.highlightColor,
                  decimals: 0,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDetailedStats() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
        border: Border.all(
          color: AppConstant.primaryColor.withValues(alpha: 0.2),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Answer Analysis",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppConstant.primaryColor,
            ),
          ),
          const SizedBox(height: 20),
          _buildAnswerStatRow(
            "Correct",
            statistics.totalCorrectAnswers,
            AppConstant.secondaryColor,
            Icons.check_circle,
          ),
          const SizedBox(height: 12),
          _buildAnswerStatRow(
            "Wrong",
            statistics.totalWrongAnswers,
            AppConstant.onPrimaryColor,
            Icons.cancel,
          ),
          const SizedBox(height: 12),
          _buildAnswerStatRow(
            "Unanswered",
            statistics.totalUnanswered,
            AppConstant.highlightColor,
            Icons.help,
          ),
        ],
      ),
    );
  }

  Widget _buildGameModes() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppConstant.primaryColor.withValues(alpha: 0.1),
            AppConstant.secondaryColor.withValues(alpha: 0.1),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(25),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Game Modes",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppConstant.primaryColor,
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: _buildGameModeCard(
                  "Multiplayer",
                  statistics.gamesPlayedAgainstPlayers,
                  Icons.groups,
                  _multiplayerParticipation,
                ),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: _buildGameModeCard(
                  "Single Player",
                  statistics.totalGamesPlayed -
                      statistics.gamesPlayedAgainstPlayers,
                  Icons.person,
                  100 - _multiplayerParticipation,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTimeAnalysis() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppConstant.highlightColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(25),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Time Performance",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppConstant.highlightColor,
                ),
              ),
              Icon(
                Icons.timer,
                color: AppConstant.highlightColor.withValues(alpha: 0.5),
                size: 24,
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: _buildTimeMetric(
                  "Average Answer Time",
                  "${statistics.avgAnswerTime.toStringAsFixed(1)}s",
                  Icons.speed,
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: _buildTimeMetric(
                  "Questions Per Game",
                  (_totalAnswers / statistics.totalGamesPlayed)
                      .toStringAsFixed(1),
                  Icons.quiz,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildProgressItem(String label, double value, Color color,
      {String suffix = "", int decimals = 1}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[600],
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Text(
              value.toStringAsFixed(decimals),
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            Text(
              suffix,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: color.withValues(alpha: 0.7),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildAnswerStatRow(
      String label, int value, Color color, IconData icon) {
    final percentage = (value / _totalAnswers * 100).toStringAsFixed(1);

    return Row(
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 4),
              Container(
                height: 6,
                clipBehavior: Clip.hardEdge,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(3),
                ),
                child: LinearProgressIndicator(
                  value: value / _totalAnswers,
                  backgroundColor: color.withValues(alpha: 0.1),
                  valueColor: AlwaysStoppedAnimation<Color>(color),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              value.toString(),
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            Text(
              "$percentage%",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                color: color.withValues(alpha: 0.7),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildGameModeCard(
      String label, int value, IconData icon, double percentage) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, color: AppConstant.primaryColor, size: 28),
          const SizedBox(height: 12),
          Text(
            value.toString(),
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppConstant.primaryColor,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 4),
          Text(
            "${percentage.toStringAsFixed(1)}%",
            style: TextStyle(
              fontSize: 12,
              color: AppConstant.primaryColor.withValues(alpha: 0.7),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimeMetric(String label, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
            overflow: TextOverflow.ellipsis, // Handles long labels
          ),
          Row(
            children: [
              Icon(icon, color: AppConstant.primaryColor, size: 28),
              const SizedBox(width: 15),
              Expanded(
                // Ensures the text doesn't overflow
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 4),
                    Text(
                      value,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppConstant.primaryColor,
                      ),
                      overflow: TextOverflow.ellipsis, // Handles long values
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
