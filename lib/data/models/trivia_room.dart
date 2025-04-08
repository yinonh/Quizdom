import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:trivia/core/utils/enums/game_stage.dart';
import 'package:trivia/core/utils/timestamp_converter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

part 'trivia_room.freezed.dart';
part 'trivia_room.g.dart';

class MapDateConverter
    implements JsonConverter<Map<String, DateTime>?, Map<String, dynamic>?> {
  const MapDateConverter();

  @override
  Map<String, DateTime>? fromJson(Map<String, dynamic>? json) {
    if (json == null) return null;
    return json.map(
      (key, value) => MapEntry(key, DateTime.parse(value as String)),
    );
  }

  @override
  Map<String, dynamic>? toJson(Map<String, DateTime>? object) {
    if (object == null) return null;
    return object.map(
      (key, value) => MapEntry(key, value.toIso8601String()),
    );
  }
}

@freezed
class TriviaRoom with _$TriviaRoom {
  const factory TriviaRoom({
    required String? roomId,
    String? hostUserId,
    required int? questionCount,
    required int? categoryId,
    required String? difficulty,
    required bool? isPublic,
    @TimestampConverter() required DateTime? createdAt,

    // Player Management
    @Default([]) List<String> users,
    required List<int>? userScores,
    @MapDateConverter() Map<String, DateTime>? keepAlive,

    // Game State Tracking
    @GameStageConverter() required GameStage currentStage,
    required int currentQuestionIndex,
    @TimestampConverter() DateTime? currentQuestionStartTime,

    // Questions Data
    @Default(null) Map<String, dynamic>? questionsData,

    // Additional Game Metadata
    required int questionDuration, // in seconds
    Map<String, int>? userMissedQuestions,
  }) = _TriviaRoom;

  const TriviaRoom._();

  factory TriviaRoom.empty() => const TriviaRoom(
        roomId: null,
        hostUserId: null,
        questionCount: null,
        categoryId: null,
        difficulty: null,
        isPublic: null,
        createdAt: null,
        userScores: null,
        currentStage: GameStage.created,
        currentQuestionIndex: 0,
        currentQuestionStartTime: null,
        questionDuration: 10,
        userMissedQuestions: null,
      );

  factory TriviaRoom.fromJson(Map<String, dynamic> json) =>
      _$TriviaRoomFromJson(json);
}
