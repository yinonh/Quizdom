import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:trivia/data/trivia_provider.dart';

import 'package:trivia/models/trivia_categories.dart';
import 'package:trivia/models/trivia_response.dart';

part 'quiz_screen_manager.freezed.dart';
part 'quiz_screen_manager.g.dart';

@freezed
class QuizState with _$QuizState {
  const factory QuizState({
    required TriviaResponse triviaResponse,
  }) = _QuizState;
}

@riverpod
class QuizScreenManager extends _$QuizScreenManager {
  @override
  Future<QuizState> build() async {
    final trivia = ref.read(triviaProvider.notifier);
    return QuizState(triviaResponse: await trivia.getTriviaQuestions());
  }
}
