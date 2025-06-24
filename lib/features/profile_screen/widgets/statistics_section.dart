import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:trivia/core/constants/app_constant.dart';
import 'package:trivia/core/constants/constant_strings.dart';
import 'package:trivia/core/utils/size_config.dart';
import 'package:trivia/data/models/user_statistics.dart';

class StatisticsSection extends StatelessWidget {
  final UserStatistics statistics;

  const StatisticsSection({
    super.key,
    required this.statistics,
  });

  double? get _accuracyRate {
    final total = statistics.totalCorrectAnswers +
        statistics.totalWrongAnswers +
        statistics.totalUnanswered;
    return total > 0 ? (statistics.totalCorrectAnswers / total) * 100 : null;
  }

  double? get _multiplayerParticipation => statistics.totalGamesPlayed > 0
      ? (statistics.gamesPlayedAgainstPlayers / statistics.totalGamesPlayed) *
          100
      : null;

  int get _totalAnswers =>
      statistics.totalCorrectAnswers +
      statistics.totalWrongAnswers +
      statistics.totalUnanswered;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: calcWidth(10)),
      padding:
          EdgeInsets.fromLTRB(calcWidth(15), calcHeight(25), calcWidth(15), 0),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(35.0),
          topRight: Radius.circular(35.0),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: calcHeight(25),
        children: [
          _buildHeader(),
          _buildCurrentStreak(),
          _buildAnswersAnalysis(),
          _buildGameModes(),
          _buildTimeAnalysis(),
          const SizedBox.shrink(),
        ],
      ),
    );
  }

  Widget _buildAnswersAnalysis() {
    if (_totalAnswers == 0) {
      return const SizedBox.shrink();
    }

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
        spacing: calcHeight(20),
        children: [
          const Text(
            Strings.answerDistribution,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppConstant.primaryColor,
            ),
          ),
          SizedBox(
            height: 220,
            child: Row(
              children: [
                Expanded(
                  flex: 3,
                  child: PieChart(
                    PieChartData(
                      sections: _buildPieChartSections(),
                      sectionsSpace: 2,
                      centerSpaceRadius: 20,
                      startDegreeOffset: -90,
                    ),
                  ),
                ),
                SizedBox(width: calcWidth(20)),
                Expanded(
                  flex: 2,
                  child: Column(
                    spacing: calcHeight(20),
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildLegendItem(
                        Strings.correct,
                        statistics.totalCorrectAnswers,
                        AppConstant.secondaryColor,
                        Icons.check_circle,
                      ),
                      _buildLegendItem(
                        Strings.wrong,
                        statistics.totalWrongAnswers,
                        AppConstant.onPrimaryColor,
                        Icons.cancel,
                      ),
                      _buildLegendItem(
                        Strings.skipped,
                        statistics.totalUnanswered,
                        AppConstant.highlightColor,
                        Icons.help_outline,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          if (_accuracyRate != null) ...[
            Text(
              "${Strings.accuracyRate} ${_accuracyRate!.toStringAsFixed(1)}%",
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppConstant.primaryColor,
              ),
            ),
          ],
        ],
      ),
    );
  }

  List<PieChartSectionData> _buildPieChartSections() {
    final total = _totalAnswers.toDouble();
    if (total == 0) return [];

    return [
      PieChartSectionData(
        color: AppConstant.secondaryColor,
        value: statistics.totalCorrectAnswers.toDouble(),
        radius: 60,
        showTitle: false,
      ),
      PieChartSectionData(
        color: AppConstant.onPrimaryColor,
        value: statistics.totalWrongAnswers.toDouble(),
        radius: 60,
        showTitle: false,
      ),
      PieChartSectionData(
        color: AppConstant.highlightColor,
        value: statistics.totalUnanswered.toDouble(),
        radius: 60,
        showTitle: false,
      ),
    ];
  }

  Widget _buildLegendItem(String label, int value, Color color, IconData icon) {
    final percentage = _totalAnswers > 0
        ? (value / _totalAnswers * 100).toStringAsFixed(1)
        : '0.0';

    return Row(
      children: [
        Icon(icon, color: color, size: 20),
        SizedBox(width: calcWidth(10)),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
              Text(
                "$value ($percentage%)",
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
        ),
      ],
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
                Strings.statisticsTitle,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppConstant.primaryColor,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                "${statistics.totalGamesPlayed} ${Strings.gamesPlayed}",
                style: TextStyle(
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(bottom: 8),
            child: Text(
              Strings.loginStreak,
              textAlign: TextAlign.start,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStreakColumn(
                Strings.current,
                statistics.currentLoginStreak,
                Icons.local_fire_department,
              ),
              Container(
                width: 2,
                height: calcHeight(70),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(1),
                ),
              ),
              _buildStreakColumn(
                Strings.best,
                statistics.longestLoginStreak,
                Icons.emoji_events,
                isHighlight: true,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStreakColumn(String label, int value, IconData icon,
      {bool isHighlight = false}) {
    return Column(
      spacing: calcHeight(12),
      children: [
        Icon(
          icon,
          color: isHighlight ? AppConstant.goldColor : Colors.white,
          size: 32,
        ),
        Text(
          value.toString(),
          style: const TextStyle(
            color: Colors.white,
            fontSize: 28,
            fontWeight: FontWeight.bold,
          ),
        ),
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
            Strings.gameModes,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppConstant.primaryColor,
            ),
          ),
          SizedBox(height: calcHeight(20)),
          Row(
            children: [
              Expanded(
                child: _buildGameModeCard(
                  Strings.multiplayer,
                  statistics.gamesPlayedAgainstPlayers,
                  Icons.groups,
                  _multiplayerParticipation ?? 0,
                ),
              ),
              SizedBox(width: calcWidth(15)),
              Expanded(
                child: _buildGameModeCard(
                  Strings.singlePlayer,
                  statistics.totalGamesPlayed -
                      statistics.gamesPlayedAgainstPlayers,
                  Icons.person,
                  100 - (_multiplayerParticipation ?? 0),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTimeAnalysis() {
    // Guard against division by zero
    final hasPlayedGames = statistics.totalGamesPlayed > 0;
    final avgTimePerQuestion = hasPlayedGames ? statistics.avgAnswerTime : 0.0;
    final totalGameTime =
        hasPlayedGames ? avgTimePerQuestion * 10 : 0.0; // 10 questions per game

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppConstant.highlightColor.withValues(alpha: 0.1),
            AppConstant.primaryColor.withValues(alpha: 0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(25),
        border: Border.all(
          color: AppConstant.highlightColor.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: calcHeight(20),
        children: [
          const Text(
            Strings.timePerformance,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppConstant.highlightColor,
            ),
          ),
          Row(
            children: [
              Expanded(
                child: _buildTimeMetric(
                  Strings.averageResponseTime,
                  "${avgTimePerQuestion.toStringAsFixed(1)}s",
                  Icons.speed,
                  Strings.perquestion,
                ),
              ),
              SizedBox(width: calcWidth(20)),
              Expanded(
                child: _buildTimeMetric(
                  Strings.averageGameDuration,
                  "${totalGameTime.toStringAsFixed(1)}s",
                  Icons.timeline,
                  Strings.pergame,
                ),
              ),
            ],
          ),
          if (hasPlayedGames) ...[
            _buildSpeedIndicator(avgTimePerQuestion),
          ],
        ],
      ),
    );
  }

  Widget _buildTimeMetric(
      String label, String value, IconData icon, String subtitle) {
    return Container(
      padding: EdgeInsets.symmetric(
          vertical: calcHeight(12), horizontal: calcWidth(15)),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Icon at the top
          Icon(icon,
              color: AppConstant.highlightColor.withValues(alpha: 0.7),
              size: 24),
          SizedBox(height: calcHeight(8)),
          // Title with wrap
          Text(
            label,
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey[600],
              height: 1.2,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          SizedBox(height: calcHeight(6)),
          // Value
          Text(
            value,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: AppConstant.highlightColor,
            ),
          ),
          SizedBox(height: calcHeight(2)),
          // Subtitle
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 11,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSpeedIndicator(double avgTime) {
    String getSpeedCategory(double time) {
      if (time <= 3) return Strings.lightningFast;
      if (time <= 5) return Strings.quickThinker;
      if (time <= 8) return Strings.steadyPace;
      return Strings.takingTime;
    }

    Color getSpeedColor(double time) {
      if (time <= 3) return Colors.purple;
      if (time <= 5) return Colors.blue;
      if (time <= 8) return Colors.green;
      return Colors.orange;
    }

    return Container(
      padding: EdgeInsets.symmetric(
          vertical: calcHeight(10), horizontal: calcWidth(15)),
      decoration: BoxDecoration(
        color: getSpeedColor(avgTime).withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        spacing: calcWidth(8),
        children: [
          Icon(
            Icons.insights,
            color: getSpeedColor(avgTime),
            size: 20,
          ),
          Text(
            getSpeedCategory(avgTime),
            style: TextStyle(
              color: getSpeedColor(avgTime),
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
        ],
      ),
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
          SizedBox(height: calcHeight(12)),
          Text(
            value.toString(),
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppConstant.primaryColor,
            ),
          ),
          SizedBox(height: calcHeight(8)),
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
          SizedBox(height: calcHeight(4)),
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
}
