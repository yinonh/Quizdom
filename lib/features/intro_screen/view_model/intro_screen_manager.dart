import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:trivia/core/utils/enums/game_mode.dart';
import 'package:trivia/data/models/general_trivia_room.dart';
import 'package:trivia/data/models/trivia_user.dart';
import 'package:trivia/data/providers/game_mode_provider.dart';
import 'package:trivia/data/providers/general_trivia_room_provider.dart';
import 'package:trivia/data/providers/user_provider.dart';

part 'intro_screen_manager.freezed.dart';
part 'intro_screen_manager.g.dart';

@freezed
class IntroState with _$IntroState {
  const factory IntroState({
    required GeneralTriviaRoom? room,
    required GameMode gameMode,
    required TriviaUser currentUser,
  }) = _IntroState;
}

@riverpod
class IntroScreenManager extends _$IntroScreenManager {
  @override
  Future<IntroState> build() async {
    final triviaRoomState = ref.watch(generalTriviaRoomsProvider);
    final currentUser = ref.watch(authProvider).currentUser;
    final gameMode = ref.watch(gameModeNotifierProvider) ?? GameMode.solo;

    return IntroState(
      room: triviaRoomState.selectedRoom,
      gameMode: gameMode,
      currentUser: currentUser,
    );
  }

  void payCoins(int amount) {
    ref.read(authProvider.notifier).updateCoins(amount);
  }

  void setReady() {
    // Implement ready logic before creating the trivia room.
  }
}
