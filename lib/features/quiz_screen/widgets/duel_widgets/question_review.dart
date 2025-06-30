import 'package:flutter/material.dart';
import 'package:Quizdom/core/constants/app_constant.dart';
import 'package:Quizdom/core/constants/constant_strings.dart';
import 'package:Quizdom/core/utils/size_config.dart';
import 'package:Quizdom/data/models/question.dart';

class QuestionReviewWidget extends StatelessWidget {
  final Question question;
  final String correctAnswer;
  final int? selectedAnswerIndex;
  final int correctAnswerIndex;

  const QuestionReviewWidget({
    super.key,
    required this.question,
    required this.correctAnswer,
    required this.selectedAnswerIndex,
    required this.correctAnswerIndex,
  });

  @override
  Widget build(BuildContext context) {
    final isCorrect = selectedAnswerIndex == correctAnswerIndex;

    return Container(
      color: Colors.white,
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Middle: Icon + feedback + question + correct answer
            Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      isCorrect ? Icons.check_circle : Icons.cancel,
                      size: calcHeight(70),
                      color: isCorrect ? AppConstant.green : AppConstant.red,
                    ),
                    SizedBox(height: calcHeight(8)),
                    Text(
                      isCorrect
                          ? Strings.correctExclamationMark
                          : selectedAnswerIndex == -1
                              ? Strings.timesUp
                              : Strings.incorrect,
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: isCorrect ? Colors.green : Colors.red,
                      ),
                    ),
                    SizedBox(height: calcHeight(20)),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: calcWidth(16)),
                      child: Text(
                        question.question!,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    SizedBox(height: calcWidth(16)),
                    Container(
                      width: double.infinity,
                      margin: EdgeInsets.symmetric(horizontal: calcWidth(16)),
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.green.shade50,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.green),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            Strings.correctAnswer,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: AppConstant.green,
                            ),
                          ),
                          SizedBox(height: calcHeight(8)),
                          Center(
                            child: Text(
                              correctAnswer,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Bottom: Timer
            Container(
              alignment: Alignment.center,
              padding: EdgeInsets.symmetric(
                  vertical: calcHeight(8), horizontal: calcWidth(19)),
              decoration: BoxDecoration(
                color: AppConstant.lightBlue,
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Text(
                Strings.nextQuestionIn3s,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: AppConstant.primaryColor,
                  fontSize: 14,
                ),
              ),
            ),
            SizedBox(height: calcHeight(16)),
          ],
        ),
      ),
    );
  }
}
