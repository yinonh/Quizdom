import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:trivia/service/user_provider.dart';
import 'package:trivia/utility/app_constant.dart';
import 'package:trivia/utility/color_utility.dart';
import 'package:trivia/utility/size_config.dart';

class UserAvatar extends ConsumerWidget {
  final double radius;
  const UserAvatar({this.radius = 42, super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userState = ref.watch(userProvider).currentUser;
    return userState.userImage != null
        ? CircleAvatar(
            backgroundImage: FileImage(userState.userImage!),
            radius: calcWidth(radius),
          )
        : CircleAvatar(
            backgroundColor: AppConstant.userAvatarBackground.toColor(),
            radius: calcWidth(radius),
            child: ClipOval(
              child: SvgPicture.string(
                userState.avatar!,
                fit: BoxFit.cover,
                height: calcWidth(radius * 2),
                width: calcWidth(radius * 2),
              ),
            ),
          );
  }
}
