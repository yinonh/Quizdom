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
    required bool shouldShowAccountLinkForm, // New field
  }) = _ProfileState;
}

@riverpod
class ProfileScreenManager extends _$ProfileScreenManager {
  @override
  Future<ProfileState> build() async { // Changed to Future<ProfileState>
    final authState = ref.watch(authProvider);
    final currentUserModel = authState.currentUser; // This is TriviaUser
    final firebaseUser = authState.firebaseUser; // This is the actual FirebaseUser
    final userNotifier = ref.read(authProvider.notifier);
    final statistics = ref.watch(statisticsProvider).userStatistics;

    final prefs = await SharedPreferences.getInstance();
    final storedDeviceGuestUid = prefs.getString('device_guest_uid');

    bool localShouldShowAccountLinkForm = false;
    if (firebaseUser != null && storedDeviceGuestUid == firebaseUser.uid) {
      // User's UID matches the stored device_guest_uid.
      // Now check if they have linked other providers (e.g., email/password, Google).
      // If they only have 'firebase' (custom token) or 'anonymous' (initial session)
      // as providers, they are still considered a device guest needing to link.
      bool isLinkedToPermanent = firebaseUser.providerData.any((userInfo) =>
          userInfo.providerId == 'password' || userInfo.providerId == 'google.com');

      if (!isLinkedToPermanent) {
        localShouldShowAccountLinkForm = true;
      }
    }
    // No further checks against currentUserModel.isAnonymous are needed here for this flag,
    // as the storedDeviceGuestUid and providerData check is more definitive for
    // a user who might have logged out and back in via custom token.

    return ProfileState(
      currentUser: currentUserModel,
      statistics: statistics,
      isEditing: false,
      isGoogleAuth: userNotifier.isGoogleSignIn(),
      nameController: TextEditingController(text: currentUserModel.name),
      oldPasswordController: TextEditingController(),
      newPasswordController: TextEditingController(),
      oldPasswordErrorMessage: '',
      newPasswordErrorMessage: '',
      linkEmailController: TextEditingController(),
      linkPasswordController: TextEditingController(),
      linkConfirmPasswordController: TextEditingController(),
      linkEmailErrorMessage: '',
      linkPasswordErrorMessage: '',
      linkConfirmPasswordErrorMessage: '',
      showPassword: false,
      showConfirmPassword: false,
      showOldPassword: false,
      shouldShowAccountLinkForm: localShouldShowAccountLinkForm,
    );
  }

  // Methods that modify state need to handle AsyncValue if state becomes AsyncValue.
  // For now, they modify 'state.value' if 'state' is AsyncData.
  // Riverpod generators handle this somewhat automatically for AsyncNotifiers.

  void toggleShowPassword() {
    state = state.whenData((s) => s.copyWith(showPassword: !s.showPassword));
  }

  void toggleShowConfirmPassword() {
    state = state.whenData((s) => s.copyWith(showConfirmPassword: !s.showConfirmPassword));
  }
  void toggleShowOldPassword() {
    state = state.whenData((s) => s.copyWith(showOldPassword: !s.showOldPassword));
  }

  void toggleIsEditing() {
    state = state.whenData((s) => s.copyWith(
        isEditing: !s.isEditing,
        oldPasswordErrorMessage: '',
        newPasswordErrorMessage: ''
    ));
  }

  void deleteFirebaseMessage() {
    state = state.whenData((s) => s.copyWith(firebaseErrorMessage: null));
  }

  Future<void> updateUserDetails() async {
    final currentProfileState = state.valueOrNull;
    if (currentProfileState == null) return;

    if (!currentProfileState.isGoogleAuth) {
      String oldPasswordError = '';
      String newPasswordError = '';

      if (currentProfileState.newPasswordController.text.isNotEmpty &&
          currentProfileState.newPasswordController.text.length < 6) {
        newPasswordError = Strings.passwordTooShort;
      }
      if (currentProfileState.oldPasswordController.text.isEmpty) {
        oldPasswordError = Strings.currentPasswordRequired;
      }

      if (oldPasswordError.isNotEmpty || newPasswordError.isNotEmpty) {
        state = state.whenData((s) => s.copyWith(
          oldPasswordErrorMessage: oldPasswordError,
          newPasswordErrorMessage: newPasswordError,
        ));
        return;
      }
      state = state.whenData((s) => s.copyWith(
        oldPasswordErrorMessage: '',
        newPasswordErrorMessage: '',
      ));
    }

    ref.read(loadingProvider.notifier).state = true;
    try {
      final userProvider = ref.watch(authProvider);
      final firebaseUser = userProvider.firebaseUser; // The actual FirebaseUser
      AuthCredential credential;

      if (currentProfileState.isGoogleAuth) {
        final googleSignIn = GoogleSignIn();
        final googleUser = await googleSignIn.signIn();
        if (googleUser == null) {
          throw FirebaseAuthException(code: 'ERROR_ABORTED_BY_USER', message: 'Sign in aborted by user');
        }
        final googleAuth = await googleUser.authentication;
        credential = GoogleAuthProvider.credential(accessToken: googleAuth.accessToken, idToken: googleAuth.idToken);
      } else {
        if (firebaseUser?.email == null) throw Exception("Current user email is null");
        credential = EmailAuthProvider.credential(email: firebaseUser!.email!, password: currentProfileState.oldPasswordController.text);
      }

      if (firebaseUser != null) {
        await firebaseUser.reauthenticateWithCredential(credential);
        if (currentProfileState.newPasswordController.text.isNotEmpty) {
          await firebaseUser.updatePassword(currentProfileState.newPasswordController.text);
        }
        await ref.read(authProvider.notifier).updateUserDetails(
              uid: firebaseUser.uid,
              name: currentProfileState.nameController.text,
            );
        state = state.whenData((s) => s.copyWith(isEditing: false));
      }
    } on FirebaseAuthException catch (e) {
      logger.e(e);
      state = state.whenData((s) => s.copyWith(firebaseErrorMessage: mapFirebaseErrorCodeToMessage(e)));
    } finally {
      ref.read(loadingProvider.notifier).state = false;
    }
  }

