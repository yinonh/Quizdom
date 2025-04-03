import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trivia/core/common_widgets/app_bar.dart';
import 'package:trivia/core/common_widgets/base_screen.dart';
import 'package:trivia/core/constants/app_constant.dart';
import 'package:trivia/core/constants/constant_strings.dart';
import 'package:trivia/core/utils/general_functions.dart';
import 'package:trivia/core/utils/enums/game_stage.dart';
import 'package:trivia/features/quiz_screen/view_model/duel_quiz_screen_manager.dart';
import 'package:trivia/features/quiz_screen/widgets/question_review.dart';
import 'package:trivia/features/quiz_screen/widgets/question_shemmer.dart';
import 'package:trivia/features/quiz_screen/widgets/duel_question_widget.dart';
import 'package:trivia/features/results_screen/results_screen.dart';

class DuelQuizScreen extends ConsumerWidget {
  static const routeName = Strings.duelQuizRouteName;

  const DuelQuizScreen({super.key});

  // Add this widget to your DuelQuizScreen when gameStage is 'created'
  Widget buildStartGameButton(
      DuelQuizState state, BuildContext context, WidgetRef ref) {
    if (!state.isHost || state.gameStage != GameStage.created) {
      return state.isHost
          ? const SizedBox()
          : const Center(child: Text("Waiting for host to start the game..."));
    }

    return Center(
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppConstant.secondaryColor,
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
        ),
        onPressed: () {
          ref.read(duelQuizScreenManagerProvider.notifier).startGame();
        },
        child: const Text(
          "Start Game",
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final questionsState = ref.watch(duelQuizScreenManagerProvider);

    return BaseScreen(
      child: Scaffold(
        backgroundColor: AppConstant.primaryColor,
        appBar: CustomAppBar(
          title: questionsState.when(
            data: (state) => cleanCategoryName(state.categoryName),
            error: (error, _) => "Error",
            loading: () => "Loading...",
          ),
          actions: [
            // Score indicator
            questionsState.when(
              data: (state) {
                // Get current user index
                final currentUserId = ref
                    .read(duelQuizScreenManagerProvider.notifier)
                    .getCurrentUserId();
                final userIndex = state.users.indexOf(currentUserId ?? "");
                if (userIndex == -1 || state.userScores.isEmpty) {
                  return const SizedBox();
                }

                final myScore = userIndex < state.userScores.length
                    ? state.userScores[userIndex]
                    : 0;
                return Padding(
                  padding: const EdgeInsets.only(right: 16.0),
                  child: Chip(
                    label: Text(
                      "Score: $myScore",
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    backgroundColor: AppConstant.secondaryColor,
                  ),
                );
              },
              error: (_, __) => const SizedBox(),
              loading: () => const SizedBox(),
            ),
          ],
        ),
        body: Container(
          height: double.infinity,
          width: double.infinity,
          padding: const EdgeInsets.all(16.0),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(35.0),
              topRight: Radius.circular(35.0),
            ),
          ),
          child: questionsState.when(
            data: (state) {
              // If game is completed, navigate to results
              if (state.gameStage == GameStage.completed) {
                // Use post-frame callback to navigate after the build is complete
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  Navigator.pushReplacementNamed(
                      context, ResultsScreen.routeName);
                });
                return const Center(child: CircularProgressIndicator());
              }

              // Show start game button when game is in created stage
              if (state.gameStage == GameStage.created) {
                return buildStartGameButton(state, context, ref);
              }

              // Show different widgets based on game stage
              if (state.gameStage == GameStage.questionReview) {
                return QuestionReviewWidget(
                  question: state.questions[state.questionIndex],
                  correctAnswer:
                      state.questions[state.questionIndex].correctAnswer!,
                  selectedAnswerIndex: state.selectedAnswerIndex,
                  correctAnswerIndex: state.correctAnswerIndex,
                  userScores: state.userScores,
                  users: state.users,
                );
              } else {
                return DuelQuestionWidget(
                  users: state.users,
                  userScores: state.userScores,
                );
              }
            },
            error: (error, _) => Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 48, color: Colors.red),
                  const SizedBox(height: 16),
                  Text(
                    "Error: ${error.toString()}",
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text("Go Back"),
                  ),
                ],
              ),
            ),
            loading: () => const ShimmerLoadingQuestionWidget(),
          ),
        ),
      ),
    );
  }
}
