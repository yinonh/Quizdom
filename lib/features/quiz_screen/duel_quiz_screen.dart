import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:Quizdom/core/common_widgets/ad_interstitial_widget.dart';
import 'package:Quizdom/core/common_widgets/app_bar.dart';
import 'package:Quizdom/core/common_widgets/base_screen.dart';
import 'package:Quizdom/core/common_widgets/custom_when.dart';
import 'package:Quizdom/core/common_widgets/emoji_bubble.dart';
import 'package:Quizdom/core/constants/app_constant.dart';
import 'package:Quizdom/core/constants/app_routes.dart';
import 'package:Quizdom/core/constants/constant_strings.dart';
import 'package:Quizdom/core/navigation/route_extensions.dart';
import 'package:Quizdom/core/utils/enums/game_stage.dart';
import 'package:Quizdom/core/utils/size_config.dart';
import 'package:Quizdom/features/quiz_screen/view_model/duel_quiz_screen_manager.dart';
import 'package:Quizdom/features/quiz_screen/widgets/duel_widgets/duel_question_widget.dart';
import 'package:Quizdom/features/quiz_screen/widgets/duel_widgets/question_review.dart';
import 'package:Quizdom/features/quiz_screen/widgets/duel_widgets/waiting_or_countdown.dart';
import 'package:Quizdom/features/quiz_screen/widgets/duel_widgets/user_score_bar.dart';
import 'package:Quizdom/features/quiz_screen/widgets/question_shemmer.dart';
import 'package:Quizdom/features/results_screen/duel_result_screen.dart';
import 'package:Quizdom/features/results_screen/game_canceled.dart';

class DuelQuizScreen extends ConsumerStatefulWidget {
  static const routeName = AppRoutes.duelQuizRouteName;
  final String roomId;

  const DuelQuizScreen({super.key, required this.roomId});

  @override
  ConsumerState<DuelQuizScreen> createState() => _DuelQuizScreenState();
}

class _DuelQuizScreenState extends ConsumerState<DuelQuizScreen> {
  String? _showEmojiBubbleForUserId;
  bool _showingAd = false;

  void _showInterstitialAndNavigate(String roomId) {
    if (_showingAd) return;

    setState(() {
      _showingAd = true;
    });

    // Show the ad widget as a new route using GoRouter
    pushRoute<void>(
      InterstitialAdWidget.routeName,
      extra: {
        'onComplete': () {
          // Navigate to results after ad completion
          pop(); // Pop the ad screen
          if (context.mounted) {
            goRoute(
              DuelResultsScreen.routeName,
              pathParameters: {'roomId': roomId},
            );
          }
        },
        'onSkip': () {
          // Navigate to results if user skips
          pop(); // Pop the ad screen
          if (context.mounted) {
            goRoute(
              DuelResultsScreen.routeName,
              pathParameters: {'roomId': roomId},
            );
          }
        },
      },
    );
  }

