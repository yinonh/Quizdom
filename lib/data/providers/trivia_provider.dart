import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:trivia/core/utils/enums/game_mode.dart';
import 'package:trivia/core/utils/general_functions.dart';
import 'package:trivia/data/data_source/trivia_data_source.dart';
import 'package:trivia/data/models/general_trivia_room.dart';
import 'package:trivia/data/models/trivia_categories.dart';
import 'package:trivia/data/models/question.dart';
import 'package:trivia/data/models/trivia_room.dart';

part 'trivia_provider.freezed.dart';
part 'trivia_provider.g.dart';

@freezed
class TriviaState with _$TriviaState {
  const factory TriviaState({
    required String? token,
    required GeneralTriviaRoom? generalTriviaRoom,
    required TriviaRoom? triviaRoom,
    GameMode? currentGameMode,
    TriviaCategories? categories,
  }) = _TriviaState;
}

@Riverpod(keepAlive: true)
class Trivia extends _$Trivia {
  @override
  TriviaState build() {
    return const TriviaState(
      generalTriviaRoom: null,
      triviaRoom: null,
      token: null,
    );
  }

  get categoryId => state.triviaRoom?.categoryId;
  get token => state.token;

  Future<void> setToken() async {
    final data = await TriviaDataSource.requestToken();
    state = state.copyWith(token: data['token'] as String);
  }

  Future<TriviaCategories> getCategories() async {
    if (state.categories != null) {
      return state.categories!;
    }

    final data = await TriviaDataSource.fetchCategories(state.token);
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
    state = state.copyWith(
        generalTriviaRoom: triviaRoom,
        triviaRoom: null,
        currentGameMode: GameMode.solo);
  }

  void setTriviaRoom(TriviaRoom triviaRoom) {
    state = state.copyWith(
        triviaRoom: triviaRoom,
        generalTriviaRoom: null,
        currentGameMode: GameMode.duel);
  }

  Future<List<Question>?> getTriviaQuestions() async {
    Map<String, dynamic>? data;

    if (state.currentGameMode == GameMode.solo) {
      data = await TriviaDataSource.fetchTriviaQuestions(
          state.generalTriviaRoom?.categoryId, state.token);
    } else {
      // If trivia room exists and has questions, use it.
      if (state.triviaRoom != null && state.triviaRoom!.questionsData != null) {
        data = state.triviaRoom!.questionsData;
      } else {
        // Instead of immediately calling the API,
        // wait until the trivia room is updated with questionsData.
        // This polling loop waits up to 10 seconds.
        final stopwatch = Stopwatch()..start();
        while (stopwatch.elapsed < const Duration(seconds: 10)) {
          await Future.delayed(const Duration(seconds: 1));
          if (state.triviaRoom != null &&
              state.triviaRoom!.questionsData != null) {
            data = state.triviaRoom!.questionsData;
            break;
          }
        }

        // If still no data, return an empty list or show an error.
        if (data == null) {
          throw Exception();
        }
      }
    }

    final List<Question> questions = (data?['results'] as List).map((result) {
      final decodedResult = decodeFields(result);
      return Question.fromJson(decodedResult);
    }).toList();
    return questions;
  }
}
