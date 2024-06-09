import 'dart:async';

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:trivia/models/user_achievements.dart';
import 'package:trivia/service/user_provider.dart';

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
      userAchievements: ref.watch(userProvider).achievements,
    );
  }

  double getTimeAvg() {
    final achievements = ref.read(userProvider).achievements;
    final totalAnswered = achievements.correctAnswers +
        achievements.wrongAnswers +
        achievements.unanswered;

    if (totalAnswered == 0) return 0.0;

    return achievements.sumResponseTime / totalAnswered;
  }
}
