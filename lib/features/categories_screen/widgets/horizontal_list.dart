import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trivia/features/categories_screen/view_model/categories_screen_manager.dart';
import 'package:trivia/features/quiz_screen/quiz_screen.dart';
import 'package:trivia/models/trivia_categories.dart';

class HorizontalList extends ConsumerWidget {
  final List<TriviaCategory>? categories;

  const HorizontalList({
    Key? key,
    required this.categories,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categoriesNotifier =
        ref.read(categoriesScreenManagerProvider.notifier);
    final backgroundColor = Theme.of(context).scaffoldBackgroundColor;

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Wrap(
        spacing: 8.0,
        runSpacing: 8.0,
        children: List.generate(
          (categories?.length ?? 0).clamp(0, 4), // Limit to 4 items
          (index) {
            final category = categories![index];
            return GestureDetector(
              onTap: () {
                categoriesNotifier.setCategory(category.id!);
                categoriesNotifier.resetAchievements();
                Navigator.pushNamed(context, QuizScreen.routeName);
              },
              child: Container(
                width: (MediaQuery.of(context).size.width - 32) / 2 - 8,
                height: 50,
                margin: const EdgeInsets.symmetric(horizontal: 4.0),
                padding: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  color: backgroundColor,
                  borderRadius: BorderRadius.circular(8.0),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      spreadRadius: 1,
                      blurRadius: 5,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.category,
                        size: 20.0,
                      ),
                      const SizedBox(
                        width: 8.0,
                      ),
                      FittedBox(
                        fit: BoxFit.fitWidth,
                        child: Text(
                          category.name!.toUpperCase(),
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
