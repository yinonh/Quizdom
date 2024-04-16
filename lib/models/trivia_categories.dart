import 'package:freezed_annotation/freezed_annotation.dart';

part 'trivia_categories.freezed.dart';
part 'trivia_categories.g.dart';

@freezed
class TriviaCategories with _$TriviaCategories {
  const factory TriviaCategories({
    @JsonKey(name: "trivia_categories") List<TriviaCategory>? triviaCategories,
  }) = _TriviaCategories;

  factory TriviaCategories.fromJson(Map<String, dynamic> json) =>
      _$TriviaCategoriesFromJson(json);
}

@freezed
class TriviaCategory with _$TriviaCategory {
  const factory TriviaCategory({
    @JsonKey(name: "id") int? id,
    @JsonKey(name: "name") String? name,
  }) = _TriviaCategory;

  factory TriviaCategory.fromJson(Map<String, dynamic> json) =>
      _$TriviaCategoryFromJson(json);
}
