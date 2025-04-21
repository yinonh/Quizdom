import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lottie/lottie.dart';
import 'package:trivia/core/common_widgets/app_bar.dart';
import 'package:trivia/core/common_widgets/base_screen.dart';
import 'package:trivia/core/constants/app_constant.dart';
import 'package:trivia/core/constants/constant_strings.dart';
import 'package:trivia/core/utils/general_functions.dart';
import 'package:trivia/core/utils/enums/game_stage.dart';
import 'package:trivia/core/utils/size_config.dart';
import 'package:trivia/features/quiz_screen/view_model/duel_quiz_screen_manager.dart';
import 'package:trivia/features/quiz_screen/widgets/duel_widgets/question_review.dart';
import 'package:trivia/features/quiz_screen/widgets/question_shemmer.dart';
import 'package:trivia/features/quiz_screen/widgets/duel_widgets/duel_question_widget.dart';
import 'package:trivia/features/results_screen/results_screen.dart';

class DuelQuizScreen extends ConsumerWidget {
  static const routeName = 'duel-quiz';
  final String roomId;

  const DuelQuizScreen({super.key, required this.roomId});

  Widget buildWaitingOrCountdown(DuelQuizState state) {
    // Set the duration of your Lottie animation here.
    const animationDuration = Duration(seconds: 5);

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          FutureBuilder(
            future: Future.delayed(animationDuration),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.done) {
                return Container(
                  padding: EdgeInsets.all(calcWidth(10)),
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppConstant.primaryColor,
                  ),
                  child: const Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  ),
                );
              } else {
                return SizedBox(
                  height: calcHeight(250),
                  width: calcWidth(250),
                  child: Lottie.asset(
                    Strings.countDownAnimation,
                    repeat: false,
                  ),
                );
              }
            },
          ),
          const SizedBox(height: 20),
          Text(
            state.isHost
                ? "Waiting for all players to join..."
                : "Waiting for host to start the game...",
            style: const TextStyle(fontSize: 18),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final questionsState = ref.watch(duelQuizScreenManagerProvider(roomId));

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
                    .read(duelQuizScreenManagerProvider(roomId).notifier)
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
                  context.goNamed(ResultsScreen.routeName);
                });
                return const Center(child: CircularProgressIndicator());
              }

              if (state.gameStage == GameStage.created) {
                return buildWaitingOrCountdown(state);
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
                  currentUser: state.currentUser,
                  opponent: state.opponent,
                );
              } else {
                return DuelQuestionWidget(
                  users: state.users,
                  userScores: state.userScores,
                  roomId: roomId,
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
                    onPressed: () => context.pop(),
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
