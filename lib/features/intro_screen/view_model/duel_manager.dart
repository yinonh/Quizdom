import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:trivia/core/constants/app_constant.dart';
import 'package:trivia/core/network/server.dart';
import 'package:trivia/data/data_source/user_data_source.dart';
import 'package:trivia/data/data_source/user_preference_data_source.dart';
import 'package:trivia/data/models/trivia_categories.dart';
import 'package:trivia/data/models/trivia_user.dart';
import 'package:trivia/data/models/user_preference.dart';
import 'package:trivia/core/global_providers/app_lifecycle_provider.dart';
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
  // Set up a listener to handle lifecycle changes
  ref.listen(appLifecycleNotifierProvider, (previous, current) {
    if (current == AppLifecycleStatus.paused ||
        current == AppLifecycleStatus.detached) {
      // Cleanup when app goes to background or is closed
      UserPreferenceDataSource.cleanupUserPreference(userId);
    } else if (current == AppLifecycleStatus.resumed && previous != null) {
      // Only recreate if we're coming back from a background state
      if (previous == AppLifecycleStatus.paused ||
          previous == AppLifecycleStatus.detached) {
        UserPreferenceDataSource.recreateUserPreference(userId);
      }
    }
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

    // Ensure we're passing an empty list initially but with required parameter
    matchedUserId = await UserPreferenceDataSource.findMatch(
      currentUser.uid,
      excludedIds: oldMatchedUsers,
    );

    if (matchedUserId != null) {
      _startProgressTimer();
      oldMatchedUsers = List.from(oldMatchedUsers)..add(matchedUserId);
      matchedUser = await UserDataSource.getUserById(matchedUserId);
    }

    // Use a slightly longer timer to reduce race conditions
    _matchTimer = Timer.periodic(const Duration(seconds: 7), (timer) async {
      final currentState = state;
      if (currentState is AsyncData<DuelState>) {
        if (currentState.value.matchedUserId == null) {
          logger.i("🔄 Timer: No match found, trying to find match again...");

          // Always use the latest state to get the current list of excluded users
          final newMatch = await UserPreferenceDataSource.findMatch(
            currentUser.uid,
            excludedIds: currentState.value.oldMatchedUsers,
          );

          if (newMatch != null) {
            logger.i("✅ Found new match: $newMatch");

            // Fetch the matched user data
            final newMatchedUser = await UserDataSource.getUserById(newMatch);

            // Reset match progress when finding a new match
            _startProgressTimer();

            // Update the excluded users list with the new match
            final updatedOldMatches =
                List<String>.from(currentState.value.oldMatchedUsers)
                  ..add(newMatch);

            // Update state with all the new information atomically
            state = AsyncData(
              currentState.value.copyWith(
                matchedUserId: newMatch,
                matchedUser: newMatchedUser,
                oldMatchedUsers: updatedOldMatches,
                matchProgress: 0.0,
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

        logger.i(
            "🔔 Preference update: matchedUserId=$newMatchedUserId, currentMatchedId=${currentData.matchedUserId}");

        // Handle matched user changes and ready state
        if (currentData.matchedUserId != newMatchedUserId) {
          if (newMatchedUserId != null) {
            _startProgressTimer();
            final newMatchedUser =
                await UserDataSource.getUserById(newMatchedUserId);

            // Make sure we add this to our excluded list to prevent re-matching
            final updatedOldMatches =
                List<String>.from(currentData.oldMatchedUsers);
            if (!updatedOldMatches.contains(newMatchedUserId)) {
              updatedOldMatches.add(newMatchedUserId);
            }

            state = AsyncData(
              currentData.copyWith(
                matchedUserId: newMatchedUserId,
                matchedUser: newMatchedUser,
                isReady: userReady,
                oldMatchedUsers: updatedOldMatches,
                matchProgress: 0.0,
              ),
            );
          } else {
            // Reset ready state when match is cleared
            state = AsyncData(
              currentData.copyWith(
                matchedUserId: null,
                matchedUser: null,
                isReady: false,
                matchProgress: 0.0,
              ),
            );
          }
        } else if (currentData.isReady != userReady) {
          // Just update ready state if that's all that changed
          state = AsyncData(
            currentData.copyWith(
              isReady: userReady,
            ),
          );
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
      _progressTimer?.cancel();

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
    // Cancel any existing timer first
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

    logger.i("🔄 Finding new match. Current matched ID: ${data.matchedUserId}");
    logger.i("🔄 Current excluded IDs: ${data.oldMatchedUsers}");

    if (data.matchedUserId != null) {
      await UserPreferenceDataSource.removeMatchFromOther(
          currentUserId, data.matchedUserId!);
      await UserPreferenceDataSource.clearMatch(currentUserId);

      // Immediately update state to reflect the cleared match
      state = AsyncData(data.copyWith(
        matchedUserId: null,
        matchedUser: null,
      ));
    }

    final newMatch = await UserPreferenceDataSource.findMatch(
      currentUserId,
      excludedIds: data.oldMatchedUsers,
    );

    if (newMatch != null) {
      logger.i("✅ Found new match: $newMatch");
      final newMatchedUser = await UserDataSource.getUserById(newMatch);
      _startProgressTimer();

      List<String> updatedOldMatches = List.from(data.oldMatchedUsers);
      if (!updatedOldMatches.contains(newMatch)) {
        updatedOldMatches.add(newMatch);
      }

      state = AsyncData(data.copyWith(
        matchedUserId: newMatch,
        matchedUser: newMatchedUser,
        oldMatchedUsers: updatedOldMatches,
        matchProgress: 0.0,
      ));
    }
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

    // First update the state with the new preferences
    state = AsyncData(currentData.copyWith(userPreferences: newPreferences));

    // Then perform the Firebase updates
    if (currentData.matchedUserId != null) {
      await UserPreferenceDataSource.removeMatchFromOther(
          currentData.currentUser.uid, currentData.matchedUserId!);

      // Update the state to reflect that there's no match
      state = AsyncData(state.value!.copyWith(
        matchedUserId: null,
        matchedUser: null,
      ));
    }

    await UserPreferenceDataSource.updateUserPreference(
        userId: ref.read(authProvider).currentUser.uid,
        updatedPreference: newPreferences);
  }

  Future<void> setIsNavigated() async {
    _matchTimer?.cancel();
    _progressTimer?.cancel();
    state.whenData(
      (stateData) async {
        if (stateData.matchedRoom != null) {
          state = AsyncData(stateData.copyWith(hasNavigated: true));
        }
      },
    );
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
