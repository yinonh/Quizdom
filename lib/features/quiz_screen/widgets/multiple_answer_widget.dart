import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trivia/core/constants/constant_strings.dart';
import 'package:trivia/features/quiz_screen/view_model/quiz_screen_manager.dart';
import 'package:trivia/core/constants/app_constant.dart';

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
        return AppConstant.secondaryColor.withValues(alpha: 0.4);
      case OptionState.correct:
        return Colors.green.withValues(alpha: 0.3);
      case OptionState.wrong:
        return Colors.red.withValues(alpha: 0.2);
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
    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
            child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              constraints: const BoxConstraints(
                minHeight: 120,
                maxHeight: 200,
              ),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              margin: const EdgeInsets.only(bottom: 25.0),
              padding: const EdgeInsets.all(16.0),
              child: Stack(
                children: [
                  Text(
                    "${Strings.question} ${questionsState.questionIndex + 1}/10",
                    style: const TextStyle(color: Color(0xFF6E6E6E)),
                  ),
                  Center(
                    child: SingleChildScrollView(
                      child: Text(
                        question,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 18.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Using Column instead of ListView.builder for options
            Column(
              mainAxisSize: MainAxisSize.min,
              children: List.generate(
                options.length,
                (index) {
                  if (questionsState.selectedAnswerIndex == null) {
                    return optionWidget(index, OptionState.unchosen);
                  } else if (questionsState.selectedAnswerIndex ==
                      questionsState.correctAnswerIndex) {
                    return optionWidget(
                      index,
                      questionsState.correctAnswerIndex == index
                          ? OptionState.correct
                          : OptionState.unchosen,
                    );
                  } else {
                    return optionWidget(
                      index,
                      questionsState.selectedAnswerIndex == index
                          ? OptionState.wrong
                          : questionsState.correctAnswerIndex == index
                              ? OptionState.correct
                              : OptionState.unchosen,
                    );
                  }
                },
              ),
            ),
          ],
        ));
      },
    );
  }
}
