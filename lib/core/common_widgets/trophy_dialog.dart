import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:trivia/core/common_widgets/custom_button.dart';
import 'package:trivia/core/constants/app_constant.dart';
import 'package:trivia/core/constants/constant_strings.dart';
import 'package:trivia/core/navigation/route_extensions.dart';
import 'package:trivia/core/utils/size_config.dart';

class TrophyAchievementDialog extends StatelessWidget {
  final TrophyAchievement achievement;
  final VoidCallback onClose;

  const TrophyAchievementDialog({
    super.key,
    required this.achievement,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(calcWidth(20)),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [AppConstant.secondaryColor, AppConstant.primaryColor],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            // Outer glow effect that matches trophy color
            BoxShadow(
              color: achievement.levelColor.withValues(alpha: 0.5),
              blurRadius: 20,
              spreadRadius: 5,
            ),
          ],
        ),
        child: Stack(
          children: [
            Column(
              spacing: calcHeight(10),
              mainAxisSize: MainAxisSize.min,
              children: [
                // Title
                Padding(
                  padding: EdgeInsets.only(top: calcHeight(30)),
                  child: const Text(
                    Strings.congratulations,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                // Subtitle
                Text(
                  "${Strings.newText} ${achievement.level.name.toUpperCase()} ${Strings.trophyUnlocked}",
                  style: const TextStyle(fontSize: 16, color: Colors.white70),
                  textAlign: TextAlign.center,
                ),

                // Lottie Animation
                SizedBox(
                  height: calcHeight(120),
                  width: calcWidth(120),
                  child: Lottie.asset(
                    Strings.trophyAnimation,
                    fit: BoxFit.contain,
                    repeat: false,
                  ),
                ),

                // Trophy container
                Container(
                  margin: EdgeInsets.symmetric(horizontal: calcWidth(30)),
                  padding: const EdgeInsets.all(15),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Trophy Icon
                      Icon(
                        AppConstant.getTrophyIcon(achievement.type),
                        size: 50,
                        color: achievement.levelColor,
                      ),
                      // Achievement Type
                      Text(
                        achievement.typeLabel,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(height: calcHeight(5)),
                      // Achievement Value
                      Text(
                        "${achievement.value}",
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                          color: Colors.white,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),

                CustomButton(
                  text: Strings.goToProfile,
                  onTap: () {
                    onClose();
                    pop();
                  },
                  color: AppConstant.secondaryColor,
                ),

                // Motivational text
                const Text(
                  Strings.keepUpUnlockMore,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white70,
                  ),
                ),
              ],
            ),
            // X Icon positioned at top-right
            Positioned(
              top: 0,
              right: 0,
              child: GestureDetector(
                onTap: () {
                  context.pop();
                },
                child: Container(
                  padding: const EdgeInsets.all(8),
                  child: const Icon(
                    Icons.close,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
