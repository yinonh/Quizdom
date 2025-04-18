import 'package:flutter/material.dart';
import 'package:trivia/core/common_widgets/user_coins.dart';
import 'package:trivia/core/common_widgets/user_resources_dialog.dart';
import 'package:trivia/core/constants/app_constant.dart';

class ResourceFloatingActionButton extends StatelessWidget {
  const ResourceFloatingActionButton({super.key});

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      onPressed: () {
        UserResourcesDialog.show(context);
      },
      backgroundColor: AppConstant.primaryColor,
      shape: const CircleBorder(),
      child: const UserCoins(),
    );
  }
}
