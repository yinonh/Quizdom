import 'dart:async';

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:trivia/data/data_source/trivia_room_data_source.dart';
import 'package:trivia/data/models/trivia_room.dart';

part 'available_rooms_provider.freezed.dart';
part 'available_rooms_provider.g.dart';

@freezed
class AvailableRoomsState with _$AvailableRoomsState {
  const factory AvailableRoomsState({
    List<TriviaRoom>? availableRooms,
    String? error,
  }) = _AvailableRoomsState;
}

@riverpod
class AvailableRooms extends _$AvailableRooms {
  StreamSubscription<List<TriviaRoom>>? _availableRoomsSubscription;

  @override
  AvailableRoomsState build() {
    // Automatically start watching rooms when the provider is first accessed
    watchAvailableRooms();

    ref.onDispose(() {
      _availableRoomsSubscription?.cancel();
    });

    return const AvailableRoomsState(
      availableRooms: null,
    );
  }

  Future<void> watchAvailableRooms() async {
    // Cancel any existing subscription first
    await _availableRoomsSubscription?.cancel();

    _availableRoomsSubscription =
        TriviaRoomDataSource.watchAvailableRooms().listen(
      (rooms) {
        state = state.copyWith(availableRooms: rooms);
      },
      onError: (error) {
        state = state.copyWith(error: error.toString());
      },
    );
  }
}
