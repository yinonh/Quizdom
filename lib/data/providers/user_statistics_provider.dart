import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:trivia/data/data_source/user_statistics_data_source.dart';
import 'package:trivia/data/models/user_statistics.dart';
import 'package:trivia/data/providers/user_provider.dart';

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
      // Update Firestore
      await UserStatisticsDataSource.updateUserStatistics(
        userId: userId,
        updatedStatistics: newStatistics,
      );

      // Update local state
      state = state.copyWith(userStatistics: newStatistics);
    } catch (e) {
      print('Error updating user statistics: $e');
      rethrow;
    }
  }
}
