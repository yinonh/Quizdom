import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:trivia/core/utils/timestamp_converter.dart';

part 'trivia_room.freezed.dart';
part 'trivia_room.g.dart';

@freezed
class TriviaRoom with _$TriviaRoom {
  const factory TriviaRoom({
    required String? roomId,
    required int questionCount,
    required int categoryId,
    required String categoryName,
    required String difficulty,
    required bool isPublic,
    @TimestampConverter() required DateTime createdAt,
    @Default([]) List<String> users,
    @Default([]) List<String> topUsers,
  }) = _TriviaRoom;

  factory TriviaRoom.fromJson(Map<String, dynamic> json) =>
      _$TriviaRoomFromJson(json);
}
