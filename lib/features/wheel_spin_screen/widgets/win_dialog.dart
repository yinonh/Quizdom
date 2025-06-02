import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:trivia/core/constants/app_constant.dart';
import 'package:trivia/core/constants/app_routes.dart';
import 'package:trivia/core/constants/constant_strings.dart';
import 'package:trivia/core/utils/size_config.dart';

class WinDialogScreen extends StatelessWidget {
  static const routeName = AppRoutes.winDialog;

  final int coins;

  const WinDialogScreen({
    super.key,
    required this.coins,
  });

  /// Navigate to the Win Dialog screen
  static void show(BuildContext context, int coins) {
    context.pushNamed(routeName, extra: {'coins': coins});
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Container(
        color: Colors.black.withValues(alpha: 0.5),
        child: Center(
          child: WinDialogContent(coins: coins),
        ),
      ),
    );
  }
}

class WinDialogContent extends StatelessWidget {
  const WinDialogContent({required this.coins, super.key});

  final int coins;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
      ),
      child: Container(
        padding: EdgeInsets.all(24),
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
                  Icons.celebration,
                  color: AppConstant.goldColor,
                  size: 60,
                ),
              ],
            ),
            SizedBox(height: calcHeight(20)),
            Text(
              Strings.congratulations,
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
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.monetization_on,
                    color: AppConstant.goldColor,
                    size: 24,
                  ),
                  SizedBox(width: calcWidth(8)),
                  Text(
                    '$coins ${Strings.coinsExclamationMark}',
                    style: const TextStyle(
                      fontSize: 18,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
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
                Strings.awesome,
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
