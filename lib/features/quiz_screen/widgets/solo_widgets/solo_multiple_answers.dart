import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trivia/core/constants/constant_strings.dart';
import 'package:trivia/features/quiz_screen/view_model/solo_quiz_screen_manager.dart';

enum OptionState { correct, wrong, unchosen }

class SoloMultipleAnswerWidget extends ConsumerWidget {
  final String question;
  final List<String> options;
  final Function(int) onAnswerSelected;

  const SoloMultipleAnswerWidget({
    super.key,
    required this.question,
    required this.options,
    required this.onAnswerSelected,
  });

  // Get the appropriate color for an option based on the review state
  Color _getOptionColor(int index, OptionState optionState) {
    switch (optionState) {
      case OptionState.correct:
        return Colors.green.withValues(alpha: 0.3);
      case OptionState.wrong:
        return Colors.red.withValues(alpha: 0.2);
      case OptionState.unchosen:
        return Colors.white;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final questionsState =
        ref.watch(soloQuizScreenManagerProvider).asData!.value;
    final selectedAnswerIndex = questionsState.selectedAnswerIndex;
    final correctAnswerIndex = questionsState.correctAnswerIndex;

    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Question container - styled like the duel mode
              Container(
                padding: const EdgeInsets.all(16.0),
                margin: const EdgeInsets.only(bottom: 16.0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "${Strings.question} ${questionsState.questionIndex + 1}/10",
                      style: const TextStyle(color: Color(0xFF6E6E6E)),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      question,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),

              // Options list - Using a column of options instead of ListView with Expanded
              Column(
                mainAxisSize: MainAxisSize.min,
                children: List.generate(
                  options.length,
                  (index) {
                    // Determine the option state
                    OptionState optionState = OptionState.unchosen;
                    if (selectedAnswerIndex != null) {
                      if (index == correctAnswerIndex) {
                        optionState = OptionState.correct;
                      } else if (index == selectedAnswerIndex) {
                        optionState = OptionState.wrong;
                      }
                    }

                    final isSelected = index == selectedAnswerIndex;
                    final isCorrect = index == correctAnswerIndex;
                    final isAnswered = selectedAnswerIndex != null;

                    return Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      child: InkWell(
                        onTap:
                            isAnswered ? null : () => onAnswerSelected(index),
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: _getOptionColor(index, optionState),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: isSelected
                                  ? Colors.blue
                                  : Colors.grey.shade300,
                              width: isSelected ? 2 : 1,
                            ),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  options[index],
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: isSelected
                                        ? FontWeight.bold
                                        : FontWeight.normal,
                                    color: isAnswered && isCorrect
                                        ? Colors.black
                                        : null,
                                  ),
                                ),
                              ),
                              if (isAnswered && isCorrect)
                                const Icon(Icons.check_circle,
                                    color: Colors.green),
                              if (isAnswered && isSelected && !isCorrect)
                                const Icon(Icons.close_rounded,
                                    color: Colors.red),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
