import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:trivia/core/constants/app_constant.dart';
import 'package:trivia/core/constants/constant_strings.dart';
import 'package:trivia/core/utils/size_config.dart';
import 'package:trivia/data/providers/user_provider.dart';

class UserResourcesDialog extends ConsumerWidget {
  const UserResourcesDialog({super.key});

  // Method to show the bottom sheet
  static Future<void> show(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => const UserResourcesDialog(),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentUser = ref.watch(authProvider).currentUser;

    // Calculate the chest icon size and its position
    final chestIconRadius = calcWidth(55);
    final chestIconPosition = chestIconRadius;

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Stack(
        alignment: Alignment.topCenter,
        clipBehavior: Clip.none,
        children: [
          // Bottom sheet content
          Container(
            margin: EdgeInsets.only(top: chestIconPosition),
            padding: EdgeInsets.only(
              top: chestIconPosition + calcHeight(16),
              left: calcWidth(15),
              right: calcWidth(15),
              bottom: calcHeight(15),
            ),
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(30),
                topRight: Radius.circular(30),
              ),
              gradient: const LinearGradient(
                colors: [
                  AppConstant.primaryColor,
                  AppConstant.highlightColor,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.2),
                  blurRadius: 20,
                  spreadRadius: 3,
                ),
              ],
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(height: calcHeight(10)),

                  // Resource Cards - keeping the original design
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
                    icon: Strings.energyIcon,
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
                    icon: Strings.goldIcon,
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
                ],
              ),
            ),
          ),

          Positioned(
            top: 0,
            child: Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  width: chestIconRadius * 2,
                  height: chestIconRadius * 2,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppConstant.highlightColor,
                  ),
                ),
                CircleAvatar(
                  radius: chestIconRadius * 0.9,
                  backgroundColor: AppConstant.softHighlightColor,
                  child: SizedBox(
                    width: chestIconRadius * 1.8,
                    height: chestIconRadius * 1.8,
                    child: SvgPicture.asset(
                      Strings.openChestIcon,
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
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
              padding: EdgeInsets.all(calcWidth(2)),
              decoration: BoxDecoration(
                color: primaryColor.withValues(alpha: 0.2),
                shape: BoxShape.circle,
              ),
              child: SvgPicture.asset(
                icon,
                height: calcHeight(60),
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
