import 'dart:async';

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:trivia/core/constants/app_constant.dart';
import 'package:trivia/data/data_source/user_data_source.dart';
import 'package:trivia/data/models/trivia_achievements.dart';
import 'package:trivia/data/models/trivia_user.dart';
import 'package:trivia/data/providers/current_trivia_achievements_provider.dart';
import 'package:trivia/data/providers/general_trivia_room_provider.dart';
import 'package:trivia/data/providers/user_provider.dart';
import 'package:trivia/data/providers/user_statistics_provider.dart';

part 'result_screen_manager.freezed.dart';
part 'result_screen_manager.g.dart';

@freezed
class ResultState with _$ResultState {
  const factory ResultState({
    required TriviaAchievements userAchievements,
    required int totalScore,
    required double avgTime,
    required Map<TriviaUser, int> topUsers,
  }) = _ResultState;
}

@riverpod
class ResultScreenManager extends _$ResultScreenManager {
  @override
  Future<ResultState> build() async {
    // First get the achievements from current trivia session
    final userAchievements =
        ref.read(currentTriviaAchievementsProvider).currentAchievements;
    final totalScore = calculateTotalScore(userAchievements);
    final avgTime = getTimeAvg(userAchievements);

    // Update the user statistics with the new achievements
    await ref.read(statisticsProvider.notifier).updateUserStatistics(
          addToTotalGamesPlayed: 1,
          addToCorrectAnswers: userAchievements.correctAnswers,
          addToWrongAnswers: userAchievements.wrongAnswers,
          addToUnanswered: userAchievements.unanswered,
          sessionAvgAnswerTime: avgTime,
          addToScore: totalScore,
        );

    // Update server score and get top users
    await updateUserScoreOnServer();
    final topUsersScores =
        ref.read(generalTriviaRoomsProvider).selectedRoom?.topUsers;

    Map<TriviaUser, int> topUsers = {};
    for (String userId in topUsersScores?.keys.toList() ?? []) {
      final userForId = await UserDataSource.getUserById(userId);
      if (userForId != null) {
        topUsers[userForId] = topUsersScores![userId]!;
      }
    }

    return ResultState(
      userAchievements: userAchievements,
      totalScore: totalScore,
      avgTime: avgTime,
      topUsers: topUsers,
    );
  }

  double getTimeAvg(TriviaAchievements achievements) {
    final totalQuestions = achievements.correctAnswers +
        achievements.wrongAnswers +
        achievements.unanswered;

    if (totalQuestions == 0) return 0.0;

    return AppConstant.questionTime -
        (achievements.sumResponseTime / totalQuestions);
  }

  int calculateTotalScore(TriviaAchievements achievements) {
    // Define weights
    const int maxScore = 100;
    const double correctWeight = 0.7; // 70% weight for correct answers
    const double timeWeight = 0.3; // 30% weight for response time efficiency

    // Calculate the total number of questions
    final int totalQuestions = achievements.correctAnswers +
        achievements.wrongAnswers +
        achievements.unanswered;

    if (totalQuestions == 0) return 0;

    // Normalize the correct answers
    final double correctFactor = achievements.correctAnswers / totalQuestions;

    // Normalize the time factor (0 if max time exceeded, 1 if perfect)
    final double maxTimePerQuestion = AppConstant.questionTime.toDouble();

    final double timeFactor =
        (getTimeAvg(achievements) / maxTimePerQuestion).clamp(0.0, 1.0);

    // Calculate weighted score
    final double rawScore =
        (correctFactor * correctWeight) + (timeFactor * timeWeight);

    // Map rawScore to 0–100 range and return as an int
    return (rawScore.clamp(0.0, 1.0) * maxScore).round();
  }

  /// Updates the user's score on the server
  Future<void> updateUserScoreOnServer() async {
    final userId = ref.read(authProvider).currentUser.uid;
    final selectedRoom = ref.read(generalTriviaRoomsProvider).selectedRoom;

    if (selectedRoom == null) {
      throw Exception("No selected trivia room");
    }

    final totalScore = calculateTotalScore(
        ref.read(currentTriviaAchievementsProvider).currentAchievements);
    await ref.read(generalTriviaRoomsProvider.notifier).updateUserScore(
          roomId: selectedRoom.roomId ?? "",
          userId: userId,
          newScore: totalScore,
        );
  }

  void addXpToUser() {
    ref.read(authProvider.notifier).addXp(5.0);
  }
}
