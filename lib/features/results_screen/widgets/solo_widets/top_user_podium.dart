import 'package:flutter/material.dart';
import 'package:flutter_podium/src/podium_bar.dart';
import 'package:trivia/core/common_widgets/user_avatar.dart';
import 'package:trivia/core/constants/app_constant.dart';

import 'package:trivia/core/utils/size_config.dart';
import 'package:trivia/data/models/trivia_user.dart';

class TopUsersPodium extends StatelessWidget {
  final List<MapEntry<TriviaUser, int>> topUsersScores;

  const TopUsersPodium({super.key, required this.topUsersScores});

  @override
  Widget build(BuildContext context) {
    // Extract user names and scores for the podium
    final firstUser = topUsersScores[0].key;
    final firstScore = topUsersScores[0].value;

    final secondUser = topUsersScores[1].key;
    final secondScore = topUsersScores[1].value;

    final thirdUser = topUsersScores[2].key;
    final thirdScore = topUsersScores[2].value;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        // Second place podium
        Stack(
          alignment: Alignment.center,
          children: [
            // Podium bar
            PodiumBar(
              title: Column(
                children: [
                  UserAvatar(
                    user: secondUser,
                    radius: 30,
                  ),
                  Text(
                    secondUser.name ?? "",
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
              width: calcWidth(110),
              displayRankingNumberInsteadOfText: false,
              hideRanking: true, // Hide the original ranking text
              rankingText: "", // Empty string for the original ranking
              backgroundColor: AppConstant.secondaryColor,
              height: calcHeight(250) / 1.5,
              rankingTextStyle: const TextStyle(),
              is2D: false,
            ),
            // Score text positioned above the podium
            Positioned(
              bottom: 0,
              child: SizedBox(
                width: calcWidth(110),
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    secondScore.toString(),
                    style: const TextStyle(
                      fontSize: 50,
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(
          width: 3,
        ),
        // First place podium
        Stack(
          alignment: Alignment.center,
          children: [
            PodiumBar(
              title: Column(
                children: [
                  UserAvatar(
                    user: firstUser,
                    radius: 30,
                  ),
                  Text(
                    firstUser.name ?? "",
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
              width: calcWidth(110),
              displayRankingNumberInsteadOfText: false,
              hideRanking: true,
              rankingText: "",
              backgroundColor: AppConstant.secondaryColor,
              height: calcHeight(250),
              rankingTextStyle: const TextStyle(),
              is2D: false,
            ),
            Positioned(
              bottom: 0,
              child: SizedBox(
                width: calcWidth(110),
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    firstScore.toString(),
                    style: const TextStyle(
                      fontSize: 50,
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(
          width: 3,
        ),
        // Third place podium
        Stack(
          alignment: Alignment.center,
          children: [
            PodiumBar(
              title: Column(
                children: [
                  UserAvatar(
                    user: thirdUser,
                    radius: 30,
                  ),
                  Text(
                    thirdUser.name ?? "",
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
              width: calcWidth(110),
              displayRankingNumberInsteadOfText: false,
              hideRanking: true,
              rankingText: "",
              backgroundColor: AppConstant.secondaryColor,
              height: calcHeight(250) / 2.5,
              is2D: false,
              rankingTextStyle: const TextStyle(),
            ),
            Positioned(
              bottom: 0,
              child: SizedBox(
                width: calcWidth(110),
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    thirdScore.toString(),
                    style: const TextStyle(
                      fontSize: 50,
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
