import 'package:flutter/material.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trivia/core/constants/app_constant.dart';
import 'package:trivia/core/utils/size_config.dart';
import 'package:trivia/data/models/general_trivia_room.dart';
import 'package:trivia/features/categories_screen/view_model/categories_screen_manager.dart';
import 'package:trivia/features/trivia_intro_screen/intro_screen.dart';

class ExpandableHorizontalList extends ConsumerStatefulWidget {
  final List<GeneralTriviaRoom>? triviaRoom;
  final String title;

  const ExpandableHorizontalList({
    super.key,
    required this.triviaRoom,
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

  @override
  Widget build(BuildContext context) {
    final categoriesNotifier =
        ref.read(categoriesScreenManagerProvider.notifier);
    final backgroundColor = Theme.of(context).scaffoldBackgroundColor;
    final categoriesTriviaRoom = widget.triviaRoom ?? [];

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Text(
                widget.title,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
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
          height: isExpanded ? calcHeight(250) : calcHeight(160),
          child: SingleChildScrollView(
            physics: isExpanded
                ? const AlwaysScrollableScrollPhysics()
                : const NeverScrollableScrollPhysics(),
            child: Padding(
              padding: EdgeInsets.symmetric(
                vertical: calcHeight(8),
                horizontal: calcWidth(8),
              ),
              child: Wrap(
                spacing: calcWidth(8),
                runSpacing: calcWidth(8),
                children: categoriesTriviaRoom
                    .take(isExpanded ? categoriesTriviaRoom.length : 4)
                    .map((category) {
                  return GestureDetector(
                    onTap: () {
                      categoriesNotifier.setTriviaRoom(category.roomId!);
                      Navigator.pushNamed(context, TriviaIntroScreen.routeName);
                    },
                    child: Container(
                      width: (MediaQuery.of(context).size.width * 0.9) / 2,
                      height: calcHeight(80),
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
                              AppConstant.categoryIcons[category.categoryId] ??
                                  Icons.category,
                              color: AppConstant
                                      .categoryColors[category.categoryId] ??
                                  Colors.black,
                              size: calcWidth(20),
                            ),
                          ),
                          const SizedBox(width: 8.0),
                          Expanded(
                            child: AutoSizeText(
                              categoriesNotifier
                                  .cleanCategoryName(category.categoryName)
                                  .toUpperCase(),
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.start,
                              maxLines: 2,
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
    );
  }
}
