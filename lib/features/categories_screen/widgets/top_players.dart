import 'dart:math';

import 'package:flutter/material.dart';
import 'package:Quizdom/core/common_widgets/user_avatar.dart';
import 'package:Quizdom/core/constants/app_constant.dart';
import 'package:Quizdom/core/constants/constant_strings.dart';
import 'package:Quizdom/core/utils/general_functions.dart';
import 'package:Quizdom/core/utils/size_config.dart';
import 'package:Quizdom/data/models/trivia_user.dart';

class ExpandableHighScorePlayersList extends StatefulWidget {
  final Map<TriviaUser, int> topUsers;

  const ExpandableHighScorePlayersList({
    super.key,
    required this.topUsers,
  });

  @override
  State<ExpandableHighScorePlayersList> createState() =>
      _ExpandableHighScorePlayersListState();
}

class _ExpandableHighScorePlayersListState
    extends State<ExpandableHighScorePlayersList> {
  bool isExpanded = false;

  void toggleExpand() {
    setState(() {
      isExpanded = !isExpanded;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Convert the map to a sorted list by score (descending).
    final sortedEntries = widget.topUsers.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    // Determine how many items to show based on expanded state
    final itemsToShow = isExpanded ? sortedEntries.length : 3;

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: calcWidth(10)),
              child: const Text(
                Strings.topPlayers,
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            IconButton(
              icon: Icon(
                isExpanded
                    ? Icons.keyboard_arrow_up_rounded
                    : Icons.keyboard_arrow_down_rounded,
              ),
              onPressed: toggleExpand,
              color: Colors.black,
            ),
          ],
        ),
        Container(
          margin: EdgeInsets.symmetric(
            horizontal: calcWidth(16),
            vertical: calcHeight(8),
          ),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: AppConstant.primaryColor.withValues(alpha: 0.1),
                offset: const Offset(0, 8),
                blurRadius: 16,
              ),
            ],
          ),
          child: Column(
            children: [
              // The list of players (or a placeholder if none)
              if (sortedEntries.isEmpty)
                Padding(
                  padding: EdgeInsets.symmetric(
                    vertical: calcHeight(40),
                    horizontal: calcWidth(20),
                  ),
                  child: Column(
                    spacing: calcHeight(16),
                    children: const [
                      Icon(
                        Icons.group_off,
                        size: 48,
                        color: AppConstant.silverColor,
                      ),
                      Text(
                        Strings.noPlayersFound,
                        style: TextStyle(
                          color: AppConstant.silverColor,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                )
              else
                // Replace AnimatedContainer with AnimatedSize for dynamic height
                AnimatedSize(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                  child: Column(
                    children: [
                      // Generate the list items directly instead of using ListView
                      for (int index = 0;
                          index < min(itemsToShow, sortedEntries.length);
                          index++) ...[
                        _buildPlayerRow(
                          context: context,
                          rank: index + 1,
                          user: sortedEntries[index].key,
                          score: sortedEntries[index].value,
                        ),
                        // Add divider between items (except for the last item)
                        if (index < min(itemsToShow, sortedEntries.length) - 1)
                          Divider(
                            color: Colors.grey.shade200,
                            height: 1,
                          ),
                      ],
                    ],
                  ),
                ),

              // Show "View all" button if there are more than 3 players and not expanded
              if (sortedEntries.length > 3 && !isExpanded)
                GestureDetector(
                  onTap: toggleExpand,
                  child: Container(
                    width: double.infinity,
                    padding: EdgeInsets.symmetric(vertical: calcHeight(12)),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade50,
                      borderRadius: const BorderRadius.only(
                        bottomLeft: Radius.circular(16),
                        bottomRight: Radius.circular(16),
                      ),
                    ),
                    child: Center(
                      child: Text(
                        "${Strings.viewAll} ${sortedEntries.length} ${Strings.playersSmall}",
                        style: const TextStyle(
                          color: AppConstant.primaryColor,
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
                ),

              if (isExpanded && sortedEntries.length > 3)
                GestureDetector(
                  onTap: toggleExpand,
                  child: Container(
                    width: double.infinity,
                    padding: EdgeInsets.symmetric(vertical: calcHeight(12)),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade50,
                      borderRadius: const BorderRadius.only(
                        bottomLeft: Radius.circular(16),
                        bottomRight: Radius.circular(16),
                      ),
                    ),
                    child: const Center(
                      child: Text(
                        Strings.showLess,
                        style: TextStyle(
                          color: AppConstant.primaryColor,
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPlayerRow({
    required BuildContext context,
    required int rank,
    required TriviaUser user,
    required int score,
  }) {
    return GestureDetector(
      onTap: () => showProfileOverview(context, user),
      child: Container(
        padding: EdgeInsets.symmetric(
          vertical: calcHeight(12),
          horizontal: calcWidth(8),
        ),
        decoration: BoxDecoration(
          color: rank <= 3
              ? _getRankBackgroundColor(rank).withValues(alpha: 0.05)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            // Rank Circle with gradient
            Container(
              width: calcWidth(40),
              height: calcWidth(40),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: _getRankGradientColors(rank),
                ),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: _getRankCircleColor(rank).withValues(alpha: 0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              alignment: Alignment.center,
              child: Text(
                '$rank',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
            SizedBox(width: calcWidth(16)),

            // User Avatar with border
            Stack(
              children: [
                Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: rank <= 3
                        ? Border.all(
                            color: _getRankCircleColor(rank),
                            width: calcWidth(2),
                          )
                        : null,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: UserAvatar(
                    user: user,
                    radius: 22,
                  ),
                ),
                if (rank == 1)
                  Positioned(
                    top: -2,
                    right: -2,
                    child: Container(
                      padding: const EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        color: AppConstant.goldColor,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 1),
                      ),
                      child: const Icon(
                        Icons.stars,
                        size: 12,
                        color: Colors.white,
                      ),
                    ),
                  ),
              ],
            ),
            SizedBox(width: calcWidth(16)),

            // User Name + Medal
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          user.name ?? Strings.unknownPlayer,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: rank <= 3
                                ? _getRankTextColor(rank)
                                : Colors.black,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Score Card
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: calcWidth(12),
                vertical: calcHeight(6),
              ),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: rank <= 3
                      ? _getScoreGradientColors(rank)
                      : [
                          AppConstant.primaryColor.withValues(alpha: 0.1),
                          AppConstant.secondaryColor.withValues(alpha: 0.1),
                        ],
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                '$score ${Strings.pts}',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: rank <= 3 ? Colors.white : AppConstant.primaryColor,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Returns the color for the rank circle
  Color _getRankCircleColor(int rank) {
    switch (rank) {
      case 1:
        return AppConstant.goldColor;
      case 2:
        return AppConstant.silverColor; // Silver
      case 3:
        return AppConstant.bronzeColor; // Bronze
      default:
        return Colors.grey.shade400;
    }
  }

  /// Returns gradient colors for the rank circle
  List<Color> _getRankGradientColors(int rank) {
    switch (rank) {
      case 1:
        return [
          AppConstant.goldColor,
          AppConstant.onPrimaryColor,
        ];
      case 2:
        return [
          AppConstant.silverColor.withValues(alpha: 0.2),
          AppConstant.silverColor,
        ];
      case 3:
        return [
          AppConstant.bronzeColor.withValues(alpha: 0.2),
          AppConstant.bronzeColor,
        ];
      default:
        return [
          AppConstant.secondaryColor.withValues(alpha: 0.5),
          AppConstant.primaryColor.withValues(alpha: 0.5),
        ];
    }
  }

  /// Returns gradient colors for the score card
  List<Color> _getScoreGradientColors(int rank) {
    switch (rank) {
      case 1:
        return [
          AppConstant.onPrimaryColor,
          AppConstant.goldColor,
        ];
      case 2:
        return [
          AppConstant.silverColor,
          AppConstant.silverColor.withValues(alpha: 0.5),
        ];
      case 3:
        return [
          AppConstant.bronzeColor,
          AppConstant.bronzeColor.withValues(alpha: 0.5),
        ];
      default:
        return [
          AppConstant.primaryColor,
          AppConstant.secondaryColor,
        ];
    }
  }

  /// Returns text color for top ranks
  Color _getRankTextColor(int rank) {
    switch (rank) {
      case 1:
        return AppConstant.onPrimaryColor;
      case 2:
        return AppConstant.silverColor;
      case 3:
        return AppConstant.bronzeColor;
      default:
        return AppConstant.primaryColor;
    }
  }

  /// Returns background color for top ranks
  Color _getRankBackgroundColor(int rank) {
    switch (rank) {
      case 1:
        return AppConstant.goldColor;
      case 2:
        return AppConstant.lightGray; // Silver
      case 3:
        return AppConstant.bronzeColor; // Bronze
      default:
        return Colors.transparent;
    }
  }
}
