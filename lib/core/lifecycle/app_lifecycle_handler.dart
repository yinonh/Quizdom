import 'package:flutter/widgets.dart';
import 'app_lifecycle_observer.dart';

// Singleton to track active user sessions and handle app lifecycle
class AppLifecycleHandler {
  static final AppLifecycleHandler _instance = AppLifecycleHandler._internal();
  factory AppLifecycleHandler() => _instance;
  AppLifecycleHandler._internal();

  final _activeUserIds = <String>{};
  bool _isInitialized = false;

  void initialize() {
    if (!_isInitialized) {
      WidgetsBinding.instance.addObserver(AppLifecycleObserver());
      _isInitialized = true;
    }
  }

  void registerUserId(String userId) {
    _activeUserIds.add(userId);
  }

  void unregisterUserId(String userId) {
    _activeUserIds.remove(userId);
  }

  Set<String> get activeUserIds => _activeUserIds;
}
