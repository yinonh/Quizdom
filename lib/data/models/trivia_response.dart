import 'package:freezed_annotation/freezed_annotation.dart';

part 'trivia_response.freezed.dart';
part 'trivia_response.g.dart';

@freezed
class TriviaResponse with _$TriviaResponse {
  const factory TriviaResponse({
    @JsonKey(name: "response_code") int? responseCode,
    @JsonKey(name: "results") List<Question>? results,
  }) = _TriviaResponse;

  factory TriviaResponse.fromJson(Map<String, dynamic> json) =>
      _$TriviaResponseFromJson(json);
}

@freezed
class Question with _$Question {
  const factory Question({
    @JsonKey(name: "type") Type? type,
    @JsonKey(name: "difficulty") Difficulty? difficulty,
    @JsonKey(name: "category") String? category,
    @JsonKey(name: "question") String? question,
    @JsonKey(name: "correct_answer") String? correctAnswer,
    @JsonKey(name: "incorrect_answers") List<String>? incorrectAnswers,
  }) = _Result;

  factory Question.fromJson(Map<String, dynamic> json) =>
      _$QuestionFromJson(json);
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
