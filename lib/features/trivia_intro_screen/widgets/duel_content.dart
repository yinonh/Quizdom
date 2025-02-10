import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shimmer/shimmer.dart';
import 'package:trivia/core/common_widgets/current_user_avatar.dart';
import 'package:trivia/core/common_widgets/custom_bottom_button.dart';
import 'package:trivia/core/common_widgets/user_avatar.dart';
import 'package:trivia/core/constants/app_constant.dart';
import 'package:trivia/core/constants/constant_strings.dart';
import 'package:trivia/core/utils/size_config.dart';
import 'package:trivia/features/trivia_intro_screen/view_model/intro_screen_manager.dart';

import 'detail_row.dart';
import 'filter_room.dart';

class DuelIntroContent extends ConsumerWidget {
  const DuelIntroContent({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final introStateAsync = ref.watch(introScreenManagerProvider);
    final introNotifier = ref.read(introScreenManagerProvider.notifier);

    // Shimmer loading widget
    Widget buildShimmerLoading() {
      return Center(
        child: Shimmer.fromColors(
          baseColor: Colors.grey[300]!,
          highlightColor: Colors.grey[100]!,
          child: Container(
            width: MediaQuery.of(context).size.width * 0.8,
            height: 300,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(30),
            ),
          ),
        ),
      );
    }

    return introStateAsync.when(
      loading: () => Stack(
        children: [
          Positioned.fill(
            child: CustomPaint(
              painter: DiagonalSplitPainter(),
            ),
          ),
          buildShimmerLoading(),
        ],
      ),
      error: (error, stack) => Center(child: Text('Error: $error')),
      data: (introState) {
        final isLoading = introState.matchedUserId == null ||
            introState.matchedUserId!.isEmpty;
        final currentUserId = introState.matchedUserId;
        final currentUserPreference =
            currentUserId != null ? introState.userPreferences : null;

        if (isLoading) {
          return Stack(
            children: [
              Positioned.fill(
                child: CustomPaint(
                  painter: DiagonalSplitPainter(),
                ),
              ),
              buildShimmerLoading(),
            ],
          );
        }

        return Stack(
          children: [
            Positioned.fill(
              child: CustomPaint(
                painter: DiagonalSplitPainter(),
              ),
            ),

            // Right user
            Positioned(
              top: calcHeight(70),
              right: calcWidth(60),
              child: const CurrentUserAvatar(
                radius: 60,
              ),
            ),

            // Left user
            Positioned(
              bottom: calcHeight(70),
              left: calcWidth(60),
              child: UserAvatar(
                radius: calcWidth(60),
                user: introState.currentUser,
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
                        padding: const EdgeInsets.only(bottom: 16.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Badge(
                              label: Text(
                                  introNotifier.preferencesNum().toString()),
                              isLabelVisible:
                                  introNotifier.preferencesNum() > 0,
                              backgroundColor: AppConstant.onPrimaryColor,
                              child: IconButton(
                                icon: const Icon(
                                  Icons.filter_list,
                                  color: AppConstant.primaryColor,
                                ),
                                onPressed: () {
                                  showDialog(
                                    context: context,
                                    builder: (context) =>
                                        const RoomFilterDialog(),
                                  );
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
                          Strings.duelMode,
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
                          text: (currentUserPreference?.categoryId ?? -1)
                              .toString(),
                        ),
                        const DetailRow(
                          icon: Icons.question_answer,
                          text:
                              '${Strings.questions} ${AppConstant.numberOfQuestions}',
                        ),
                        const DetailRow(
                          icon: Icons.speed,
                          text:
                              '${Strings.difficulty} ${AppConstant.questionsDifficulty}',
                        ),
                        const DetailRow(
                          icon: Icons.timer,
                          text:
                              '${Strings.timePerQuestion} ${AppConstant.questionTime}s',
                        ),
                        DetailRow(
                          icon: Icons.monetization_on,
                          text: '${Strings.price} 10 coins',
                          iconColor: introState.currentUser.coins > 10
                              ? AppConstant.onPrimaryColor
                              : Colors.red,
                        ),

                        SizedBox(height: calcHeight(20)),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Expanded(
                              child: CustomBottomButton(
                                text: Strings.back,
                                onTap: () => Navigator.pop(context),
                                isSecondary: true,
                              ),
                            ),
                            SizedBox(width: calcWidth(10)),
                            Expanded(
                              child: CustomBottomButton(
                                text: _getButtonText(
                                  false,
                                  introState.matchedUserId != null ? 1 : 0,
                                ),
                                onTap: () {
                                  introNotifier.findNewMatch();
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

  // Helper method to determine button text
  String _getButtonText(bool isReady, int userCount) {
    if (isReady) {
      return Strings.start;
    } else if (userCount > 1) {
      return "Next Player";
    } else {
      return Strings.ready;
    }
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
