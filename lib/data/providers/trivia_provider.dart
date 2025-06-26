import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:Quizdom/core/utils/enums/difficulty.dart';
import 'package:Quizdom/core/utils/general_functions.dart';
import 'package:Quizdom/data/data_source/trivia_data_source.dart';
import 'package:Quizdom/data/models/general_trivia_room.dart';
import 'package:Quizdom/data/models/question.dart';
import 'package:Quizdom/data/models/trivia_categories.dart';
import 'package:Quizdom/data/models/trivia_room.dart';

part 'trivia_provider.freezed.dart';
part 'trivia_provider.g.dart';

@freezed
class TriviaState with _$TriviaState {
  const factory TriviaState({
    required String? token,
    required GeneralTriviaRoom? triviaRoom,
    required Difficulty? selectedDifficulty,
    TriviaCategories? categories,
  }) = _SoloTriviaState;
}

@Riverpod(keepAlive: true)
class Trivia extends _$Trivia {
  @override
  TriviaState build() {
    return const TriviaState(
      triviaRoom: null,
      token: null,
      selectedDifficulty: null,
    );
  }

  void setDifficulty(Difficulty difficulty) {
    state = state.copyWith(selectedDifficulty: difficulty);
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

  void setTriviaRoom(GeneralTriviaRoom triviaRoom) {
    state = state.copyWith(triviaRoom: triviaRoom);
  }

  Future<List<Question>?> getDuelTriviaQuestions(TriviaRoom? triviaRoom) async {
    Map<String, dynamic>? data;

    // If trivia room exists and has questions, use it.
    if (triviaRoom != null && triviaRoom.questionsData != null) {
      data = triviaRoom.questionsData;
    } else {
      // Instead of immediately calling the API,
      // wait until the trivia room is updated with questionsData.
      // This polling loop waits up to 10 seconds.
      final stopwatch = Stopwatch()..start();
      while (stopwatch.elapsed < const Duration(seconds: 10)) {
        await Future.delayed(const Duration(seconds: 1));
        if (triviaRoom != null && triviaRoom.questionsData != null) {
          data = triviaRoom.questionsData;
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

  Future<List<Question>?> getSoloTriviaQuestions() async {
    Map<String, dynamic>? data;

    data = await TriviaDataSource.fetchTriviaQuestions(
      category: state.triviaRoom?.categoryId,
      token: state.token,
      difficulty: state.selectedDifficulty,
    ); // Pass difficulty to the API call

    final List<Question> questions = (data['results'] as List).map((result) {
      final decodedResult = decodeFields(result);
      return Question.fromJson(decodedResult);
    }).toList();
    return questions;
  }
}
