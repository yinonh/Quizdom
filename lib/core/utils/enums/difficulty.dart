import 'package:freezed_annotation/freezed_annotation.dart';

enum Difficulty {
  @JsonValue("easy")
  easy('easy', 'Easy'),
  @JsonValue("medium")
  medium('medium', 'Medium'),
  @JsonValue("hard")
  hard('hard', 'Hard');

  const Difficulty(this.value, this.displayName);

  final String value;
  final String displayName;

  static Difficulty fromString(String value) {
    return Difficulty.values.firstWhere(
      (difficulty) => difficulty.value == value,
      orElse: () => Difficulty.medium,
    );
  }
}
