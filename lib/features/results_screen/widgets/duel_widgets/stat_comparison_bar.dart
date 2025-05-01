import 'package:flutter/material.dart';
import 'package:trivia/core/constants/app_constant.dart';
import 'package:trivia/core/constants/constant_strings.dart';
import 'package:trivia/core/utils/size_config.dart';

class StatComparisonBar extends StatelessWidget {
  final String label;
  final double leftValue;
  final double rightValue;
  final String leftLabel;
  final String rightLabel;
  final Color primaryColor;
  final Color secondaryColor;
  final IconData icon;
  final bool lowerIsBetter;

  const StatComparisonBar({
    super.key,
    required this.label,
    required this.leftValue,
    required this.rightValue,
    required this.leftLabel,
    required this.rightLabel,
    required this.primaryColor,
    required this.secondaryColor,
    required this.icon,
    this.lowerIsBetter = false,
  });

  @override
  Widget build(BuildContext context) {
    final total = leftValue + rightValue;
    final leftRatio = total > 0 ? leftValue / total : 0.5;
    final rightRatio = total > 0 ? rightValue / total : 0.5;

    // Determine who performed better for this stat
    final leftIsBetter = lowerIsBetter
        ? leftValue < rightValue && leftValue > 0
        : leftValue > rightValue;
    final rightIsBetter = lowerIsBetter
        ? rightValue < leftValue && rightValue > 0
        : rightValue > leftValue;
    final isDraw = leftValue == rightValue;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.grey.shade200,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                spacing: calcWidth(6),
                children: [
                  Icon(
                    icon,
                    size: 16,
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withValues(alpha: 0.7),
                  ),
                  Text(
                    label,
                    style: TextStyle(
                      color: Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withValues(alpha: 0.7),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  if (leftIsBetter && !isDraw)
                    const Icon(Icons.star,
                        color: AppConstant.goldColor, size: 14),
                  Text(
                    leftLabel,
                    style: TextStyle(
                      fontWeight: leftIsBetter && !isDraw
                          ? FontWeight.bold
                          : FontWeight.normal,
                      color: leftIsBetter && !isDraw
                          ? primaryColor
                          : Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: calcWidth(5)),
                    child: Text(
                      Strings.vs,
                      style: TextStyle(
                        color: Theme.of(context)
                            .colorScheme
                            .onSurface
                            .withValues(alpha: 0.5),
                      ),
                    ),
                  ),
                  Text(
                    rightLabel,
                    style: TextStyle(
                      fontWeight: rightIsBetter && !isDraw
                          ? FontWeight.bold
                          : FontWeight.normal,
                      color: rightIsBetter && !isDraw
                          ? secondaryColor
                          : Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  if (rightIsBetter && !isDraw)
                    const Icon(Icons.star,
                        color: AppConstant.goldColor, size: 14),
                ],
              ),
            ],
          ),
          SizedBox(height: calcHeight(10)),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Row(
              children: [
                Expanded(
                  flex: (leftRatio * 100).toInt().clamp(5, 95),
                  child: Container(
                    height: calcHeight(14),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          primaryColor.withValues(alpha: 0.7),
                          primaryColor,
                        ],
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                      ),
                    ),
                  ),
                ),
                Expanded(
                  flex: (rightRatio * 100).toInt().clamp(5, 95),
                  child: Container(
                    height: calcHeight(14),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          secondaryColor,
                          secondaryColor.withValues(alpha: 0.7),
                        ],
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                      ),
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
}
