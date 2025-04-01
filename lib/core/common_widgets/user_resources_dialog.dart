import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:trivia/core/common_widgets/custom_button.dart';
import 'package:trivia/core/constants/app_constant.dart';
import 'package:trivia/core/constants/constant_strings.dart';
import 'package:trivia/core/utils/size_config.dart';
import 'package:trivia/data/providers/user_provider.dart';

class UserResourcesDialog extends ConsumerWidget {
  const UserResourcesDialog({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentUser = ref.watch(authProvider).currentUser;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(calcWidth(15)),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppConstant.primaryColor.withValues(alpha: 0.8),
              AppConstant.highlightColor.withValues(alpha: 0.8),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.2),
              blurRadius: 20,
              spreadRadius: 3,
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Playful title with wave effect
            Stack(
              alignment: Alignment.center,
              children: [
                Text(
                  Strings.yourTreasureChest,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    foreground: Paint()
                      ..style = PaintingStyle.stroke
                      ..strokeWidth = 2
                      ..color = Colors.white.withValues(alpha: 0.2),
                  ),
                ),
                const Text(
                  Strings.yourTreasureChest,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppConstant.onPrimaryColor,
                  ),
                ),
              ],
            ),
            SizedBox(height: calcHeight(20)),

            // Resource Cards
            _buildResourceCard(
              context: context,
              icon: Strings.coinsIcon,
              label: Strings.coins,
              value: currentUser.coins.toString(),
              primaryColor: AppConstant.onPrimaryColor,
              secondaryColor: Colors.orangeAccent.shade100,
              onTap: () {
                Navigator.pop(context);
                // Add navigation logic
              },
            ),
            SizedBox(height: calcHeight(10)),
            _buildResourceCard(
              context: context,
              icon: Strings.coinsIcon,
              label: Strings.energy,
              value: '8/8',
              primaryColor: AppConstant.secondaryColor,
              secondaryColor: Colors.tealAccent.shade100,
              onTap: () {
                Navigator.pop(context);
                // Add navigation logic
              },
            ),
            SizedBox(height: calcHeight(10)),
            _buildResourceCard(
              context: context,
              icon: Strings.coinsIcon,
              label: Strings.gold,
              value: currentUser.coins.toString(),
              primaryColor: AppConstant.goldColor,
              secondaryColor: AppConstant.goldColor,
              onTap: () {
                Navigator.pop(context);
                // Add navigation logic
              },
            ),
            SizedBox(height: calcHeight(20)),

            // Playful Close Button
            CustomButton(
              onTap: () => Navigator.pop(context),
              padding: EdgeInsets.symmetric(vertical: calcWidth(15)),
              text: Strings.closeTreasureChest,
              color: Colors.white,
              textStyle: const TextStyle(
                color: AppConstant.primaryColor,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResourceCard({
    required BuildContext context,
    required String icon,
    required String label,
    required String value,
    required Color primaryColor,
    required Color secondaryColor,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.white.withValues(alpha: 0.2),
              secondaryColor.withValues(alpha: 0.3),
            ],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
          borderRadius: BorderRadius.circular(25),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.3),
            width: 2,
          ),
        ),
        padding: EdgeInsets.symmetric(
          horizontal: calcWidth(15),
          vertical: calcHeight(15),
        ),
        child: Row(
          children: [
            // Slightly larger and more vibrant icon
            Container(
              padding: EdgeInsets.all(calcWidth(10)),
              decoration: BoxDecoration(
                color: primaryColor.withValues(alpha: 0.2),
                shape: BoxShape.circle,
              ),
              child: SvgPicture.asset(
                icon,
                height: calcHeight(35),
                colorFilter: ColorFilter.mode(
                  primaryColor,
                  BlendMode.srcIn,
                ),
              ),
            ),
            SizedBox(width: calcWidth(15)),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  Strings.tapViewDetails,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.7),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
            const Spacer(),
            Text(
              value,
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
                shadows: [
                  Shadow(
                    blurRadius: 10.0,
                    color: primaryColor,
                    offset: const Offset(0, 0),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
