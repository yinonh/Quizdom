import 'package:email_validator/email_validator.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:flutter/material.dart';
import 'package:trivia/service/user_provider.dart';
import 'package:trivia/utility/constant_strings.dart';

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
      emailError = Strings.invalidEmail;
    }
    if (state.password.length < 6) {
      passwordError = Strings.passwordTooShort;
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
        await ref.read(userProvider.notifier).saveUid(userCredential.user?.uid);
        await ref.read(userProvider.notifier).initializeUser();
        ref.read(userProvider.notifier).updateLastLogin();
      } else {
        userCredential = await _auth.createUserWithEmailAndPassword(
          email: state.email,
          password: state.password,
        );

        final user = userCredential.user;
        if (user != null) {
          ref.read(userProvider.notifier).saveUser(
              user.uid, user.email?.split('@')[0] ?? '', user.email ?? '');
        }
      }
      ref.read(userProvider.notifier).updateAutoLogin(true);

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
        return Strings.invalidEmail;
      case 'user-disabled':
        return Strings.userDisabled;
      case 'user-not-found':
        return Strings.userNotFound;
      case 'wrong-password':
        return Strings.wrongPassword;
      case 'email-already-in-use':
        return Strings.emailAlreadyUse;
      case 'operation-not-allowed':
        return Strings.operationNotAllowed;
      case 'weak-password':
        return Strings.passwordTooWeak;
      case 'invalid-credential':
        return Strings.invalidCredential;
      case 'account-exists-with-different-credential':
        return Strings.accountExistsWithDifferentCredential;
      case 'invalid-verification-code':
        return Strings.invalidVerificationCode;
      case 'invalid-verification-id':
        return Strings.invalidVerificationID;
      case 'session-cookie-expired':
        return Strings.sessionCookieExpired;
      case 'session-cookie-revoked':
        return Strings.sessionCookieRevoked;
      case 'too-many-requests':
        return Strings.tooManyRequests;
      case 'missing-email':
        return Strings.missingEmail;
      default:
        return Strings.undefinedError;
    }
  }

  void resetNavigate() {
    state = state.copyWith(navigate: false);
  }
}
