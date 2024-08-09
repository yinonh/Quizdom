import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';

import 'package:trivia/features/quiz_screen/view_model/quiz_screen_manager.dart';
import 'package:trivia/features/quiz_screen/widgets/multiple_answer_widget.dart';
import 'package:trivia/features/results_screen/results_screen.dart';
import 'package:trivia/utility/app_constant.dart';
import 'package:trivia/utility/color_utility.dart';

class QuestionWidget extends ConsumerWidget {
  bool _hasNavigatedToResults = false;

  QuestionWidget({super.key});

  Future<LottieComposition?> customDecoder(List<int> bytes) {
    return LottieComposition.decodeZip(bytes, filePicker: (files) {
      return files.firstWhereOrNull(
          (f) => f.name.startsWith('animations/') && f.name.endsWith('.json'));
    });
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final questionsState = ref.watch(quizScreenManagerProvider);
    final questionsStateNotifier = ref.read(quizScreenManagerProvider.notifier);
    return questionsState.when(
      data: (data) {
        WidgetsBinding.instance.addPostFrameCallback(
          (_) {
            if (!_hasNavigatedToResults &&
                data.questions.length == data.questionIndex) {
              _hasNavigatedToResults = true;
              Navigator.pushReplacementNamed(context, ResultsScreen.routeName);
            }
          },
        );
        if (data.questions.length == data.questionIndex) {
          return const SizedBox();
        }

        questionsStateNotifier.startTimer();
        final currentQuestion = data.questions[data.questionIndex];

        return Column(
          children: [
            const Spacer(),
            MultipleAnswerWidget(
              question: currentQuestion.question!,
              options: data.shuffledOptions,
              onAnswerSelected: questionsStateNotifier.selectAnswer,
            ),
            const Spacer(),
            data.selectedAnswerIndex == null
                ? LinearProgressIndicator(
                    value: data.timeLeft / data.questions.length,
                    minHeight: 10,
                    borderRadius: const BorderRadius.all(Radius.circular(20)),
                    color: data.timeLeft / data.questions.length < 0.2
                        ? Colors.red
                        : data.timeLeft / data.questions.length < 0.5
                            ? Colors.amber
                            : AppConstant.onPrimary.toColor(),
                  )
                : LinearProgressIndicator(
                    minHeight: 10,
                    borderRadius: BorderRadius.all(Radius.circular(20)),
                    color: AppConstant.onPrimary.toColor(),
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
        return Center(
          child: SizedBox(
            height: 300,
            width: 200,
            child: Lottie.asset(
              'assets/loading_animation.lottie',
              decoder: customDecoder,
            ),
          ),
        );
      },
    );
  }
}
