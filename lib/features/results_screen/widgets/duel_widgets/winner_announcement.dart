import 'package:flutter/material.dart';
import 'package:trivia/core/constants/app_constant.dart';
import 'package:trivia/core/constants/constant_strings.dart';
import 'package:trivia/core/utils/size_config.dart';
import 'package:trivia/features/results_screen/view_model/duel_screen_manager/duel_result_screen_manager.dart';
import 'package:trivia/features/results_screen/widgets/duel_widgets/player_avatar.dart';

class WinnerAnnouncement extends StatelessWidget {
  final DuelResultState resultsState;

  const WinnerAnnouncement({
    super.key,
    required this.resultsState,
  });

  bool get isWinner => resultsState.winnerId == resultsState.currentUserId;

  bool get isDraw => resultsState.winnerId == null;

  Color get resultColor => isDraw
      ? AppConstant.goldColor
      : isWinner
          ? AppConstant.green
          : AppConstant.red;

  String get resultText => isDraw
      ? Strings.itsDraw
      : isWinner
          ? Strings.youWin
          : Strings.youLost;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 6,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.white,
              AppConstant.softHighlightColor.withValues(alpha: 0.3),
            ],
          ),
        ),
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.symmetric(
                  horizontal: calcWidth(40), vertical: calcHeight(12)),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [resultColor.withValues(alpha: 0.8), resultColor],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: resultColor.withValues(alpha: 0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Text(
                resultText,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
              ),
            ),
            SizedBox(height: calcHeight(30)),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Expanded(
                  child: Column(
                    children: [
                      PlayerAvatar(
                        user: resultsState.currentUser,
                        displayName:
                            resultsState.currentUser?.name ?? Strings.you,
                        score: resultsState
                                .room.userScores![resultsState.currentUserId] ??
                            0,
                        isWinner: isWinner || isDraw,
                        color: AppConstant.primaryColor,
                      ),
                    ],
                  ),
                ),
                _buildVsContainer(context),
                Expanded(
                  child: Column(
                    children: [
                      PlayerAvatar(
                        user: resultsState.opponentUser,
                        displayName:
                            resultsState.opponentUser?.name ?? Strings.opponent,
                        score: resultsState.room
                                .userScores![resultsState.opponentUser?.uid] ??
                            0,
                        isWinner: !isWinner || isDraw,
                        color: AppConstant.highlightColor,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVsContainer(BuildContext context) {
    return Container(
      width: calcWidth(50),
      height: calcHeight(50),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: const LinearGradient(
          colors: [AppConstant.onPrimaryColor, AppConstant.goldColor],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: AppConstant.onPrimaryColor.withValues(alpha: 0.3),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Center(
        child: Text(
          Strings.vs,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
        ),
      ),
    );
  }
}
