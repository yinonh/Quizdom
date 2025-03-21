import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/common_widgets/custom_progress_indicator.dart';
import 'core/constants/app_constant.dart';
import 'core/utils/size_config.dart';
import 'data/providers/app_initialization_provider.dart';
import 'features/auth_screen/auth_screen.dart';
import 'features/avatar_screen/avatar_screen.dart';
import 'features/categories_screen/categories_screen.dart';
import 'features/intro_screen/intro_screen.dart';
import 'features/no_internet_screen/connectivity_wrapper.dart';
import 'features/profile_screen/profile_screen.dart';
import 'features/quiz_screen/duel_quiz_screen.dart';
import 'features/quiz_screen/solo_quiz_screen.dart';
import 'features/results_screen/results_screen.dart';
import 'features/wheel_spin_screen/wheel_spin_screen.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    SizeConfig().init(context);
    // Watch initialization state using the updated providers
    final initialization = ref.watch(appInitializationProvider);
    final authState = ref.watch(authStateChangesProvider);

    return MaterialApp(
      title: 'Flutter Demo',
      navigatorKey: navigatorKey,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppConstant.primaryColor,
        ),
        useMaterial3: true,
      ),
      builder: (context, child) {
        return ConnectivityWrapper(
          child: child!,
        );
      },
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
          case SoloQuizScreen.routeName:
            page = const SoloQuizScreen();
            break;
          case DuelQuizScreen.routeName:
            page = const DuelQuizScreen();
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
          case WheelSpinScreen.routeName:
            page = const WheelSpinScreen();
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
