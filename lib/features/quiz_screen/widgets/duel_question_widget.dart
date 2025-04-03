import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trivia/core/constants/app_constant.dart';
import 'package:trivia/core/utils/enums/game_stage.dart';
import 'package:trivia/features/quiz_screen/view_model/duel_quiz_screen_manager.dart';
import 'package:trivia/features/quiz_screen/widgets/multiple_answer_widget.dart';
import 'package:trivia/features/quiz_screen/widgets/question_shemmer.dart';

class DuelQuestionWidget extends ConsumerWidget {
  final List<String> users;
  final List<int> userScores;

  const DuelQuestionWidget({
    super.key,
    required this.users,
    required this.userScores,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final questionsState = ref.watch(duelQuizScreenManagerProvider);

    return questionsState.when(
      data: (data) {
        if (data.questions.length <= data.questionIndex) {
          return const Center(child: CircularProgressIndicator());
        }

        final currentQuestion = data.questions[data.questionIndex];

        return Column(
          children: [
            // User Scores
            UserScoreBar(users: users, userScores: userScores),

            const SizedBox(height: 10),

            // Question and Answers
            Expanded(
              child: MultipleAnswerWidget(
                question: currentQuestion.question!,
                options: data.shuffledOptions,
                onAnswerSelected: (index) {
                  // Only allow selection if not already selected and game is active
                  if (data.selectedAnswerIndex == null &&
                      data.gameStage == GameStage.active) {
                    // Ensure this is correct
                    ref
                        .read(duelQuizScreenManagerProvider.notifier)
                        .selectAnswer(index);
                  }
                },
                questionIndex: data.questionIndex,
                selectedAnswerIndex: data.selectedAnswerIndex,
                correctAnswerIndex: data.correctAnswerIndex,
                userAnswers: data.userAnswers,
                gameStage: data.gameStage,
                users: users,
              ),
            ),

            // Timer Bar
            const SizedBox(height: 10),
            data.selectedAnswerIndex == null
                ? LinearProgressIndicator(
                    value: data.timeLeft / AppConstant.questionTime,
                    minHeight: 10,
                    borderRadius: const BorderRadius.all(Radius.circular(20)),
                    color: data.timeLeft / AppConstant.questionTime < 0.2
                        ? Colors.red
                        : data.timeLeft / AppConstant.questionTime < 0.5
                            ? Colors.amber
                            : AppConstant.onPrimaryColor,
                  )
                : const LinearProgressIndicator(
                    value: 1.0,
                    minHeight: 10,
                    borderRadius: BorderRadius.all(Radius.circular(20)),
                    color: AppConstant.onPrimaryColor,
                  ),
            const SizedBox(height: 20),
          ],
        );
      },
      error: (error, _) {
        return Text(error.toString());
      },
      loading: () {
        return const ShimmerLoadingQuestionWidget();
      },
    );
  }
}

// New widget to show user scores in a horizontal bar
class UserScoreBar extends StatelessWidget {
  final List<String> users;
  final List<int> userScores;

  const UserScoreBar({
    super.key,
    required this.users,
    required this.userScores,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: List.generate(
            users.length > 2 ? 2 : users.length, // Show max 2 users
            (index) {
              final score = index < userScores.length ? userScores[index] : 0;

              return Column(
                children: [
                  CircleAvatar(
                    backgroundColor: index == 0
                        ? Colors.blue.shade200
                        : Colors.orange.shade200,
                    child: Text(
                      users[index].substring(0, 1).toUpperCase(),
                      style: TextStyle(
                        color: index == 0
                            ? Colors.blue.shade800
                            : Colors.orange.shade800,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "Player ${index + 1}",
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                  Text(
                    "$score pts",
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: AppConstant.secondaryColor,
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
