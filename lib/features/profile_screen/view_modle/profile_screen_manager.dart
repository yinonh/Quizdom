import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:profanity_filter/profanity_filter.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:Quizdom/core/common_widgets/base_screen.dart';
import 'package:Quizdom/core/constants/constant_strings.dart';
import 'package:Quizdom/core/network/server.dart';
import 'package:Quizdom/core/utils/map_firebase_errors_to_message.dart';
import 'package:Quizdom/data/models/trivia_user.dart';
import 'package:Quizdom/data/models/user_statistics.dart';
import 'package:Quizdom/data/providers/user_provider.dart';
import 'package:Quizdom/data/providers/user_statistics_provider.dart';

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
    required String usenameErrorMessage,
    String? firebaseErrorMessage,
    // Fields for account linking
    required TextEditingController linkEmailController,
    required TextEditingController linkPasswordController,
    required TextEditingController linkConfirmPasswordController,
    required String linkEmailErrorMessage,
    required String linkPasswordErrorMessage,
    required String linkConfirmPasswordErrorMessage,
    required bool showPassword,
    required bool showConfirmPassword,
    required bool showOldPassword,
  }) = _ProfileState;
}

@riverpod
class ProfileScreenManager extends _$ProfileScreenManager {
  @override
  ProfileState build() {
    final authState = ref.watch(authProvider);
    final currentUser = authState.currentUser;
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
      usenameErrorMessage: '',
      // Initialize linking fields
      linkEmailController: TextEditingController(),
      linkPasswordController: TextEditingController(),
      linkConfirmPasswordController: TextEditingController(),
      linkEmailErrorMessage: '',
      linkPasswordErrorMessage: '',
      linkConfirmPasswordErrorMessage: '',
      showPassword: false,
      showConfirmPassword: false,
      showOldPassword: false,
    );
  }

  void toggleShowPassword() {
    state = state.copyWith(showPassword: !state.showPassword);
  }

  void toggleShowConfirmPassword() {
    state = state.copyWith(showConfirmPassword: !state.showConfirmPassword);
  }

  void toggleShowOldPassword() {
    state = state.copyWith(showOldPassword: !state.showOldPassword);
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
    final filter = ProfanityFilter();
    final newName = state.nameController.text.trim();

    final RegExp validCharacters = RegExp(r'^[a-zA-Z0-9]+$');
    const int maxNameLength = 20;

    if (filter.hasProfanity(newName)) {
      state = state.copyWith(
        usenameErrorMessage: Strings.userNameNotAllowed,
      );
      return;
    }

    if (!validCharacters.hasMatch(newName)) {
      state = state.copyWith(
        usenameErrorMessage: Strings.onlyEnglishLettersAllowed,
      );
      return;
    }

    if (newName.length > maxNameLength) {
      state = state.copyWith(
        usenameErrorMessage:
            "${Strings.userNameTooLong} $maxNameLength ${Strings.characters}",
      );
      return;
    }

    if (!state.isGoogleAuth) {
      String oldPasswordError = '';
      String newPasswordError = '';

      if (state.newPasswordController.text.isNotEmpty &&
          state.newPasswordController.text.length < 6) {
        newPasswordError = Strings.passwordTooShort;
      }

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
        credential = EmailAuthProvider.credential(
          email: currentUser!.email!,
          password: state.oldPasswordController.text,
        );
      }

      if (currentUser != null) {
        await currentUser.reauthenticateWithCredential(credential);

        if (state.newPasswordController.text.isNotEmpty) {
          await currentUser.updatePassword(state.newPasswordController.text);
        }

        await ref.read(authProvider.notifier).updateUserDetails(
              uid: currentUser.uid,
              name: newName,
            );

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

  bool _isPasswordStrong(String password) {
    if (password.length < 6) return false;

    final RegExp englishLetterRegex = RegExp(r'[a-zA-Z]');
    return englishLetterRegex.hasMatch(password);
  }

  Future<void> linkAccount() async {
    // Validation
    String emailError = '';
    String passwordError = '';
    String confirmPasswordError = '';

    final email = state.linkEmailController.text;
    final password = state.linkPasswordController.text;
    final confirmPassword = state.linkConfirmPasswordController.text;

    if (email.isEmpty ||
        !RegExp(r"[^@ \t\r\n]+@[^@ \t\r\n]+\.[^@ \t\r\n]+").hasMatch(email)) {
      emailError = Strings.invalidEmail;
    }
    if (!_isPasswordStrong(password)) {
      if (password.length < 6) {
        passwordError = Strings.passwordTooShort;
      } else {
        passwordError = Strings.passwordMustContainLetter;
      }
    }
    if (password != confirmPassword) {
      confirmPasswordError = Strings.passwordsNotMatch;
    }

    state = state.copyWith(
      linkEmailErrorMessage: emailError,
      linkPasswordErrorMessage: passwordError,
      linkConfirmPasswordErrorMessage: confirmPasswordError,
    );

    if (emailError.isNotEmpty ||
        passwordError.isNotEmpty ||
        confirmPasswordError.isNotEmpty) {
      return;
    }

    ref.read(loadingProvider.notifier).state = true;
    try {
      await ref
          .read(authProvider.notifier)
          .linkEmailAndPassword(email, password);
      // After successful linking, the authStateChanges listener in router or
      // relevant widgets should handle UI updates.
      // We can clear the form fields and potentially hide the form.
      state.linkEmailController.clear();
      state.linkPasswordController.clear();
      state.linkConfirmPasswordController.clear();
      // The user is no longer anonymous, so subsequent builds of ProfileState
      // should reflect this, potentially hiding the link form.
      // We might not need an explicit showLinkForm if currentUser.isAnonymous is used.
      state = state.copyWith(
          firebaseErrorMessage: null); // Clear any previous error
    } on FirebaseAuthException catch (e) {
      state = state.copyWith(
          firebaseErrorMessage: mapFirebaseErrorCodeToMessage(e));
    } catch (e) {
      state = state.copyWith(firebaseErrorMessage: e.toString());
    } finally {
      ref.read(loadingProvider.notifier).state = false;
    }
  }
}
