import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:Quizdom/core/constants/constant_strings.dart';
import 'package:Quizdom/core/utils/enums/difficulty.dart';
import 'package:Quizdom/core/constants/app_constant.dart';
import 'package:Quizdom/core/utils/size_config.dart';

class DifficultySelector extends ConsumerWidget {
  final Difficulty? selectedDifficulty;
  final Function(Difficulty) onDifficultySelected;

  const DifficultySelector({
    super.key,
    required this.selectedDifficulty,
    required this.onDifficultySelected,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          Strings.selectDifficulty,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppConstant.primaryColor,
          ),
        ),
        SizedBox(height: calcHeight(10)),
        Row(
          children: Difficulty.values.map((difficulty) {
            final isSelected = selectedDifficulty == difficulty;
            return Expanded(
              child: GestureDetector(
                onTap: () => onDifficultySelected(difficulty),
                child: Container(
                  margin: EdgeInsets.symmetric(horizontal: calcWidth(4)),
                  padding: EdgeInsets.symmetric(
                    vertical: calcHeight(12),
                    horizontal: calcWidth(8),
                  ),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? _getDifficultyColor(difficulty).withValues(alpha: 0.1)
                        : Colors.grey[100],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSelected
                          ? _getDifficultyColor(difficulty)
                          : Colors.grey[300]!,
                      width: isSelected ? 2 : 1,
                    ),
                  ),
                  child: Column(
                    children: [
                      Icon(
                        _getDifficultyIcon(difficulty),
                        color: isSelected
                            ? _getDifficultyColor(difficulty)
                            : Colors.grey[600],
                        size: 24,
                      ),
                      SizedBox(height: calcHeight(4)),
                      Text(
                        difficulty.displayName,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight:
                              isSelected ? FontWeight.bold : FontWeight.normal,
                          color: isSelected
                              ? _getDifficultyColor(difficulty)
                              : Colors.grey[700],
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Color _getDifficultyColor(Difficulty difficulty) {
    switch (difficulty) {
      case Difficulty.easy:
        return Colors.green;
      case Difficulty.medium:
        return Colors.orange;
      case Difficulty.hard:
        return Colors.red;
    }
  }

  IconData _getDifficultyIcon(Difficulty difficulty) {
    switch (difficulty) {
      case Difficulty.easy:
        return Icons.local_florist;
      case Difficulty.medium:
        return Icons.whatshot;
      case Difficulty.hard:
        return Icons.flash_on;
    }
  }
}
