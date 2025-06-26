import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:Quizdom/core/common_widgets/custom_bottom_button.dart';
import 'package:Quizdom/core/common_widgets/custom_when.dart';
import 'package:Quizdom/core/constants/app_constant.dart';
import 'package:Quizdom/core/constants/app_routes.dart';
import 'package:Quizdom/core/constants/constant_strings.dart';
import 'package:Quizdom/core/navigation/route_extensions.dart';
import 'package:Quizdom/core/utils/general_functions.dart';
import 'package:Quizdom/core/utils/size_config.dart';
import 'package:Quizdom/features/intro_screen/view_model/duel_manager.dart';
import 'package:Quizdom/features/intro_screen/view_model/filter_manager.dart';
import 'package:Quizdom/features/intro_screen/widgets/difficulty_selector.dart';

class RoomFilterScreen extends ConsumerStatefulWidget {
  static const routeName = AppRoutes.filterDialog;

  const RoomFilterScreen({super.key});

  /// Navigate to the Room Filter screen
  static void show(BuildContext context) {
    goRoute(routeName);
  }

  @override
  ConsumerState<RoomFilterScreen> createState() => _RoomFilterScreenState();
}

class _RoomFilterScreenState extends ConsumerState<RoomFilterScreen> {
  @override
  void initState() {
    super.initState();
    // Initialize filter state from current user preferences
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final introState = ref.read(duelManagerProvider);
      introState.whenData((state) {
        ref
            .read(filterManagerProvider.notifier)
            .initializeFromUserPreference(state.userPreferences);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: calcWidth(30)),
        color: Colors.black.withValues(alpha: 0.5),
        child: const Center(
          child: RoomFilterContent(),
        ),
      ),
    );
  }
}

class RoomFilterContent extends ConsumerWidget {
  const RoomFilterContent({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final introStateAsync = ref.watch(duelManagerProvider);
    final filterState = ref.watch(filterManagerProvider);
    final filterNotifier = ref.read(filterManagerProvider.notifier);
    final introNotifier = ref.read(duelManagerProvider.notifier);

    return introStateAsync.customWhen(
      data: (introState) {
        return Container(
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
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.clear, color: Colors.white),
                      onPressed: () => pop(),
                    ),
                  ],
                ),
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
                      size: calcWidth(70),
                      color: Colors.white,
                    ),
                  ],
                ),
                SizedBox(height: calcHeight(16)),
                Text(
                  Strings.filterRooms,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                ),
                SizedBox(height: calcHeight(16)),
                _buildDropdown(
                  context: context,
                  value: filterState.categoryId,
                  label: Strings.category,
                  items: [
                    ...?introState.categories?.triviaCategories?.map(
                      (category) => DropdownMenuItem(
                        value: category.id,
                        child: Text(cleanCategoryName(category.name ?? "")),
                      ),
                    ),
                  ],
                  onChanged: (value) {
                    filterNotifier.updateFilters(categoryId: value);
                  },
                ),
                SizedBox(height: calcHeight(16)),
                // _buildDropdown(
                //   context: context,
                //   value: filterState.questionCount,
                //   label: Strings.numberOfQuestions,
                //   items: [
                //     const DropdownMenuItem(value: -1, child: Text(Strings.any)),
                //     ...[10, 15, 20].map(
                //       (count) => DropdownMenuItem(
                //         value: count,
                //         child: Text('$count ${Strings.questions}'),
                //       ),
                //     ),
                //   ],
                //   onChanged: (value) {
                //     filterNotifier.updateFilters(questionCount: value);
                //   },
                // ),
                DifficultySelector(
                  selectedDifficulty: filterState.difficulty,
                  onDifficultySelected: (value) {
                    filterNotifier.updateFilters(difficulty: value);
                  },
                ),
                SizedBox(height: calcHeight(35)),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    CustomBottomButton(
                      text: Strings.clear,
                      onTap: () {
                        filterNotifier.resetFilters();
                      },
                    ),
                    CustomBottomButton(
                      text: Strings.setFilters,
                      onTap: () {
                        final userPreference = filterState.toUserPreference();
                        introNotifier.updateUserPreferences(
                          category: userPreference.categoryId,
                          numOfQuestions: userPreference.questionCount,
                          difficulty: userPreference.difficulty,
                        );
                        pop();
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
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
