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
    String? userAvatar,
  }) = _CategoriesState;
}

@riverpod
class CategoriesScreenManager extends _$CategoriesScreenManager {
  @override
  Future<CategoriesState> build() async {
    final trivia = ref.read(triviaProvider.notifier);
    final userState = ref.read(userProvider);
    return CategoriesState(
        categories: await trivia.getCategories(), userAvatar: userState.avatar);
  }

  void resetAchievements() {
    ref.read(userProvider.notifier).resetAchievements();
  }

  void setCategory(int categoryId) {
    final trivia = ref.read(triviaProvider.notifier);
    trivia.setCategory(categoryId);
  }
}
