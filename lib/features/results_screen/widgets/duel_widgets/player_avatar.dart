import 'package:flutter/material.dart';
import 'package:trivia/core/common_widgets/user_avatar.dart';
import 'package:trivia/core/constants/app_constant.dart';
import 'package:trivia/core/constants/constant_strings.dart';
import 'package:trivia/core/utils/size_config.dart';
import 'package:trivia/data/models/trivia_user.dart';

class PlayerAvatar extends StatelessWidget {
  final TriviaUser? user;
  final String displayName;
  final int score;
  final bool isWinner;
  final Color color;

  const PlayerAvatar({
    super.key,
    required this.user,
    required this.displayName,
    required this.score,
    required this.isWinner,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Stack(
          alignment: Alignment.center,
          clipBehavior: Clip.none, // Allow children to render outside bounds
          children: [
            // Winner ring
            if (isWinner)
              Container(
                width: calcWidth(110),
                height: calcHeight(110),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [
                      AppConstant.goldColor.withValues(alpha: 0.7),
                      AppConstant.darkGoldColor,
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppConstant.goldColor.withValues(alpha: 0.7),
                      blurRadius: 12,
                      spreadRadius: 5,
                    ),
                  ],
                ),
              ),

            // Avatar container
            UserAvatar(
              user: user,
              radius: 55,
            ),

            // Score badge - Positioned with a negative bottom value
            Positioned(
              bottom: -calcHeight(25), // Adjust this negative value as needed
              child: Container(
                padding: EdgeInsets.symmetric(
                    horizontal: calcWidth(16), vertical: calcHeight(6)),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [color.withValues(alpha: 0.8), color],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: color.withValues(alpha: 0.3),
                      blurRadius: 6,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.star,
                        color: AppConstant.goldColor, size: 16),
                    SizedBox(width: calcWidth(4)),
                    Text(
                      '$score',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: calcHeight(25)),
        Text(
          user?.name ?? Strings.opponent,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
          textAlign: TextAlign.center,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}
