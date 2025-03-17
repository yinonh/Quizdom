import 'package:freezed_annotation/freezed_annotation.dart';

part 'user_statistics.freezed.dart';
part 'user_statistics.g.dart';

@freezed
class UserStatistics with _$UserStatistics {
  const factory UserStatistics({
    @Default(0) int currentLoginStreak,
    @Default(0) int longestLoginStreak,
    @Default(0) int totalGamesPlayed,
    @Default(0) int totalCorrectAnswers,
    @Default(0) int totalWrongAnswers,
    @Default(0) int totalUnanswered,
    @Default(0) double avgAnswerTime,
    @Default(0) int gamesPlayedAgainstPlayers,
    @Default(0) int gamesWon,
    @Default(0) int gamesLost,
    @Default(0) int totalScore,
    @JsonKey(includeFromJson: false, includeToJson: false)
    @Default({})
    Map<String, List<String>> displayedTrophies,
  }) = _UserStatistics;

  factory UserStatistics.fromJson(Map<String, dynamic> json) =>
      _$UserStatisticsFromJson(json);
}
