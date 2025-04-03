import 'package:freezed_annotation/freezed_annotation.dart';

enum GameStage {
  created, // Room just created
  waiting, // Waiting for players to join/ready
  preparing, // Players ready, about to start
  active, // Game in progress
  questionReview, // Between questions, showing results
  completed // Game fully finished
}

class GameStageConverter implements JsonConverter<GameStage, String> {
  const GameStageConverter();

  @override
  GameStage fromJson(String json) {
    return GameStage.values.firstWhere(
      (e) => e.toString().split('.').last == json,
      orElse: () => throw ArgumentError('Invalid GameStage value: $json'),
    );
  }

  @override
  String toJson(GameStage object) => object.toString().split('.').last;
}
