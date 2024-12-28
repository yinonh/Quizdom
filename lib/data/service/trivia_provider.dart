import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:trivia/core/network/server.dart';
import 'package:trivia/core/utils/general_functions.dart';
import 'package:trivia/data/data_source/trivia_data_source.dart';
import 'package:trivia/data/models/general_trivia_room.dart';
import 'package:trivia/data/models/trivia_categories.dart';
import 'package:trivia/data/models/question.dart';

part 'trivia_provider.freezed.dart';
part 'trivia_provider.g.dart';

@freezed
class TriviaState with _$TriviaState {
  const factory TriviaState({
    required String? token,
    required GeneralTriviaRoom? triviaRoom,
    required TriviaDataSource dataSource,
    TriviaCategories? categories,
  }) = _TriviaState;
}

@Riverpod(keepAlive: true)
class Trivia extends _$Trivia {
  @override
  TriviaState build() {
    final dioClient = ref.watch(dioProvider);

    return TriviaState(
        triviaRoom: null,
        token: null,
        dataSource: TriviaDataSource(client: dioClient));
  }

  get categoryId => state.triviaRoom?.categoryId;

  Future<void> setToken() async {
    final data = await state.dataSource.requestToken();
    state = state.copyWith(token: data['token'] as String);
  }

  Future<TriviaCategories> getCategories() async {
    if (state.categories != null) {
      return state.categories!;
    }

    final data = await state.dataSource.fetchCategories(state.token);
    TriviaCategories categories = TriviaCategories.fromJson(data);
    categories = categories.copyWith(triviaCategories: [
      const TriviaCategory(name: "All", id: -1),
      ...?categories.triviaCategories,
    ]);
    state = state.copyWith(categories: categories);

    return categories;
  }

  TriviaCategory? getCategoryById(int id) {
    if (state.categories != null) {
      return state.categories?.triviaCategories?.firstWhere(
        (category) => category.id == id,
        orElse: () => const TriviaCategory(id: -1, name: 'Unknown'),
      );
    }
    return null;
  }

  void setGeneralTriviaRoom(GeneralTriviaRoom triviaRoom) {
    state = state.copyWith(triviaRoom: triviaRoom);
  }

  Future<List<Question>?> getTriviaQuestions() async {
    final data = await state.dataSource
        .fetchTriviaQuestions(state.triviaRoom, state.token);

    final List<Question> questions = (data['results'] as List).map((result) {
      final decodedResult = decodeFields(result);
      return Question.fromJson(decodedResult);
    }).toList();
    return questions;
  }
}
