import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:trivia/core/utils/enums/game_mode.dart';
import 'package:trivia/data/models/general_trivia_room.dart';
import 'package:trivia/data/models/trivia_room.dart';
import 'package:trivia/data/models/trivia_user.dart';
import 'package:trivia/data/providers/game_mode_provider.dart';
import 'package:trivia/data/providers/general_trivia_room_provider.dart';
import 'package:trivia/data/providers/user_provider.dart';
import 'package:trivia/features/trivia_intro_screen/view_model/available_rooms_provider.dart';

part 'intro_screen_manager.freezed.dart';
part 'intro_screen_manager.g.dart';

@freezed
class IntroState with _$IntroState {
  const factory IntroState({
    required GeneralTriviaRoom? room,
    required GameMode gameMode,
    required TriviaUser currentUser,
    List<TriviaUser>? otherUsers,
    List<TriviaRoom>? availableRooms,
    int? currentRoomIndex, // New field to track current room
    @Default(false) bool isReady, // New field to track ready status
  }) = _IntroState;
}

@riverpod
class IntroScreenManager extends _$IntroScreenManager {
  @override
  IntroState build() {
    final triviaRoomState = ref.watch(generalTriviaRoomsProvider);
    final currentUser = ref.watch(authProvider).currentUser;
    final gameMode = ref.watch(gameModeNotifierProvider) ?? GameMode.solo;
    List<TriviaRoom>? availableRooms;

    if (gameMode == GameMode.duel) {
      // Only listen to available rooms when in duel mode
      availableRooms = ref.watch(availableRoomsProvider).availableRooms;
      print("availableRoomsState: $availableRooms");
    }

    return IntroState(
      room: triviaRoomState.selectedRoom,
      gameMode: gameMode,
      currentUser: currentUser,
      availableRooms: availableRooms,
      currentRoomIndex:
          availableRooms != null && availableRooms.isNotEmpty ? 0 : null,
    );
  }

  void payCoins(int amount) {
    ref.read(authProvider.notifier).updateCoins(amount);
  }

  // Method to switch to the next available room
  void switchToNextRoom() {
    final currentRooms = state.availableRooms;
    if (currentRooms == null || currentRooms.isEmpty) return;

    // Calculate the next room index, wrapping around if at the end
    final nextIndex = state.currentRoomIndex != null
        ? (state.currentRoomIndex! + 1) % currentRooms.length
        : 0;

    state = state.copyWith(currentRoomIndex: nextIndex);
  }

  // Method to mark user as ready
  void setReady() {
    state = state.copyWith(isReady: true);
    // Additional logic for marking ready can be added here
  }
}
