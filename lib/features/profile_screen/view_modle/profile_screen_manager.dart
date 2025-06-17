import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:trivia/core/common_widgets/base_screen.dart';
import 'package:trivia/core/constants/constant_strings.dart';
import 'package:trivia/core/network/server.dart';
import 'package:trivia/core/utils/map_firebase_errors_to_message.dart';
import 'package:trivia/data/models/trivia_user.dart';
import 'package:trivia/data/models/user_statistics.dart';
import 'package:trivia/data/providers/user_provider.dart';
import 'package:trivia/data/providers/user_statistics_provider.dart';

part 'profile_screen_manager.freezed.dart';
part 'profile_screen_manager.g.dart';

@freezed
class ProfileState with _$ProfileState {
  const factory ProfileState({
    TriviaUser? currentUser,
    required UserStatistics statistics,
    required bool isEditing,
    required bool isGoogleAuth,
    required TextEditingController nameController,
    required TextEditingController oldPasswordController,
    required TextEditingController newPasswordController,
    required String oldPasswordErrorMessage,
    required String newPasswordErrorMessage,
    String? firebaseErrorMessage,
  }) = _ProfileState;
}

@riverpod
class ProfileScreenManager extends _$ProfileScreenManager {
  @override
  ProfileState build() {
    final currentUser = ref.watch(authProvider).currentUser;
    final userNotifier = ref.read(authProvider.notifier);
    final statistics = ref.watch(statisticsProvider).userStatistics;
    return ProfileState(
      currentUser: currentUser,
      statistics: statistics,
      isEditing: false,
      isGoogleAuth: userNotifier.isGoogleSignIn(),
      nameController: TextEditingController(text: currentUser.name),
      oldPasswordController: TextEditingController(),
      newPasswordController: TextEditingController(),
      oldPasswordErrorMessage: '',
      newPasswordErrorMessage: '',
    );
  }

  void toggleIsEditing() {
    state = state.copyWith(
        isEditing: !state.isEditing,
        oldPasswordErrorMessage: '',
        newPasswordErrorMessage: '');
  }

  void deleteFirebaseMessage() {
    state = state.copyWith(firebaseErrorMessage: null);
  }

  Future<void> updateUserDetails() async {
    if (!state.isGoogleAuth) {
      String oldPasswordError = '';
      String newPasswordError = '';

      // Password validation (for new password)
      if (state.newPasswordController.text.isNotEmpty &&
          state.newPasswordController.text.length < 6) {
        newPasswordError = Strings.passwordTooShort;
      }

      // Old password validation
      if (state.oldPasswordController.text.isEmpty) {
        oldPasswordError = Strings.currentPasswordRequired;
      }

      if (oldPasswordError.isNotEmpty || newPasswordError.isNotEmpty) {
        state = state.copyWith(
          oldPasswordErrorMessage: oldPasswordError,
          newPasswordErrorMessage: newPasswordError,
        );
        return;
      }
      state = state.copyWith(
        oldPasswordErrorMessage: '',
        newPasswordErrorMessage: '',
      );
    }

    ref.read(loadingProvider.notifier).state = true;

    try {
      final userProvider = ref.watch(authProvider);
      final currentUser = userProvider.firebaseUser;
      AuthCredential credential;

      if (state.isGoogleAuth) {
        // Re-authenticate the user using Google credentials
        final googleSignIn = GoogleSignIn();
        final googleUser = await googleSignIn.signIn();

        if (googleUser == null) {
          throw FirebaseAuthException(
              code: 'ERROR_ABORTED_BY_USER',
              message: 'Sign in aborted by user');
        }

        final googleAuth = await googleUser.authentication;
        credential = GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken,
        );
      } else {
        // Re-authenticate the user with old credentials
        credential = EmailAuthProvider.credential(
          email: currentUser!.email!,
          password: state.oldPasswordController.text,
        );
      }
      if (currentUser != null) {
        await currentUser.reauthenticateWithCredential(credential);

        // Update password in Firebase Auth (if provided)
        if (state.newPasswordController.text.isNotEmpty) {
          await currentUser.updatePassword(state.newPasswordController.text);
        }

        // Update name and email in state and Firestore
        await ref.read(authProvider.notifier).updateUserDetails(
              uid: currentUser.uid,
              name: state.nameController.text,
            );

        // Reset the editing state
        state = state.copyWith(isEditing: false);
      }
    } on FirebaseAuthException catch (e) {
      logger.e(e);
      state = state.copyWith(
          firebaseErrorMessage: mapFirebaseErrorCodeToMessage(e));
    } finally {
      ref.read(loadingProvider.notifier).state = false;
    }
  }
}
