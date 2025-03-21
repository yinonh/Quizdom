// solo_trivia_provider.dart
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:trivia/core/utils/general_functions.dart';
import 'package:trivia/data/data_source/trivia_data_source.dart';
import 'package:trivia/data/models/general_trivia_room.dart';
import 'package:trivia/data/models/question.dart';
import 'package:trivia/data/models/trivia_categories.dart';

part 'solo_trivia_provider.freezed.dart';
part 'solo_trivia_provider.g.dart';

@freezed
class SoloTriviaState with _$SoloTriviaState {
  const factory SoloTriviaState({
    required String? token,
    required GeneralTriviaRoom? triviaRoom,
    TriviaCategories? categories,
  }) = _SoloTriviaState;
}

@Riverpod(keepAlive: true)
class SoloTrivia extends _$SoloTrivia {
  @override
  SoloTriviaState build() {
    return const SoloTriviaState(
      triviaRoom: null,
      token: null,
    );
  }

  Future setToken() async {
    final data = await TriviaDataSource.requestToken();
    state = state.copyWith(token: data['token'] as String);
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

  Future<List<Question>?> getTriviaQuestions() async {
    Map<String, dynamic>? data;

    data = await TriviaDataSource.fetchTriviaQuestions(
        state.triviaRoom?.categoryId, state.token);

    final List<Question> questions = (data?['results'] as List).map((result) {
      final decodedResult = decodeFields(result);
      return Question.fromJson(decodedResult);
    }).toList();
    return questions;
  }
}
