import 'package:flutter/material.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:Quizdom/core/common_widgets/trophy_dialog.dart';
import 'package:Quizdom/core/constants/app_constant.dart';
import 'package:Quizdom/core/constants/app_routes.dart';
import 'package:Quizdom/core/navigation/route_extensions.dart';
import 'package:Quizdom/core/navigation/router_service.dart';
import 'package:Quizdom/core/network/server.dart';
import 'package:Quizdom/data/data_source/user_statistics_data_source.dart';
import 'package:Quizdom/data/models/user_statistics.dart';
import 'package:Quizdom/data/providers/user_provider.dart';

part 'user_statistics_provider.freezed.dart';
part 'user_statistics_provider.g.dart';

@freezed
class UserStatisticsState with _$UserStatisticsState {
  const factory UserStatisticsState({
    required UserStatistics userStatistics,
  }) = _UserStatisticsState;
}

@Riverpod(keepAlive: true)
class Statistics extends _$Statistics {
  @override
  UserStatisticsState build() {
    return const UserStatisticsState(
      userStatistics: UserStatistics(),
    );
  }

  Future<void> initializeUserStatistics() async {
    final user = ref.read(authProvider).currentUser;
    final loginNewDayInARow = ref.read(authProvider).loginNewDayInARow;
    if (user.uid != "") {
      final userStatistics =
          await UserStatisticsDataSource.getUserStatistics(user.uid);
      if (userStatistics != null) {
        state = state.copyWith(userStatistics: userStatistics);
      }
      if (loginNewDayInARow != null) {
        if (loginNewDayInARow) {
          await updateUserStatistics(incrementLoginStreak: true);
        } else {
          await updateUserStatistics(incrementLoginStreak: false);
        }
      }
    }
  }

  Future<void> updateUserStatistics({
    bool? incrementLoginStreak,
    int? addToTotalGamesPlayed,
    int? addToCorrectAnswers,
    int? addToWrongAnswers,
    int? addToUnanswered,
    double? sessionAvgAnswerTime,
    int? addToGamesAgainstPlayers,
    bool? wonGame,
    int? addToScore,
  }) async {
    String userId = ref.read(authProvider).currentUser.uid;
    if (userId == "") return;

    // Get current statistics
    final oldStats = state.userStatistics;
    final currentStats = state.userStatistics;

    // Calculate new avg answer time if provided
    double newAvgAnswerTime = currentStats.avgAnswerTime;
    if (sessionAvgAnswerTime != null) {
      if (currentStats.totalGamesPlayed > 0) {
        newAvgAnswerTime =
            ((currentStats.avgAnswerTime * currentStats.totalGamesPlayed) +
                    sessionAvgAnswerTime) /
                (currentStats.totalGamesPlayed + (addToTotalGamesPlayed ?? 0));
      } else {
        newAvgAnswerTime = sessionAvgAnswerTime;
      }
    }

    // Update login streak
    int newLoginStreak = currentStats.currentLoginStreak;
    int newLongestStreak = currentStats.longestLoginStreak;

    if (incrementLoginStreak != null) {
      if (incrementLoginStreak) {
        newLoginStreak += 1;
        if (newLoginStreak > newLongestStreak) {
          newLongestStreak = newLoginStreak;
        }
      } else {
        newLoginStreak = 0;
      }
    }

    // Create updated statistics
    final newStatistics = currentStats.copyWith(
      currentLoginStreak: newLoginStreak,
      longestLoginStreak: newLongestStreak,
      totalGamesPlayed:
          currentStats.totalGamesPlayed + (addToTotalGamesPlayed ?? 0),
      totalCorrectAnswers:
          currentStats.totalCorrectAnswers + (addToCorrectAnswers ?? 0),
      totalWrongAnswers:
          currentStats.totalWrongAnswers + (addToWrongAnswers ?? 0),
      totalUnanswered: currentStats.totalUnanswered + (addToUnanswered ?? 0),
      avgAnswerTime: newAvgAnswerTime,
      gamesPlayedAgainstPlayers: currentStats.gamesPlayedAgainstPlayers +
          (addToGamesAgainstPlayers ?? 0),
      gamesWon: currentStats.gamesWon + (wonGame == true ? 1 : 0),
      gamesLost: currentStats.gamesLost + (wonGame == false ? 1 : 0),
      totalScore: currentStats.totalScore + (addToScore ?? 0),
    );

    try {
      // Check for new achievements
      final newAchievements = TrophyAchievementService.checkNewAchievements(
        oldStats,
        newStatistics,
      );

      // Update displayed trophies
      Map<String, List<String>> updatedDisplayedTrophies =
          TrophyAchievementService.updateDisplayedTrophies(
              newStatistics, newAchievements);

      // Create final statistics with updated displayed trophies
      final finalStatistics = newStatistics.copyWith(
        displayedTrophies: updatedDisplayedTrophies,
      );

      // Update Firestore
      await UserStatisticsDataSource.updateUserStatistics(
        userId: userId,
        updatedStatistics: finalStatistics,
      );

      // Update local state
      state = state.copyWith(userStatistics: finalStatistics);

      // Show achievement popups if there are any
      if (newAchievements.isNotEmpty) {
        _showAchievementPopups(newAchievements);
      }
    } catch (e) {
      logger.e('Error updating user statistics: $e');
      rethrow;
    }
  }

  // Method to show achievement popups one by one
  void _showAchievementPopups(List<TrophyAchievement> achievements,
      {bool secTime = false}) {
    if (achievements.isEmpty) return;

    final BuildContext? context =
        AppNavigatorKeys.navigatorKey.currentContext ??
            AppNavigatorKeys.shellNavigatorKey.currentContext;

    if (context == null && !secTime) {
      // Try again after a short delay
      Future.delayed(const Duration(milliseconds: 100),
          () => _showAchievementPopups(achievements));
      return;
    } else if (context == null) {
      return;
    }

    // Show the first achievement
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (dialogContext) => TrophyAchievementDialog(
        achievement: achievements.first,
        onClose: () {
          // Use go_router navigation instead of Navigator
          goRoute(AppRoutes.profileRouteName);

          // Show the next achievement after a short delay
          if (achievements.length > 1) {
            Future.delayed(const Duration(milliseconds: 500), () {
              _showAchievementPopups(achievements.sublist(1));
            });
          }
        },
      ),
    );
  }
}
