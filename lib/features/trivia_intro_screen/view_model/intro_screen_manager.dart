import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:trivia/core/utils/enums/game_mode.dart';
import 'package:trivia/data/models/general_trivia_room.dart';
import 'package:trivia/data/models/trivia_categories.dart';
import 'package:trivia/data/models/trivia_user.dart';
import 'package:trivia/data/models/user_preference.dart';
import 'package:trivia/data/providers/game_mode_provider.dart';
import 'package:trivia/data/providers/general_trivia_room_provider.dart';
import 'package:trivia/data/providers/trivia_provider.dart';
import 'package:trivia/data/providers/user_preference_provider.dart';
import 'package:trivia/data/providers/user_provider.dart';

part 'intro_screen_manager.freezed.dart';
part 'intro_screen_manager.g.dart';

@freezed
class IntroState with _$IntroState {
  const factory IntroState({
    required GeneralTriviaRoom? room,
    required GameMode gameMode,
    required TriviaUser currentUser,
    required Future<TriviaCategories?> categories,
    required UserPreference userPreferences,
    Map<String, UserPreference>? availableUsers,
    String? currentUserId,
  }) = _IntroState;
}

@riverpod
class IntroScreenManager extends _$IntroScreenManager {
  @override
  IntroState build() {
    final triviaRoomState = ref.watch(generalTriviaRoomsProvider);
    final currentUser = ref.watch(authProvider).currentUser;
    final gameMode = ref.watch(gameModeNotifierProvider) ?? GameMode.solo;
    final categories = ref.read(triviaProvider.notifier).getCategories();

    final availableUsers = gameMode == GameMode.duel
        ? ref.watch(
            availableUsersProvider.select((value) => value.availableUsers))
        : null;

    // Get the first user ID if available
    final firstUserId = availableUsers?.keys.firstOrNull;

    return IntroState(
      room: triviaRoomState.selectedRoom,
      gameMode: gameMode,
      currentUser: currentUser,
      categories: categories,
      userPreferences: UserPreference.empty(),
      availableUsers: availableUsers,
      currentUserId: firstUserId,
    );
  }

  // Method to switch to the next available user
  void switchToNextUser() {
    final users = state.availableUsers;
    if (users == null || users.isEmpty) return;

    final userIds = users.keys.toList();
    final currentIndex = userIds.indexOf(state.currentUserId ?? userIds.first);

    // Calculate the next user index, wrapping around if at the end
    final nextIndex = (currentIndex + 1) % userIds.length;

    state = state.copyWith(currentUserId: userIds[nextIndex]);
  }

  void payCoins(int amount) {
    ref.read(authProvider.notifier).updateCoins(amount);
  }

  // Method to mark user as ready
  void setReady() {}

  void updateUserPreferences({
    int? category,
    int? numOfQuestions,
    String? difficulty,
  }) {
    state = state.copyWith(
      userPreferences: state.userPreferences.copyWith(
        categoryId: category == -1
            ? null
            : category ?? state.userPreferences.categoryId,
        questionCount: numOfQuestions == -1
            ? null
            : numOfQuestions ?? state.userPreferences.questionCount,
        difficulty: difficulty == "-1"
            ? null
            : difficulty ?? state.userPreferences.difficulty,
      ),
    );
  }

  int preferencesNum() {
    int count = 0;
    if (state.userPreferences.categoryId != null) count++;
    if (state.userPreferences.questionCount != null) count++;
    if (state.userPreferences.difficulty != null) count++;
    return count;
  }
}
