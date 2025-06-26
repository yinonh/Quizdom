import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:Quizdom/core/navigation/router_service.dart';

// Get router contexts
BuildContext get _routerContext =>
    AppNavigatorKeys.navigatorKey.currentContext!;
BuildContext get _routerShellContext =>
    AppNavigatorKeys.shellNavigatorKey.currentContext!;

// Navigation methods
void goRoute(
  String route, {
  Map<String, String> pathParameters = const <String, String>{},
  Map<String, dynamic> queryParameters = const <String, dynamic>{},
  Object? extra,
}) {
  GoRouter.of(_routerContext).goNamed(
    route,
    pathParameters: pathParameters,
    queryParameters: queryParameters,
    extra: extra,
  );
  RouterService.updateCurrentMainRoute();
}

Future<T?> pushRoute<T extends Object?>(
  String route, {
  Map<String, String> pathParameters = const <String, String>{},
  Map<String, dynamic> queryParameters = const <String, dynamic>{},
  Object? extra,
}) {
  RouterService.updateCurrentMainRoute();

  final Future<T?> result = GoRouter.of(_routerContext).pushNamed(
    route,
    pathParameters: pathParameters,
    queryParameters: queryParameters,
    extra: extra,
  );

  RouterService.previousRoute = GoRouter.of(_routerContext).state.name;
  return result;
}

void replaceNamed(
  String route, {
  Map<String, String> pathParameters = const <String, String>{},
  Map<String, dynamic> queryParameters = const <String, dynamic>{},
  Object? extra,
}) {
  RouterService.updateCurrentMainRoute();
  GoRouter.of(_routerContext).replaceNamed(
    route,
    pathParameters: pathParameters,
    queryParameters: queryParameters,
    extra: extra,
  );
}

void pop<T extends Object?>([T? result]) {
  if (GoRouter.of(_routerShellContext).canPop()) {
    GoRouter.of(_routerShellContext).pop(result);
  }
}

bool canPop() => GoRouter.of(_routerContext).canPop();

void popAll() {
  while (canPop()) {
    pop();
  }
}
