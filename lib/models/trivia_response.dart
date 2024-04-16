import 'package:freezed_annotation/freezed_annotation.dart';

part 'trivia_response.freezed.dart';
part 'trivia_response.g.dart';

@freezed
class TriviaResponse with _$TriviaResponse {
  const factory TriviaResponse({
    @JsonKey(name: "response_code") int? responseCode,
    @JsonKey(name: "results") List<Result>? results,
  }) = _TriviaResponse;

  factory TriviaResponse.fromJson(Map<String, dynamic> json) =>
      _$TriviaResponseFromJson(json);
}

@freezed
class Result with _$Result {
  const factory Result({
    @JsonKey(name: "type") Type? type,
    @JsonKey(name: "difficulty") Difficulty? difficulty,
    @JsonKey(name: "category") String? category,
    @JsonKey(name: "question") String? question,
    @JsonKey(name: "correct_answer") String? correctAnswer,
    @JsonKey(name: "incorrect_answers") List<String>? incorrectAnswers,
  }) = _Result;

  factory Result.fromJson(Map<String, dynamic> json) => _$ResultFromJson(json);
}

enum Difficulty {
  @JsonValue("easy")
  EASY,
  @JsonValue("hard")
  HARD,
  @JsonValue("medium")
  MEDIUM
}

enum Type {
  @JsonValue("boolean")
  BOOLEAN,
  @JsonValue("multiple")
  MULTIPLE
}
