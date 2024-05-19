import 'dart:async';

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
    required int timeLeft,
    required int questionIndex,
    required List<String> shuffledOptions,
    required int correctAnswerIndex,
    int? selectedAnswerIndex,
  }) = _QuizState;
}

class ShuffledData {
  final List<String> options;
  final int correctIndex;

  ShuffledData({
    required this.options,
    required this.correctIndex,
  });
}

@riverpod
class QuizScreenManager extends _$QuizScreenManager {
  Timer? _timer;

  @override
  Future<QuizState> build() async {
    final trivia = ref.read(triviaProvider.notifier);
    final response = await trivia.getTriviaQuestions();
    final initialShuffledData = _getShuffledOptions(response.results![0]);

    return QuizState(
      triviaResponse: response,
      timeLeft: 10,
      questionIndex: 0,
      shuffledOptions: initialShuffledData.options,
      correctAnswerIndex: initialShuffledData.correctIndex,
      selectedAnswerIndex: null,
    );
  }

  void startTimer() {
    _timer?.cancel(); // Cancel any existing timer
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      // Check if the state is ready and not an error or loading state
      state.whenData((quizState) {
        if (quizState.timeLeft > 0) {
          state = AsyncValue.data(
              quizState.copyWith(timeLeft: quizState.timeLeft - 1));
        } else {
          _moveToNextQuestion();
        }
      });
    });
  }

  void _moveToNextQuestion() {
    state.whenData((quizState) {
      if (quizState.questionIndex <
          quizState.triviaResponse.results!.length - 1) {
        final nextIndex = quizState.questionIndex + 1;
        final nextShuffledData =
            _getShuffledOptions(quizState.triviaResponse.results![nextIndex]);

        state = AsyncValue.data(quizState.copyWith(
          questionIndex: nextIndex,
          timeLeft: 10, // Reset time for the next question
          shuffledOptions: nextShuffledData.options,
          correctAnswerIndex: nextShuffledData.correctIndex,
          selectedAnswerIndex: null, // Reset the selected answer index
        ));
      } else {
        _timer?.cancel();
      }
    });
  }

  ShuffledData _getShuffledOptions(Question question) {
    final options = [...question.incorrectAnswers!, question.correctAnswer!];
    options.shuffle();
    final shuffledCorrectIndex = options.indexOf(question.correctAnswer!);
    return ShuffledData(options: options, correctIndex: shuffledCorrectIndex);
  }

  void selectAnswer(int index) {
    state.whenData((quizState) {
      state = AsyncValue.data(quizState.copyWith(selectedAnswerIndex: index));
    });
  }
}
