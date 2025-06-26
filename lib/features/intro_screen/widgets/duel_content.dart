import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:Quizdom/core/common_widgets/background.dart';
import 'package:Quizdom/core/common_widgets/current_user_avatar.dart';
import 'package:Quizdom/core/common_widgets/custom_bottom_button.dart';
import 'package:Quizdom/core/common_widgets/custom_progress_indicator.dart';
import 'package:Quizdom/core/common_widgets/custom_when.dart';
import 'package:Quizdom/core/common_widgets/loading_avatar.dart';
import 'package:Quizdom/core/common_widgets/user_avatar.dart';
import 'package:Quizdom/core/constants/app_constant.dart';
import 'package:Quizdom/core/constants/constant_strings.dart';
import 'package:Quizdom/core/navigation/route_extensions.dart';
import 'package:Quizdom/core/network/server.dart';
import 'package:Quizdom/core/utils/size_config.dart';
import 'package:Quizdom/features/intro_screen/view_model/duel_manager.dart';
import 'package:Quizdom/features/quiz_screen/duel_quiz_screen.dart';

import 'detail_row.dart';
import 'filter_room.dart';

class DuelIntroContent extends ConsumerWidget {
  const DuelIntroContent({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final duelStateAsync = ref.watch(duelManagerProvider);
    final duelNotifier = ref.read(duelManagerProvider.notifier);

    ref.listen(duelManagerProvider, (previous, next) {
      next.whenData((introState) {
        if (introState.matchedRoom != null && !introState.hasNavigated) {
          WidgetsBinding.instance.addPostFrameCallback((_) async {
            await ref.read(duelManagerProvider.notifier).setIsNavigated();
            logger.i('Navigate to QuizScreen');
            // Navigate with roomId parameter
            goRoute(
              DuelQuizScreen.routeName,
              pathParameters: {'roomId': introState.matchedRoom!},
            );
          });
        }
      });
    });

    return duelStateAsync.customWhen(
      loading: () => const Stack(
        children: [
          // Background with gradient
          CustomBackground(
            child: CustomProgressIndicator(),
          ),
        ],
      ),
      data: (introState) {
        final isLoading = introState.matchedUserId == null ||
            introState.matchedUserId!.isEmpty;
        final currentUserId = introState.matchedUserId;
        final currentUserPreference =
            currentUserId != null ? introState.userPreferences : null;

        return Stack(
          children: [
            Positioned.fill(
              child: CustomPaint(
                painter: DiagonalSplitPainter(),
              ),
            ),
            Positioned(
              top: calcHeight(70),
              right: calcWidth(60),
              child: CurrentUserAvatar(
                radius: calcWidth(60),
              ),
            ),
            Positioned(
              bottom: calcHeight(70),
              left: calcWidth(60),
              child: !isLoading
                  ? Stack(
                      alignment: Alignment.center,
                      children: [
                        // Progress indicator
                        SizedBox(
                          width: calcWidth(124),
                          height: calcWidth(124),
                          child: CircularProgressIndicator(
                            value: introState.isReady
                                ? 1
                                : introState.matchProgress ??
                                    0.0 / AppConstant.matchTimeout,
                            color: introState.isReady
                                ? AppConstant.green
                                : AppConstant.primaryColor,
                            strokeWidth: 7,
                          ),
                        ),
                        // User avatar
                        UserAvatar(
                          radius: calcWidth(60),
                          user: introState.matchedUser,
                        ),
                      ],
                    )
                  : LoadingAvatar(
                      radius: calcWidth(60),
                    ),
            ),
            Center(
              child: Container(
                padding: const EdgeInsets.all(20),
                margin: EdgeInsets.symmetric(horizontal: calcWidth(20)),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Stack(
                  children: [
                    Positioned(
                      child: Padding(
                        padding: EdgeInsets.only(bottom: calcHeight(16)),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            IconButton(
                              icon: const Icon(
                                Icons.arrow_back_ios_rounded,
                                color: AppConstant.primaryColor,
                              ),
                              onPressed: () {
                                pop();
                              },
                              tooltip: Strings.filterRooms,
                            ),
                            Badge(
                              label: Text(
                                  duelNotifier.preferencesNum().toString()),
                              isLabelVisible: duelNotifier.preferencesNum() > 0,
                              backgroundColor: AppConstant.onPrimaryColor,
                              child: IconButton(
                                icon: const Icon(
                                  Icons.filter_list,
                                  color: AppConstant.primaryColor,
                                ),
                                onPressed: () {
                                  // Changed from showDialog to the new screen navigation
                                  RoomFilterScreen.show(context);
                                },
                                tooltip: Strings.filterRooms,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.handshake_rounded,
                            size: 60, color: AppConstant.highlightColor),

                        // Title
                        const Text(
                          Strings.duelChallenge,
                          style: TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        SizedBox(height: calcHeight(10)),

                        // Room details
                        DetailRow(
                          icon: Icons.category,
                          text:
                              (currentUserPreference?.categoryId ?? Strings.any)
                                  .toString(),
                          isLoading: isLoading,
                        ),
                        DetailRow(
                          icon: Icons.question_answer,
                          text:
                              '${Strings.questions} ${currentUserPreference?.questionCount ?? Strings.any}',
                          isLoading: isLoading,
                        ),
                        DetailRow(
                          icon: Icons.speed,
                          text:
                              '${Strings.difficulty} ${currentUserPreference?.difficulty ?? Strings.any}',
                          isLoading: isLoading,
                        ),
                        DetailRow(
                          icon: Icons.timer,
                          text:
                              '${Strings.timePerQuestion} ${AppConstant.questionTime}s',
                          isLoading: isLoading,
                        ),
                        DetailRow(
                          icon: Icons.monetization_on,
                          text: '${Strings.price} 10 ${Strings.coins}',
                          iconColor: introState.currentUser.coins > 10
                              ? AppConstant.onPrimaryColor
                              : Colors.red,
                          isLoading: isLoading,
                        ),

                        SizedBox(height: calcHeight(20)),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Expanded(
                              child: CustomBottomButton(
                                text: Strings.nextPlayer,
                                onTap: isLoading
                                    ? null // Disable button when loading
                                    : () => duelNotifier.findNewMatch(),
                                isSecondary: true,
                              ),
                            ),
                            SizedBox(width: calcWidth(10)),
                            Expanded(
                              child: CustomBottomButton(
                                text: Strings.ready,
                                onTap: isLoading || introState.isReady
                                    ? null // Disable button when loading
                                    : () async {
                                        await duelNotifier.setReady();
                                      },
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

// Custom painter for diagonal split background
class DiagonalSplitPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    var paint = Paint();

    // Upper right background (sky blue)
    paint.color = Colors.lightBlue;
    var path1 = Path();
    path1.moveTo(0, 0); // Start from top left
    path1.lineTo(size.width, 0); // Line to top right
    path1.lineTo(size.width, size.height); // Line to bottom right
    path1.close(); // Close the path (automatically connects to starting point)
    canvas.drawPath(path1, paint);

    // Lower left background (orange)
    paint.color = Colors.orange;
    var path2 = Path();
    path2.moveTo(0, 0); // Start from top left
    path2.lineTo(0, size.height); // Line to bottom left
    path2.lineTo(size.width, size.height); // Line to bottom right
    path2.close(); // Close the path (connect to top left)
    canvas.drawPath(path2, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return false;
  }
}
