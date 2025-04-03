import 'package:flutter/material.dart';
import 'package:trivia/core/constants/app_constant.dart';
import 'package:trivia/data/models/question.dart';

class QuestionReviewWidget extends StatelessWidget {
  final Question question;
  final String correctAnswer;
  final int? selectedAnswerIndex;
  final int correctAnswerIndex;
  final List<int> userScores;
  final List<String> users;

  const QuestionReviewWidget({
    super.key,
    required this.question,
    required this.correctAnswer,
    required this.selectedAnswerIndex,
    required this.correctAnswerIndex,
    required this.userScores,
    required this.users,
  });

  @override
  Widget build(BuildContext context) {
    final isCorrect = selectedAnswerIndex == correctAnswerIndex;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Question review header
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              "Question Review",
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppConstant.primaryColor,
                  ),
            ),
          ),

          // Result icon
          Icon(
            isCorrect ? Icons.check_circle : Icons.cancel,
            size: 80,
            color: isCorrect ? Colors.green : Colors.red,
          ),

          const SizedBox(height: 16),

          // Result text
          Text(
            isCorrect
                ? "Correct!"
                : selectedAnswerIndex == -1
                    ? "Time's up!"
                    : "Incorrect!",
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: isCorrect ? Colors.green : Colors.red,
                ),
          ),

          const SizedBox(height: 24),

          // Question text
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              question.question!,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Correct answer
          Container(
            padding: const EdgeInsets.all(16),
            margin: const EdgeInsets.symmetric(horizontal: 16),
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
                const SizedBox(height: 4),
                Text(
                  correctAnswer,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 32),

          // Current standings
          Card(
            elevation: 4,
            margin: const EdgeInsets.symmetric(horizontal: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  const Text(
                    "Current Standings",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: List.generate(
                      users.length > 2 ? 2 : users.length, // Show max 2 users
                      (index) {
                        final score =
                            index < userScores.length ? userScores[index] : 0;

                        return Column(
                          children: [
                            CircleAvatar(
                              backgroundColor: index == 0
                                  ? Colors.blue.shade200
                                  : Colors.orange.shade200,
                              radius: 24,
                              child: Text(
                                users[index].substring(0, 1).toUpperCase(),
                                style: TextStyle(
                                  fontSize: 18,
                                  color: index == 0
                                      ? Colors.blue.shade800
                                      : Colors.orange.shade800,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              "Player ${index + 1}",
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              "$score pts",
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                                color: AppConstant.secondaryColor,
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),

          const Spacer(),

          // Wait message
          const Text(
            "Next question in a moment...",
            style: TextStyle(
              fontStyle: FontStyle.italic,
              color: Colors.grey,
            ),
          ),

          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
