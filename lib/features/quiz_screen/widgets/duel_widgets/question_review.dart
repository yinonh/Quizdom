import 'package:flutter/material.dart';
import 'package:trivia/data/models/question.dart';
import 'package:trivia/data/models/trivia_user.dart';
import 'package:trivia/features/quiz_screen/widgets/duel_widgets/user_score_bar.dart';

class QuestionReviewWidget extends StatelessWidget {
  final Question question;
  final String correctAnswer;
  final int? selectedAnswerIndex;
  final int correctAnswerIndex;
  final List<int> userScores;
  final List<String> users;
  final TriviaUser? currentUser;
  final TriviaUser? opponent;

  const QuestionReviewWidget({
    super.key,
    required this.question,
    required this.correctAnswer,
    required this.selectedAnswerIndex,
    required this.correctAnswerIndex,
    required this.userScores,
    required this.users,
    required this.currentUser,
    required this.opponent,
  });

  @override
  Widget build(BuildContext context) {
    final isCorrect = selectedAnswerIndex == correctAnswerIndex;

    return Container(
      color: Colors.white,
      child: SafeArea(
        child: Column(
          children: [
            // Top: Score bar
            UserScoreBar(
              users: users,
              userScores: userScores,
              opponent: opponent,
              currentUser: currentUser,
            ),

            // Middle: Icon + feedback + question + correct answer
            Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      isCorrect ? Icons.check_circle : Icons.cancel,
                      size: 70,
                      color: isCorrect ? Colors.green : Colors.red,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      isCorrect
                          ? "Correct!"
                          : selectedAnswerIndex == -1
                              ? "Time's up!"
                              : "Incorrect!",
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: isCorrect ? Colors.green : Colors.red,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
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
                    const SizedBox(height: 16),
                    Container(
                      width: double.infinity,
                      margin: const EdgeInsets.symmetric(horizontal: 16),
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
                            "Correct Answer:",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.green,
                            ),
                          ),
                          const SizedBox(height: 8),
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
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.blue.shade100,
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Text(
                "Next question in 3s",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.blue,
                  fontSize: 14,
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
