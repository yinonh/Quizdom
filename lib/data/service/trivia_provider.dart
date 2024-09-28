import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:trivia/core/network/server.dart';
import 'package:trivia/data/data_source/trivia_data_source.dart';
import 'package:trivia/data/models/trivia_categories.dart';
import 'package:trivia/data/models/trivia_response.dart';
import 'package:trivia/data/repository/trivia_repository.dart';

part 'trivia_provider.freezed.dart';
part 'trivia_provider.g.dart';

@freezed
class TriviaState with _$TriviaState {
  const factory TriviaState({
    required String? token,
    required int? categoryId,
    TriviaCategories? categories,
  }) = _TriviaState;
}

@Riverpod(keepAlive: true)
class Trivia extends _$Trivia {
  late final TriviaRepository repository;

  @override
  TriviaState build() {
    final dioClient = ref.watch(dioProvider);
    final dataSource = TriviaDataSource(client: dioClient);
    repository = TriviaRepository(dataSource: dataSource);

    return const TriviaState(
      categoryId: null,
      token: null,
    );
  }

  Future<void> setToken() async {
    final token = await repository.getToken();
    state = state.copyWith(token: token);
  }

  Future<TriviaCategories> getCategories() async {
    if (state.categories != null) {
      return state.categories!;
    }

    final categories = await repository.getCategories(state.token);
    state = state.copyWith(categories: categories);

    return categories;
  }

  TriviaCategory? getCategoryById(int id) {
    if (state.categories != null) {
      return repository.getCategoryById(state.categories!, id);
    }
    return null;
  }

  void setCategory(int categoryId) {
    if (categoryId != -1) {
      state = state.copyWith(categoryId: categoryId);
    }
  }

  Future<TriviaResponse> getTriviaQuestions() async {
    return repository.getTriviaQuestions(state.categoryId, state.token);
  }
}
