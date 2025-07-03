import 'dart:async';

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:Quizdom/core/utils/general_functions.dart';
import 'package:Quizdom/data/data_source/user_data_source.dart';
import 'package:Quizdom/data/models/trivia_achievements.dart';
import 'package:Quizdom/data/models/trivia_user.dart';
import 'package:Quizdom/data/providers/current_trivia_achievements_provider.dart';
import 'package:Quizdom/data/providers/general_trivia_room_provider.dart';
import 'package:Quizdom/data/providers/user_provider.dart';
import 'package:Quizdom/data/providers/user_statistics_provider.dart';

part 'solo_result_screen_manager.freezed.dart';
part 'solo_result_screen_manager.g.dart';

@freezed
class SoloResultState with _$SoloResultState {
  const factory SoloResultState({
    required TriviaAchievements userAchievements,
    required int totalScore,
    required double avgTime,
    required Map<TriviaUser, int> topUsers,
  }) = _SoloResultState;
}

@riverpod
class SoloResultScreenManager extends _$SoloResultScreenManager {
  @override
  Future<SoloResultState> build() async {
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

    return SoloResultState(
      userAchievements: userAchievements,
      totalScore: totalScore,
      avgTime: avgTime,
      topUsers: topUsers,
    );
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
}
