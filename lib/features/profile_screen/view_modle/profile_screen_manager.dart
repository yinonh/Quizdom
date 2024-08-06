import 'package:flutter/cupertino.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:trivia/models/user.dart';
import 'package:trivia/service/user_provider.dart';

part 'profile_screen_manager.freezed.dart';

part 'profile_screen_manager.g.dart';

@freezed
class ProfileState with _$ProfileState {
  const factory ProfileState({
    TriviaUser? currentUser,
    required bool isEditing,
    required TextEditingController nameController,
    required TextEditingController emailController,
    required TextEditingController passwordController,
  }) = _ProfileState;
}

@riverpod
class ProfileScreenManager extends _$ProfileScreenManager {
  @override
  ProfileState build() {
    final currentUser = ref.watch(userProvider).currentUser;
    return ProfileState(
      currentUser: currentUser,
      isEditing: false,
      nameController: TextEditingController(text: currentUser.name),
      emailController: TextEditingController(text: currentUser.email),
      passwordController: TextEditingController(),
    );
  }

  void toggleIsEditing() {
    state = state.copyWith(isEditing: !state.isEditing);
  }
}
