import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:trivia/data/data_source/trivia_room_data_source.dart';
import 'package:trivia/data/models/trivia_room.dart';
import 'package:trivia/data/providers/trivia_provider.dart';

part 'trivia_room_provider.freezed.dart';
part 'trivia_room_provider.g.dart';

@freezed
class TriviaRoomsState with _$TriviaRoomsState {
  const factory TriviaRoomsState({
    required List<TriviaRoom>? triviaRooms,
  }) = _TriviaRoomsState;
}

@Riverpod(keepAlive: true)
class TriviaRooms extends _$TriviaRooms {
  @override
  TriviaRoomsState build() {
    return const TriviaRoomsState(triviaRooms: null);
  }

  /// Creates a new trivia room
  Future<void> createRoom({
    required String roomId,
    required int questionCount,
    required int categoryId,
    required String categoryName,
    required String difficulty,
    required bool isPublic,
  }) async {
    await TriviaRoomDataSource.createRoom(
      roomId: roomId,
      questionCount: questionCount,
      categoryId: categoryId,
      categoryName: categoryName,
      difficulty: difficulty,
      isPublic: isPublic,
      userIds: [],
    );
    // TODO: Refresh rooms
  }

  /// Selects a trivia room by ID
  void selectRoom(String roomId) {
    final room = state.triviaRooms?.firstWhere((room) => room.roomId == roomId);
    if (room == null) {
      throw Exception("Room not found");
    }
    // TODO: set the room
    ref.read(triviaProvider.notifier).setTriviaRoom(room);
  }

  /// Deletes a trivia room by ID
  Future<void> deleteRoom(String roomId) async {
    await TriviaRoomDataSource.deleteRoom(roomId);
    // TODO: Refresh rooms
  }

  /// Joins a user to a trivia room
  Future<void> joinRoom({
    required String roomId,
    required String userId,
    String? userName,
  }) async {
    await TriviaRoomDataSource.joinRoom(
      roomId: roomId,
      userId: userId,
      userName: userName,
    );
    // Refresh selected room
    if (ref.read(triviaProvider).triviaRoom?.roomId == roomId) {
      selectRoom(roomId);
    }
  }

  /// Updates the score of a user in a trivia room
  Future<void> updateUserScore({
    required String roomId,
    required String userId,
    required int newScore,
  }) async {
    await TriviaRoomDataSource.updateUserScore(
      roomId: roomId,
      userId: userId,
      newScore: newScore,
    );
    // Refresh selected room
    if (ref.read(triviaProvider).triviaRoom?.roomId == roomId) {
      selectRoom(roomId);
    }
  }
}
