import 'package:flutter/material.dart';
import 'package:Quizdom/core/constants/app_constant.dart';
import 'package:Quizdom/core/constants/app_routes.dart';
import 'package:Quizdom/core/constants/constant_strings.dart';
import 'package:Quizdom/core/navigation/route_extensions.dart';
import 'package:Quizdom/core/utils/size_config.dart';

class LoseDialogScreen extends StatelessWidget {
  static const routeName = AppRoutes.loseDialog;

  const LoseDialogScreen({super.key});

  /// Navigate to the Lose Dialog screen
  static void show(BuildContext context) {
    goRoute(routeName);
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Container(
        color: Colors.black.withValues(alpha: 0.5),
        child: const Center(
          child: LoseDialogContent(),
        ),
      ),
    );
  }
}

class LoseDialogContent extends StatelessWidget {
  const LoseDialogContent({super.key});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
      ),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppConstant.primaryColor,
              AppConstant.highlightColor,
            ],
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  width: calcWidth(100),
                  height: calcWidth(100),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppConstant.highlightColor.withValues(alpha: 0.3),
                  ),
                ),
                const Icon(
                  Icons.sentiment_neutral,
                  color: AppConstant.secondaryColor,
                  size: 60,
                ),
              ],
            ),
            SizedBox(height: calcHeight(20)),
            Text(
              Strings.betterLuckNextTime,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
            ),
            SizedBox(height: calcHeight(16)),
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: calcWidth(20),
                vertical: calcHeight(12),
              ),
              decoration: BoxDecoration(
                color: AppConstant.highlightColor.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(16),
              ),
              child: FittedBox(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.tips_and_updates,
                      color: AppConstant.secondaryColor,
                      size: 24,
                    ),
                    SizedBox(width: calcWidth(8)),
                    const Text(
                      Strings.keepPlayingWinCoins,
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: calcHeight(24)),
            ElevatedButton(
              onPressed: () => pop(),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppConstant.onPrimaryColor,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(
                  horizontal: calcWidth(24),
                  vertical: calcHeight(12),
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              child: const Text(
                Strings.close,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
