import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:trivia/core/constants/app_constant.dart';
import 'package:trivia/core/lifecycle/app_lifecycle_handler.dart';
import 'package:trivia/data/data_source/trivia_room_data_source.dart';
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
    String? matchedRoom,
    @Default(0.0) double? matchProgress,
    @Default(false) bool isReady,
    @Default(false) bool hasNavigated,
  }) = _DuelState;
}

@riverpod
Stream<Map<String, dynamic>> userPreference(Ref ref, String userId) {
  // Initialize lifecycle handler
  AppLifecycleHandler().initialize();
  AppLifecycleHandler().registerUserId(userId);

  // Cleanup when this provider is disposed
  ref.onDispose(() {
    AppLifecycleHandler().unregisterUserId(userId);
  });

  return UserPreferenceDataSource.watchUserPreference(userId);
}

@riverpod
class DuelManager extends _$DuelManager {
  Timer? _matchTimer;
  Timer? _progressTimer;

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
      _startProgressTimer();
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

    // Listen for changes in user preferences and matched user's state
    ref.listen<AsyncValue<Map<String, dynamic>>>(
        userPreferenceProvider(currentUser.uid), (previous, next) {
      next.whenData((preferences) async {
        final currentData = state.value;
        if (currentData == null) return;

        final String? newMatchedUserId = preferences['matchedUserId'];
        final String? triviaRoomId = preferences['triviaRoomId'];
        final bool userReady = preferences['ready'] ?? false;

        // Handle matched user changes and ready state
        if (currentData.matchedUserId != newMatchedUserId ||
            currentData.isReady != userReady) {
          if (newMatchedUserId != null) {
            _startProgressTimer();
            matchedUser = await UserDataSource.getUserById(newMatchedUserId);
            state = AsyncData(
              currentData.copyWith(
                matchedUserId: newMatchedUserId,
                matchedUser: matchedUser,
                isReady: userReady,
              ),
            );
          } else {
            // Reset ready state when match is cleared
            state = AsyncData(
              currentData.copyWith(
                matchedUserId: newMatchedUserId,
                isReady: false,
              ),
            );
          }
        }

        // Handle trivia room creation
        if (triviaRoomId != null && !currentData.hasNavigated) {
          state = AsyncData(
            currentData.copyWith(
              matchedRoom: triviaRoomId,
            ),
          );
          await UserPreferenceDataSource.deleteUserPreference(currentUser.uid);
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
        matchedRoom: null,
        isReady: false);
  }

  void _startProgressTimer() {
    _progressTimer?.cancel();

    const duration = Duration(milliseconds: 100);
    final totalSteps =
        (AppConstant.matchTimeout * 1000) ~/ duration.inMilliseconds;
    var currentStep = 0;

    _progressTimer = Timer.periodic(duration, (timer) {
      final currentState = state;
      if (currentState is AsyncData<DuelState>) {
        currentStep++;
        final progress = currentStep / totalSteps;

        if (progress >= 1.0) {
          timer.cancel();
          findNewMatch(); // Auto-find new match when time expires
          return;
        }

        state = AsyncData(currentState.value.copyWith(
          matchProgress: progress,
        ));
      }
    });
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

  Future<void> setIsNavigated() async {
    _matchTimer?.cancel();
    _progressTimer?.cancel();
    state.whenData((stateData) async {
      TriviaRoomDataSource.getRoomById(stateData.matchedRoom ?? "")
          .then((room) {
        if (room != null) {
          ref.read(triviaProvider.notifier).setTriviaRoom(room);
        }
        state = AsyncData(stateData.copyWith(hasNavigated: true));
      });
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

  Future<void> setReady() async {
    final currentState = state;
    if (currentState is! AsyncData<DuelState>) return;
    final currentData = currentState.value;
    await UserPreferenceDataSource.setUserReady(
      currentData.currentUser.uid,
      ref.read(triviaProvider).token,
    );
  }
}
