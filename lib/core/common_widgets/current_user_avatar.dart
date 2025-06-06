import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shimmer/shimmer.dart';
import 'package:trivia/core/common_widgets/user_avatar.dart'; // Import UserAvatar
import 'package:trivia/core/utils/enums/selected_emoji.dart'; // Import SelectedEmoji
import 'package:trivia/core/utils/size_config.dart';
import 'package:trivia/data/providers/user_provider.dart';

class CurrentUserAvatar extends ConsumerWidget {
  final double radius;
  final bool showProgress;
  final SelectedEmoji? emoji;
  final bool showEmojiBadge;
  final VoidCallback? onTapOverride;

  const CurrentUserAvatar({
    this.radius = 42,
    this.showProgress = false,
    this.emoji,
    this.showEmojiBadge = false,
    this.onTapOverride,
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userState = ref.watch(authProvider);
    if (userState.imageLoading && userState.currentUser.imageUrl == null) {
      // Show shimmer only if image is loading AND no imageUrl (might be new user / fluttermoji)
      return Shimmer.fromColors(
        baseColor: Colors.grey[300]!,
        highlightColor: Colors.grey[100]!,
        child: CircleAvatar(
          backgroundColor: Colors.grey[300]!,
          radius: calcWidth(radius),
        ),
      );
    }

    // Delegate to UserAvatar
    return UserAvatar(
      user: userState.currentUser,
      radius: radius,
      showProgress: showProgress,
      disabled: false,
      emoji: emoji,
      showEmojiBadge: showEmojiBadge,
      isEmojiSideRight: true,
      onTapOverride: onTapOverride,
    );
  }
}
