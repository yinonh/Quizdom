import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trivia/service/trivia_provider.dart';

class CustomRouteObserver extends RouteObserver<PageRoute> {
  WidgetRef ref;

  CustomRouteObserver({required this.ref});

  @override
  void didPush(Route route, Route? previousRoute) {
    if (route.settings.name == "/") {
      ref.read(triviaProvider.notifier).setToken();
    }
    super.didPush(route, previousRoute);
  }
}
