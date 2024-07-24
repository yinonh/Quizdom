import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trivia/features/quiz_screen/view_model/quiz_screen_manager.dart';
import 'package:trivia/utility/app_constant.dart';
import 'package:trivia/utility/color_utility.dart';

enum OptionState { correct, wrong, unchosen }

class MultipleAnswerWidget extends ConsumerWidget {
  final String question;
  final List<String> options;
  final Function(int) onAnswerSelected;

  const MultipleAnswerWidget({
    super.key,
    required this.question,
    required this.options,
    required this.onAnswerSelected,
  });

  Color getColorForState(OptionState state) {
    switch (state) {
      case OptionState.unchosen:
        return AppConstant.highlightColor.toColor().withOpacity(0.2);
      case OptionState.correct:
        return AppConstant.secondaryColor.toColor().withOpacity(0.3);
      case OptionState.wrong:
        return AppConstant.onPrimary.toColor().withOpacity(0.2);
    }
  }

  Widget optionWidget(int index, OptionState optionState) {
    return GestureDetector(
      onTap: () => onAnswerSelected(index),
      child: Container(
        margin: const EdgeInsets.only(bottom: 8.0),
        padding: const EdgeInsets.all(12.0),
        decoration: BoxDecoration(
          color: getColorForState(optionState),
          borderRadius: BorderRadius.circular(10.0),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "${index + 1}.  ",
              style: const TextStyle(fontSize: 16.0),
            ),
            Expanded(
              child: Text(
                options[index],
                style: const TextStyle(fontSize: 16.0),
                maxLines: 2,
              ),
            ),
            optionState == OptionState.wrong
                ? const Icon(
                    Icons.close_rounded,
                    color: Colors.red,
                  )
                : optionState == OptionState.correct
                    ? const Icon(
                        Icons.check_rounded,
                        color: Colors.green,
                      )
                    : const SizedBox.shrink(),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final questionsState = ref.watch(quizScreenManagerProvider).asData!.value;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          question,
          textAlign: TextAlign.justify,
          style: const TextStyle(
            fontSize: 18.0,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 25.0),
        ListView.builder(
          shrinkWrap: true,
          itemCount: options.length,
          itemBuilder: (BuildContext context, int index) {
            if (questionsState.selectedAnswerIndex == null) {
              return optionWidget(index, OptionState.unchosen);
            } else if (questionsState.selectedAnswerIndex ==
                questionsState.correctAnswerIndex) {
              return optionWidget(
                  index,
                  questionsState.correctAnswerIndex == index
                      ? OptionState.correct
                      : OptionState.unchosen);
            } else {
              return optionWidget(
                  index,
                  questionsState.selectedAnswerIndex == index
                      ? OptionState.wrong
                      : questionsState.correctAnswerIndex == index
                          ? OptionState.correct
                          : OptionState.unchosen);
            }
          },
        ),
      ],
    );
  }
}
