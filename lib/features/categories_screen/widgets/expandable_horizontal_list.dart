import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:trivia/features/categories_screen/view_model/categories_screen_manager.dart';
import 'package:trivia/features/quiz_screen/quiz_screen.dart';
import 'package:trivia/models/trivia_categories.dart';
import 'package:trivia/utility/app_constant.dart';

class ExpandableHorizontalList extends ConsumerStatefulWidget {
  final List<TriviaCategory>? categories;
  final String title;

  const ExpandableHorizontalList({
    super.key,
    required this.categories,
    required this.title,
  });

  @override
  _ExpandableHorizontalListState createState() =>
      _ExpandableHorizontalListState();
}

class _ExpandableHorizontalListState
    extends ConsumerState<ExpandableHorizontalList> {
  bool isExpanded = false;

  void toggleExpand() {
    setState(() {
      isExpanded = !isExpanded;
    });
  }

  // Function to clean up category names
  String cleanCategoryName(String name) {
    return name.replaceAll(RegExp(r'^(Entertainment: |Science: )'), '').trim();
  }

  @override
  Widget build(BuildContext context) {
    final categoriesNotifier =
        ref.read(categoriesScreenManagerProvider.notifier);
    final backgroundColor = Theme.of(context).scaffoldBackgroundColor;
    final categories = widget.categories ?? [];

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                widget.title,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              IconButton(
                icon: Icon(
                  isExpanded
                      ? Icons.keyboard_arrow_up_rounded
                      : Icons.keyboard_arrow_down_rounded,
                ),
                onPressed: toggleExpand,
              ),
            ],
          ),
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            height: isExpanded ? 250.0 : 160.0,
            child: SingleChildScrollView(
              physics: isExpanded
                  ? const AlwaysScrollableScrollPhysics()
                  : const NeverScrollableScrollPhysics(),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                child: Wrap(
                  spacing: 8.0,
                  runSpacing: 8.0,
                  children: categories
                      .take(isExpanded ? categories.length : 4)
                      .map((category) {
                    return GestureDetector(
                      onTap: () {
                        categoriesNotifier.setCategory(category.id!);
                        categoriesNotifier.resetAchievements();
                        Navigator.pushNamed(context, QuizScreen.routeName);
                      },
                      child: Container(
                        width: 150,
                        height: 70,
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
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.grey.withOpacity(0.2),
                                    spreadRadius: 0.01,
                                    blurRadius: 5,
                                    offset: const Offset(0, 1),
                                  ),
                                ],
                              ),
                              child: Icon(
                                AppConstant.categoryIcons[category.id] ??
                                    Icons.category,
                                color:
                                    AppConstant.categoryColors[category.id] ??
                                        Colors.black,
                                size: 20.0,
                              ),
                            ),
                            const SizedBox(width: 8.0),
                            Expanded(
                              child: Text(
                                cleanCategoryName(category.name!).toUpperCase(),
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                                textAlign: TextAlign.start,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
