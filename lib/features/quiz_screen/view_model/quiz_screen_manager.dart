import 'dart:async';

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:trivia/data/models/trivia_response.dart';
import 'package:trivia/data/models/user_achievements.dart';
import 'package:trivia/data/service/trivia_provider.dart';
import 'package:trivia/data/service/user_provider.dart';
import 'package:trivia/core/constants/app_constant.dart';

part 'quiz_screen_manager.freezed.dart';
part 'quiz_screen_manager.g.dart';

@freezed
class QuizState with _$QuizState {
  const factory QuizState({
    required List<Question> questions,
    required double timeLeft,
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
    final triviaNotifier = ref.read(triviaProvider.notifier);
    final response = await triviaNotifier.getTriviaQuestions();
    final initialShuffledData = _getShuffledOptions(response.results![0]);
    ref.onDispose(() {
      _timer?.cancel();
    });

    return QuizState(
      questions: response.results!,
      timeLeft: AppConstant.questionTime.toDouble(),
      questionIndex: 0,
      shuffledOptions: initialShuffledData.options,
      correctAnswerIndex: initialShuffledData.correctIndex,
      selectedAnswerIndex: null,
    );
  }

  void startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(
      const Duration(milliseconds: 40),
      (timer) {
        state.whenData(
          (quizState) {
            if (quizState.timeLeft > 0) {
              state = AsyncValue.data(
                  quizState.copyWith(timeLeft: quizState.timeLeft - 0.04));
            } else {
              if (quizState.selectedAnswerIndex == null) {
                selectAnswer(-1);
              } else {
                _moveToNextQuestion();
              }
            }
          },
        );
      },
    );
  }

  void _moveToNextQuestion() {
    state.whenData((quizState) {
      if (quizState.questionIndex < quizState.questions.length - 1) {
        final nextIndex = quizState.questionIndex + 1;
        final nextShuffledData =
            _getShuffledOptions(quizState.questions[nextIndex]);

        state = AsyncValue.data(
          quizState.copyWith(
            questionIndex: nextIndex,
            timeLeft: AppConstant.questionTime.toDouble(),
            // Reset time for the next question
            shuffledOptions: nextShuffledData.options,
            correctAnswerIndex: nextShuffledData.correctIndex,
            selectedAnswerIndex: null, // Reset the selected answer index
          ),
        );
      } else {
        state = AsyncValue.data(
          quizState.copyWith(
            questionIndex: quizState.questionIndex + 1,
          ),
        );
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
    final userNotifier = ref.read(authProvider.notifier);
    state.whenData(
      (quizState) {
        if (quizState.selectedAnswerIndex == null) {
          if (quizState.correctAnswerIndex == index) {
            userNotifier.updateAchievements(
                field: AchievementField.correctAnswers,
                sumResponseTime: quizState.timeLeft);
          } else if (index == -1) {
            userNotifier.updateAchievements(field: AchievementField.unanswered);
          } else {
            userNotifier.updateAchievements(
                field: AchievementField.wrongAnswers,
                sumResponseTime: quizState.timeLeft);
          }
          state = AsyncValue.data(
              quizState.copyWith(selectedAnswerIndex: index, timeLeft: 1));
        }
      },
    );
  }
}
