import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';

import 'package:trivia/features/categories_screen/view_model/categories_screen_manager.dart';
import 'package:trivia/features/quiz_screen/quiz_screen.dart';
import 'package:trivia/fluttermoji/fluttermojiFunctions.dart';

class CategoriesScreen extends ConsumerWidget {
  static const routeName = "/categories_screen";
  const CategoriesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categoriesState = ref.watch(categoriesScreenManagerProvider);
    final categoriesNotifier =
        ref.read(categoriesScreenManagerProvider.notifier);
    return Scaffold(
      // appBar: const CustomAppBar(
      //   title: 'Categories',
      // ),
      appBar: AppBar(
        title: const Text("hello"),
        leading: FutureBuilder<String?>(
          future: categoriesNotifier.fetchAvatar(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return const Center(child: Text('Error fetching avatar'));
            } else if (!snapshot.hasData || snapshot.data == null) {
              return const Center(child: Text('No avatar found'));
            } else {
              final avatarSvg = snapshot.data!;
              return Center(
                child: SvgPicture.string(
                  FluttermojiFunctions().decodeFluttermojifromString(avatarSvg),
                ),
              );
            }
          },
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
                    categoriesNotifier.setCategory(
                        data.categories.triviaCategories![index].id!);
                    categoriesNotifier.resetAchievements();
                    Navigator.pushNamed(context, QuizScreen.routeName);
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
