import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'core/constants/app_routes.dart';
import 'data/providers/app_initialization_provider.dart';
import 'features/auth_screen/auth_screen.dart';
import 'features/avatar_screen/avatar_screen.dart';
import 'features/categories_screen/categories_screen.dart';
import 'features/intro_screen/intro_screen.dart';
import 'features/no_internet_screen/connectivity_wrapper.dart';
import 'features/profile_screen/profile_screen.dart';
import 'features/quiz_screen/duel_quiz_screen.dart';
import 'features/quiz_screen/solo_quiz_screen.dart';
import 'features/results_screen/results_screen.dart';
import 'features/wheel_spin_screen/wheel_spin_screen.dart';

class AppNavigatorKeys {
  static final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>();
  static final GlobalKey<NavigatorState> shellNavigatorKey =
      GlobalKey<NavigatorState>();
}

// Router provider
final routerProvider = Provider<GoRouter>(
  (ref) {
    final authState = ref.watch(authStateChangesProvider);

    return GoRouter(
      navigatorKey: AppNavigatorKeys.navigatorKey,
      // Use your existing navigatorKey
      initialLocation: AppRoutes.categoriesRouteName,
      debugLogDiagnostics: true,
      redirect: (context, state) {
        // Check if the user is authenticated
        final isAuthenticated = authState.value != null;
        final isLoggingIn = state.matchedLocation == AppRoutes.authRouteName;

        // If not authenticated and not on the auth page, redirect to auth
        if (!isAuthenticated && !isLoggingIn) {
          return AppRoutes.authRouteName;
        }

        // If authenticated and on the auth page, redirect to categories
        if (isAuthenticated && isLoggingIn) {
          return AppRoutes.categoriesRouteName;
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
            return ConnectivityWrapper(child: child);
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
                  path: 'avatar',
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
                  path: ResultsScreen.routeName,
                  name: ResultsScreen.routeName,
                  builder: (context, state) => const ResultsScreen(),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  },
);
