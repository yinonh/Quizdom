import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trivia/features/quiz_screen/view_model/quiz_screen_manager.dart';
import 'package:trivia/features/quiz_screen/widgets/multiple_answer_widget.dart';

class QuestionWidget extends ConsumerWidget {
  const QuestionWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final questionsState = ref.watch(quizScreenManagerProvider);
    final questionsStateNotifier =
        ref.watch(quizScreenManagerProvider.notifier);
    return questionsState.when(
      data: (data) {
        questionsStateNotifier.startTimer();
        final currentQuestion =
            data.triviaResponse.results![data.questionIndex];

        return Column(
          children: [
            const Spacer(),
            MultipleAnswerWidget(
              question: currentQuestion.question!,
              options: data.shuffledOptions,
              onAnswerSelected: (int x) {
                print(x);
              },
            ),
            const Spacer(),
            LinearProgressIndicator(
              value: data.timeLeft / data.triviaResponse.results!.length,
              minHeight: 10,
              borderRadius: const BorderRadius.all(Radius.circular(20)),
            ),
            const SizedBox(
              height: 20,
            ),
          ],
        );
      },
      error: (error, _) {
        return Text(error.toString());
      },
      loading: () {
        return const CircularProgressIndicator();
      },
    );
  }
}
