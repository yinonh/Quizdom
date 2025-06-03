import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trivia/core/common_widgets/custom_bottom_button.dart';
import 'package:trivia/core/common_widgets/custom_when.dart';
import 'package:trivia/core/common_widgets/user_avatar.dart';
import 'package:trivia/core/constants/app_constant.dart';
import 'package:trivia/core/constants/constant_strings.dart';
import 'package:trivia/core/navigation/route_extensions.dart';
import 'package:trivia/core/utils/size_config.dart';
import 'package:trivia/features/quiz_screen/solo_quiz_screen.dart';
import 'package:trivia/features/intro_screen/view_model/intro_screen_manager.dart';
import 'package:trivia/features/intro_screen/widgets/detail_row.dart';

class GroupIntroContent extends ConsumerWidget {
  const GroupIntroContent({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final introStateAsync = ref.watch(introScreenManagerProvider);
    return introStateAsync.customWhen(
      data: (introState) => Stack(
        children: [
          // Dynamic gradient background
          Container(
            decoration: BoxDecoration(
              gradient: RadialGradient(
                colors: [Colors.blue.shade200, Colors.orange.shade200],
                center: Alignment.topLeft,
                radius: 1.8,
              ),
            ),
          ),

          // Game details card with user list
          Center(
            child: Container(
              padding: const EdgeInsets.all(25),
              margin: EdgeInsets.symmetric(horizontal: calcWidth(30)),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.9),
                borderRadius: BorderRadius.circular(25),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.2),
                    blurRadius: 15,
                    spreadRadius: 5,
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Group icon with gradient
                  const Icon(Icons.groups,
                      size: 60, color: AppConstant.highlightColor),

                  // Title
                  const Text(
                    Strings.groupChallenge,
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  SizedBox(height: calcHeight(10)),
                  // Game details
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

                  // Scrollable list of users
                  const Text(
                    Strings.players,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  SizedBox(
                    height: calcHeight(120),
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: 6, // Static number of users for now
                      itemBuilder: (context, index) {
                        return Padding(
                          padding:
                              EdgeInsets.symmetric(horizontal: calcWidth(5)),
                          child: UserAvatar(
                            user: introState.currentUser,
                            radius: 35,
                          ),
                        );
                      },
                    ),
                  ),
                  Row(
                    spacing: calcWidth(10),
                    children: [
                      Expanded(
                        child: CustomBottomButton(
                          text: Strings.back,
                          onTap: () => pop(),
                          isSecondary: true,
                        ),
                      ),
                      Expanded(
                        child: CustomBottomButton(
                          text: Strings.ready,
                          onTap: () {
                            goRoute(SoloQuizScreen.routeName);
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // Player count indicator with animation
          Positioned(
            bottom: calcHeight(35),
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                padding: EdgeInsets.symmetric(
                    horizontal: calcWidth(20), vertical: calcHeight(12)),
                decoration: BoxDecoration(
                  color: AppConstant.highlightColor.withValues(alpha: 0.9),
                  borderRadius: BorderRadius.circular(25),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.2),
                      blurRadius: 10,
                      spreadRadius: 3,
                    ),
                  ],
                ),
                child: const Text(
                  '${Strings.waitingForMorePlayers} (4/6)',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
