import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:Quizdom/core/common_widgets/current_user_avatar.dart';
import 'package:Quizdom/core/common_widgets/custom_bottom_button.dart';
import 'package:Quizdom/core/common_widgets/custom_when.dart';
import 'package:Quizdom/core/constants/app_constant.dart';
import 'package:Quizdom/core/constants/constant_strings.dart';
import 'package:Quizdom/core/navigation/route_extensions.dart';
import 'package:Quizdom/core/utils/size_config.dart';
import 'package:Quizdom/features/intro_screen/view_model/intro_screen_manager.dart';
import 'package:Quizdom/features/quiz_screen/solo_quiz_screen.dart';

import 'detail_row.dart';
import 'difficulty_selector.dart';

class SoloIntroContent extends ConsumerWidget {
  const SoloIntroContent({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final introStateAsync = ref.watch(introScreenManagerProvider);
    final introNotifier = ref.read(introScreenManagerProvider.notifier);

    return introStateAsync.customWhen(
      data: (introState) => Stack(
        children: [
          // Background with gradient
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topRight,
                end: Alignment.bottomLeft,
                colors: [Colors.lightBlue, Colors.orange],
              ),
            ),
          ),

          Center(
            child: Container(
              padding: const EdgeInsets.all(30),
              margin: EdgeInsets.symmetric(horizontal: calcWidth(40)),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(30),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 10,
                    spreadRadius: 5,
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const CurrentUserAvatar(radius: 60),
                  SizedBox(height: calcHeight(20)),
                  const Text(
                    Strings.soloChallenge,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: calcHeight(20)),
                  DetailRow(
                      icon: Icons.category,
                      text: introState.room?.categoryName ?? ""),
                  const DetailRow(
                      icon: Icons.question_answer,
                      text:
                          '${Strings.questions} ${AppConstant.numberOfQuestions}'),
                  DetailRow(
                    icon: Icons.monetization_on,
                    text: '${Strings.price} 10 coins',
                    iconColor: introState.currentUser.coins > 10
                        ? AppConstant.onPrimaryColor
                        : Colors.red,
                  ),
                  SizedBox(height: calcHeight(20)),
                  DifficultySelector(
                    selectedDifficulty: introState.selectedDifficulty,
                    onDifficultySelected: (difficulty) {
                      introNotifier.setDifficulty(difficulty);
                    },
                  ),
                  SizedBox(height: calcHeight(10)),
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
                          text: Strings.start,
                          onTap: introState.currentUser.coins < 10
                              ? null
                              : () {
                                  introNotifier.payCoins(-10);
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
        ],
      ),
    );
  }
}
