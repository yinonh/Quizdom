import 'package:email_validator/email_validator.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:flutter/material.dart';
import 'package:trivia/service/user_provider.dart';

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
    required bool isLoading,
    required bool navigate,
    required GlobalKey formKey,
  }) = _AuthState;
}

@riverpod
class AuthScreenManager extends _$AuthScreenManager {
  final FirebaseAuth _auth = FirebaseAuth.instance;

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
      isLoading: false,
      navigate: false,
      formKey: GlobalKey<FormState>(),
    );
  }

  void toggleFormMode() {
    state = state.copyWith(
      isLogin: !state.isLogin,
      showPassword: false,
      showConfirmPassword: false,
      email: '',
      password: '',
      confirmPassword: '',
      emailErrorMessage: '',
      passwordErrorMessage: '',
      confirmPasswordErrorMessage: '',
      firebaseErrorMessage: null,
      isLoading: false,
      navigate: false,
      formKey: GlobalKey<FormState>(),
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

  Future<void> submit() async {
    String emailError = '';
    String passwordError = '';
    String confirmPasswordError = '';

    if (!EmailValidator.validate(state.email)) {
      emailError = 'Invalid email';
    }
    if (state.password.length < 6) {
      passwordError = 'Password must be at least 6 characters long';
    }
    if (!state.isLogin && state.password != state.confirmPassword) {
      confirmPasswordError = 'Passwords do not match';
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

    state = state.copyWith(
      isLoading: true,
      emailErrorMessage: '',
      passwordErrorMessage: '',
      confirmPasswordErrorMessage: '',
    );

    try {
      UserCredential userCredential;
      if (state.isLogin) {
        userCredential = await _auth.signInWithEmailAndPassword(
          email: state.email,
          password: state.password,
        );
      } else {
        userCredential = await _auth.createUserWithEmailAndPassword(
          email: state.email,
          password: state.password,
        );
      }

      final user = userCredential.user;
      if (user != null) {
        ref.read(userProvider.notifier).saveUser(
            user.uid, user.email?.split('@')[0] ?? '', user.email ?? '');
      }

      state = state.copyWith(navigate: true);
    } on FirebaseAuthException catch (e) {
      state = state.copyWith(
          firebaseErrorMessage: _mapFirebaseErrorCodeToMessage(e));
    } finally {
      state = state.copyWith(isLoading: false);
    }
  }

  String _mapFirebaseErrorCodeToMessage(FirebaseAuthException e) {
    switch (e.code) {
      case 'invalid-email':
        return 'The email address is not valid.';
      case 'user-disabled':
        return 'The user corresponding to the given email has been disabled.';
      case 'user-not-found':
        return 'There is no user corresponding to the given email.';
      case 'wrong-password':
        return 'The password is invalid for the given email.';
      case 'email-already-in-use':
        return 'The email address is already in use by another account.';
      case 'operation-not-allowed':
        return 'Email/Password accounts are not enabled.';
      case 'weak-password':
        return 'The password is too weak.';
      case 'invalid-credential':
        return 'The credential is not valid.';
      case 'account-exists-with-different-credential':
        return 'Account exists with different credentials.';
      case 'invalid-verification-code':
        return 'Invalid verification code.';
      case 'invalid-verification-id':
        return 'Invalid verification ID.';
      case 'session-cookie-expired':
        return 'The session cookie has expired.';
      case 'session-cookie-revoked':
        return 'The session cookie has been revoked.';
      case 'too-many-requests':
        return 'Too many requests. Please try again later.';
      case 'missing-email':
        return 'An email address must be provided.';
      default:
        return 'An undefined error occurred.';
    }
  }

  void resetNavigate() {
    state = state.copyWith(navigate: false);
  }
}
