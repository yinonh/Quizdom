import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:trivia/data/trivia_api_provider.dart';

import 'package:trivia/models/trivia_categories.dart';

part 'categories_screen_manager.freezed.dart';
part 'categories_screen_manager.g.dart';

@freezed
class CategoriesState with _$CategoriesState {
  const factory CategoriesState({
    required TriviaCategories categories,
  }) = _CategoriesState;
}

@riverpod
class CategoriesScreenManager extends _$CategoriesScreenManager {
  @override
  Future<CategoriesState> build() async {
    final api = ref.read(triviaApiProvider.notifier);
    return CategoriesState(categories: await api.getCategories());
  }
}
