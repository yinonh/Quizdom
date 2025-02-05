import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trivia/core/global_providers/connectivity_provider.dart';

import 'no_internet_screen.dart';

class ConnectivityWrapper extends ConsumerWidget {
  final Widget child;

  const ConnectivityWrapper({super.key, required this.child});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Listen to connectivity state
    final isConnected = ref.watch(connectivityProvider);

    if (!isConnected) {
      // If no internet, always show NoInternetScreen
      return const MaterialApp(
        title: 'No Internet',
        home: NoInternetScreen(),
      );
    }

    return child;
  }
}
