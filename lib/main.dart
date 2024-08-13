import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:trivia/common_widgets/customProgressIndicator.dart';
import 'package:trivia/features/profile_screen/profile_screen.dart';
import 'custom_route_observer.dart';
import 'features/auth_screen/auth_screen.dart';
import 'firebase_options.dart';

import 'package:trivia/features/avatar_screen/avatar_screen.dart';
import 'package:trivia/features/categories_screen/categories_screen.dart';
import 'package:trivia/features/quiz_screen/quiz_screen.dart';
import 'package:trivia/features/results_screen/results_screen.dart';
import 'package:trivia/service/user_provider.dart';
import 'package:trivia/utility/app_constant.dart';
import 'package:trivia/utility/color_utility.dart';
import 'package:trivia/utility/size_config.dart';

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

        // Check the user state
        final userState = ref.watch(userProvider).currentUser;

        // Determine the home screen
        Widget home;
        if (userState.uid == null || userState.autoLogin == false) {
          home = const AuthScreen();
        } else {
          home = const CategoriesScreen();
        }

        return MaterialApp(
          title: 'Flutter Demo',
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(
                seedColor: AppConstant.primaryColor.toColor()),
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
              case '/profile':
                page = ProfileScreen();
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
