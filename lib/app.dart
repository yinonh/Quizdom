import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trivia/core/global_providers/connectivity_provider.dart';
import 'package:trivia/data/service/general_trivia_room_provider.dart';
import 'package:trivia/data/service/user_provider.dart';
import 'package:trivia/data/service/user_statistics_provider.dart';
import 'package:trivia/features/trivia_intro_screen/intro_screen.dart';

import 'core/common_widgets/custom_progress_indicator.dart';
import 'core/constants/app_constant.dart';
import 'core/utils/size_config.dart';
import 'data/service/current_trivia_achievements_provider.dart';
import 'features/auth_screen/auth_screen.dart';
import 'features/avatar_screen/avatar_screen.dart';
import 'features/categories_screen/categories_screen.dart';
import 'features/no_internet_screen/no_internet_screen.dart';
import 'features/profile_screen/profile_screen.dart';
import 'features/quiz_screen/quiz_screen.dart';
import 'features/results_screen/results_screen.dart';

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    SizeConfig().init(context);

    Future<void> startAppInitialization() async {
      await ref
          .read(generalTriviaRoomsProvider.notifier)
          .initializeGeneralTriviaRoom();
      await ref.read(authProvider.notifier).initializeUser();
      await ref.read(statisticsProvider.notifier).initializeUserStatistics();
      ref.read(currentTriviaAchievementsProvider);
    }

    // Listen to connectivity state
    final isConnected = ref.watch(connectivityProvider);

    if (!isConnected) {
      return const MaterialApp(
        title: 'No Internet',
        home: NoInternetScreen(),
      );
    }

    return FutureBuilder(
      future: startAppInitialization(),
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
              seedColor: AppConstant.primaryColor,
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
              case TriviaIntroScreen.routeName:
                page = const TriviaIntroScreen();
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
          // navigatorObservers: [CustomRouteObserver(ref: ref)],
        );
      },
    );
  }
}
