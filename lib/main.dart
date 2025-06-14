import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:trivia/features/no_internet_screen/connectivity_wrapper.dart';
import 'core/global_providers/ad_provider.dart';
import 'firebase_options.dart';
import 'app.dart';

void main() async {
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);

  // Initialize Firebase first
  await Firebase.initializeApp(
    name: "app",
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Initialize AdMob
  try {
    await AdService.instance.initialize();
    if (kDebugMode) {
      print('AdMob initialized successfully in main');
    }
  } catch (e) {
    if (kDebugMode) {
      print('Failed to initialize AdMob in main: $e');
    }
  }

  // Set preferred orientations
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Configure and activate Firebase App Check
  try {
    if (kDebugMode) {
      // Debug mode - use debug providers and enable debug logging
      await FirebaseAppCheck.instance.activate(
        androidProvider: AndroidProvider.debug,
      );
      print('Firebase App Check activated in DEBUG mode');
    } else {
      // Production mode
      await FirebaseAppCheck.instance.activate(
        androidProvider: AndroidProvider.playIntegrity,
      );
      print('Firebase App Check activated in PRODUCTION mode');
    }
  } catch (e) {
    print('Failed to activate Firebase App Check: $e');
  }

  // Remove splash screen after initialization
  FlutterNativeSplash.remove();

  // Run the app
  runApp(
    const ProviderScope(
      child: ConnectivityWrapper(child: MyApp()),
    ),
  );
}
