import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:trivia/core/utils/enums/game_mode.dart';
import 'package:trivia/data/data_source/user_preference_data_source.dart';
import 'package:trivia/data/models/general_trivia_room.dart';
import 'package:trivia/data/models/trivia_categories.dart';
import 'package:trivia/data/models/trivia_user.dart';
import 'package:trivia/data/models/user_preference.dart';
import 'package:trivia/data/providers/game_mode_provider.dart';
import 'package:trivia/data/providers/general_trivia_room_provider.dart';
import 'package:trivia/data/providers/trivia_provider.dart';
import 'package:trivia/data/providers/user_provider.dart';

part 'intro_screen_manager.freezed.dart';
part 'intro_screen_manager.g.dart';

@freezed
class IntroState with _$IntroState {
  const factory IntroState({
    required GeneralTriviaRoom? room,
    required GameMode gameMode,
    required TriviaUser currentUser,
    required TriviaCategories? categories,
    required UserPreference userPreferences,
    Map<String, UserPreference>? availableUsers,
    String? currentUserId,
  }) = _IntroState;
}

@riverpod
class IntroScreenManager extends _$IntroScreenManager {
  @override
  Future<IntroState> build() async {
    final triviaRoomState = ref.watch(generalTriviaRoomsProvider);
    final currentUser = ref.watch(authProvider).currentUser;
    final gameMode = ref.watch(gameModeNotifierProvider) ?? GameMode.solo;
    final categories = await ref.read(triviaProvider.notifier).getCategories();

    Map<String, UserPreference>? availableUsers;
    if (gameMode == GameMode.duel) {
      availableUsers = await UserPreferenceDataSource.getAvailableUsers();
      await UserPreferenceDataSource.createUserPreference(
          userId: currentUser.uid, preference: UserPreference.empty());
    }

    ref.onDispose(() {
      UserPreferenceDataSource.deleteUserPreference(currentUser.uid);
    });

    return IntroState(
      room: triviaRoomState.selectedRoom,
      gameMode: gameMode,
      currentUser: currentUser,
      categories: categories,
      userPreferences: UserPreference.empty(),
      availableUsers: availableUsers,
      currentUserId: availableUsers?.keys.firstOrNull,
    );
  }

  void switchToNextUser() {
    final currentState = state;
    if (currentState is! AsyncData<IntroState>) return;
    final currentData = currentState.value;

    final users = currentData.availableUsers;
    if (users == null || users.isEmpty) return;

    final userIds = users.keys.toList();
    final currentIndex =
        userIds.indexOf(currentData.currentUserId ?? userIds.first);
    final nextIndex = (currentIndex + 1) % userIds.length;

    state = AsyncData(currentData.copyWith(currentUserId: userIds[nextIndex]));
  }

  void payCoins(int amount) {
    ref.read(authProvider.notifier).updateCoins(amount);
  }

  void setReady() {
    // Implement setReady logic here
  }

  void updateUserPreferences({
    int? category,
    int? numOfQuestions,
    String? difficulty,
  }) {
    final currentState = state;
    if (currentState is! AsyncData<IntroState>) return;
    final currentData = currentState.value;

    final newPreferences = currentData.userPreferences.copyWith(
      categoryId: category == -1
          ? null
          : category ?? currentData.userPreferences.categoryId,
      questionCount: numOfQuestions == -1
          ? null
          : numOfQuestions ?? currentData.userPreferences.questionCount,
      difficulty: difficulty == "-1"
          ? null
          : difficulty ?? currentData.userPreferences.difficulty,
    );

    state = AsyncData(currentData.copyWith(userPreferences: newPreferences));
  }

  int preferencesNum() {
    final currentState = state;
    if (currentState is! AsyncData<IntroState>) return 0;
    final currentData = currentState.value;

    int count = 0;
    if (currentData.userPreferences.categoryId != null) count++;
    if (currentData.userPreferences.questionCount != null) count++;
    if (currentData.userPreferences.difficulty != null) count++;
    return count;
  }
}
