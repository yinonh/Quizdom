import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trivia/core/common_widgets/custom_button.dart';
import 'package:trivia/core/constants/app_constant.dart';
import 'package:trivia/core/constants/constant_strings.dart';
import 'package:trivia/core/utils/size_config.dart';
import 'package:trivia/features/profile_screen/view_modle/profile_screen_manager.dart';

import 'editable_field.dart';

class EditUserDetails extends ConsumerWidget {
  const EditUserDetails({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileState = ref.watch(profileScreenManagerProvider);
    final profileNotifier = ref.read(profileScreenManagerProvider.notifier);
    return Column(
      children: [
        EditableField(
          label: Strings.username,
          controller: profileState.nameController,
        ),
        if (!profileState.isGoogleAuth)
          Column(
            children: [
              const SizedBox(height: 8),
              EditableField(
                label: Strings.currentPassword,
                isPassword: true,
                controller: profileState.oldPasswordController,
                errorText: profileState.oldPasswordErrorMessage.isNotEmpty
                    ? profileState.oldPasswordErrorMessage
                    : null,
              ),
              const SizedBox(height: 8),
              EditableField(
                label: Strings.newPassword,
                isPassword: true,
                controller: profileState.newPasswordController,
                errorText: profileState.newPasswordErrorMessage.isNotEmpty
                    ? profileState.newPasswordErrorMessage
                    : null,
              ),
            ],
          ),
        SizedBox(height: calcHeight(8)),
        CustomButton(
          text: Strings.save,
          onTap: () async {
            await profileNotifier.updateUserDetails();
          },
          color: AppConstant.secondaryColor,
          padding: EdgeInsets.symmetric(vertical: calcHeight(15)),
        ),
      ],
    );
  }
}
