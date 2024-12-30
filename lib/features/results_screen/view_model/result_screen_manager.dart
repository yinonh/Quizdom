import 'dart:async';

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:trivia/core/constants/app_constant.dart';
import 'package:trivia/data/data_source/user_data_source.dart';
import 'package:trivia/data/models/user.dart';
import 'package:trivia/data/models/user_achievements.dart';
import 'package:trivia/data/service/general_trivia_room_provider.dart';
import 'package:trivia/data/service/user_provider.dart';

part 'result_screen_manager.freezed.dart';
part 'result_screen_manager.g.dart';

@freezed
class ResultState with _$ResultState {
  const factory ResultState({
    required UserAchievements userAchievements,
    required double avgTime,
    required Map<TriviaUser, int> topUsers,
  }) = _ResultState;
}

@riverpod
class ResultScreenManager extends _$ResultScreenManager {
  @override
  Future<ResultState> build() async {
    await updateUserScoreOnServer();
    final topUsersScores =
        ref.read(generalTriviaRoomsProvider).selectedRoom?.topUsers;
    Map<TriviaUser, int> topUsers = {};
    for (String userId in topUsersScores?.keys.toList() ?? []) {
      final userForId = await UserDataSource.getUserById(userId);
      if (await UserDataSource.getUserById(userId) != null) {
        topUsers[userForId!] = topUsersScores![userId]!;
      }
    }
    final userAchievements = ref.read(authProvider).currentUser.achievements;
    return ResultState(
      userAchievements: ref.read(authProvider).currentUser.achievements,
      avgTime: getTimeAvg(userAchievements),
      topUsers: topUsers,
    );
  }

  double getTimeAvg(UserAchievements achievements) {
    final totalQuestions = achievements.correctAnswers +
        achievements.wrongAnswers +
        achievements.unanswered;

    if (totalQuestions == 0) return 0.0;

    return AppConstant.questionTime -
        (achievements.sumResponseTime / totalQuestions);
  }

  Future<int> calculateTotalScore(UserAchievements achievements) async {
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

    final totalScore = await calculateTotalScore(
        ref.read(authProvider).currentUser.achievements);
    await ref.read(generalTriviaRoomsProvider.notifier).updateUserScore(
          roomId: selectedRoom.roomId ?? "",
          userId: userId ?? "",
          newScore: totalScore,
        );
  }

  void addXpToUser() {
    ref.read(authProvider.notifier).addXp(5.0);
  }
}
