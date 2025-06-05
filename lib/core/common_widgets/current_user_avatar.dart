import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shimmer/shimmer.dart';
import 'package:trivia/core/constants/app_constant.dart';
// import 'package:trivia/core/utils/fluttermoji/fluttermoji_circle_avatar.dart'; // No longer directly used
import 'package:trivia/core/utils/size_config.dart';
import 'package:trivia/data/providers/user_provider.dart';
import 'package:trivia/core/common_widgets/user_avatar.dart'; // Import UserAvatar
import 'package:trivia/core/utils/enums/selected_emoji.dart'; // Import SelectedEmoji

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

    // While UserAvatar handles its own loading/placeholder for image,
    // CurrentUserAvatar might still want to show a general loading indicator
    // if the user object itself isn't available, though typically authProvider handles this.
    // For simplicity, we'll assume userState.currentUser is available if not imageLoading.
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
      disabled: false, // CurrentUserAvatar is generally not disabled for profile view by default
      emoji: emoji,
      showEmojiBadge: showEmojiBadge,
      onTapOverride: onTapOverride, // Pass it here
    );
  }
}
