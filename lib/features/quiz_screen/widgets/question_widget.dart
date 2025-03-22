import 'package:flutter/material.dart';
import 'package:trivia/core/constants/app_constant.dart';
import 'package:trivia/data/models/question.dart';
import 'package:trivia/features/quiz_screen/widgets/multiple_answer_widget.dart';
import 'package:trivia/features/quiz_screen/widgets/question_shemmer.dart';
import 'package:trivia/features/results_screen/results_screen.dart';

class QuestionWidget extends StatelessWidget {
  final List<Question> questions;
  final int questionIndex;
  final List<String> shuffledOptions;
  final int? selectedAnswerIndex;
  final int correctAnswerIndex;
  final double timeLeft;
  final Function(int) onAnswerSelected;
  final VoidCallback startTimer;
  final bool isLoading;
  final String? errorMessage;

  const QuestionWidget({
    super.key,
    required this.questions,
    required this.questionIndex,
    required this.shuffledOptions,
    required this.selectedAnswerIndex,
    required this.correctAnswerIndex,
    required this.timeLeft,
    required this.onAnswerSelected,
    required this.startTimer,
    this.isLoading = false,
    this.errorMessage,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const ShimmerLoadingQuestionWidget();
    }

    if (errorMessage != null) {
      return Text(errorMessage!);
    }

    // Handle navigation to results screen
    WidgetsBinding.instance.addPostFrameCallback(
      (_) {
        if (questions.length == questionIndex) {
          Navigator.pushReplacementNamed(context, ResultsScreen.routeName);
        }
      },
    );

    if (questions.length == questionIndex) {
      return const SizedBox();
    }

    startTimer();
    final currentQuestion = questions[questionIndex];

    return Column(
      children: [
        const Spacer(),
        MultipleAnswerWidget(
          question: currentQuestion.question!,
          options: shuffledOptions,
          onAnswerSelected: onAnswerSelected,
          questionIndex: questionIndex,
          selectedAnswerIndex: selectedAnswerIndex,
          correctAnswerIndex: correctAnswerIndex,
        ),
        const Spacer(),
        selectedAnswerIndex == null
            ? LinearProgressIndicator(
                value: timeLeft / questions.length,
                minHeight: 10,
                borderRadius: const BorderRadius.all(Radius.circular(20)),
                color: timeLeft / questions.length < 0.2
                    ? Colors.red
                    : timeLeft / questions.length < 0.5
                        ? Colors.amber
                        : AppConstant.onPrimaryColor,
              )
            : const LinearProgressIndicator(
                minHeight: 10,
                borderRadius: BorderRadius.all(Radius.circular(20)),
                color: AppConstant.onPrimaryColor,
              ),
        const SizedBox(
          height: 20,
        ),
      ],
    );
  }
}
