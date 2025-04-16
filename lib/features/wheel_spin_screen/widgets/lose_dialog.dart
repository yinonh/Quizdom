import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:trivia/core/constants/app_constant.dart';
import 'package:trivia/core/constants/constant_strings.dart';
import 'package:trivia/core/utils/size_config.dart';

class LoseDialog extends StatelessWidget {
  const LoseDialog({super.key});

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
              onPressed: () => context.pop(),
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
