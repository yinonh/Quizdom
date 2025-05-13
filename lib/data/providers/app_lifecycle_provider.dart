import 'package:flutter/widgets.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'app_lifecycle_provider.g.dart';

enum AppLifecycleStatus {
  resumed, // App is visible and responding to user input
  inactive, // App is in an inactive state and not receiving user input
  paused, // App is not visible to the user, running in the background
  detached, // App is in a suspended state
}

@riverpod
class AppLifecycleNotifier extends _$AppLifecycleNotifier
    with WidgetsBindingObserver {
  @override
  AppLifecycleStatus build() {
    // Register observer when the provider is first initialized
    WidgetsBinding.instance.addObserver(this);

    // Clean up when the provider is disposed
    ref.onDispose(() {
      WidgetsBinding.instance.removeObserver(this);
    });

    // Initial state is resumed (app is active)
    return AppLifecycleStatus.resumed;
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.resumed:
        this.state = AppLifecycleStatus.resumed;
        break;
      case AppLifecycleState.inactive:
        this.state = AppLifecycleStatus.inactive;
        break;
      case AppLifecycleState.paused:
        this.state = AppLifecycleStatus.paused;
        break;
      case AppLifecycleState.detached:
        this.state = AppLifecycleStatus.detached;
        break;
      default:
        break;
    }
  }
}
