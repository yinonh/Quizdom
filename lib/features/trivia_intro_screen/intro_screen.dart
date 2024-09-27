import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trivia/core/common_widgets/stars.dart';
import 'package:trivia/core/common_widgets/user_avater.dart';
import 'package:trivia/core/constants/app_constant.dart';
import 'package:trivia/core/constants/constant_strings.dart';
import 'package:trivia/core/utils/size_config.dart';
import 'package:trivia/features/quiz_screen/quiz_screen.dart';
import 'package:trivia/features/trivia_intro_screen/view_model/intro_screen_manager.dart';

class TriviaIntroScreen extends ConsumerWidget {
  static const routeName = Strings.triviaIntroScreen;

  const TriviaIntroScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final introState = ref.watch(introScreenManagerProvider);
    return Scaffold(
      body: Stack(
        children: [
          // Background with diagonal split
          Positioned.fill(
            child: CustomPaint(
              painter: DiagonalSplitPainter(),
            ),
          ),

          // User details in the top right corner
          Positioned(
            top: 70,
            right: 50,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const UserAvatar(
                  radius: 60,
                ), // competition image
                const SizedBox(width: 10),
                Container(
                  padding: const EdgeInsets.all(5),
                  margin: const EdgeInsets.symmetric(vertical: 3),
                  decoration: const BoxDecoration(
                    color: AppConstant.highlightColor,
                    borderRadius: BorderRadius.all(Radius.circular(30)),
                  ),
                  child: const UserStars(),
                ),
                const Text(
                  'User XP: 1200',
                  style: TextStyle(color: Colors.white, fontSize: 18),
                ),
              ],
            ),
          ),

          Positioned(
            bottom: 70,
            left: 50,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const UserAvatar(
                  radius: 60,
                ), // competition image
                const SizedBox(width: 10),
                Container(
                  padding: const EdgeInsets.all(5),
                  margin: const EdgeInsets.symmetric(vertical: 3),
                  decoration: const BoxDecoration(
                    color: AppConstant.highlightColor,
                    borderRadius: BorderRadius.all(Radius.circular(30)),
                  ),
                  child: const UserStars(),
                ),
                const Text(
                  'User XP: 1200',
                  style: TextStyle(color: Colors.white, fontSize: 18),
                ),
              ],
            ),
          ),

          Center(
            child: Container(
              padding: const EdgeInsets.all(20),
              margin: const EdgeInsets.symmetric(horizontal: 20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(30),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '${introState.category.name}',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                        fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: calcHeight(10)),
                  const Text(
                    'Number of Questions: 10',
                    style: TextStyle(fontSize: 16),
                  ),
                  SizedBox(height: calcHeight(10)),
                  const Text(
                    'Hardness: Medium',
                    style: TextStyle(fontSize: 16),
                  ),
                  SizedBox(height: calcHeight(10)),
                  Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            Navigator.pop(context);
                          },
                          child: Container(
                            margin: const EdgeInsets.only(bottom: 8.0),
                            padding: const EdgeInsets.all(12.0),
                            decoration: BoxDecoration(
                              color:
                                  AppConstant.secondaryColor.withOpacity(0.5),
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                            alignment: Alignment.center, // Center the text
                            child: const Text(
                              "back",
                              style: TextStyle(fontSize: 16.0),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(
                        width: calcWidth(10),
                      ),
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            Navigator.pushReplacementNamed(
                                context, QuizScreen.routeName);
                          },
                          child: Container(
                            margin: const EdgeInsets.only(bottom: 8.0),
                            padding: const EdgeInsets.all(12.0),
                            decoration: BoxDecoration(
                              color:
                                  AppConstant.secondaryColor.withOpacity(0.5),
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                            alignment: Alignment.center, // Center the text
                            child: const Text(
                              "continue",
                              style: TextStyle(
                                  fontSize: 16.0, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                      ),
                    ],
                  )
                ],
              ),
            ),
          ),
        ],
      ),
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
