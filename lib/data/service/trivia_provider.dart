import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:trivia/data/models/trivia_categories.dart';
import 'package:trivia/data/models/trivia_response.dart';
import 'package:trivia/data/models/trivia_room.dart';
import 'package:trivia/data/repository/trivia_repository.dart';

part 'trivia_provider.freezed.dart';
part 'trivia_provider.g.dart';

@freezed
class TriviaState with _$TriviaState {
  const factory TriviaState({
    required String? token,
    required TriviaRoom? triviaRoom,
    TriviaCategories? categories,
  }) = _TriviaState;
}

@Riverpod(keepAlive: true)
class Trivia extends _$Trivia {
  late final TriviaRepository repository;

  @override
  TriviaState build() {
    repository = ref.read(triviaRepositoryProvider);

    return const TriviaState(
      triviaRoom: null,
      token: null,
    );
  }

  get categoryId => state.triviaRoom?.categoryId;

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

  void setTriviaRoom(TriviaRoom triviaRoom) {
    state = state.copyWith(triviaRoom: triviaRoom);
  }

  Future<TriviaResponse> getTriviaQuestions() async {
    return repository.getTriviaQuestions(state.triviaRoom, state.token);
  }
}
