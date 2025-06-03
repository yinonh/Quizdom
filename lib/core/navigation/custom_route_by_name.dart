import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class CustomRouteByName extends GoRoute {
  static const Duration transitionDuration = Duration(milliseconds: 300);

  CustomRouteByName(
    String path, {
    required Widget Function(BuildContext, GoRouterState) super.builder,
    String? name,
    super.routes,
    super.redirect,
    super.parentNavigatorKey,
    super.onExit,
  }) : super(
            path: path,
            name: name ?? path,
            pageBuilder: (context, state) {
              return MaterialPage(
                key: state.pageKey,
                child: builder(context, state),
              );
            });

  // Dialog transition builder for popup-style routes
  static CustomTransitionPage<T> buildDialogTransition<T>({
    required Widget child,
    required LocalKey key,
    Duration transitionDuration = const Duration(milliseconds: 300),
    Duration reverseTransitionDuration = const Duration(milliseconds: 300),
    bool barrierDismissible = true,
    Color barrierColor = Colors.black54,
  }) =>
      CustomTransitionPage<T>(
        key: key,
        child: child,
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(
            opacity: animation,
            child: child,
          );
        },
        transitionDuration: transitionDuration,
        reverseTransitionDuration: reverseTransitionDuration,
        opaque: false,
        barrierDismissible: barrierDismissible,
        barrierColor: barrierColor,
      );
}

class CustomRouteByNameWithId extends CustomRouteByName {
  CustomRouteByNameWithId(
    super.path, {
    required String id,
    required Widget Function(BuildContext, GoRouterState, String) builder,
    super.name,
    super.routes,
    super.redirect,
    super.parentNavigatorKey,
    super.onExit,
  }) : super(
          builder: (context, state) {
            if (state.pathParameters[id] == null) {
              // Return a not found screen or handle the error
              return const Scaffold(
                body: Center(child: Text('Route parameter not found')),
              );
            }
            final pathId = state.pathParameters[id]!;
            return builder(context, state, pathId);
          },
        );
}
