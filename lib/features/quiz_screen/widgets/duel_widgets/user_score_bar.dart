import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:trivia/core/common_widgets/current_user_avatar.dart';
import 'package:trivia/core/common_widgets/user_avatar.dart';
import 'package:trivia/core/constants/app_constant.dart';
import 'package:trivia/core/constants/constant_strings.dart';
import 'package:trivia/core/utils/enums/selected_emoji.dart';
import 'package:trivia/data/models/trivia_user.dart';

class UserScoreBar extends StatelessWidget {
  final List<String> users; // users[0] is current, users[1] is opponent
  final Map<String, int> userScores;
  final TriviaUser? opponent;
  final TriviaUser? currentUser;
  final Map<String, Map<String, dynamic>> userEmojis;
  final Function(String userId) onCurrentUserAvatarTap;
  final String? currentUserId;
  final VoidCallback? onBackgroundTap; // Add this parameter

  const UserScoreBar({
    super.key,
    required this.users,
    required this.userScores,
    required this.opponent,
    required this.currentUser,
    required this.userEmojis,
    required this.onCurrentUserAvatarTap,
    required this.currentUserId,
    this.onBackgroundTap, // Add this parameter
  });

  @override
  Widget build(BuildContext context) {
    List<int> adjustedScores = [
      userScores[currentUser?.uid] ?? 0,
      userScores[opponent?.uid] ?? 0
    ];

    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: onBackgroundTap,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(
            users.length > 2 ? 2 : users.length,
            (index) {
              final score =
                  index < adjustedScores.length ? adjustedScores[index] : 0;

              // Determine user details based on index
              final bool isCurrentUserWidget = index == 0;
              final TriviaUser? userForAvatar =
                  isCurrentUserWidget ? currentUser : opponent;
              final String? userId = userForAvatar?.uid;

              SelectedEmoji? selectedEmoji;
              bool showBadge = false;

              if (userId != null && userEmojis.containsKey(userId)) {
                final emojiData = userEmojis[userId]!;

                // Get the emoji as a string first
                final emojiString = emojiData['emoji'] as String?;

                // Convert string to SelectedEmoji using your helper method
                if (emojiString != null) {
                  selectedEmoji = SelectedEmojiExtension.fromName(emojiString);
                } else {
                  selectedEmoji = null;
                }

                final timestamp = emojiData['timestamp'] as Timestamp?;
                if (timestamp != null) {
                  showBadge =
                      DateTime.now().difference(timestamp.toDate()).inSeconds <
                          6;
                }
              }

              Widget avatarWidget;
              if (isCurrentUserWidget) {
                avatarWidget = CurrentUserAvatar(
                  emoji: selectedEmoji,
                  showEmojiBadge: showBadge,
                  onTapOverride: isCurrentUserWidget && currentUserId != null
                      ? () => onCurrentUserAvatarTap(currentUserId!)
                      : null,
                );
              } else {
                avatarWidget = UserAvatar(
                  user: opponent, // Opponent data
                  emoji: selectedEmoji,
                  showEmojiBadge: showBadge,
                  onTapOverride: null,
                );
              }

              return GestureDetector(
                behavior: HitTestBehavior.translucent,
                onTap: onBackgroundTap,
                child: Column(
                  children: [
                    avatarWidget,
                    const SizedBox(height: 4),
                    Text(
                      userForAvatar?.name ?? "${Strings.players} ${index + 1}",
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
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
