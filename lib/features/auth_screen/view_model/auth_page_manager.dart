import 'package:email_validator/email_validator.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:trivia/core/common_widgets/base_screen.dart';
import 'package:trivia/core/constants/constant_strings.dart';
import 'package:trivia/core/global_providers/auth_providers.dart';
import 'package:trivia/core/utils/map_firebase_errors_to_message.dart';
import 'package:trivia/data/data_source/user_statistics_data_source.dart';
import 'package:trivia/data/providers/user_provider.dart';

part 'auth_page_manager.freezed.dart';
part 'auth_page_manager.g.dart';

@freezed
class AuthState with _$AuthState {
  const factory AuthState({
    required bool isLogin,
    required bool showPassword,
    required bool showConfirmPassword,
    required String email,
    required String password,
    required String confirmPassword,
    required String emailErrorMessage,
    required String passwordErrorMessage,
    required String confirmPasswordErrorMessage,
    String? firebaseErrorMessage,
    required bool navigate,
    required bool isNewUser,
    required GlobalKey<FormState> formKey,
  }) = _AuthState;
}

@riverpod
class AuthScreenManager extends _$AuthScreenManager {
  final _formKey = GlobalKey<FormState>();

  @override
  AuthState build() {
    return AuthState(
      isLogin: true,
      showPassword: false,
      showConfirmPassword: false,
      email: '',
      password: '',
      confirmPassword: '',
      emailErrorMessage: '',
      passwordErrorMessage: '',
      confirmPasswordErrorMessage: '',
      navigate: false,
      isNewUser: false,
      formKey: _formKey,
    );
  }

  void toggleFormMode() {
    ref.read(loadingProvider.notifier).state = false;
    state = state.copyWith(
      isLogin: !state.isLogin,
      showPassword: false,
      showConfirmPassword: false,
      confirmPassword: '',
      emailErrorMessage: '',
      passwordErrorMessage: '',
      confirmPasswordErrorMessage: '',
      firebaseErrorMessage: null,
      navigate: false,
      isNewUser: state.isLogin,
      formKey: _formKey,
    );
  }

  void toggleShowPassword() {
    state = state.copyWith(showPassword: !state.showPassword);
  }

  void toggleShowConfirmPassword() {
    state = state.copyWith(showConfirmPassword: !state.showConfirmPassword);
  }

  void setEmail(String email) {
    state = state.copyWith(email: email);
  }

  void setPassword(String password) {
    state = state.copyWith(password: password);
  }

  void setConfirmPassword(String confirmPassword) {
    state = state.copyWith(confirmPassword: confirmPassword);
  }

  void deleteFirebaseMessage() {
    state = state.copyWith(firebaseErrorMessage: null);
  }

  void resetNavigate() {
    state = state.copyWith(navigate: false);
  }

  bool _isPasswordStrong(String password) {
    if (password.length < 6) return false;

    final RegExp englishLetterRegex = RegExp(r'[a-zA-Z]');
    return englishLetterRegex.hasMatch(password);
  }

  Future<void> submit() async {
    String emailError = '';
    String passwordError = '';
    String confirmPasswordError = '';

    if (!EmailValidator.validate(state.email)) {
      emailError = Strings.invalidEmail;
    }
    if (!_isPasswordStrong(state.password)) {
      if (state.password.length < 6) {
        passwordError = Strings.passwordTooShort;
      } else {
        passwordError = Strings.passwordMustContainLetter;
      }
    }
    if (!state.isLogin && state.password != state.confirmPassword) {
      confirmPasswordError = Strings.passwordsNotMatch;
    }

    if (emailError.isNotEmpty ||
        passwordError.isNotEmpty ||
        confirmPasswordError.isNotEmpty) {
      state = state.copyWith(
        emailErrorMessage: emailError,
        passwordErrorMessage: passwordError,
        confirmPasswordErrorMessage: confirmPasswordError,
      );
      return;
    }

    ref.read(loadingProvider.notifier).state = true;
    state = state.copyWith(
        emailErrorMessage: '',
        passwordErrorMessage: '',
        confirmPasswordErrorMessage: '');

    try {
      if (state.isLogin) {
        await ref
            .read(authProvider.notifier)
            .signIn(state.email, state.password);
        // For login, clear any existing new user flag
        ref.read(newUserRegistrationProvider.notifier).clearNewUser();
        state = state.copyWith(navigate: true, isNewUser: false);
      } else {
        final userCredential = await ref
            .read(authProvider.notifier)
            .createUser(state.email, state.password);
        final newUserUid = userCredential.user!.uid;
        await UserStatisticsDataSource.createUserStatistics(newUserUid);

        // Set the new user flag in the global provider
        ref.read(newUserRegistrationProvider.notifier).setNewUser(true);
        state = state.copyWith(navigate: true, isNewUser: true);
      }
    } on FirebaseAuthException catch (e) {
      state = state.copyWith(
          firebaseErrorMessage: mapFirebaseErrorCodeToMessage(e));
    } finally {
      ref.read(loadingProvider.notifier).state = false;
    }
  }

// Updated signInWithGoogle method
  Future<void> signInWithGoogle() async {
    ref.read(loadingProvider.notifier).state = true;

    try {
      final additionalUserInfo =
          await ref.read(authProvider.notifier).signInWithGoogle();

      // Check if this is a new user or existing user
      final isNewUser = additionalUserInfo?.isNewUser ?? false;

      if (isNewUser) {
        // Set the new user flag in the global provider
        ref.read(newUserRegistrationProvider.notifier).setNewUser(true);
      } else {
        // Clear any existing new user flag
        ref.read(newUserRegistrationProvider.notifier).clearNewUser();
      }

      state = state.copyWith(navigate: true, isNewUser: isNewUser);
    } on FirebaseAuthException catch (e) {
      state = state.copyWith(
          firebaseErrorMessage: mapFirebaseErrorCodeToMessage(e));
    } catch (e) {
      state = state.copyWith(
          firebaseErrorMessage: 'An error occurred during Google sign-in');
    } finally {
      ref.read(loadingProvider.notifier).state = false;
    }
  }

  Future<void> signInAsGuest() async {
    ref.read(loadingProvider.notifier).state = true;
    try {
      // Use the authProvider to sign in anonymously
      // The authProvider should handle user creation in UserDataSource
      final userCredential =
          await ref.read(authProvider.notifier).signInAnonymously();

      if (userCredential.user != null) {
        // Ensure statistics are created for the new guest user
        // This is similar to what happens in the createUser path of submit()
        await UserStatisticsDataSource.createUserStatistics(
            userCredential.user!.uid);

        // Set the new user flag, as a guest is a new user session
        ref.read(newUserRegistrationProvider.notifier).setNewUser(true);
        state = state.copyWith(navigate: true, isNewUser: true);
      } else {
        state = state.copyWith(
            firebaseErrorMessage: "Failed to sign in as guest.");
      }
    } on FirebaseAuthException catch (e) {
      state = state.copyWith(
          firebaseErrorMessage: mapFirebaseErrorCodeToMessage(e));
    } catch (e) {
      state = state.copyWith(
          firebaseErrorMessage: "An unexpected error occurred: ${e.toString()}");
    } finally {
      ref.read(loadingProvider.notifier).state = false;
    }
  }
}
