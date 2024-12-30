import 'package:flutter/material.dart';
import 'package:flutter_podium/src/podium_bar.dart';
import 'package:trivia/core/common_widgets/current_user_avatar.dart';
import 'package:trivia/core/constants/app_constant.dart';

import 'package:trivia/core/utils/size_config.dart';
import 'package:trivia/data/models/user.dart';

class TopUsersPodium extends StatelessWidget {
  final Map<TriviaUser, int> topUsersScores;

  const TopUsersPodium({super.key, required this.topUsersScores});

  @override
  Widget build(BuildContext context) {
    // Sort the map by values (descending order) and take the top 3
    final sortedTopUsers = topUsersScores.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final topThree = sortedTopUsers.take(3).toList();

    // Extract user names and scores for the podium
    final firstUser = topThree.isNotEmpty ? topThree[0].key : "N/A";
    final firstScore = topThree.isNotEmpty ? topThree[0].value : 0;

    final secondUser = topThree.length > 1 ? topThree[1].key : "N/A";
    final secondScore = topThree.length > 1 ? topThree[1].value : 0;

    final thirdUser = topThree.length > 2 ? topThree[2].key : "N/A";
    final thirdScore = topThree.length > 2 ? topThree[2].value : 0;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        PodiumBar(
          title: const CurrentUserAvatar(radius: 35),
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
          title: const CurrentUserAvatar(radius: 35),
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
          title: const CurrentUserAvatar(radius: 35),
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
