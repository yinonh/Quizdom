import 'package:flutter/material.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:trivia/app.dart';
import 'package:trivia/core/constants/app_constant.dart';
import 'package:trivia/core/network/server.dart';
import 'package:trivia/data/data_source/user_statistics_data_source.dart';
import 'package:trivia/data/models/user_statistics.dart';
import 'package:trivia/data/providers/user_provider.dart';
import 'package:trivia/core/common_widgets/trophy_dialog.dart';
import 'package:trivia/features/profile_screen/profile_screen.dart';

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
  void _showAchievementPopups(List<TrophyAchievement> achievements) {
    if (achievements.isEmpty) return;

    // Get the context using a navigator key
    final context = navigatorKey.currentContext;
    if (context == null) return;

    // Show the first achievement
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => TrophyAchievementDialog(
        achievement: achievements.first,
        onClose: () {
          Navigator.of(context).pushReplacementNamed(ProfileScreen.routeName);

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
