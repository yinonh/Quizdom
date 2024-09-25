import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final connectivityProvider =
    StateNotifierProvider<ConnectivityNotifier, bool>((ref) {
  return ConnectivityNotifier();
});

class ConnectivityNotifier extends StateNotifier<bool> {
  ConnectivityNotifier() : super(true) {
    _initConnectivity();
  }

  void _initConnectivity() {
    Connectivity()
        .onConnectivityChanged
        .listen((List<ConnectivityResult> result) {
      if (result.contains(ConnectivityResult.none)) {
        state = false; // No internet
      } else {
        state = true; // Has internet
      }
    });
  }
}
