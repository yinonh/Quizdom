import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trivia/core/common_widgets/custom_when.dart';
import 'package:trivia/core/constants/app_constant.dart';
import 'package:trivia/core/utils/enums/game_stage.dart';
import 'package:trivia/core/utils/size_config.dart';
import 'package:trivia/features/quiz_screen/view_model/duel_quiz_screen_manager.dart';
import 'package:trivia/features/quiz_screen/widgets/duel_widgets/duel_multiple_answer_widget.dart';
import 'package:trivia/features/quiz_screen/widgets/duel_widgets/user_score_bar.dart';
import 'package:trivia/features/quiz_screen/widgets/question_shemmer.dart';
import 'package:trivia/data/models/trivia_user.dart'; // For TriviaUser
import 'package:trivia/core/utils/enums/selected_emoji.dart'; // For SelectedEmoji (indirectly)
import 'package:cloud_firestore/cloud_firestore.dart'; // For Timestamp (indirectly)


class DuelQuestionWidget extends ConsumerWidget {
  final List<String> usersList; // Renamed from users
  final Map<String, int> userScores;
  final String roomId;
  final Map<String, Map<String, dynamic>> userEmojis;
  final Function(String userId) onCurrentUserAvatarTap;
  final String? currentUserId;
  // opponentId can be derived if needed, or passed if convenient
  final TriviaUser? currentUser; // Already passed to UserScoreBar
  final TriviaUser? opponentUser; // Already passed to UserScoreBar


  const DuelQuestionWidget({
    super.key,
    required this.usersList,
    required this.userScores,
    required this.roomId,
    required this.userEmojis,
    required this.onCurrentUserAvatarTap,
    required this.currentUserId,
    this.currentUser, // Keep as they are passed to UserScoreBar
    this.opponentUser, // Keep as they are passed to UserScoreBar
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final questionsState = ref.watch(duelQuizScreenManagerProvider(roomId));

    return questionsState.customWhen(
      data: (data) {
        if (data.questions.length <= data.questionIndex) {
          return const Center(child: CircularProgressIndicator());
        }

        final currentQuestion = data.questions[data.questionIndex];

        return Column(
          children: [
            // User Scores - now with user data
            UserScoreBar(
              users: usersList, // Pass usersList
              userScores: userScores,
              opponent: opponentUser ?? data.opponent, // Use passed opponentUser or from state
              currentUser: currentUser ?? data.currentUser, // Use passed currentUser or from state
              userEmojis: userEmojis, // Pass down
              onCurrentUserAvatarTap: onCurrentUserAvatarTap, // Pass down
              currentUserId: currentUserId, // Pass down
            ),

            SizedBox(height: calcHeight(10)),

            // Question and Answers
            Expanded(
              child: DuelMultipleAnswerWidget(
                question: currentQuestion.question!,
                options: data.shuffledOptions,
                onAnswerSelected: (index) {
                  // Only allow selection if not already selected and game is active
                  if (data.selectedAnswerIndex == null &&
                      data.gameStage == GameStage.active) {
                    // Ensure this is correct
                    ref
                        .read(duelQuizScreenManagerProvider(roomId).notifier)
                        .selectAnswer(index);
                  }
                },
                questionIndex: data.questionIndex,
                selectedAnswerIndex: data.selectedAnswerIndex,
                correctAnswerIndex: data.correctAnswerIndex,
                userAnswers: data.userAnswers,
                gameStage: data.gameStage,
                users: usersList, // Pass usersList
              ),
            ),

            // Timer Bar
            SizedBox(height: calcHeight(10)),
            data.selectedAnswerIndex == null
                ? LinearProgressIndicator(
                    value: data.timeLeft / AppConstant.questionTime,
                    minHeight: calcHeight(10),
                    borderRadius: const BorderRadius.all(Radius.circular(20)),
                    color: data.timeLeft / AppConstant.questionTime < 0.2
                        ? AppConstant.red
                        : data.timeLeft / AppConstant.questionTime < 0.5
                            ? AppConstant.amber
                            : AppConstant.onPrimaryColor,
                  )
                : LinearProgressIndicator(
                    value: 1.0,
                    minHeight: calcHeight(10),
                    borderRadius: const BorderRadius.all(Radius.circular(20)),
                    color: AppConstant.onPrimaryColor,
                  ),
            SizedBox(height: calcHeight(20)),
          ],
        );
      },
      loading: () {
        return const ShimmerLoadingQuestionWidget();
      },
    );
  }
}
