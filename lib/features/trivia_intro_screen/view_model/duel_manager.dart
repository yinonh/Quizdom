import 'dart:async';

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:trivia/data/data_source/user_data_source.dart';
import 'package:trivia/data/data_source/user_preference_data_source.dart';
import 'package:trivia/data/models/trivia_categories.dart';
import 'package:trivia/data/models/trivia_user.dart';
import 'package:trivia/data/models/user_preference.dart';
import 'package:trivia/data/providers/trivia_provider.dart';
import 'package:trivia/data/providers/user_provider.dart';

part 'duel_manager.freezed.dart';
part 'duel_manager.g.dart';

@freezed
class DuelState with _$DuelState {
  const factory DuelState({
    required UserPreference userPreferences,
    required TriviaUser currentUser,
    @Default([]) List<String> oldMatchedUsers,
    String? matchedUserId,
    TriviaUser? matchedUser,
    required TriviaCategories? categories,
  }) = _DuelState;
}

@riverpod
Stream<Map<String, dynamic>> userPreference(
    UserPreferenceRef ref, String userId) {
  return UserPreferenceDataSource.watchUserPreference(userId);
}

@riverpod
class DuelManager extends _$DuelManager {
  Timer? _matchTimer;

  @override
  Future<DuelState> build() async {
    final currentUser = ref.watch(authProvider).currentUser;
    List<String> oldMatchedUsers = [];
    String? matchedUserId;
    TriviaUser? matchedUser;
    final categories = await ref.read(triviaProvider.notifier).getCategories();

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
      matchedUser = await UserDataSource.getUserById(matchedUserId);
    }

    _matchTimer = Timer.periodic(const Duration(seconds: 5), (timer) async {
      final currentState = state;
      if (currentState is AsyncData<DuelState>) {
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

    // Listen for changes in user preferences
    ref.listen<AsyncValue<Map<String, dynamic>>>(
        userPreferenceProvider(currentUser.uid), (previous, next) {
      next.whenData((preferences) async {
        final currentData = state.value;
        if (currentData == null) return;

        final String? newMatchedUserId = preferences['matchedUserId'];
        final String? triviaRoomId = preferences['triviaRoomId'];

        // Handle matched user changes
        if (currentData.matchedUserId != newMatchedUserId) {
          if (newMatchedUserId != null) {
            matchedUser = await UserDataSource.getUserById(newMatchedUserId);
            state = AsyncData(
              currentData.copyWith(
                matchedUserId: newMatchedUserId,
                matchedUser: matchedUser,
              ),
            );
          } else {
            state = AsyncData(
              currentData.copyWith(
                matchedUserId: newMatchedUserId,
              ),
            );
          }
        }

        // Handle trivia room creation
        if (triviaRoomId != null) {
          await UserPreferenceDataSource.deleteUserPreference(currentUser.uid);
          print("move to diffrent screen");
        }
      });
    });

    // Cleanup
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

    return DuelState(
      userPreferences: UserPreference.empty(),
      oldMatchedUsers: oldMatchedUsers,
      currentUser: currentUser,
      matchedUserId: matchedUserId,
      matchedUser: matchedUser,
      categories: categories,
    );
  }

  Future<void> findNewMatch() async {
    final currentState = state;
    if (currentState is! AsyncData<DuelState>) return;
    final data = currentState.value;
    final currentUserId = ref.read(authProvider).currentUser.uid;

    if (data.matchedUserId != null) {
      await UserPreferenceDataSource.removeMatchFromOther(
          currentUserId, data.matchedUserId!);
      await UserPreferenceDataSource.clearMatch(currentUserId);
    }

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

  Future<void> updateUserPreferences({
    int? category,
    int? numOfQuestions,
    String? difficulty,
  }) async {
    final currentState = state;
    if (currentState is! AsyncData<DuelState>) return;
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
    state.whenData((stateData) async {
      if (stateData.matchedUserId != null) {
        await UserPreferenceDataSource.removeMatchFromOther(
            stateData.currentUser.uid, stateData.matchedUserId!);
      }

      UserPreferenceDataSource.updateUserPreference(
          userId: ref.read(authProvider).currentUser.uid,
          updatedPreference: newPreferences);

      state = AsyncData(currentData.copyWith(userPreferences: newPreferences));
    });
  }

  int preferencesNum() {
    final currentState = state;
    if (currentState is! AsyncData<DuelState>) return 0;
    final currentData = currentState.value;
    int count = 0;
    if (currentData.userPreferences.categoryId != null) count++;
    if (currentData.userPreferences.questionCount != null) count++;
    if (currentData.userPreferences.difficulty != null) count++;
    return count;
  }

  void setReady() {
    final currentState = state;
    if (currentState is! AsyncData<DuelState>) return;
    final currentData = currentState.value;
    UserPreferenceDataSource.setUserReady(
      currentData.currentUser.uid,
    );
  }
}
