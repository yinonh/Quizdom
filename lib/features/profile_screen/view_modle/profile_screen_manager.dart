import 'package:email_validator/email_validator.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:trivia/core/constants/constant_strings.dart';
import 'package:trivia/core/network/server.dart';
import 'package:trivia/core/utils/map_firebase_errors_to_message.dart';
import 'package:trivia/data/models/user.dart';
import 'package:trivia/data/service/user_provider.dart';

part 'profile_screen_manager.freezed.dart';

part 'profile_screen_manager.g.dart';

@freezed
class ProfileState with _$ProfileState {
  const factory ProfileState({
    TriviaUser? currentUser,
    required bool isEditing,
    required bool isLoading,
    required TextEditingController nameController,
    required TextEditingController emailController,
    required TextEditingController oldPasswordController,
    required TextEditingController newPasswordController,
    required String emailErrorMessage,
    required String oldPasswordErrorMessage,
    required String newPasswordErrorMessage,
    String? firebaseErrorMessage,
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
      isLoading: false,
      nameController: TextEditingController(text: currentUser.name),
      emailController: TextEditingController(text: currentUser.email),
      oldPasswordController: TextEditingController(),
      newPasswordController: TextEditingController(),
      emailErrorMessage: '',
      oldPasswordErrorMessage: '',
      newPasswordErrorMessage: '',
    );
  }

  void toggleIsEditing() {
    state = state.copyWith(isEditing: !state.isEditing);
  }

  void deleteFirebaseMessage() {
    state = state.copyWith(firebaseErrorMessage: null);
  }

  Future<void> updateUserDetails() async {
    String emailError = '';
    String oldPasswordError = '';
    String newPasswordError = '';

    // Email validation
    if (!EmailValidator.validate(state.emailController.text)) {
      emailError = Strings.invalidEmail;
    }

    // Password validation (for new password)
    if (state.newPasswordController.text.isNotEmpty &&
        state.newPasswordController.text.length < 6) {
      newPasswordError = Strings.passwordTooShort;
    }

    // Old password validation
    if (state.oldPasswordController.text.isEmpty) {
      oldPasswordError = "Old Password Required";
    }

    if (emailError.isNotEmpty ||
        oldPasswordError.isNotEmpty ||
        newPasswordError.isNotEmpty) {
      state = state.copyWith(
        emailErrorMessage: emailError,
        oldPasswordErrorMessage: oldPasswordError,
        newPasswordErrorMessage: newPasswordError,
      );
      return;
    }

    state = state.copyWith(
      isLoading: true,
      emailErrorMessage: '',
      oldPasswordErrorMessage: '',
      newPasswordErrorMessage: '',
    );

    try {
      final currentUser = FirebaseAuth.instance.currentUser;

      // Re-authenticate the user with old credentials
      final credential = EmailAuthProvider.credential(
        email: currentUser!.email!,
        password: state.oldPasswordController.text,
      );

      await currentUser.reauthenticateWithCredential(credential);

      // Update email in Firebase Auth
      if (currentUser.email != state.emailController.text) {
        await currentUser.verifyBeforeUpdateEmail(state.emailController.text);
      }

      // Update password in Firebase Auth (if provided)
      if (state.newPasswordController.text.isNotEmpty) {
        await currentUser.updatePassword(state.newPasswordController.text);
      }

      // Update name and email in state and Firestore
      await ref.read(userProvider.notifier).updateUserDetails(
            uid: currentUser.uid,
            name: state.nameController.text,
            email: state.emailController.text,
          );

      // Reset the editing state
      state = state.copyWith(isEditing: false);
    } on FirebaseAuthException catch (e) {
      logger.e(e);
      state = state.copyWith(
          firebaseErrorMessage: mapFirebaseErrorCodeToMessage(e));
    } finally {
      state = state.copyWith(isLoading: false);
    }
  }
}
