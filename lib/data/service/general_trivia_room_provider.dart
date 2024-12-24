import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:trivia/data/data_source/general_trivia_room_data_source.dart';
import 'package:trivia/data/models/general_trivia_room.dart';
import 'package:trivia/data/service/trivia_provider.dart';

part 'general_trivia_room_provider.freezed.dart';
part 'general_trivia_room_provider.g.dart';

@freezed
class GeneralTriviaRoomsState with _$GeneralTriviaRoomsState {
  const factory GeneralTriviaRoomsState({
    required List<GeneralTriviaRoom>? generalTriviaRooms,
    GeneralTriviaRoom? selectedRoom,
  }) = _GeneralTriviaRoomsState;
}

@Riverpod(keepAlive: true)
class GeneralTriviaRooms extends _$GeneralTriviaRooms {
  late final GeneralTriviaRoomDataSource _dataSource;

  @override
  GeneralTriviaRoomsState build() {
    _dataSource = GeneralTriviaRoomDataSource();
    return const GeneralTriviaRoomsState(
        generalTriviaRooms: null, selectedRoom: null);
  }

  Future<void> initializeGeneralTriviaRoom() async {
    final rooms = await _fetchAllGeneralRooms();
    state =
        GeneralTriviaRoomsState(generalTriviaRooms: rooms, selectedRoom: null);
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

  /// Selects a trivia room by ID
  void selectRoom(String roomId) {
    final room =
        state.generalTriviaRooms?.firstWhere((room) => room.roomId == roomId);
    if (room == null) {
      throw Exception("Room not found");
    }
    ref.read(triviaProvider.notifier).setGeneralTriviaRoom(room);
    state = state.copyWith(selectedRoom: room);
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
