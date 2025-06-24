import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:trivia/core/network/server.dart';
import 'package:trivia/data/providers/current_trivia_achievements_provider.dart';
import 'package:trivia/data/providers/general_trivia_room_provider.dart';
import 'package:trivia/data/providers/user_provider.dart';
import 'package:trivia/data/providers/user_statistics_provider.dart';

part 'auth_providers.g.dart';

// State class to hold authentication state and new user flag
class AuthState {
  final User? user;
  final bool isNewUser;
  final bool isInitialized;
  final String? error;

  const AuthState({
    this.user,
    this.isNewUser = false,
    this.isInitialized = false,
    this.error,
  });

  AuthState copyWith({
    User? user,
    bool? isNewUser,
    bool? isInitialized,
    String? error,
  }) {
    return AuthState(
      user: user ?? this.user,
      isNewUser: isNewUser ?? this.isNewUser,
      isInitialized: isInitialized ?? this.isInitialized,
      error: error ?? this.error,
    );
  }
}

// Enhanced auth state provider with token validation and new user tracking
@riverpod
class UnifiedAuth extends _$UnifiedAuth {
  StreamController<AuthState>? _controller;
  User? _lastUser;
  bool _lastIsNewUser = false;

  @override
  Stream<AuthState> build() {
    _controller = StreamController<AuthState>.broadcast();

    // Watch the new user provider
    ref.listen(newUserRegistrationProvider, (previous, next) {
      _lastIsNewUser = next;
      _emitCurrentState();
    });

    // Watch auth state changes
    final authSubscription =
        FirebaseAuth.instance.authStateChanges().listen((user) {
      _lastUser = user;
      _emitCurrentState();
    });

    // Clean up when disposed
    ref.onDispose(() {
      authSubscription.cancel();
      _controller?.close();
    });

    return _controller!.stream;
  }

  void _emitCurrentState() async {
    if (_controller?.isClosed == true) return;

    final authState = await _processAuthState(_lastUser, _lastIsNewUser);
    if (_controller?.isClosed == false) {
      _controller!.add(authState);
    }
  }

  // Async method to process the auth state
  Future<AuthState> _processAuthState(User? user, bool isNewUser) async {
    if (user == null) {
      return const AuthState(user: null, isInitialized: true);
    }

    try {
      // Validate token - this will fail if user was deleted
      await user.getIdToken(true);

      // Initialize app data for authenticated user
      await _initializeAppData();

      return AuthState(
        user: user,
        isNewUser: isNewUser,
        isInitialized: true,
      );
    } catch (e) {
      // User was deleted or token is invalid
      print('User token invalid, signing out: $e');
      await FirebaseAuth.instance.signOut();
      return AuthState(
        user: null,
        isInitialized: true,
        error: e.toString(),
      );
    }
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

  // Method to manually validate token (from your original userTokenValidationProvider)
  Future<bool> validateUserToken() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return false;

    try {
      // Force token refresh - this will fail if user was deleted
      await user.getIdToken(true);
      return true;
    } catch (e) {
      // Token is invalid - user was likely deleted
      print('Token validation failed: $e');
      await FirebaseAuth.instance.signOut();
      return false;
    }
  }
}

// New user registration provider (kept separate for specific new user logic)
final newUserRegistrationProvider =
    StateNotifierProvider<NewUserRegistrationNotifier, bool>((ref) {
  return NewUserRegistrationNotifier();
});

class NewUserRegistrationNotifier extends StateNotifier<bool> {
  NewUserRegistrationNotifier() : super(false);

  void setNewUser(bool isNewUser) {
    state = isNewUser;
  }

  void clearNewUser() {
    state = false;
  }
}

// Convenience providers for easier access
@riverpod
User? currentUser(Ref ref) {
  final authState = ref.watch(unifiedAuthProvider);
  return authState.whenOrNull(data: (state) => state.user);
}

@riverpod
bool isUserAuthenticated(Ref ref) {
  final authState = ref.watch(unifiedAuthProvider);
  return authState.whenOrNull(data: (state) => state.user != null) ?? false;
}

@riverpod
bool isNewUser(Ref ref) {
  final authState = ref.watch(unifiedAuthProvider);
  return authState.whenOrNull(data: (state) => state.isNewUser) ?? false;
}

@riverpod
bool isAuthInitialized(Ref ref) {
  final authState = ref.watch(unifiedAuthProvider);
  return authState.whenOrNull(data: (state) => state.isInitialized) ?? false;
}

// If you need the raw auth state changes (without token validation)
@riverpod
Stream<User?> rawAuthStateChanges(Ref ref) {
  return FirebaseAuth.instance.authStateChanges();
}
