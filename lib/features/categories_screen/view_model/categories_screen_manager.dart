import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:trivia/models/trivia_categories.dart';
import 'package:trivia/service/trivia_provider.dart';
import 'package:trivia/service/user_provider.dart';

part 'categories_screen_manager.freezed.dart';

part 'categories_screen_manager.g.dart';

@freezed
class CategoriesState with _$CategoriesState {
  const factory CategoriesState({
    required TriviaCategories categories,
    required List<int> userRecentCategories,
  }) = _CategoriesState;
}

@riverpod
class CategoriesScreenManager extends _$CategoriesScreenManager {
  late final Trivia triviaProviderNotifier;
  late final User userProviderNotifier;

  @override
  Future<CategoriesState> build() async {
    // Initialize notifiers
    triviaProviderNotifier = ref.read(triviaProvider.notifier);
    userProviderNotifier = ref.read(userProvider.notifier);

    // Fetch necessary data
    final currentUser = ref.watch(userProvider).currentUser;
    return CategoriesState(
      categories: await triviaProviderNotifier.getCategories(),
      userRecentCategories: currentUser.recentTriviaCategories,
    );
  }

  // Reset achievements using the initialized notifier
  void resetAchievements() {
    userProviderNotifier.resetAchievements();
  }

  // Set a category and update user's recent categories
  void setCategory(int categoryId) {
    triviaProviderNotifier.setCategory(categoryId);
    userProviderNotifier.addTriviaCategory(categoryId);
  }

  // Function to clean up category names
  String cleanCategoryName(String name) {
    return name.replaceAll(RegExp(r'^(Entertainment: |Science: )'), '').trim();
  }
}
