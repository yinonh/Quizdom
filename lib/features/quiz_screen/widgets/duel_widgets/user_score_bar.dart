import 'package:flutter/material.dart';
import 'package:trivia/core/common_widgets/current_user_avatar.dart';
import 'package:trivia/core/common_widgets/user_avatar.dart';
import 'package:trivia/core/constants/app_constant.dart';
import 'package:trivia/core/constants/constant_strings.dart';
import 'package:trivia/data/models/trivia_user.dart';

class UserScoreBar extends StatelessWidget {
  final List<String> users;
  final Map<String, int> userScores;
  final TriviaUser? opponent;
  final TriviaUser? currentUser;

  const UserScoreBar({
    super.key,
    required this.users,
    required this.userScores,
    required this.opponent,
    required this.currentUser,
  });

  @override
  Widget build(BuildContext context) {
    List<int> adjustedScores = [
      userScores[currentUser?.uid] ?? 0,
      userScores[opponent?.uid] ?? 0
    ];

    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: List.generate(
          users.length > 2 ? 2 : users.length,
          (index) {
            final score =
                index < adjustedScores.length ? adjustedScores[index] : 0;

            return Column(
              children: [
                index == 0
                    ? const CurrentUserAvatar()
                    : UserAvatar(user: opponent),
                const SizedBox(height: 4),
                Text(
                  "${Strings.players} ${index + 1}",
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
                Text(
                  "$score ${Strings.pts}",
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: AppConstant.secondaryColor,
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
