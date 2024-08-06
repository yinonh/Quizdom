import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trivia/common_widgets/stars.dart';
import 'package:trivia/features/profile_screen/view_modle/profile_screen_manager.dart';
import 'package:trivia/features/profile_screen/widgets/trophys.dart';
import 'package:trivia/utility/app_constant.dart';
import 'package:trivia/utility/color_utility.dart';
import 'package:trivia/utility/size_config.dart';
import 'editable_field.dart';

class ProfileContent extends ConsumerWidget {
  const ProfileContent({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileState = ref.watch(profileScreenManagerProvider);
    final profileNotifier = ref.read(profileScreenManagerProvider.notifier);

    return Container(
      height: MediaQuery.of(context).size.height,
      width: double.infinity,
      margin: const EdgeInsets.only(top: 60),
      padding: const EdgeInsets.all(16.0),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(35.0),
          topRight: Radius.circular(35.0),
        ),
      ),
      child: Column(
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
            decoration: BoxDecoration(
              color: AppConstant.onPrimary.toColor(),
              borderRadius: const BorderRadius.all(Radius.circular(30)),
            ),
            child: const UserStars(),
          ),
          const SizedBox(height: 16),
          profileState.isEditing
              ? EditableField(
                  label: 'Username',
                  controller: profileState.nameController,
                )
              : _buildDisplayText('Username', profileState.nameController.text),
          const SizedBox(height: 8),
          profileState.isEditing
              ? EditableField(
                  controller: profileState.emailController,
                  label: 'Email',
                )
              : _buildDisplayText('Email', profileState.emailController.text),
          const SizedBox(height: 8),
          if (profileState.isEditing)
            EditableField(
              label: 'Password',
              controller: profileState.passwordController,
            ),
          const SizedBox(height: 32),
          const TrophySection(),
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
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppConstant.highlightColor.toColor(),
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
