import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:trivia/core/utils/enums/difficulty.dart';
import 'package:trivia/core/utils/enums/game_stage.dart';
import 'package:trivia/core/utils/timestamp_converter.dart';
import 'package:trivia/data/models/trivia_achievements.dart';

part 'trivia_room.freezed.dart';
part 'trivia_room.g.dart';

@freezed
class TriviaRoom with _$TriviaRoom {
  const factory TriviaRoom({
    required String? roomId,
    String? hostUserId,
    required int? questionCount,
    required int? categoryId,
    required Difficulty? difficulty,
    required bool? isPublic,
    @TimestampConverter() required DateTime? createdAt,

    // Player Management
    @Default([]) List<String> users,
    required Map<String, int>? userScores,

    // Game State Tracking
    @GameStageConverter() required GameStage currentStage,
    required int currentQuestionIndex,
    @TimestampConverter() DateTime? currentQuestionStartTime,

    // Questions Data
    @Default(null) Map<String, dynamic>? questionsData,

    // Additional Game Metadata
    required int questionDuration,
    Map<String, int>? userMissedQuestions,
    Map<String, TriviaAchievements>? userAchievements,
    Map<String, Map<String, dynamic>>? userEmojis,
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
        users: [],
        userScores: {},
        currentStage: GameStage.created,
        currentQuestionIndex: 0,
        currentQuestionStartTime: null,
        questionsData: null,
        questionDuration: 10,
        userMissedQuestions: {},
        userAchievements: {},
        userEmojis: {},
      );

  factory TriviaRoom.fromJson(Map<String, dynamic> json) =>
      _$TriviaRoomFromJson(json);
}
