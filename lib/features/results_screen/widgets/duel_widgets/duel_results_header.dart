import 'package:flutter/material.dart';
import 'package:trivia/core/constants/app_constant.dart';
import 'package:trivia/core/constants/constant_strings.dart';
import 'package:trivia/core/utils/size_config.dart';
import 'package:trivia/features/results_screen/view_model/duel_screen_manager/duel_result_screen_manager.dart';

class DuelResultsHeader extends StatelessWidget {
  final DuelResultState resultsState;
  final String categoryName;

  const DuelResultsHeader({
    super.key,
    required this.resultsState,
    required this.categoryName,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
          vertical: calcHeight(16), horizontal: calcWidth(24)),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppConstant.primaryColor, AppConstant.highlightColor],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        spacing: calcHeight(12),
        children: [
          Text(
            Strings.duelResults,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
          ),
          Row(
            spacing: calcWidth(10),
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildInfoChip(
                context,
                icon: Icons.category,
                label: categoryName,
              ),
              _buildInfoChip(
                context,
                icon: Icons.psychology,
                label: resultsState.room.difficulty?.displayName ?? 'Unknown',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoChip(BuildContext context,
      {required IconData icon, required String label}) {
    return Container(
      padding: EdgeInsets.symmetric(
          horizontal: calcWidth(12), vertical: calcHeight(6)),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        spacing: calcWidth(6),
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white, size: 16),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
