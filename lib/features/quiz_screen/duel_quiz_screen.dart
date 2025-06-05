import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:trivia/core/common_widgets/app_bar.dart';
import 'package:trivia/core/common_widgets/base_screen.dart';
import 'package:trivia/core/common_widgets/custom_when.dart';
import 'package:trivia/core/constants/app_constant.dart';
import 'package:trivia/core/constants/app_routes.dart';
import 'package:trivia/core/constants/constant_strings.dart';
import 'package:trivia/core/utils/enums/game_stage.dart';
import 'package:trivia/core/utils/size_config.dart';
import 'package:trivia/features/quiz_screen/view_model/duel_quiz_screen_manager.dart';
import 'package:trivia/features/quiz_screen/widgets/duel_widgets/duel_question_widget.dart';
import 'package:trivia/features/quiz_screen/widgets/duel_widgets/question_review.dart';
import 'package:trivia/features/quiz_screen/widgets/duel_widgets/waiting_or_countdown.dart';
import 'package:trivia/features/quiz_screen/widgets/question_shemmer.dart';
import 'package:trivia/features/quiz_screen/widgets/duel_widgets/emoji_bubble.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Required for Timestamp
import 'package:trivia/features/results_screen/duel_result_screen.dart';
import 'package:trivia/features/results_screen/game_canceled.dart';


class DuelQuizScreen extends ConsumerStatefulWidget {
  static const routeName = AppRoutes.duelQuizRouteName;
  final String roomId;

  const DuelQuizScreen({super.key, required this.roomId});

  @override
  ConsumerState<DuelQuizScreen> createState() => _DuelQuizScreenState();
}

class _DuelQuizScreenState extends ConsumerState<DuelQuizScreen> {
  String? _showEmojiBubbleForUserId;
  // TODO: In a subsequent step, if UserAvatars are in child widgets,
  // we might need GlobalKeys to position the bubble accurately.
  // GlobalKey _currentUserAvatarKey = GlobalKey();
  // GlobalKey _opponentAvatarKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context); // Initialize SizeConfig
    final questionsState = ref.watch(duelQuizScreenManagerProvider(widget.roomId));

    // This is a placeholder for where UserAvatars would be if directly in this widget.
    // For now, we assume they are in child widgets like DuelQuestionWidget.
    // Tap handling for the current user's avatar to show the bubble will need to be
    // implemented there, or a callback passed down.

    // Dummy tap handler for current user's avatar - replace with actual later
    // This would typically be on the UserAvatar widget instance for the current user.
    // For now, let's imagine a button or area in this screen's main content
    // that triggers the bubble for the current user.
    // This will be refined when UserAvatars are actually handled.

