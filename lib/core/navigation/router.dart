import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:trivia/core/common_widgets/ad_interstitial_widget.dart';
import 'package:trivia/core/common_widgets/ad_rewarded_widget.dart';
import 'package:trivia/core/constants/app_routes.dart';
import 'package:trivia/core/navigation/router_service.dart';
import 'package:trivia/core/navigation/routes_popup.dart';
import 'package:trivia/core/navigation/routes_quiz.dart';
import 'package:trivia/data/providers/app_initialization_provider.dart';
import 'package:trivia/features/auth_screen/auth_screen.dart';
import 'package:trivia/features/avatar_screen/avatar_screen.dart';
import 'package:trivia/features/categories_screen/categories_screen.dart';
import 'package:trivia/features/intro_screen/intro_screen.dart';
import 'package:trivia/features/intro_screen/widgets/filter_room.dart';
import 'package:trivia/features/profile_screen/profile_screen.dart';
import 'package:trivia/features/wheel_spin_screen/wheel_spin_screen.dart';

import 'custom_route_by_name.dart';
import 'new_user_registration_provider.dart';

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

        // Authentication logic
        if (!isAuthenticated && !isLoggingIn) {
          return AppRoutes.authRouteName;
        }

        if (isAuthenticated && isLoggingIn) {
          if (isNewUser) {
            return '${AppRoutes.categoriesRouteName}${AppRoutes.avatarRouteName}';
          }
          return AppRoutes.categoriesRouteName;
        }

        if (isAuthenticated && isNewUser && !isOnAvatarScreen) {
          return '${AppRoutes.categoriesRouteName}${AppRoutes.avatarRouteName}';
        }

        return null;
      },
      routes: [
        // Auth route (outside hierarchy)
        CustomRouteByName(
          AppRoutes.authRouteName,
          name: AuthScreen.routeName,
          builder: (context, state) => const AuthScreen(),
        ),

        // Main shell route
        ShellRoute(
          navigatorKey: AppNavigatorKeys.shellNavigatorKey,
          builder: (context, state, child) => child,
          routes: [
            // Categories route with all nested routes
            CustomRouteByName(
              AppRoutes.categoriesRouteName,
              name: CategoriesScreen.routeName,
              builder: (context, state) => const CategoriesScreen(),
              routes: [
                // Popup routes
                ...ref.read(popupRoutesProvider),

                // Regular nested routes
                CustomRouteByName(AppRoutes.triviaIntroRouteName,
                    name: TriviaIntroScreen.routeName,
                    builder: (context, state) => const TriviaIntroScreen(),
                    routes: [
                      GoRoute(
                        path: RoomFilterScreen.routeName,
                        name: RoomFilterScreen.routeName,
                        pageBuilder: (context, state) {
                          return CustomRouteByName.buildDialogTransition(
                            key: state.pageKey,
                            child: const RoomFilterScreen(),
                          );
                        },
                      ),
                    ]),

                CustomRouteByName(
                  AppRoutes.avatarRouteName,
                  name: AvatarScreen.routeName,
                  builder: (context, state) => const AvatarScreen(),
                ),

                CustomRouteByName(
                  ProfileScreen.routeName,
                  name: ProfileScreen.routeName,
                  builder: (context, state) => const ProfileScreen(),
                ),

                CustomRouteByName(
                  WheelSpinScreen.routeName,
                  name: WheelSpinScreen.routeName,
                  builder: (context, state) => const WheelSpinScreen(),
                  routes: [
                    // Wheel spin popup routes nested here
                    ...ref.read(wheelSpinPopupRoutesProvider),
                  ],
                ),

                // Quiz routes
                ...ref.read(quizRoutesProvider),
              ],
            ),
          ],
        ),
        GoRoute(
          path: InterstitialAdWidget.routeName,
          name: InterstitialAdWidget.routeName,
          pageBuilder: (context, state) {
            final extra = state.extra as Map<String, dynamic>?;

            return CustomRouteByName.buildDialogTransition(
              key: state.pageKey,
              child: InterstitialAdWidget(
                onComplete: extra?['onComplete'] ?? () {},
                onSkip: extra?['onSkip'],
              ),
            );
          },
        ),

// Updated router configuration for RewardedAdWidget
        GoRoute(
          path: RewardedAdWidget.routeName,
          name: RewardedAdWidget.routeName,
          pageBuilder: (context, state) {
            final extra = state.extra as Map<String, dynamic>?;

            return CustomRouteByName.buildDialogTransition(
              key: state.pageKey,
              child: RewardedAdWidget(
                onRewardEarned: extra?['onRewardEarned'] ?? (reward) {},
                onComplete: extra?['onComplete'] ?? () {},
                onSkip: extra?['onSkip'],
              ),
            );
          },
        ),
      ],
    );
  },
);
