import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:trivia/data/data_source/trivia_room_data_source.dart';
import 'package:trivia/data/models/general_trivia_room.dart';
import 'package:trivia/data/service/trivia_provider.dart';

part 'trivia_room_provider.freezed.dart';
part 'trivia_room_provider.g.dart';

@freezed
class TriviaRoomsState with _$TriviaRoomsState {
  const factory TriviaRoomsState({
    required List<GeneralTriviaRoom>? generalTriviaRooms,
    GeneralTriviaRoom? selectedRoom,
  }) = _TriviaRoomsState;
}

@Riverpod(keepAlive: true)
class TriviaRooms extends _$TriviaRooms {
  late final TriviaRoomDataSource _dataSource;

  @override
  TriviaRoomsState build() {
    _dataSource = TriviaRoomDataSource();
    return const TriviaRoomsState(generalTriviaRooms: null, selectedRoom: null);
  }

  Future<void> initializeTriviaRoom() async {
    final rooms = await _fetchAllGeneralRooms();
    state = TriviaRoomsState(generalTriviaRooms: rooms, selectedRoom: null);
    ref.read(triviaProvider.notifier).setToken();
  }

  /// Fetches all trivia rooms from the data source
  Future<List<GeneralTriviaRoom>> _fetchAllGeneralRooms() async {
    try {
      final snapshot =
          await _dataSource.firestore.collection('generalTriviaRooms').get();

      // Map the documents to TriviaRoom instances
      return snapshot.docs.map((doc) {
        final data = doc.data(); // Retrieve the document data
        return GeneralTriviaRoom.fromJson({
          ...data, // Spread the document data
          'roomId': doc.id, // Add the document ID as 'roomId'
        });
      }).toList();
    } catch (e) {
      // Handle potential errors
      print('Error fetching rooms: $e');
      return [];
    }
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
    await _dataSource.createRoom(
      roomId: roomId,
      questionCount: questionCount,
      categoryId: categoryId,
      categoryName: categoryName,
      difficulty: difficulty,
      isPublic: isPublic,
    );
    // Refresh rooms
    state = state.copyWith(
      generalTriviaRooms: await _fetchAllGeneralRooms(),
    );
  }

  /// Selects a trivia room by ID
  void selectRoom(String roomId) {
    final room =
        state.generalTriviaRooms?.firstWhere((room) => room.roomId == roomId);
    if (room == null) {
      throw Exception("Room not found");
    }
    ref.read(triviaProvider.notifier).setTriviaRoom(room);
    state = state.copyWith(selectedRoom: room);
  }

  /// Deletes a trivia room by ID
  Future<void> deleteRoom(String roomId) async {
    await _dataSource.deleteRoom(roomId);
    // Refresh rooms
    state = state.copyWith(
      generalTriviaRooms: await _fetchAllGeneralRooms(),
    );
  }

  /// Joins a user to a trivia room
  Future<void> joinRoom({
    required String roomId,
    required String userId,
    String? userName,
  }) async {
    await _dataSource.joinRoom(
      roomId: roomId,
      userId: userId,
      userName: userName,
    );
    // Refresh selected room
    if (state.selectedRoom?.roomId == roomId) {
      selectRoom(roomId);
    }
  }

  /// Updates the score of a user in a trivia room
  Future<void> updateUserScore({
    required String roomId,
    required String userId,
    required int newScore,
  }) async {
    await _dataSource.updateUserScore(
      roomId: roomId,
      userId: userId,
      newScore: newScore,
    );
    // Refresh selected room
    if (state.selectedRoom?.roomId == roomId) {
      selectRoom(roomId);
    }
  }
}
