import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:trivia/data/trivia_api_provider.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categories = ref.watch(triviaApiProvider);
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
        child: categories.when(data: (data) {
          return ListView.builder(
              itemCount: data.triviaCategories?.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(data.triviaCategories![index].name!),
                  trailing: Icon(Icons.arrow_forward_ios_rounded),
                  onTap: () {
                    print(data.triviaCategories![index].name);
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
