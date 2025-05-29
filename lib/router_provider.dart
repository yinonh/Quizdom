import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'core/constants/app_routes.dart';
import 'data/providers/app_initialization_provider.dart';
import 'features/auth_screen/auth_screen.dart';
import 'features/avatar_screen/avatar_screen.dart';
import 'features/categories_screen/categories_screen.dart';
import 'features/intro_screen/intro_screen.dart';
import 'features/profile_screen/profile_screen.dart';
import 'features/quiz_screen/duel_quiz_screen.dart';
import 'features/quiz_screen/solo_quiz_screen.dart';
import 'features/results_screen/duel_result_screen.dart';
import 'features/results_screen/game_canceled.dart';
import 'features/results_screen/solo_results_screen.dart';
import 'features/wheel_spin_screen/wheel_spin_screen.dart';

part 'router_provider.g.dart';

@riverpod
class NewUserRegistration extends _$NewUserRegistration {
  @override
  bool build() {
    return false;
  }

  void setNewUser(bool isNewUser) {
    state = isNewUser;
  }

  void clearNewUser() {
    state = false;
  }
}

class AppNavigatorKeys {
  static final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>();
  static final GlobalKey<NavigatorState> shellNavigatorKey =
      GlobalKey<NavigatorState>();
}

// Updated Router provider
final routerProvider = Provider<GoRouter>(
  (ref) {
    final authState = ref.watch(authStateChangesProvider);
    final isNewUser = ref.watch(newUserRegistrationProvider);

    return GoRouter(
      navigatorKey: AppNavigatorKeys.navigatorKey,
      initialLocation: AppRoutes.categoriesRouteName,
      debugLogDiagnostics: true,
      redirect: (context, state) {
        final isAuthenticated = authState.value != null;
        final isLoggingIn = state.matchedLocation == AppRoutes.authRouteName;
        final isOnAvatarScreen = state.matchedLocation ==
            '${AppRoutes.categoriesRouteName}${AppRoutes.avatarRouteName}';

        // If not authenticated and not on the auth page, redirect to auth
        if (!isAuthenticated && !isLoggingIn) {
          return AppRoutes.authRouteName;
        }

        // If authenticated and on the auth page
        if (isAuthenticated && isLoggingIn) {
          // If it's a new user, redirect to avatar screen
          if (isNewUser) {
            return '${AppRoutes.categoriesRouteName}${AppRoutes.avatarRouteName}';
          }
          // Otherwise redirect to categories
          return AppRoutes.categoriesRouteName;
        }

        // If authenticated, new user, and not on avatar screen, redirect to avatar
        if (isAuthenticated && isNewUser && !isOnAvatarScreen) {
          return '${AppRoutes.categoriesRouteName}${AppRoutes.avatarRouteName}';
        }

        // No redirect needed
        return null;
      },
      routes: [
        // Auth route (outside hierarchy)
        GoRoute(
          path: AppRoutes.authRouteName,
          name: AuthScreen.routeName,
          builder: (context, state) => const AuthScreen(),
        ),

        // Categories is our base route with nested routes
        ShellRoute(
          navigatorKey: AppNavigatorKeys.shellNavigatorKey,
          builder: (context, state, child) {
            return child;
          },
          routes: [
            GoRoute(
              path: AppRoutes.categoriesRouteName,
              name: CategoriesScreen.routeName,
              builder: (context, state) => const CategoriesScreen(),
              routes: [
                // Intro route (nested under categories)
                GoRoute(
                  path: AppRoutes.triviaIntroRouteName,
                  name: TriviaIntroScreen.routeName,
                  builder: (context, state) => const TriviaIntroScreen(),
                ),
                // Avatar route (nested under categories)
                GoRoute(
                  path: AppRoutes.avatarRouteName,
                  name: AvatarScreen.routeName,
                  builder: (context, state) => const AvatarScreen(),
                ),

                // Profile route (nested under categories)
                GoRoute(
                  path: 'profile',
                  name: ProfileScreen.routeName,
                  builder: (context, state) => const ProfileScreen(),
                ),

                // Wheel spin route (nested under categories)
                GoRoute(
                  path: 'wheel-spin',
                  name: WheelSpinScreen.routeName,
                  builder: (context, state) => const WheelSpinScreen(),
                ),

                // Solo quiz route (nested under categories)
                GoRoute(
                  path: AppRoutes.soloQuizRouteName
                      .substring(1), // Remove leading slash
                  name: SoloQuizScreen.routeName,
                  builder: (context, state) => const SoloQuizScreen(),
                ),

                // Duel quiz route (nested under categories)
                GoRoute(
                  path: '${AppRoutes.duelQuizRouteName.substring(1)}/:roomId',
                  name: DuelQuizScreen.routeName,
                  builder: (context, state) {
                    final roomId = state.pathParameters['roomId']!;
                    return DuelQuizScreen(roomId: roomId);
                  },
                ),

                // Result route (nested under categories)
                GoRoute(
                  path: SoloResultsScreen.routeName,
                  name: SoloResultsScreen.routeName,
                  builder: (context, state) => const SoloResultsScreen(),
                ),
                GoRoute(
                  path: '${DuelResultsScreen.routeName}/:roomId',
                  name: DuelResultsScreen.routeName,
                  builder: (context, state) => DuelResultsScreen(
                    roomId: state.pathParameters['roomId']!,
                  ),
                ),
                GoRoute(
                  path: '/game-canceled',
                  name: GameCanceledScreen.routeName,
                  builder: (context, state) {
                    final extra = state.extra! as Map<String, dynamic>;
                    return GameCanceledScreen(
                      users: extra['users'],
                      userScores: extra['userScores'],
                      currentUserId: extra['currentUserId'],
                      opponentId: extra['opponentId'],
                    );
                  },
                ),
              ],
            ),
          ],
        ),
      ],
    );
  },
);
