import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shimmer/shimmer.dart';
import 'package:Quizdom/core/common_widgets/user_avatar.dart';
import 'package:Quizdom/core/constants/app_constant.dart';
import 'package:Quizdom/core/utils/enums/selected_emoji.dart';
import 'package:Quizdom/core/utils/size_config.dart';
import 'package:Quizdom/data/providers/user_provider.dart';

class CurrentUserAvatar extends ConsumerWidget {
  final double radius;
  final bool showProgress;
  final SelectedEmoji? emoji;
  final bool showEmojiBadge;
  final bool addEmojiFeatureOn;
  final VoidCallback? onTapOverride;

  const CurrentUserAvatar({
    this.radius = 42,
    this.showProgress = false,
    this.emoji,
    this.showEmojiBadge = false,
    this.addEmojiFeatureOn = false,
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

    // If addEmojiFeatureOn is true, wrap with Stack to show + icon
    if (addEmojiFeatureOn) {
      return Stack(
        alignment: Alignment.center,
        children: [
          UserAvatar(
            user: userState.currentUser,
            radius: radius,
            showProgress: showProgress,
            disabled: false,
            emoji: emoji,
            showEmojiBadge: showEmojiBadge,
            isEmojiSideRight: true,
            onTapOverride: onTapOverride,
          ),
          if (!showEmojiBadge || emoji == null)
            Positioned(
              bottom: 0,
              right: 0,
              child: GestureDetector(
                onTap: onTapOverride,
                child: Container(
                  width: radius * 0.6,
                  height: radius * 0.6,
                  decoration: BoxDecoration(
                    color: AppConstant.primaryColor,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.white,
                      width: 2,
                    ),
                  ),
                  child: Icon(
                    Icons.add,
                    color: Colors.white,
                    size: radius * 0.3,
                  ),
                ),
              ),
            )
        ],
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
