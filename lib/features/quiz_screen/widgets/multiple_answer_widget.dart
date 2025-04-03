import 'package:flutter/material.dart';
import 'package:trivia/core/utils/enums/game_stage.dart';

class MultipleAnswerWidget extends StatelessWidget {
  final String question;
  final List<String> options;
  final Function(int) onAnswerSelected;
  final int questionIndex;
  final int? selectedAnswerIndex;
  final int correctAnswerIndex;
  final Map<String, Map<int, int>> userAnswers;
  final GameStage gameStage;
  final List<String> users;

  const MultipleAnswerWidget({
    Key? key,
    required this.question,
    required this.options,
    required this.onAnswerSelected,
    required this.questionIndex,
    this.selectedAnswerIndex,
    required this.correctAnswerIndex,
    this.userAnswers = const {},
    required this.gameStage,
    required this.users,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            question,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: options.length,
            itemBuilder: (context, index) {
              // Show different UI during question review
              final isReview = gameStage == GameStage.questionReview;
              final isCorrect = index == correctAnswerIndex;
              final isSelected = index == selectedAnswerIndex;

              // Get user selections for this question during review
              List<Widget> userIndicators = [];
              if (isReview) {
                for (int i = 0; i < users.length && i < 2; i++) {
                  final userId = users[i];
                  final userAnswer = userAnswers[userId]?[questionIndex];

                  if (userAnswer == index) {
                    userIndicators.add(
                      CircleAvatar(
                        radius: 12,
                        backgroundColor: i == 0
                            ? Colors.blue.shade200
                            : Colors.orange.shade200,
                        child: Text(
                          (i + 1).toString(),
                          style: TextStyle(
                            fontSize: 10,
                            color: i == 0
                                ? Colors.blue.shade800
                                : Colors.orange.shade800,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    );
                  }
                }
              }

              return Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: InkWell(
                  onTap: selectedAnswerIndex == null
                      ? () => onAnswerSelected(index)
                      : null,
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: _getOptionColor(index, isReview),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isSelected ? Colors.blue : Colors.grey.shade300,
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
                              color:
                                  isReview && isCorrect ? Colors.white : null,
                            ),
                          ),
                        ),
                        if (isReview && isCorrect)
                          const Icon(Icons.check_circle, color: Colors.white),
                        if (userIndicators.isNotEmpty) ...[
                          const SizedBox(width: 8),
                          ...userIndicators,
                        ],
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Color _getOptionColor(int index, bool isReview) {
    if (!isReview) {
      return Colors.white;
    }

    // During review stage, highlight correct and incorrect answers
    if (index == correctAnswerIndex) {
      return Colors.green;
    } else if (userAnswers.values
        .any((answers) => answers[questionIndex] == index)) {
      return Colors.red.shade200; // Some user selected this incorrect answer
    }

    return Colors.white;
  }
}
