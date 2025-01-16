import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/common_widgets/custom_progress_indicator.dart';
import 'core/constants/app_constant.dart';
import 'core/global_providers/connectivity_provider.dart';
import 'core/utils/size_config.dart';
import 'data/service/app_initialization_provider.dart';
import 'features/auth_screen/auth_screen.dart';
import 'features/avatar_screen/avatar_screen.dart';
import 'features/categories_screen/categories_screen.dart';
import 'features/no_internet_screen/no_internet_screen.dart';
import 'features/profile_screen/profile_screen.dart';
import 'features/quiz_screen/quiz_screen.dart';
import 'features/results_screen/results_screen.dart';
import 'features/trivia_intro_screen/intro_screen.dart';

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

    // Watch initialization state using the updated providers
    final initialization = ref.watch(appInitializationProvider);
    final authState = ref.watch(authStateChangesProvider);

    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppConstant.primaryColor,
        ),
        useMaterial3: true,
      ),
      home: initialization.when(
        data: (_) => authState.when(
          data: (user) =>
              user == null ? const AuthScreen() : const CategoriesScreen(),
          loading: () => const Scaffold(
            body: Center(child: CustomProgressIndicator()),
          ),
          error: (_, __) => const AuthScreen(),
        ),
        loading: () => const Scaffold(
          body: Center(child: CustomProgressIndicator()),
        ),
        error: (error, stack) => Scaffold(
          body: Center(
            child: Text('Error: $error'),
          ),
        ),
      ),
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
          builder: (context) => page,
          settings: settings,
        );
      },
    );
  }
}
