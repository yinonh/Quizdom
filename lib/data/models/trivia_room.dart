import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:trivia/core/utils/timestamp_converter.dart';

part 'trivia_room.freezed.dart';
part 'trivia_room.g.dart';

@freezed
class TriviaRoom with _$TriviaRoom {
  const factory TriviaRoom({
    required String? roomId,
    required int? questionCount,
    required int? categoryId,
    required String? difficulty,
    required bool? isPublic,
    @TimestampConverter() required DateTime? createdAt,
    @Default([]) List<String> users,
    @Default([]) List<int> userScores,
    @Default(null) Map<String, dynamic>? questionsData,
  }) = _TriviaRoom;

  factory TriviaRoom.empty() => const TriviaRoom(
        roomId: null,
        questionCount: null,
        categoryId: null,
        difficulty: null,
        isPublic: null,
        createdAt: null,
      );

  factory TriviaRoom.fromJson(Map<String, dynamic> json) =>
      _$TriviaRoomFromJson(json);
}
