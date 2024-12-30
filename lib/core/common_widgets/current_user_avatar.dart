import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shimmer/shimmer.dart';
import 'package:trivia/core/constants/app_constant.dart';
import 'package:trivia/core/utils/fluttermoji/fluttermoji_circle_avatar.dart';
import 'package:trivia/core/utils/size_config.dart';
import 'package:trivia/data/service/user_provider.dart';

class CurrentUserAvatar extends ConsumerWidget {
  final double radius;
  final bool showProgress;

  const CurrentUserAvatar(
      {this.radius = 42, this.showProgress = false, super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userState = ref.watch(authProvider);
    if (userState.imageLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }
    return Stack(
      alignment: Alignment.center,
      children: [
        if (showProgress)
          SizedBox(
            width: calcWidth(radius * 2.1),
            height: calcWidth(radius * 2.1),
            child: CircularProgressIndicator(
              strokeWidth: 6.0,
              value: userState.currentUser.userXp / 100,
              color: AppConstant.onPrimary,
            ),
          ),
        userState.currentUser.imageUrl != null
            ? CachedNetworkImage(
                imageUrl: userState.currentUser.imageUrl!,
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

            // ? CircleAvatar(
            //     backgroundImage: NetworkImage(userState.currentUser.imageUrl!),
            //     radius: calcWidth(radius),
            //   )
            : FluttermojiCircleAvatar(
                backgroundColor: AppConstant.userAvatarBackground,
                radius: calcWidth(radius),
              ),
      ],
    );
  }
}
