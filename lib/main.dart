import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trivia/features/categories_screen/view_model/categories_screen_manager.dart';

import 'features/categories_screen/categories_screen.dart';

void main() {
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
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
    );
  }
}