  void _showInterstitialAndNavigateToGameCanceled(DuelQuizState state) {
    if (_showingAd) return; // Prevent multiple ad shows

    setState(() {
      _showingAd = true;
    });

    // Show the ad widget as a new route using GoRouter
    pushRoute<void>(
      InterstitialAdWidget.routeName,
      extra: {
        'onComplete': () {
          // Navigate to game canceled screen after ad completion
          pop(); // Pop the ad screen
          if (context.mounted) {
            goRoute(
              GameCanceledScreen.routeName,
              extra: {
                'users': state.users,
                'userScores': state.userScores,
                'currentUserId': state.currentUser?.uid ?? '',
                'opponentId': state.opponent?.uid ?? '',
              },
            );
          }
        },
        'onSkip': () {
          // Navigate to game canceled screen if user skips
          pop(); // Pop the ad screen
          if (context.mounted) {
            goRoute(
              GameCanceledScreen.routeName,
              extra: {
                'users': state.users,
                'userScores': state.userScores,
                'currentUserId': state.currentUser?.uid ?? '',
                'opponentId': state.opponent?.uid ?? '',
              },
            );
          }
        },
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final questionsState =
        ref.watch(duelQuizScreenManagerProvider(widget.roomId));

    return BaseScreen(
      child: Scaffold(
        backgroundColor: AppConstant.primaryColor,
        appBar: CustomAppBar(
          actions: [
            // Score indicator
            questionsState.customWhen(
              data: (state) {
                final myScore = state.userScores[state.currentUser?.uid] ?? 0;
                return Padding(
                  padding: EdgeInsets.only(right: calcWidth(16)),
                  child: Chip(
                    label: Text(
                      "${Strings.score} $myScore",
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    backgroundColor: AppConstant.secondaryColor,
                  ),
                );
              },
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
          child: GestureDetector(
            behavior: HitTestBehavior.translucent,
            onTap: () {
              // Close emoji bubble when tapping outside
              if (_showEmojiBubbleForUserId != null) {
                setState(() {
                  _showEmojiBubbleForUserId = null;
                });
              }
            },
            child: Stack(
              children: [
                questionsState.customWhen(
                  data: (state) {
                    // If game is completed, navigate to results
                    if (state.gameStage == GameStage.completed) {
                      // Use post-frame callback to navigate after the build is complete
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        if (!_showingAd) {
                          _showInterstitialAndNavigate(state.roomId!);
                        }
                      });
                      return const Center(child: CircularProgressIndicator());
                    }

                    // Handle canceled game state
                    if (state.gameStage == GameStage.canceled) {
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        if (!_showingAd) {
                          _showInterstitialAndNavigateToGameCanceled(state);
                        }
                      });
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (state.gameStage == GameStage.created) {
                      return const WaitingOrCountdown();
                    }

                    // Define avatar tap handler
                    void handleAvatarTap(String userId) {
                      // Only allow current user to trigger their own bubble
                      if (userId == state.currentUser?.uid) {
                        setState(() {
                          _showEmojiBubbleForUserId = userId;
                        });
                      }
                    }

                    return Column(
                      children: [
                        // Extracted UserScoreBar
                        UserScoreBar(
                          users: state.users,
                          userScores: state.userScores,
                          opponent: state.opponent,
                          currentUser: state.currentUser,
                          userEmojis: state.userEmojis,
                          onCurrentUserAvatarTap: handleAvatarTap,
                          currentUserId: state.currentUser?.uid,
                        ),

                        // Extracted Question Number Display
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            "${Strings.question} ${state.questionIndex + 1}/${AppConstant.numberOfQuestions}",
                            textAlign: TextAlign.start,
                            style: const TextStyle(
                                color: AppConstant.highlightColor,
                                fontWeight: FontWeight.bold),
                          ),
                        ),

                        Expanded(
                          child: state.gameStage == GameStage.questionReview
                              ? QuestionReviewWidget(
                                  question:
                                      state.questions[state.questionIndex],
                                  correctAnswer: state
                                      .questions[state.questionIndex]
                                      .correctAnswer!,
                                  selectedAnswerIndex:
                                      state.selectedAnswerIndex,
                                  correctAnswerIndex: state.correctAnswerIndex,
                                )
                              : DuelQuestionWidget(
                                  roomId: widget.roomId,
                                  gameStage: state.gameStage,
                                ),
                        ),
                      ],
                    );
                  },
                  error: (error, _) => Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.error_outline,
                            size: 48, color: AppConstant.red),
                        SizedBox(height: calcHeight(16)),
                        Text(
                          "${Strings.error} ${error.toString()}",
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontSize: 16),
                        ),
                        SizedBox(height: calcHeight(24)),
                        ElevatedButton(
                          onPressed: () => pop(),
                          child: const Text(Strings.back),
                        ),
                      ],
                    ),
                  ),
                  loading: () => const ShimmerLoadingQuestionWidget(),
                ),
                if (_showEmojiBubbleForUserId != null &&
                    questionsState.value?.currentUser?.uid ==
                        _showEmojiBubbleForUserId)
                  Positioned(
                    top: calcHeight(40),
                    left: 0,
                    right: 0,
                    child: Align(
                      alignment: Alignment.center,
                      child: GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: () {
                          // Prevent the tap from propagating to the parent GestureDetector
                          // This ensures the bubble doesn't close when tapped
                        },
                        child: EmojiBubble(
                          onEmojiSelected: (selectedEmoji) {
                            // Changed parameter name for clarity
                            final notifier = ref.read(
                                duelQuizScreenManagerProvider(widget.roomId)
                                    .notifier);
                            notifier.updateUserEmoji(
                                selectedEmoji); // Pass SelectedEmoji object
                            setState(() {
                              _showEmojiBubbleForUserId = null;
                            });
                          },
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
