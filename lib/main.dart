import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_app_check/firebase_app_check.dart';

import 'package:trivia/common_widgets/customProgressIndicator.dart';
import 'package:trivia/features/avatar_screen/avatar_screen.dart';
import 'package:trivia/features/categories_screen/categories_screen.dart';
import 'package:trivia/features/profile_screen/profile_screen.dart';
import 'package:trivia/features/quiz_screen/quiz_screen.dart';
import 'package:trivia/features/results_screen/results_screen.dart';
import 'package:trivia/service/connectivity_provider.dart';
import 'package:trivia/service/user_provider.dart';
import 'package:trivia/utility/app_constant.dart';
import 'package:trivia/utility/color_utility.dart';
import 'package:trivia/utility/size_config.dart';

import 'custom_route_observer.dart';
import 'features/auth_screen/auth_screen.dart';
import 'features/no_internet_screen/no_internet_screen.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  try {
    if (!kDebugMode) {
      await FirebaseAppCheck.instance.activate(
        androidProvider: AndroidProvider.playIntegrity,
        appleProvider: AppleProvider.appAttest,
        webProvider: ReCaptchaV3Provider('recaptcha-v3-site-key'),
      );
    } else {
      await FirebaseAppCheck.instance.activate(
        androidProvider: AndroidProvider.debug,
        appleProvider: AppleProvider.debug,
      );
    }
    print('Firebase App Check activated successfully');
  } catch (e) {
    print('Failed to activate Firebase App Check: $e');
  }

  FlutterNativeSplash.remove();

  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    SizeConfig().init(context);

    // Listen to connectivity state
    final isConnected = ref.watch(connectivityProvider);

    if (!isConnected) {
      return const MaterialApp(
        title: 'No Internet',
        home: NoInternetScreen(),
      );
    }

    return FutureBuilder(
      future: ref.read(userProvider.notifier).initializeUser(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const MaterialApp(
            home: Scaffold(
              body: Center(child: CustomProgressIndicator()),
            ),
          );
        }

        // Check Firebase Auth user state
        final user = FirebaseAuth.instance.currentUser;

        // Determine the home screen
        Widget home;
        if (user == null) {
          home = const AuthScreen();
        } else {
          home = const CategoriesScreen();
        }

        return MaterialApp(
          title: 'Flutter Demo',
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(
              seedColor: AppConstant.primaryColor.toColor(),
            ),
            useMaterial3: true,
          ),
          home: home,
          onGenerateRoute: (settings) {
            Widget page;
            switch (settings.name) {
              case AvatarScreen.routeName:
                page = const AvatarScreen();
                break;
              case CategoriesScreen.routeName:
                page = const CategoriesScreen();
                break;
              case QuizScreen.routeName:
                page = const QuizScreen();
                break;
              case ResultsScreen.routeName:
                page = const ResultsScreen();
                break;
              case AuthScreen.routeName:
                page = const AuthScreen();
                break;
              case ProfileScreen.routeName:
                page = const ProfileScreen();
                break;
              default:
                page = const SizedBox();
            }

            return MaterialPageRoute<Widget>(
              builder: (context) {
                return page;
              },
              settings: settings,
            );
          },
          navigatorObservers: [CustomRouteObserver(ref: ref)],
        );
      },
    );
  }
}
