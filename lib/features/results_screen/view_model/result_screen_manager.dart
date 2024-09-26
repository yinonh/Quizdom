import 'dart:async';

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:trivia/data/models/user_achievements.dart';
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
      userAchievements: ref.read(userProvider).currentUser.achievements,
    );
  }

  double getTimeAvg() {
    final achievements = ref.read(userProvider).currentUser.achievements;
    final totalQuestions = achievements.correctAnswers +
        achievements.wrongAnswers +
        achievements.unanswered;

    if (totalQuestions == 0) return 0.0;

    return AppConstant.questionTime -
        (achievements.sumResponseTime / totalQuestions);
  }

  void addXpToUser() {
    ref.read(userProvider.notifier).addXp(5.0);
  }
}
