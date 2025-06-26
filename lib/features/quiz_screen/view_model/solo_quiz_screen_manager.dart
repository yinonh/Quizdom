import 'dart:async';

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:Quizdom/core/constants/app_constant.dart';
import 'package:Quizdom/core/utils/enums/difficulty.dart';
import 'package:Quizdom/data/models/question.dart';
import 'package:Quizdom/data/models/shuffled_data.dart';
import 'package:Quizdom/data/models/trivia_achievements.dart';
import 'package:Quizdom/data/providers/current_trivia_achievements_provider.dart';
import 'package:Quizdom/data/providers/trivia_provider.dart';

part 'solo_quiz_screen_manager.freezed.dart';
part 'solo_quiz_screen_manager.g.dart';

@freezed
class SoloQuizState with _$SoloQuizState {
  const factory SoloQuizState({
    required List<Question> questions,
    required double timeLeft,
    required int questionIndex,
    required List<String> shuffledOptions,
    required int correctAnswerIndex,
    required String categoryName,
    required Difficulty? difficulty,
    int? selectedAnswerIndex,
  }) = _SoloQuizState;
}

@riverpod
class SoloQuizScreenManager extends _$SoloQuizScreenManager {
  Timer? _timer;

  @override
  Future<SoloQuizState> build() async {
    final triviaNotifier = ref.read(triviaProvider.notifier);
    final triviaState = ref.read(triviaProvider);

    final response = await triviaNotifier.getSoloTriviaQuestions();
    final initialShuffledData = _getShuffledOptions(response![0]);
    ref.onDispose(() {
      _timer?.cancel();
    });

    return SoloQuizState(
      questions: response,
      timeLeft: AppConstant.questionTime.toDouble(),
      questionIndex: 0,
      shuffledOptions: initialShuffledData.options,
      correctAnswerIndex: initialShuffledData.correctIndex,
      selectedAnswerIndex: null,
      categoryName: ref.read(triviaProvider).triviaRoom?.categoryName ?? "",
      difficulty: triviaState.selectedDifficulty,
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
    state.whenData(
      (quizState) {
        if (quizState.selectedAnswerIndex == null) {
          if (quizState.correctAnswerIndex == index) {
            ref
                .read(currentTriviaAchievementsProvider.notifier)
                .updateAchievements(
                    field: AchievementField.correctAnswers,
                    sumResponseTime: quizState.timeLeft);
          } else if (index == -1) {
            ref
                .read(currentTriviaAchievementsProvider.notifier)
                .updateAchievements(field: AchievementField.unanswered);
          } else {
            ref
                .read(currentTriviaAchievementsProvider.notifier)
                .updateAchievements(
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
