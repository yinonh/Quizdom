import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class AppNavigatorKeys {
  static final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>();
  static final GlobalKey<NavigatorState> shellNavigatorKey =
      GlobalKey<NavigatorState>();
}

class RouterService {
  final GoRouter router;
  final Ref ref;
  static String? currentMainRoute;
  static String? previousRoute;

  RouterService(
    this.ref, {
    required this.router,
  });

  static bool isAtThatRoute(String route) =>
      route ==
      GoRouter.of(AppNavigatorKeys.navigatorKey.currentContext!).state.name;

  static void clearPreviousRoute() => previousRoute = null;

  static String? updateCurrentMainRoute() {
    final route = GoRouter.of(AppNavigatorKeys.navigatorKey.currentContext!);
    final routeValue = route.routeInformationProvider.value;

    final List<String> routeNameNoSlashList =
        routeValue.uri.toString().split("/");

    final String? routeNameNoSlash = routeNameNoSlashList
        .firstWhere((str) => str.isNotEmpty, orElse: () => '');

    if (routeNameNoSlash?.isNotEmpty == true) {
      RouterService.currentMainRoute = "/$routeNameNoSlash";
    }

    return RouterService.currentMainRoute;
  }

  static String? get fullRoutePath {
    if (AppNavigatorKeys.shellNavigatorKey.currentState?.context == null) {
      return null;
    }

    final routeState =
        GoRouter.of(AppNavigatorKeys.shellNavigatorKey.currentState!.context)
            .state;

    return routeState.fullPath;
  }

  static int get numberOfRoutesInPath {
    if (fullRoutePath == null) {
      return 0;
    }

    if (fullRoutePath == '/') {
      return 1;
    }

    final segments =
        fullRoutePath!.split('/').where((segment) => segment.isNotEmpty);
    return segments.length;
  }
}
