import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:Quizdom/core/common_widgets/custom_when.dart';
import 'package:Quizdom/core/constants/app_constant.dart';
import 'package:Quizdom/core/navigation/route_extensions.dart';
import 'package:Quizdom/core/utils/size_config.dart';
import 'package:Quizdom/features/quiz_screen/view_model/solo_quiz_screen_manager.dart';
import 'package:Quizdom/features/quiz_screen/widgets/question_shemmer.dart';
import 'package:Quizdom/features/quiz_screen/widgets/solo_widgets/solo_multiple_answers.dart';
import 'package:Quizdom/features/results_screen/solo_results_screen.dart';

class SoloQuestionWidget extends ConsumerWidget {
  bool _hasNavigatedToResults = false;

  SoloQuestionWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final questionsState = ref.watch(soloQuizScreenManagerProvider);
    final questionsStateNotifier =
        ref.read(soloQuizScreenManagerProvider.notifier);
    return questionsState.customWhen(
      data: (data) {
        WidgetsBinding.instance.addPostFrameCallback(
          (_) {
            if (!_hasNavigatedToResults &&
                data.questions.length == data.questionIndex) {
              _hasNavigatedToResults = true;
              goRoute(SoloResultsScreen.routeName);
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
            SoloMultipleAnswerWidget(
              question: currentQuestion.question!,
              options: data.shuffledOptions,
              onAnswerSelected: questionsStateNotifier.selectAnswer,
            ),
            const Spacer(),
            data.selectedAnswerIndex == null
                ? LinearProgressIndicator(
                    value: data.timeLeft / data.questions.length,
                    minHeight: calcHeight(10),
                    borderRadius: const BorderRadius.all(Radius.circular(20)),
                    color: data.timeLeft / data.questions.length < 0.2
                        ? AppConstant.red
                        : data.timeLeft / data.questions.length < 0.5
                            ? AppConstant.amber
                            : AppConstant.onPrimaryColor,
                  )
                : LinearProgressIndicator(
                    minHeight: calcHeight(10),
                    borderRadius: const BorderRadius.all(Radius.circular(20)),
                    color: AppConstant.onPrimaryColor,
                  ),
            SizedBox(
              height: calcHeight(20),
            ),
          ],
        );
      },
      loading: () {
        return const ShimmerLoadingQuestionWidget();
      },
    );
  }
}
