import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:trivia/data/data_source/trivia_room_data_source.dart';
import 'package:trivia/data/models/trivia_response.dart';
import 'package:trivia/data/models/trivia_room.dart';
import 'package:trivia/data/repository/trivia_repository.dart';
import 'package:trivia/data/service/trivia_provider.dart';

part 'trivia_room_provider.g.dart';
part 'trivia_room_provider.freezed.dart';

@freezed
class TriviaRoomsState with _$TriviaRoomsState {
  const factory TriviaRoomsState({
    required List<TriviaRoom> triviaRooms, // List of all trivia rooms
    TriviaRoom? selectedRoom, // Currently selected trivia room
  }) = _TriviaRoomsState;
}

@Riverpod(keepAlive: true)
class TriviaRooms extends _$TriviaRooms {
  late final TriviaRoomDataSource _dataSource;
  late final TriviaRepository _triviaRepository;

  @override
  Future<TriviaRoomsState> build() async {
    // Initialize dependencies
    _dataSource = TriviaRoomDataSource();
    _triviaRepository = ref.read(triviaRepositoryProvider);

    // Fetch initial rooms
    final rooms = await _fetchAllRooms();
    return TriviaRoomsState(triviaRooms: rooms, selectedRoom: null);
  }

  /// Fetches all trivia rooms from the data source
  Future<List<TriviaRoom>> _fetchAllRooms() async {
    final snapshot =
        await _dataSource.firestore.collection('triviaRooms').get();
    return snapshot.docs.map((doc) => TriviaRoom.fromJson(doc.data())).toList();
  }

  /// Creates a new trivia room
  Future<void> createRoom({
    required String roomId,
    required int questionCount,
    required int categoryId,
    required String difficulty,
    required bool isPublic,
  }) async {
    await _dataSource.createRoom(
      roomId: roomId,
      questionCount: questionCount,
      categoryId: categoryId,
      difficulty: difficulty,
      isPublic: isPublic,
    );
    // Refresh rooms
    state = AsyncValue.data(
      state.value!.copyWith(
        triviaRooms: await _fetchAllRooms(),
      ),
    );
  }

  /// Selects a trivia room by ID
  Future<void> selectRoom(String roomId) async {
    final room = await _dataSource.getRoomById(roomId);
    if (room == null) {
      throw Exception("Room not found");
    }
    state = AsyncValue.data(
      state.value!.copyWith(selectedRoom: room),
    );
  }

  /// Deletes a trivia room by ID
  Future<void> deleteRoom(String roomId) async {
    await _dataSource.deleteRoom(roomId);
    // Refresh rooms
    state = AsyncValue.data(
      state.value!.copyWith(
        triviaRooms: await _fetchAllRooms(),
      ),
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
    if (state.value?.selectedRoom?.roomId == roomId) {
      await selectRoom(roomId);
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
    if (state.value?.selectedRoom?.roomId == roomId) {
      await selectRoom(roomId);
    }
  }

  /// Fetch trivia questions for a selected room
  Future<TriviaResponse> fetchTriviaForSelectedRoom() async {
    final selectedRoom = state.value?.selectedRoom;
    if (selectedRoom == null) {
      throw Exception("No room selected");
    }
    final token = ref.read(triviaProvider).token;
    return await _dataSource.fetchTriviaForRoom(
      selectedRoom.roomId ?? "",
      _triviaRepository,
      token,
    );
  }
}
