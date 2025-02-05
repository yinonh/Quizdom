import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trivia/core/common_widgets/current_user_avatar.dart';
import 'package:trivia/core/constants/app_constant.dart';
import 'package:trivia/core/constants/constant_strings.dart';
import 'package:trivia/core/utils/size_config.dart';
import 'package:trivia/features/quiz_screen/quiz_screen.dart';
import 'package:trivia/features/trivia_intro_screen/view_model/intro_screen_manager.dart';

import '../../../core/common_widgets/custom_bottom_button.dart';
import 'detail_row.dart';

class SoloIntroContent extends ConsumerWidget {
  const SoloIntroContent({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final introState = ref.watch(introScreenManagerProvider);
    final introNotifier = ref.read(introScreenManagerProvider.notifier);
    return Stack(
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
                const DetailRow(
                    icon: Icons.speed,
                    text:
                        '${Strings.difficulty} ${AppConstant.questionsDifficulty}'),
                const DetailRow(
                    icon: Icons.timer,
                    text:
                        '${Strings.timePerQuestion} ${AppConstant.questionTime}s'),
                DetailRow(
                  icon: Icons.monetization_on,
                  text: '${Strings.price} 10 coins',
                  iconColor: introState.currentUser.coins > 10
                      ? AppConstant.onPrimaryColor
                      : Colors.red,
                ),
                SizedBox(height: calcHeight(30)),
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
                        onTap: introState.currentUser.coins < 10
                            ? null
                            : () {
                                introNotifier.payCoins(-10);
                                Navigator.pushReplacementNamed(
                                  context,
                                  QuizScreen.routeName,
                                );
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
