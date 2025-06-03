import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:trivia/features/categories_screen/widgets/daily_login-popup.dart';
import 'package:trivia/features/wheel_spin_screen/widgets/lose_dialog.dart';
import 'package:trivia/features/wheel_spin_screen/widgets/win_dialog.dart';

import 'custom_route_by_name.dart';

final popupRoutesProvider = Provider(
  (ref) => [
    // Daily Login Popup route (nested under categories)
    GoRoute(
      path: DailyLoginScreen.routeName,
      name: DailyLoginScreen.routeName,
      pageBuilder: (context, state) {
        final extra = state.extra! as Map<String, dynamic>;
        return CustomRouteByName.buildDialogTransition(
          key: state.pageKey,
          child: DailyLoginScreen(
            streakDays: extra['streakDays'],
            startDay: extra['startDay'],
            rewards: extra['rewards'],
            onClaim: extra['onClaim'],
          ),
        );
      },
    ),
  ],
);

// Wheel spin popup routes - these should be nested under wheel spin route
final wheelSpinPopupRoutesProvider = Provider(
  (ref) => [
    // Win dialog from the wheel
    GoRoute(
      path: WinDialogScreen.routeName,
      name: WinDialogScreen.routeName,
      pageBuilder: (context, state) {
        final extra = state.extra! as Map<String, dynamic>;
        return CustomRouteByName.buildDialogTransition(
          key: state.pageKey,
          child: WinDialogScreen(coins: extra['coins']),
        );
      },
    ),

    GoRoute(
      path: LoseDialogScreen.routeName,
      name: LoseDialogScreen.routeName,
      pageBuilder: (context, state) {
        return CustomRouteByName.buildDialogTransition(
          key: state.pageKey,
          child: const LoseDialogScreen(),
        );
      },
    ),
  ],
);
