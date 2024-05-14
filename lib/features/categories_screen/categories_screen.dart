import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:trivia/features/categories_screen/view_model/categories_screen_manager.dart';

class CategoriesScreen extends ConsumerWidget {
  static const routName = "/categories_screen";
  const CategoriesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categoriesState = ref.watch(categoriesScreenManagerProvider);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Center(
          child: Text(
            "Categories",
            textAlign: TextAlign.center,
          ),
        ),
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
                    print(data.categories.triviaCategories![index].name);
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
