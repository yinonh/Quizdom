import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:trivia/core/common_widgets/user_resources_dialog.dart';
import 'package:trivia/core/constants/constant_strings.dart';
import 'package:trivia/core/utils/size_config.dart';

class UserCoins extends StatelessWidget {
  const UserCoins({super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        UserResourcesDialog.show(context);
      },
      child: SvgPicture.asset(
        Strings.closeChestIcon,
        height: calcHeight(40),
      ),
    );
  }
}
