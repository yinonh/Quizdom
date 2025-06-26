import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:Quizdom/core/utils/enums/difficulty.dart';
import 'package:Quizdom/core/utils/enums/game_mode.dart';
import 'package:Quizdom/data/models/general_trivia_room.dart';
import 'package:Quizdom/data/models/trivia_user.dart';
import 'package:Quizdom/data/providers/game_mode_provider.dart';
import 'package:Quizdom/data/providers/general_trivia_room_provider.dart';
import 'package:Quizdom/data/providers/trivia_provider.dart';
import 'package:Quizdom/data/providers/user_provider.dart';

part 'intro_screen_manager.freezed.dart';
part 'intro_screen_manager.g.dart';

@freezed
class IntroState with _$IntroState {
  const factory IntroState({
    required GeneralTriviaRoom? room,
    required GameMode gameMode,
    required TriviaUser currentUser,
    required Difficulty? selectedDifficulty,
  }) = _IntroState;
}

@riverpod
class IntroScreenManager extends _$IntroScreenManager {
  @override
  Future<IntroState> build() async {
    final triviaRoomState = ref.watch(generalTriviaRoomsProvider);
    final currentUser = ref.watch(authProvider).currentUser;
    final gameMode = ref.watch(gameModeNotifierProvider) ?? GameMode.solo;
    final triviaState = ref.read(triviaProvider);

    return IntroState(
      room: triviaRoomState.selectedRoom,
      gameMode: gameMode,
      currentUser: currentUser,
      selectedDifficulty: triviaState.selectedDifficulty,
    );
  }

  void setDifficulty(Difficulty difficulty) {
    ref.read(triviaProvider.notifier).setDifficulty(difficulty);
    final currentState = state;
    if (currentState is! AsyncData<IntroState>) return;
    final data = currentState.value;
    state = state = AsyncData(
      data.copyWith(
        selectedDifficulty: difficulty,
      ),
    );
  }

  void payCoins(int amount) {
    ref.read(authProvider.notifier).updateCoins(amount);
  }
}
