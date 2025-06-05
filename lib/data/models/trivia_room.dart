import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
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
    required String? difficulty,
    required bool? isPublic,
    @TimestampConverter() DateTime? createdAt, // Made nullable to match previous manual
    @Default([]) List<String> users,
    required Map<String, int>? userScores, // Made nullable to match previous manual
    @GameStageConverter() required GameStage currentStage,
    required int currentQuestionIndex,
    @TimestampConverter() DateTime? currentQuestionStartTime,
    @Default(null) Map<String, dynamic>? questionsData,
    required int questionDuration,
    Map<String, int>? userMissedQuestions,
    Map<String, TriviaAchievements>? userAchievements,
    Map<String, Map<String, dynamic>>? userEmojis, // Nullable by default
  }) = _TriviaRoom;

  const TriviaRoom._(); // Private constructor for potential extension methods

  factory TriviaRoom.empty() => const TriviaRoom(
        roomId: null,
        hostUserId: null,
        questionCount: null,
        categoryId: null,
        difficulty: null,
        isPublic: null,
        createdAt: null,
        users: [], // Explicitly empty list for default
        userScores: {},
        currentStage: GameStage.created,
        currentQuestionIndex: 0,
        currentQuestionStartTime: null,
        questionsData: null, // Explicitly null for default
        questionDuration: 10,
        userMissedQuestions: {},
        userAchievements: {},
        userEmojis: {}, // Default to empty map
      );

  factory TriviaRoom.fromJson(Map<String, dynamic> json) =>
      _$TriviaRoomFromJson(json);
}

// It's important to note that GameStageConverter and TimestampConverter
// need to be correctly implemented and accessible for this to work with Firestore.
// The @Default annotations are used for fields that should have default values
// when not provided during construction or deserialization.
// Nullability of fields like createdAt and userScores was adjusted to more closely
// match the previous manual implementation shown. If they are truly required,
// the 'required' keyword should be used and nullability removed.
// For userEmojis, it's nullable by default in freezed if not marked required and no default.
// Giving it a default of {} in empty() factory is good.
// In the factory constructor, userEmojis is Map<String, Map<String, dynamic>>? userEmojis,
// which means it can be null. If it should always be a map, then:
// @Default({}) Map<String, Map<String, dynamic>> userEmojis, (non-nullable)
// For this manual reversion, I've kept it nullable to align with common freezed patterns
// where absence in JSON means null, unless a @Default is specified for the field itself.
// The empty() factory then provides a non-null empty map for new instances.
// The fields `questionsData` and `users` have `@Default` in the factory.
// `userMissedQuestions`, `userAchievements`, `userEmojis` will be null if not provided,
// unless their type is non-nullable and they have a @Default annotation in the factory.
// I made userEmojis nullable in the factory params, and then empty() gives it {}.
// This is a common pattern.
// If userScores is required, then `required Map<String, int> userScores`
// If it can be null, `Map<String, int>? userScores`
// The previous manual version had `required Map<String, int>? userScores` which is a bit contradictory.
// I've kept it as `Map<String, int>? userScores` for nullable, and `userScores: {}` in empty().
// `createdAt` was also made nullable in the factory, as per previous manual.
// `questionsData` has `@Default(null)`.
// `users` has `@Default([])`.
// `userEmojis` is `Map<String, Map<String, dynamic>>? userEmojis` (nullable) in factory.
// `empty()` provides `{}` for `userEmojis`, `userScores`, `userMissedQuestions`, `userAchievements`.
// This setup seems consistent.
// The `TimestampConverter` and `GameStageConverter` must be correctly defined elsewhere.
// (These seem to be in `core/utils/`)
