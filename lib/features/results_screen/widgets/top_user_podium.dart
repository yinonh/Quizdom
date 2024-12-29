import 'package:flutter/material.dart';
import 'package:flutter_podium/flutter_podium.dart';

class TopUsersPodium extends StatelessWidget {
  final Map<String, int> topUsersScores;

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

    return Podium(
      firstPosition: Text(firstUser),
      secondPosition: Text(secondUser),
      thirdPosition: Text(thirdUser),
      firstRankingText: firstScore.toString(),
      secondRankingText: secondScore.toString(),
      thirdRankingText: thirdScore.toString(),
    );
  }
}
