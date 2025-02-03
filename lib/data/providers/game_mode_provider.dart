import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:trivia/core/utils/enums/game_mode.dart';

part 'game_mode_provider.g.dart';

@Riverpod(keepAlive: true)
class GameModeNotifier extends _$GameModeNotifier {
  @override
  GameMode? build() => null;

  // Method to update the game mode
  void setMode(GameMode mode) {
    state = mode;
  }

  // Method to reset to null
  void clearMode() {
    state = null;
  }
}
