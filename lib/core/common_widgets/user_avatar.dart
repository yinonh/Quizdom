import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:shimmer/shimmer.dart';
import 'package:Quizdom/core/constants/app_constant.dart';
import 'package:Quizdom/core/constants/constant_strings.dart';
import 'package:Quizdom/core/utils/custom_clipper.dart';
import 'package:Quizdom/core/utils/enums/selected_emoji.dart';
import 'package:Quizdom/core/utils/fluttermoji/fluttermoji_provider.dart';
import 'package:Quizdom/core/utils/general_functions.dart';
import 'package:Quizdom/core/utils/size_config.dart';
import 'package:Quizdom/data/models/trivia_user.dart';
import 'package:Quizdom/data/providers/user_provider.dart'; // Added import

class UserAvatar extends ConsumerWidget {
  final double radius;
  final bool showProgress;
  final TriviaUser? user;
  final bool disabled;
  final SelectedEmoji? emoji;
  final bool showEmojiBadge;
  final bool isEmojiSideRight;
  final VoidCallback? onTapOverride;

  const UserAvatar({
    required this.user,
    this.radius = 42,
    this.showProgress = false,
    this.disabled = false,
    this.emoji,
    this.showEmojiBadge = false,
    this.isEmojiSideRight = false,
    this.onTapOverride,
    super.key,
  });

  Widget _buildCurrentUserFluttermoji(WidgetRef ref, double radius) {
    final fluttermojiState = ref.watch(fluttermojiNotifierProvider);

    return ClipPath(
      clipper: HalfCircleClipper(),
      child: CircleAvatar(
        radius: calcWidth(radius),
        backgroundColor: AppConstant.softHighlightColor,
        child: fluttermojiState.when(
          data: (state) {
            if (state.fluttermoji.isEmpty) {
              return const CircularProgressIndicator();
            }
            return SvgPicture.string(
              state.fluttermoji,
              height: calcWidth(radius * 2.1),
              placeholderBuilder: (context) => const Center(
                child: CircularProgressIndicator(),
              ),
            );
          },
          loading: () => const CircularProgressIndicator(),
          error: (error, stackTrace) => Icon(
            Icons.person,
            color: Colors.white.withValues(alpha: 0.7),
            size: calcWidth(radius * 1.5),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Check if this is the current user and watch for updates
    final authState = ref.watch(authProvider);
    final isCurrentUser = user?.uid == authState.currentUser.uid;
    final displayUser = isCurrentUser ? authState.currentUser : user;

    return GestureDetector(
      onTap: onTapOverride ??
          (disabled
              ? null
              : (displayUser != null
                  ? () => showProfileOverview(context, displayUser)
                  : null)),
      child: Stack(
        alignment: Alignment.center,
        children: [
          if (showProgress)
            SizedBox(
              width: calcWidth(radius * 2.1),
              height: calcWidth(radius * 2.1),
              child: const CircularProgressIndicator(
                strokeWidth: 6.0,
                value: 1,
                color: AppConstant.onPrimaryColor,
              ),
            ),
          displayUser != null && displayUser.uid == AppConstant.botUserId
              ? ClipPath(
                  clipper: HalfCircleClipper(),
                  child: CircleAvatar(
                    radius: calcWidth(radius),
                    backgroundColor: AppConstant.softHighlightColor,
                    child: SvgPicture.asset(
                      displayUser.imageUrl ?? Strings.botAvatar1,
                    ),
                  ),
                )
              : displayUser != null && displayUser.imageUrl != null
                  ? CachedNetworkImage(
                      imageUrl: displayUser.imageUrl!,
                      placeholder: (context, url) => Shimmer.fromColors(
                        baseColor: Colors.grey[300]!,
                        highlightColor: Colors.grey[100]!,
                        child: CircleAvatar(
                          backgroundColor: Colors.grey[300]!,
                          radius: calcWidth(radius),
                        ),
                      ),
                      imageBuilder: (context, image) => CircleAvatar(
                        backgroundImage: image,
                        radius: calcWidth(radius),
                      ),
                    )
                  : displayUser != null &&
                          displayUser.fluttermojiOptions != null
                      ? isCurrentUser
                          ? _buildCurrentUserFluttermoji(ref, radius)
                          : ClipPath(
                              clipper: HalfCircleClipper(),
                              child: CircleAvatar(
                                radius: calcWidth(radius),
                                backgroundColor: AppConstant.softHighlightColor,
                                child: SvgPicture.string(
                                  ref
                                      .read(
                                          fluttermojiNotifierProvider.notifier)
                                      .getFluttermojiFromOptions(
                                          displayUser.fluttermojiOptions!),
                                ),
                              ),
                            )
                      : CircleAvatar(
                          radius: calcWidth(radius),
                          backgroundColor: AppConstant.softHighlightColor,
                          child: Icon(
                            Icons.person,
                            color: Colors.white.withValues(alpha: 0.7),
                            size: calcWidth(radius * 1.5),
                          ),
                        ),
          if (showEmojiBadge && emoji != null)
            Positioned(
              bottom: 0,
              left: isEmojiSideRight ? null : 0,
              right: isEmojiSideRight ? 0 : null,
              child: Text(
                emoji!.character,
                style: TextStyle(fontSize: radius * 0.5),
              ),
            ),
        ],
      ),
    );
  }
}
