import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
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
    @Default([]) List<String> oldMatchedUsers,
    String? matchedUserId,
  }) = _IntroState;
}

@riverpod
class IntroScreenManager extends _$IntroScreenManager {
  Timer? _matchTimer;

  @override
  Future<IntroState> build() async {
    final triviaRoomState = ref.watch(generalTriviaRoomsProvider);
    final currentUser = ref.watch(authProvider).currentUser;
    final gameMode = ref.watch(gameModeNotifierProvider) ?? GameMode.solo;
    final categories = await ref.read(triviaProvider.notifier).getCategories();

    // Initially, no old matches.
    List<String> oldMatchedUsers = [];
    String? matchedUserId;

    // For duel mode, create the user preference document and try to find a match.
    if (gameMode == GameMode.duel) {
      await UserPreferenceDataSource.createUserPreference(
        userId: currentUser.uid,
        preference: UserPreference.empty(),
      );

      matchedUserId = await UserPreferenceDataSource.findMatch(
        currentUser.uid,
        excludedIds: oldMatchedUsers,
      );
      if (matchedUserId != null) {
        oldMatchedUsers = List.from(oldMatchedUsers)..add(matchedUserId);
      }
    }

    // Set up a periodic timer to continuously search for a match if none is found.
    if (gameMode == GameMode.duel) {
      _matchTimer = Timer.periodic(const Duration(seconds: 5), (timer) async {
        final currentState = state;
        if (currentState is AsyncData<IntroState>) {
          if (currentState.value.matchedUserId == null) {
            print("🔄 Timer: No match found, trying to find match again...");
            final newMatch = await UserPreferenceDataSource.findMatch(
              currentUser.uid,
              excludedIds: currentState.value.oldMatchedUsers.cast<String>(),
            );
            if (newMatch != null) {
              final updatedOldMatches =
                  List<String>.from(currentState.value.oldMatchedUsers)
                    ..add(newMatch);
              state = AsyncData(
                currentState.value.copyWith(
                  matchedUserId: newMatch,
                  oldMatchedUsers: updatedOldMatches,
                ),
              );
            }
          }
        }
      });
    }

    // Create a provider for the matchedUserId stream.
    final matchedUserProvider = StreamProvider<String?>((ref) {
      final currentUser = ref.watch(authProvider).currentUser;
      return UserPreferenceDataSource.watchMatchedUserId(currentUser.uid);
    });

    // Listen for changes in matchedUserId and update the state.
    ref.listen<AsyncValue<String?>>(matchedUserProvider, (previous, next) {
      next.whenData((newMatchedUserId) {
        final currentData = state.value;
        if (currentData != null &&
            currentData.matchedUserId != newMatchedUserId) {
          state = AsyncData(
            currentData.copyWith(matchedUserId: newMatchedUserId),
          );
        }
      });
    });

    // Cleanup on screen exit: cancel timer, remove our ID from the matched user (if any), and delete our document.
    ref.onDispose(() {
      _matchTimer?.cancel();
      Future.microtask(() async {
        final currentData = state.value;
        if (currentData != null && currentData.matchedUserId != null) {
          await UserPreferenceDataSource.removeMatchFromOther(
              currentUser.uid, currentData.matchedUserId!);
        }
        await UserPreferenceDataSource.deleteUserPreference(currentUser.uid);
      });
    });

    return IntroState(
      room: triviaRoomState.selectedRoom,
      gameMode: gameMode,
      currentUser: currentUser,
      categories: categories,
      userPreferences: UserPreference.empty(),
      oldMatchedUsers: oldMatchedUsers,
      matchedUserId: matchedUserId,
    );
  }

  /// Called when the user explicitly asks for a new match.
  Future<void> findNewMatch() async {
    final currentState = state;
    if (currentState is! AsyncData<IntroState>) return;
    final data = currentState.value;
    final currentUserId = data.currentUser.uid;
    // If there's an existing match, remove our ID from the other user's document and reset our own.
    if (data.matchedUserId != null) {
      await UserPreferenceDataSource.removeMatchFromOther(
          currentUserId, data.matchedUserId!);
      await FirebaseFirestore.instance
          .collection('availablePlayers')
          .doc(currentUserId)
          .update({'matchedUserId': null});
    }
    // Look for a new match while excluding previously matched IDs.
    final newMatch = await UserPreferenceDataSource.findMatch(
      currentUserId,
      excludedIds: data.oldMatchedUsers.cast<String>(),
    );
    List<String> updatedOldMatches = List.from(data.oldMatchedUsers);
    if (newMatch != null) {
      updatedOldMatches.add(newMatch);
    }
    state = AsyncData(data.copyWith(
      matchedUserId: newMatch,
      oldMatchedUsers: updatedOldMatches,
    ));
  }

  /// Switch game: cancel the current match and search for a different opponent.
  Future<void> switchGame() async {
    await findNewMatch();
  }

  void payCoins(int amount) {
    ref.read(authProvider.notifier).updateCoins(amount);
  }

  void setReady() {
    // Implement ready logic before creating the trivia room.
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
