import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:trivia/data/models/trivia_achievements.dart';

part 'current_trivia_achievements_provider.freezed.dart';
part 'current_trivia_achievements_provider.g.dart';

@freezed
class CurrentAchievementsState with _$CurrentAchievementsState {
  const factory CurrentAchievementsState({
    required TriviaAchievements currentAchievements,
  }) = _CurrentAchievementsState;
}

@Riverpod(keepAlive: true)
class CurrentTriviaAchievements extends _$CurrentTriviaAchievements {
  @override
  CurrentAchievementsState build() {
    return const CurrentAchievementsState(
        currentAchievements: TriviaAchievements(
            correctAnswers: 0,
            wrongAnswers: 0,
            unanswered: 0,
            sumResponseTime: 0));
  }

  void resetAchievements() async {
    state = state.copyWith(
      currentAchievements: const TriviaAchievements(
        correctAnswers: 0,
        wrongAnswers: 0,
        unanswered: 0,
        sumResponseTime: 0.0,
      ),
    );
  }

  void updateAchievements({
    required AchievementField field,
    double? sumResponseTime,
  }) async {
    TriviaAchievements updatedAchievements;

    switch (field) {
      case AchievementField.correctAnswers:
        updatedAchievements = state.currentAchievements.copyWith(
          correctAnswers: state.currentAchievements.correctAnswers + 1,
        );
        break;
      case AchievementField.wrongAnswers:
        updatedAchievements = state.currentAchievements.copyWith(
          wrongAnswers: state.currentAchievements.wrongAnswers + 1,
        );
        break;
      case AchievementField.unanswered:
        updatedAchievements = state.currentAchievements.copyWith(
          unanswered: state.currentAchievements.unanswered + 1,
        );
        break;
    }

    updatedAchievements = updatedAchievements.copyWith(
      sumResponseTime: updatedAchievements.sumResponseTime +
          (field != AchievementField.unanswered
              ? (sumResponseTime ?? 10.0)
              : 10),
    );

    // final updatedUser = updateCurrentUser(achievements: updatedAchievements);
    state = state.copyWith(currentAchievements: updatedAchievements);
  }
}
