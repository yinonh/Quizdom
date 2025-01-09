import 'package:flutter/material.dart';
import 'package:flutter_podium/src/podium_bar.dart';
import 'package:trivia/core/common_widgets/user_avatar.dart';
import 'package:trivia/core/constants/app_constant.dart';

import 'package:trivia/core/utils/size_config.dart';
import 'package:trivia/data/models/user.dart';

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
        PodiumBar(
          title: Column(
            children: [
              UserAvatar(
                user: secondUser,
                radius: 30,
              ),
              Text(
                secondUser.name ?? "",
              )
            ],
          ),
          width: calcWidth(110),
          displayRankingNumberInsteadOfText: false,
          hideRanking: false,
          rankingText: secondScore.toString(),
          backgroundColor: AppConstant.secondaryColor,
          rankingTextStyle: const TextStyle(
            fontSize: 50,
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
          height: calcHeight(250) / 1.5,
          is2D: false,
        ),
        const SizedBox(
          width: 3,
        ),
        PodiumBar(
          title: Column(
            children: [
              UserAvatar(
                user: firstUser,
                radius: 30,
              ),
              Text(
                firstUser.name ?? "",
              )
            ],
          ),
          width: calcWidth(110),
          displayRankingNumberInsteadOfText: false,
          hideRanking: false,
          rankingText: firstScore.toString(),
          backgroundColor: AppConstant.secondaryColor,
          rankingTextStyle: const TextStyle(
            fontSize: 50,
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
          height: calcHeight(250),
          is2D: false,
        ),
        const SizedBox(
          width: 3,
        ),
        PodiumBar(
          title: Column(
            children: [
              UserAvatar(
                user: thirdUser,
                radius: 30,
              ),
              Text(
                thirdUser.name ?? "",
              )
            ],
          ),
          width: calcWidth(110),
          displayRankingNumberInsteadOfText: false,
          hideRanking: false,
          rankingText: thirdScore.toString(),
          backgroundColor: AppConstant.secondaryColor,
          rankingTextStyle: const TextStyle(
            fontSize: 50,
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
          height: calcHeight(250) / 2.5,
          is2D: false,
        ),
      ],
    );
  }
}
