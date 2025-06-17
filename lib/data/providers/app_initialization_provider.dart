import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:trivia/core/network/server.dart';
import 'package:trivia/data/providers/user_provider.dart';
import 'package:trivia/data/providers/user_statistics_provider.dart';

import 'current_trivia_achievements_provider.dart';
import 'general_trivia_room_provider.dart';

part 'app_initialization_provider.g.dart';

@riverpod
Stream<User?> authStateChanges(Ref ref) {
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
      error: (error, stack) async {
        // Log the error but don't throw it to prevent app crashes
        print('Auth state error: $error');
        // You might want to show a user-friendly error message here
      },
    );
  }

  Future<void> _initializeAppData() async {
    try {
      // Initialize general trivia rooms first (doesn't depend on user)
      await ref
          .read(generalTriviaRoomsProvider.notifier)
          .initializeGeneralTriviaRoom();

      // Initialize user data - this now handles missing users gracefully
      await ref.read(authProvider.notifier).initializeUser();

      // Only proceed with user-dependent initialization if user exists
      final currentUser = ref.read(authProvider).currentUser;
      if (currentUser.uid.isNotEmpty) {
        await Future.wait([
          ref.read(statisticsProvider.notifier).initializeUserStatistics(),
          Future(() => ref.read(currentTriviaAchievementsProvider)),
        ]);
      }
    } catch (e) {
      // Log the error for debugging
      logger.i('Failed to initialize app data: $e');

      // Try to recover by re-initializing user with defaults
      try {
        final firebaseUser = FirebaseAuth.instance.currentUser;
        if (firebaseUser != null) {
          await ref.read(authProvider.notifier).initializeUser();
        }
      } catch (recoveryError) {
        logger.i('Recovery initialization also failed: $recoveryError');
        // At this point, you might want to show an error screen or retry mechanism
        rethrow;
      }
    }
  }
}
