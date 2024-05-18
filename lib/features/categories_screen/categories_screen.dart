import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trivia/common_widgets/app_bar.dart';

import 'package:trivia/features/categories_screen/view_model/categories_screen_manager.dart';
import 'package:trivia/features/quiz_screen/quiz_screen.dart';

class CategoriesScreen extends ConsumerWidget {
  static const routName = "/categories_screen";
  const CategoriesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categoriesState = ref.watch(categoriesScreenManagerProvider);
    final categoriesNotifier =
        ref.read(categoriesScreenManagerProvider.notifier);
    return Scaffold(
      appBar: const CustomAppBar(
        title: 'Categories',
      ),
      body: Center(
        child: categoriesState.when(data: (data) {
          return ListView.builder(
              itemCount: data.categories.triviaCategories?.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(data.categories.triviaCategories![index].name!),
                  trailing: const Icon(Icons.arrow_forward_ios_rounded),
                  onTap: () {
                    categoriesNotifier.setCategory(
                        data.categories.triviaCategories![index].id!);
                    Navigator.pushNamed(context, QuizScreen.routName);
                  },
                );
              });
        }, error: (error, _) {
          return Text(error.toString());
        }, loading: () {
          return const CircularProgressIndicator();
        }),
      ),
    );
  }
}
