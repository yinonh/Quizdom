import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trivia/core/common_widgets/current_user_avatar.dart';
import 'package:trivia/core/common_widgets/user_avatar.dart';
import 'package:trivia/core/constants/app_constant.dart';
import 'package:trivia/core/constants/constant_strings.dart';
import 'package:trivia/core/utils/size_config.dart';
import 'package:trivia/features/quiz_screen/quiz_screen.dart';
import 'package:trivia/features/trivia_intro_screen/view_model/intro_screen_manager.dart';

import 'custom_bottom_button.dart';
import 'detail_row.dart';

class DuelIntroContent extends ConsumerWidget {
  const DuelIntroContent({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final introState = ref.watch(introScreenManagerProvider);
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
            child: Column(
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
                DetailRow(
                    icon: Icons.category,
                    text: introState.room?.categoryName ?? ""),
                const DetailRow(
                    icon: Icons.question_answer,
                    text:
                        '${Strings.questions} ${AppConstant.numberOfQuestions}'),
                const DetailRow(
                    icon: Icons.speed,
                    text:
                        '${Strings.difficulty} ${AppConstant.questionsDifficulty}'),
                const DetailRow(
                    icon: Icons.timer,
                    text:
                        '${Strings.timePerQuestion} ${AppConstant.questionTime}s'),
                SizedBox(height: calcHeight(20)),
                Row(
                  spacing: calcWidth(10),
                  children: [
                    Expanded(
                      child: CustomBottomButton(
                        text: Strings.back,
                        onTap: () => Navigator.pop(context),
                        isSecondary: true,
                      ),
                    ),
                    Expanded(
                      child: CustomBottomButton(
                        text: Strings.start,
                        onTap: () {
                          Navigator.pushReplacementNamed(
                              context, QuizScreen.routeName);
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
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
