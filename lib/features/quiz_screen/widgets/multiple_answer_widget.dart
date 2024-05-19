import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trivia/features/quiz_screen/view_model/quiz_screen_manager.dart';

class MultipleAnswerWidget extends ConsumerWidget {
  final String question;
  final List<String> options;
  final Function(int) onAnswerSelected;

  const MultipleAnswerWidget({
    Key? key,
    required this.question,
    required this.options,
    required this.onAnswerSelected,
  }) : super(key: key);

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
              return GestureDetector(
                onTap: () => onAnswerSelected(index),
                child: Container(
                  margin: const EdgeInsets.only(bottom: 8.0),
                  padding: const EdgeInsets.all(12.0),
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  child: Text(
                    options[index],
                    style: const TextStyle(fontSize: 16.0),
                  ),
                ),
              );
            } else if (questionsState.selectedAnswerIndex ==
                questionsState.correctAnswerIndex) {
              return GestureDetector(
                onTap: () => onAnswerSelected(index),
                child: Container(
                  margin: const EdgeInsets.only(bottom: 8.0),
                  padding: const EdgeInsets.all(12.0),
                  decoration: BoxDecoration(
                    color: questionsState.correctAnswerIndex == index
                        ? Colors.green.withOpacity(0.2)
                        : Colors.blue.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  child: Text(
                    options[index],
                    style: const TextStyle(fontSize: 16.0),
                  ),
                ),
              );
            } else {
              return GestureDetector(
                onTap: () => onAnswerSelected(index),
                child: Container(
                  margin: const EdgeInsets.only(bottom: 8.0),
                  padding: const EdgeInsets.all(12.0),
                  decoration: BoxDecoration(
                    color: questionsState.selectedAnswerIndex == index
                        ? Colors.red.withOpacity(0.2)
                        : questionsState.correctAnswerIndex == index
                            ? Colors.green.withOpacity(0.2)
                            : Colors.blue.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  child: Text(
                    options[index],
                    style: const TextStyle(fontSize: 16.0),
                  ),
                ),
              );
            }
          },
        ),
      ],
    );
  }
}
