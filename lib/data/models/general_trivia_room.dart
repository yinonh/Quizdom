import 'package:freezed_annotation/freezed_annotation.dart';

part 'general_trivia_room.freezed.dart';
part 'general_trivia_room.g.dart';

@freezed
class GeneralTriviaRoom with _$GeneralTriviaRoom {
  const factory GeneralTriviaRoom({
    required String? roomId,
    required int questionCount,
    required int categoryId,
    required String categoryName,
    @Default([]) List<String> topUsers,
  }) = _GeneralTriviaRoom;

  factory GeneralTriviaRoom.fromJson(Map<String, dynamic> json) =>
      _$GeneralTriviaRoomFromJson(json);
}
