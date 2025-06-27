import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:Quizdom/core/common_widgets/custom_button.dart';
import 'package:Quizdom/core/constants/app_constant.dart';
import 'package:Quizdom/core/constants/constant_strings.dart';
import 'package:Quizdom/core/utils/size_config.dart';
import 'package:Quizdom/features/profile_screen/view_modle/profile_screen_manager.dart';

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
          errorText: profileState.usenameErrorMessage.isNotEmpty
              ? profileState.usenameErrorMessage
              : null,
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