    return BaseScreen(
      child: Scaffold(
        backgroundColor: AppConstant.primaryColor,
        appBar: CustomAppBar(
          actions: [
            // Score indicator
            questionsState.customWhen(
              data: (state) {
                final myScore = state.userScores[state.currentUser?.uid] ?? 0;
                // Example of how to get emoji data for UserAvatar (will be passed to it)
                // final currentUserEmojiData = state.userEmojis?[state.currentUser?.uid];
                // final emojiId = currentUserEmojiData?['emojiId'] as int?;
                // final timestamp = currentUserEmojiData?['timestamp'] as Timestamp?;
                // bool showBadge = false;
                // if (timestamp != null) {
                //   showBadge = DateTime.now().difference(timestamp.toDate()).inSeconds <= 6;
                // }

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
          child: Stack( // Stack for EmojiBubble overlay
            children: [
              questionsState.customWhen(
                data: (state) {
                  // If game is completed, navigate to results
              if (state.gameStage == GameStage.completed) {
                // Use post-frame callback to navigate after the build is complete
                WidgetsBinding.instance.addPostFrameCallback((_) async {
                  // Show loading indicator for 3 seconds
                  await Future.delayed(const Duration(seconds: 3));

                  // Navigate only if the widget is still mounted
                  if (context.mounted) {
                    context.goNamed(
                      DuelResultsScreen.routeName,
                      pathParameters: {'roomId': state.roomId!},
                    );
                  }
                });
                return const Center(child: CircularProgressIndicator());
              }

              // Handle canceled game state
              if (state.gameStage == GameStage.canceled) {
                WidgetsBinding.instance.addPostFrameCallback((_) async {
                  // Show loading indicator for 3 seconds
                  await Future.delayed(const Duration(seconds: 3));
                  // Navigate only if the widget is still mounted
                  if (context.mounted) {
                    context.goNamed(
                      GameCanceledScreen.routeName,
                      extra: {
                        'users': state.users,
                        'userScores': state.userScores,
                        'currentUserId': state.currentUser?.uid ?? '',
                        'opponentId': state.opponent?.uid ?? '',
                      },
                    );
                  }
                });
                return const Center(child: CircularProgressIndicator());
              }

              if (state.gameStage == GameStage.created) {
                return const WaitingOrCountdown();
              }

              // Show different widgets based on game stage
              // Define avatar tap handler
              void handleAvatarTap(String userId) {
                // Only allow current user to trigger their own bubble
                if (userId == state.currentUser?.uid) {
                  setState(() {
                    _showEmojiBubbleForUserId = userId;
                  });
                }
              }

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
                  // userEmojis: state.userEmojis, // Removed as QuestionReviewWidget does not accept it
                  // Not implementing tap-to-show-bubble for review screen for now
                );
              } else {
                // We need to pass emoji data and tap handlers down to DuelQuestionWidget
                // or wherever UserAvatars are displayed.
                // For now, DuelQuestionWidget remains unchanged in this step.
                // The actual UserAvatar instances will be modified in a subsequent task
                // to accept emojiId, showEmojiBadge, and an onAvatarTap for the current user.

                // Example: Pretend UserAvatars are here for demonstration of bubble trigger
                // This is NOT where they are, but shows how the bubble would be toggled.
                // if (state.currentUser != null) {
                //   GestureDetector(
                //     onTap: () {
                //       setState(() {
                //         _showEmojiBubbleForUserId = state.currentUser!.uid;
                //       });
                //     },
                // child: UserAvatar(user: state.currentUser, /* other params */) // This is conceptual
                //   )
                // }

                return DuelQuestionWidget(
                  usersList: state.users, // Renamed to avoid conflict if any
                  userScores: state.userScores,
                  roomId: widget.roomId, // Use widget.roomId in StatefulWidget
                  userEmojis: state.userEmojis,
                  onCurrentUserAvatarTap: handleAvatarTap,
                  currentUserId: state.currentUser?.uid,
                  opponentId: state.opponent?.uid,
                  currentUser: state.currentUser, // Pass for convenience
                  opponentUser: state.opponent, // Pass for convenience
                );
              }
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
                    onPressed: () => context.pop(),
                    child: const Text(Strings.back),
                  ),
                ],
              ),
            ),
                loading: () => const ShimmerLoadingQuestionWidget(),
              ),
              if (_showEmojiBubbleForUserId != null && questionsState.value?.currentUser?.uid == _showEmojiBubbleForUserId)
                Positioned(
                  // TODO: Position this better, e.g., near the current user's avatar.
                  // This requires knowing the avatar's position (e.g. via GlobalKey)
                  // For now, placing it at bottom center as a placeholder.
                  bottom: calcHeight(20), // Updated to use calcHeight
                  left: 0,
                  right: 0,
                  child: Align(
                    alignment: Alignment.center,
                    child: EmojiBubble(
                      onEmojiSelected: (selectedEmoji) { // Changed parameter name for clarity
                        final notifier = ref.read(duelQuizScreenManagerProvider(widget.roomId).notifier);
                        notifier.updateUserEmoji(selectedEmoji); // Pass SelectedEmoji object
                        setState(() {
                          _showEmojiBubbleForUserId = null;
                        });
                      },
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
