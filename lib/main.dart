import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trivia/features/quiz_screen/quiz_screen.dart';
import 'package:trivia/features/quiz_screen/widgets/question_widget.dart';

import 'custom_route_observer.dart';
import 'features/categories_screen/categories_screen.dart';

void main() {
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
        useMaterial3: true,
      ),
      home: const CategoriesScreen(),
      onGenerateRoute: (settings) {
        Widget page;
        switch (settings.name) {
          case CategoriesScreen.routName:
            page = const CategoriesScreen();
            break;
          case QuizScreen.routName:
            page = const QuizScreen();
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
  }
}
