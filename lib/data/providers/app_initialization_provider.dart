import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:trivia/data/providers/user_provider.dart';
import 'package:trivia/data/providers/user_statistics_provider.dart';

import 'current_trivia_achievements_provider.dart';
import 'general_trivia_room_provider.dart';

part 'app_initialization_provider.g.dart';

@riverpod
Stream<User?> authStateChanges(AuthStateChangesRef ref) {
  return FirebaseAuth.instance.authStateChanges();
}

@riverpod
class AppInitialization extends _$AppInitialization {
  @override
  Future<void> build() async {
    final authState = ref.watch(authStateChangesProvider);

    return authState.when(
      data: (user) async {
        if (user != null) {
          await _initializeAppData();
        }
      },
      loading: () async {},
      error: (error, stack) async => throw error,
    );
  }

  Future<void> _initializeAppData() async {
    try {
      // Initialize in correct order
      await ref
          .read(generalTriviaRoomsProvider.notifier)
          .initializeGeneralTriviaRoom();

      // Wait for user initialization to complete before proceeding
      await ref.read(authProvider.notifier).initializeUser();

      // After user is initialized, proceed with statistics and achievements
      await Future.wait([
        ref.read(statisticsProvider.notifier).initializeUserStatistics(),
        Future(() => ref.read(currentTriviaAchievementsProvider)),
      ]);
    } catch (e) {
      // Handle any initialization errors
      throw Exception('Failed to initialize app data: $e');
    }
  }
}
