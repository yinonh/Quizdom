import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:trivia/data/models/trivia_categories.dart';
import 'package:trivia/data/service/trivia_provider.dart';
import 'package:trivia/data/service/user_provider.dart';

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
  Trivia? _triviaProviderNotifier;
  Auth? _userProviderNotifier;

  Trivia? get triviaProviderNotifier {
    return _triviaProviderNotifier ??= ref.read(triviaProvider.notifier);
  }

  Auth? get userProviderNotifier {
    return _userProviderNotifier ??= ref.read(authProvider.notifier);
  }

  @override
  Future<CategoriesState> build() async {
    // Fetch necessary data
    final currentUser = ref.watch(authProvider).currentUser;
    return CategoriesState(
      categories: await triviaProviderNotifier?.getCategories() ??
          const TriviaCategories(),
      userRecentCategories: currentUser.recentTriviaCategories,
    );
  }

  // Reset achievements using the initialized notifier
  void resetAchievements() {
    userProviderNotifier?.resetAchievements();
  }

  // Set a category and update user's recent categories
  void setCategory(int categoryId) {
    triviaProviderNotifier?.setCategory(categoryId);
    userProviderNotifier?.addTriviaCategory(categoryId);
  }

  // Function to clean up category names
  String cleanCategoryName(String name) {
    return name.replaceAll(RegExp(r'^(Entertainment: |Science: )'), '').trim();
  }
}
