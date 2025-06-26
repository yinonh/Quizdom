import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:Quizdom/core/common_widgets/custom_button.dart';
import 'package:Quizdom/core/constants/app_constant.dart';
import 'package:Quizdom/core/constants/constant_strings.dart';
import 'package:Quizdom/core/utils/size_config.dart';

class UnderConstructionDialog extends StatelessWidget {
  const UnderConstructionDialog({super.key});

  /// Show the Under Construction dialog
  static Future<void> show(BuildContext context) {
    return showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return const UnderConstructionDialog();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppConstant.primaryColor,
              AppConstant.highlightColor,
            ],
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.3),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Padding(
          padding: EdgeInsets.all(calcWidth(24)),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Circular background for animation
              Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    width: calcWidth(150),
                    height: calcWidth(150),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color:
                          AppConstant.softHighlightColor.withValues(alpha: 0.3),
                    ),
                  ),
                  Center(
                    child: SizedBox(
                      height: calcHeight(150),
                      width: calcWidth(150),
                      child: Lottie.asset(
                        Strings.underConstructionAnimation,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: calcHeight(24)),

              // Title text
              const Text(
                Strings.underConstruction,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  letterSpacing: 1.2,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: calcHeight(12)),

              // Subtitle text
              const Text(
                Strings.thisFeatureComingSoon,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.white70,
                  fontWeight: FontWeight.w300,
                  height: 1.4,
                ),
              ),
              SizedBox(height: calcHeight(20)),

              CustomButton(
                text: Strings.gotIt,
                onTap: () {
                  Navigator.of(context).pop();
                },
                color: AppConstant.onPrimaryColor,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
