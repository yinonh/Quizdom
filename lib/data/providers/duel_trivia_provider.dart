import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:trivia/core/utils/general_functions.dart';
import 'package:trivia/data/data_source/trivia_data_source.dart';
import 'package:trivia/data/models/question.dart';
import 'package:trivia/data/models/trivia_categories.dart';
import 'package:trivia/data/models/trivia_room.dart';

part 'duel_trivia_provider.freezed.dart';
part 'duel_trivia_provider.g.dart';

@freezed
class DuelTriviaState with _$DuelTriviaState {
  const factory DuelTriviaState({
    required String? token,
    required TriviaRoom? triviaRoom,
    TriviaCategories? categories,
  }) = _DuelTriviaState;
}

@Riverpod(keepAlive: true)
class DuelTrivia extends _$DuelTrivia {
  @override
  DuelTriviaState build() {
    return const DuelTriviaState(
      triviaRoom: null,
      token: null,
    );
  }

  Future setToken() async {
    final data = await TriviaDataSource.requestToken();
    state = state.copyWith(token: data['token'] as String);
  }

  Future getCategories() async {
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

  void setTriviaRoom(TriviaRoom triviaRoom) {
    state = state.copyWith(triviaRoom: triviaRoom);
  }

  Future<List<Question>?> getTriviaQuestions() async {
    Map<String, dynamic>? data;

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
      if (data == null) {
        throw Exception();
      }
    }
    final List<Question> questions = (data?['results'] as List).map((result) {
      final decodedResult = decodeFields(result);
      return Question.fromJson(decodedResult);
    }).toList();
    return questions;
  }
}
