import 'dart:async';

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:trivia/data/models/user_achievements.dart';
import 'package:trivia/data/service/general_trivia_room_provider.dart';
import 'package:trivia/data/service/user_provider.dart';
import 'package:trivia/core/constants/app_constant.dart';

part 'result_screen_manager.freezed.dart';
part 'result_screen_manager.g.dart';

@freezed
class ResultState with _$ResultState {
  const factory ResultState({
    required UserAchievements userAchievements,
  }) = _ResultState;
}

@riverpod
class ResultScreenManager extends _$ResultScreenManager {
  @override
  Future<ResultState> build() async {
    return ResultState(
      userAchievements: ref.read(authProvider).currentUser.achievements,
    );
  }

  double getTimeAvg() {
    final achievements = ref.read(authProvider).currentUser.achievements;
    final totalQuestions = achievements.correctAnswers +
        achievements.wrongAnswers +
        achievements.unanswered;

    if (totalQuestions == 0) return 0.0;

    return AppConstant.questionTime -
        (achievements.sumResponseTime / totalQuestions);
  }

  /// Calculates total score from achievements
  int calculateTotalScore() {
    final achievements = ref.read(authProvider).currentUser.achievements;
    // Example formula for calculating score
    return (achievements.correctAnswers * 10) - (achievements.wrongAnswers * 5);
  }

  /// Updates the user's score in the server
  Future<void> updateUserScoreOnServer() async {
    final userId = ref.read(authProvider).currentUser.uid;
    final selectedRoom = ref.read(generalTriviaRoomsProvider).selectedRoom;

    if (selectedRoom == null) {
      throw Exception("No selected trivia room");
    }

    final totalScore = calculateTotalScore();
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
