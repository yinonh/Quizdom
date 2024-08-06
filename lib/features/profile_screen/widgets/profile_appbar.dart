import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trivia/common_widgets/app_bar.dart';
import 'package:trivia/features/categories_screen/categories_screen.dart';
import 'package:trivia/features/profile_screen/view_modle/profile_screen_manager.dart';

class ProfileAppbar extends ConsumerWidget {
  const ProfileAppbar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileState = ref.watch(profileScreenManagerProvider);
    final profileNotifier = ref.read(profileScreenManagerProvider.notifier);
    return CustomAppBar(
      title: 'Profile',
      leading: IconButton(
        icon: const Icon(
          Icons.arrow_back_ios_new_rounded,
          color: Colors.white,
        ),
        onPressed: () {
          Navigator.pushReplacementNamed(context, CategoriesScreen.routeName);
        },
      ),
      actions: [
        IconButton(
          icon: Icon(
            profileState.isEditing ? Icons.save : Icons.edit,
            color: Colors.white,
          ),
          onPressed: profileNotifier.toggleIsEditing,
        ),
      ],
    );
  }
}
