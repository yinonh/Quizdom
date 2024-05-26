import 'package:freezed_annotation/freezed_annotation.dart';

part 'user_achievements.freezed.dart';
part 'user_achievements.g.dart';

@freezed
class UserAchievements with _$UserAchievements {
  const factory UserAchievements({
    required int correctAnswers,
    required int wrongAnswers,
    required int unanswered,
    required double sumResponseTime,
  }) = _UserAchievements;

  factory UserAchievements.fromJson(Map<String, dynamic> json) =>
      _$UserAchievementsFromJson(json);
}

enum AchievementField {
  correctAnswers,
  wrongAnswers,
  unanswered,
}
