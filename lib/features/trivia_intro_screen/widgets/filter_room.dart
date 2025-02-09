import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trivia/core/common_widgets/custom_bottom_button.dart';
import 'package:trivia/core/constants/app_constant.dart';
import 'package:trivia/core/constants/constant_strings.dart';
import 'package:trivia/core/utils/general_functions.dart';
import 'package:trivia/core/utils/size_config.dart';
import 'package:trivia/features/trivia_intro_screen/view_model/intro_screen_manager.dart';

class RoomFilterDialog extends ConsumerWidget {
  const RoomFilterDialog({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final introStateAsync = ref.watch(introScreenManagerProvider);
    final introNotifier = ref.read(introScreenManagerProvider.notifier);

    return introStateAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(child: Text('Error: $error')),
      data: (introState) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppConstant.primaryColor,
                AppConstant.highlightColor,
              ],
            ),
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              spacing: calcHeight(16),
              children: [
                Stack(
                  alignment: Alignment.center,
                  children: [
                    Container(
                      width: calcWidth(120),
                      height: calcWidth(120),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color:
                            AppConstant.highlightColor.withValues(alpha: 0.3),
                      ),
                    ),
                    Icon(
                      Icons.filter_list,
                      size: calcWidth(50),
                      color: Colors.white,
                    ),
                  ],
                ),
                Text(
                  Strings.filterRooms,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                ),
                // Category filter (now synchronous)
                _buildCategoryFilter(introState, introNotifier, context),
                // Question count filter
                _buildDropdown(
                  context: context,
                  value: introState.userPreferences.questionCount ?? -1,
                  label: Strings.numberOfQuestions,
                  items: [
                    const DropdownMenuItem(value: -1, child: Text(Strings.any)),
                    ...[10, 15, 20].map(
                      (count) => DropdownMenuItem(
                        value: count,
                        child: Text('$count ${Strings.questions}'),
                      ),
                    ),
                  ],
                  onChanged: (value) => introNotifier.updateUserPreferences(
                      numOfQuestions: value),
                ),
                // Difficulty filter
                _buildDropdown(
                  context: context,
                  value: introState.userPreferences.difficulty ?? "-1",
                  label: Strings.difficulty,
                  items: [
                    const DropdownMenuItem(
                        value: "-1", child: Text(Strings.any)),
                    ...AppConstant.difficultyMap.map(
                      (difficulty) => DropdownMenuItem(
                        value: difficulty,
                        child: Text(difficulty),
                      ),
                    ),
                  ],
                  onChanged: (value) =>
                      introNotifier.updateUserPreferences(difficulty: value),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    CustomBottomButton(
                      text: Strings.close,
                      onTap: () => Navigator.pop(context),
                    ),
                    CustomBottomButton(
                      text: Strings.clear,
                      onTap: () => introNotifier.updateUserPreferences(
                        category: -1,
                        numOfQuestions: -1,
                        difficulty: "-1",
                      ),
                      isSecondary: true,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryFilter(
    IntroState introState,
    IntroScreenManager introNotifier,
    BuildContext context,
  ) {
    final categories = introState.categories?.triviaCategories ?? [];

    return _buildDropdown(
      context: context,
      value: introState.userPreferences.categoryId ?? -1,
      label: Strings.category,
      items: [
        ...categories.map(
          (category) => DropdownMenuItem(
            value: category.id,
            child: Text(cleanCategoryName(category.name ?? "")),
          ),
        ),
      ],
      onChanged: (value) =>
          introNotifier.updateUserPreferences(category: value),
    );
  }

  Widget _buildDropdown({
    required BuildContext context,
    required String label,
    required List<DropdownMenuItem> items,
    required dynamic value,
    required Function(dynamic) onChanged,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: calcWidth(16),
        vertical: calcHeight(4),
      ),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withValues(alpha: 0.5)),
      ),
      child: DropdownButtonFormField(
        value: value,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(
            color: AppConstant.primaryColor,
            fontWeight: FontWeight.w500,
          ),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(vertical: calcHeight(5)),
        ),
        items: items,
        onChanged: onChanged,
        dropdownColor: Colors.white,
        style: const TextStyle(
          color: AppConstant.primaryColor,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
