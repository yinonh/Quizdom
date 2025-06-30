import 'package:flutter/material.dart';
import 'package:Quizdom/core/constants/app_constant.dart';
import 'package:Quizdom/core/utils/enums/game_stage.dart';
import 'package:Quizdom/core/utils/size_config.dart';

class DuelMultipleAnswerWidget extends StatelessWidget {
  final String question;
  final List<String> options;
  final Function(int) onAnswerSelected;
  final int questionIndex;
  final int? selectedAnswerIndex;
  final int correctAnswerIndex;
  final Map<String, Map<int, int>> userAnswers;
  final GameStage gameStage;
  final List<String> users;

  const DuelMultipleAnswerWidget({
    super.key,
    required this.question,
    required this.options,
    required this.onAnswerSelected,
    required this.questionIndex,
    this.selectedAnswerIndex,
    required this.correctAnswerIndex,
    this.userAnswers = const {},
    required this.gameStage,
    required this.users,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.all(calcHeight(16)),
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

              return Padding(
                padding: EdgeInsets.symmetric(
                    horizontal: calcWidth(16), vertical: calcHeight(8)),
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
                        color: isSelected
                            ? AppConstant.primaryColor
                            : AppConstant.lightGray,
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
      return Colors.green.withValues(alpha: 0.3);
    } else if (userAnswers.values
        .any((answers) => answers[questionIndex] == index)) {
      return Colors.red.withValues(alpha: 0.2);
    }

    return Colors.white;
  }
}
