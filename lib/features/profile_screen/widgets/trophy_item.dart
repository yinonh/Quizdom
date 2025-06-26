import 'package:flutter/material.dart';
import 'package:Quizdom/core/constants/app_constant.dart';
import 'package:Quizdom/core/constants/constant_strings.dart';
import 'package:Quizdom/core/utils/enums/level.dart';
import 'package:Quizdom/core/utils/enums/trophy_type.dart';
import 'package:Quizdom/core/utils/size_config.dart';

class TrophyItem extends StatelessWidget {
  final String title;
  final int value;
  final Map<Level, int> thresholds;
  final TrophyType category;

  const TrophyItem({
    super.key,
    required this.title,
    required this.value,
    required this.thresholds,
    required this.category,
  });

  @override
  Widget build(BuildContext context) {
    final level = AppConstant.getTrophyLevel(thresholds, value);
    final color = level.color;
    final icon = AppConstant.getTrophyIcon(category);
    final nextThreshold = _getNextThreshold(thresholds, value);
    final progress = _getProgressToNextLevel(thresholds, value);

    return Container(
      constraints: BoxConstraints(minWidth: calcWidth(120)),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Main Card
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: color.withValues(alpha: level == Level.none ? 0.2 : 0.3),
                width: 2,
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(height: calcHeight(24)),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[800],
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: calcHeight(8)),
                // Value
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Text(
                      value.toString(),
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: level == Level.none
                            ? color.withValues(alpha: 0.8)
                            : color,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: calcHeight(4)),
                Text(
                  nextThreshold,
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.grey[600],
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          // Circular Progress with Icon
          Positioned(
            top: -20,
            left: 0,
            right: 0,
            child: Center(
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Progress Circle
                  SizedBox(
                    width: calcHeight(44),
                    height: calcHeight(44),
                    child: TweenAnimationBuilder(
                      duration: const Duration(milliseconds: 500),
                      tween: Tween(begin: 0.0, end: progress),
                      builder: (context, double value, child) {
                        return CircularProgressIndicator(
                          value: value,
                          strokeWidth: 2,
                          backgroundColor: Colors.grey[200],
                          color: level == Level.none
                              ? color.withValues(alpha: 0.8)
                              : color,
                        );
                      },
                    ),
                  ),
                  // Icon Circle
                  Container(
                    width: calcHeight(40),
                    height: calcHeight(40),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: color.withValues(
                            alpha: level == Level.none ? 0.2 : 0.3),
                        width: 2,
                      ),
                    ),
                    child: Icon(
                      icon,
                      color: level == Level.none
                          ? color.withValues(alpha: 0.8)
                          : color,
                      size: 20, // Slightly smaller to fit better
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Helper function to calculate progress to the next level
  double _getProgressToNextLevel(Map<Level, int> thresholds, int currentValue) {
    final sortedThresholds = thresholds.values.toList()..sort();
    final nextThresholdValue = sortedThresholds
        .firstWhere((t) => t > currentValue, orElse: () => currentValue);
    final currentThresholdValue =
        sortedThresholds.lastWhere((t) => t <= currentValue, orElse: () => 0);

    if (nextThresholdValue == currentValue) return 1.0;

    return (currentValue - currentThresholdValue) /
        (nextThresholdValue - currentThresholdValue);
  }

  String _getNextThreshold(Map<Level, int> thresholds, int currentValue) {
    for (var entry in thresholds.entries) {
      if (currentValue < entry.value) {
        return '${entry.value - currentValue} ${Strings.moreTo} ${entry.key.name}';
      }
    }
    return Strings.maxLevelAchieved;
  }
}
