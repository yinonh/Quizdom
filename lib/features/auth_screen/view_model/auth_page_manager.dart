import 'package:email_validator/email_validator.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:flutter/material.dart';

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
      if (state.isLogin) {
        await _auth.signInWithEmailAndPassword(
          email: state.email,
          password: state.password,
        );
      } else {
        await _auth.createUserWithEmailAndPassword(
          email: state.email,
          password: state.password,
        );
      }
      state = state.copyWith(navigate: true);
    } catch (e) {
      state = state.copyWith(firebaseErrorMessage: e.toString());
    } finally {
      state = state.copyWith(isLoading: false);
    }
  }

  void resetNavigate() {
    state = state.copyWith(navigate: false);
  }
}
