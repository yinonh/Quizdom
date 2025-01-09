import 'package:freezed_annotation/freezed_annotation.dart';

part 'trivia_achievements.freezed.dart';
part 'trivia_achievements.g.dart';

@freezed
class TriviaAchievements with _$TriviaAchievements {
  const factory TriviaAchievements({
    required int correctAnswers,
    required int wrongAnswers,
    required int unanswered,
    required double sumResponseTime,
  }) = _TriviaAchievements;

  factory TriviaAchievements.fromJson(Map<String, dynamic> json) =>
      _$TriviaAchievementsFromJson(json);
}

enum AchievementField {
  correctAnswers,
  wrongAnswers,
  unanswered,
}
