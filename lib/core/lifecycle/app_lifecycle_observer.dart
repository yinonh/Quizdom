import 'dart:ui';
import 'package:flutter/widgets.dart';
import 'package:trivia/data/data_source/user_preference_data_source.dart';
import 'app_lifecycle_handler.dart';

class AppLifecycleObserver extends WidgetsBindingObserver {
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final activeUserIds = AppLifecycleHandler().activeUserIds.toList();

    if (state == AppLifecycleState.detached ||
        state == AppLifecycleState.paused) {
      // When app is closing or going to background, clean up all active sessions
      for (final userId in activeUserIds) {
        UserPreferenceDataSource.cleanupUserPreference(userId);
      }
    } else if (state == AppLifecycleState.resumed) {
      // When app is resumed from background, recreate user preferences
      for (final userId in activeUserIds) {
        UserPreferenceDataSource.recreateUserPreference(userId);
      }
    }
  }
}
