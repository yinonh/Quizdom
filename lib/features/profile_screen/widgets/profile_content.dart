import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trivia/core/common_widgets/stars.dart';
import 'package:trivia/core/utils/size_config.dart';
import 'package:trivia/features/profile_screen/view_modle/profile_screen_manager.dart';
import 'package:trivia/core/constants/app_constant.dart';
import 'package:trivia/core/constants/constant_strings.dart';

import 'editable_field.dart';

class ProfileContent extends ConsumerWidget {
  const ProfileContent({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileState = ref.watch(profileScreenManagerProvider);
    final profileNotifier = ref.read(profileScreenManagerProvider.notifier);

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(top: 60, left: 10, right: 10),
      padding: const EdgeInsets.all(16.0),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.all(
          Radius.circular(35.0),
        ),
      ),
      child: Stack(
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Padding(
                padding: EdgeInsets.only(
                  left: calcWidth(20),
                  right: calcWidth(20),
                  top: calcHeight(100),
                ),
                child: const SizedBox(height: 5),
              ),
              Container(
                width: calcWidth(150),
                padding: const EdgeInsets.all(3),
                decoration: const BoxDecoration(
                  color: AppConstant.onPrimary,
                  borderRadius: BorderRadius.all(Radius.circular(30)),
                ),
                child: const UserStars(),
              ),
              SizedBox(height: calcHeight(16)),
              profileState.isEditing
                  ? EditableField(
                      label: Strings.username,
                      controller: profileState.nameController,
                    )
                  : _buildDisplayText(
                      Strings.username, profileState.nameController.text),
              const SizedBox(height: 8),
              profileState.isEditing
                  ? EditableField(
                      controller: profileState.emailController,
                      label: Strings.email,
                    )
                  : _buildDisplayText(
                      Strings.email, profileState.emailController.text),
              SizedBox(height: calcHeight(8)),
              if (profileState.isEditing)
                EditableField(
                  label: Strings.password,
                  controller: profileState.passwordController,
                ),
              SizedBox(height: calcHeight(5)),
            ],
          ),
          Positioned(
            top: 0,
            right: 0,
            child: IconButton(
              icon: Icon(
                profileState.isEditing
                    ? Icons.save_rounded
                    : Icons.edit_rounded,
                color: AppConstant.primaryColor,
              ),
              onPressed: profileNotifier.toggleIsEditing,
            ),
          )
        ],
      ),
    );
  }

  Widget _buildDisplayText(String label, String text) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          "$label:",
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppConstant.highlightColor,
          ),
        ),
        const SizedBox(width: 5),
        Text(
          text,
          style: const TextStyle(
            fontSize: 16,
            color: Colors.black,
          ),
        ),
      ],
    );
  }
}