  Future<void> linkAccount() async {
    final currentProfileState = state.valueOrNull;
    if (currentProfileState == null) return;

    String emailError = '';
    String passwordError = '';
    String confirmPasswordError = '';

    final email = currentProfileState.linkEmailController.text;
    final password = currentProfileState.linkPasswordController.text;
    final confirmPassword = currentProfileState.linkConfirmPasswordController.text;

    if (email.isEmpty || !RegExp(r"[^@ \t\r\n]+@[^@ \t\r\n]+\.[^@ \t\r\n]+").hasMatch(email)) {
      emailError = Strings.invalidEmail;
    }
    if (password.length < 6) {
      passwordError = Strings.passwordTooShort;
    }
    if (password != confirmPassword) {
      confirmPasswordError = Strings.passwordsNotMatch;
    }

    state = state.whenData((s) => s.copyWith(
      linkEmailErrorMessage: emailError,
      linkPasswordErrorMessage: passwordError,
      linkConfirmPasswordErrorMessage: confirmPasswordError,
    ));

    if (emailError.isNotEmpty || passwordError.isNotEmpty || confirmPasswordError.isNotEmpty) {
      return;
    }

    ref.read(loadingProvider.notifier).state = true;
    try {
      await ref.read(authProvider.notifier).linkEmailAndPassword(email, password);
      // state.value is read-only. To update, assign to state.
      // After linking, the build method will run again, and shouldShowAccountLinkForm should become false.
      final updatedState = state.valueOrNull?.copyWith(
        firebaseErrorMessage: null,
        linkEmailController: TextEditingController(text: ''), // Clear fields
        linkPasswordController: TextEditingController(text: ''),
        linkConfirmPasswordController: TextEditingController(text: ''),
      );
      if (updatedState != null) {
         // state = AsyncData(updatedState); // This might not be needed if build() re-evaluates correctly
      }
       // Let build method re-evaluate shouldShowAccountLinkForm
       ref.invalidateSelf(); // Force re-run of build method.

    } on FirebaseAuthException catch (e) {
      state = state.whenData((s) => s.copyWith(firebaseErrorMessage: mapFirebaseErrorCodeToMessage(e)));
    } catch (e) {
      state = state.whenData((s) => s.copyWith(firebaseErrorMessage: e.toString()));
    } finally {
      ref.read(loadingProvider.notifier).state = false;
    }
  }
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

  Future<void> linkAccount() async {
    // Validation
    String emailError = '';
    String passwordError = '';
    String confirmPasswordError = '';

    final email = state.linkEmailController.text;
    final password = state.linkPasswordController.text;
    final confirmPassword = state.linkConfirmPasswordController.text;

    if (email.isEmpty || !RegExp(r"[^@ \t\r\n]+@[^@ \t\r\n]+\.[^@ \t\r\n]+").hasMatch(email)) {
      emailError = Strings.invalidEmail;
    }
    if (password.length < 6) {
      passwordError = Strings.passwordTooShort;
    }
    if (password != confirmPassword) {
      confirmPasswordError = Strings.passwordsNotMatch;
    }

    state = state.copyWith(
      linkEmailErrorMessage: emailError,
      linkPasswordErrorMessage: passwordError,
      linkConfirmPasswordErrorMessage: confirmPasswordError,
    );

    if (emailError.isNotEmpty || passwordError.isNotEmpty || confirmPasswordError.isNotEmpty) {
      return;
    }

    ref.read(loadingProvider.notifier).state = true;
    try {
      await ref.read(authProvider.notifier).linkEmailAndPassword(email, password);
      // After successful linking, the authStateChanges listener in router or
      // relevant widgets should handle UI updates.
      // We can clear the form fields and potentially hide the form.
      state.linkEmailController.clear();
      state.linkPasswordController.clear();
      state.linkConfirmPasswordController.clear();
      // The user is no longer anonymous, so subsequent builds of ProfileState
      // should reflect this, potentially hiding the link form.
      // We might not need an explicit showLinkForm if currentUser.isAnonymous is used.
       state = state.copyWith(firebaseErrorMessage: null); // Clear any previous error
    } on FirebaseAuthException catch (e) {
      state = state.copyWith(firebaseErrorMessage: mapFirebaseErrorCodeToMessage(e));
    } catch (e) {
      state = state.copyWith(firebaseErrorMessage: e.toString());
    } finally {
      ref.read(loadingProvider.notifier).state = false;
    }
  }
}
