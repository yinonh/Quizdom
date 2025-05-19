import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:shimmer/shimmer.dart';
import 'package:trivia/core/constants/app_constant.dart';
import 'package:trivia/core/constants/constant_strings.dart';
import 'package:trivia/core/utils/custom_clipper.dart';
import 'package:trivia/core/utils/fluttermoji/fluttermoji_provider.dart';
import 'package:trivia/core/utils/general_functions.dart';
import 'package:trivia/core/utils/size_config.dart';
import 'package:trivia/data/models/trivia_user.dart';

class UserAvatar extends ConsumerWidget {
  final double radius;
  final bool showProgress;
  final TriviaUser? user;
  final bool disabled;

  const UserAvatar({
    required this.user,
    this.radius = 42,
    this.showProgress = false,
    this.disabled = false,
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return GestureDetector(
      onTap: disabled
          ? null
          : user != null
              ? () => showProfileOverview(context, user!)
              : null,
      child: Stack(
        alignment: Alignment.center,
        children: [
          if (showProgress)
            SizedBox(
              width: calcWidth(radius * 2.1),
              height: calcWidth(radius * 2.1),
              child: CircularProgressIndicator(
                strokeWidth: 6.0,
                value: user?.userXp ?? 0 / 100,
                color: AppConstant.onPrimaryColor,
              ),
            ),
          user != null && user?.uid == "-1"
              ? ClipPath(
                  clipper: HalfCircleClipper(),
                  child: CircleAvatar(
                    radius: calcWidth(radius),
                    backgroundColor: AppConstant.softHighlightColor,
                    child: SvgPicture.asset(
                      user?.imageUrl ?? Strings.botAvatar,
                    ),
                  ),
                )
              : user != null && user?.imageUrl != null
                  ? CachedNetworkImage(
                      imageUrl: user!.imageUrl!,
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
                  : user != null && user?.fluttermojiOptions != null
                      ? ClipPath(
                          clipper: HalfCircleClipper(),
                          child: CircleAvatar(
                            radius: calcWidth(radius),
                            backgroundColor: AppConstant.softHighlightColor,
                            child: SvgPicture.string(
                              ref
                                  .read(fluttermojiNotifierProvider.notifier)
                                  .getFluttermojiFromOptions(
                                      user!.fluttermojiOptions!),
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
                        )
        ],
      ),
    );
  }
}
