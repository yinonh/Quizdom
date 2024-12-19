import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:trivia/data/models/trivia_room.dart';
import 'package:trivia/data/service/trivia_room_provider.dart';

part 'intro_screen_manager.freezed.dart';
part 'intro_screen_manager.g.dart';

@freezed
class IntroState with _$IntroState {
  const factory IntroState({
    required TriviaRoom? room,
  }) = _IntroState;
}

@riverpod
class IntroScreenManager extends _$IntroScreenManager {
  @override
  IntroState build() {
    final triviaRoomState = ref.watch(triviaRoomsProvider);

    return IntroState(
      room: triviaRoomState.selectedRoom,
    );
  }
}
