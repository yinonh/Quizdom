import 'package:email_validator/email_validator.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:flutter/material.dart';
import 'package:trivia/core/utils/map_firebase_errors_to_message.dart';
import 'package:trivia/data/service/user_provider.dart';
import 'package:trivia/core/constants/constant_strings.dart';

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
  final GoogleSignIn _googleSignIn = GoogleSignIn();

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
      state = state.copyWith(navigate: true);
    } on FirebaseAuthException catch (e) {
      state = state.copyWith(
          firebaseErrorMessage: mapFirebaseErrorCodeToMessage(e));
    } finally {
      state = state.copyWith(isLoading: false);
    }
  }

  void resetNavigate() {
    state = state.copyWith(navigate: false);
  }

  Future<void> signInWithGoogle() async {
    try {
      // Trigger the authentication flow
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      // Obtain the auth details from the request
      final GoogleSignInAuthentication googleAuth =
          await googleUser!.authentication;

      // Create a new credential
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // This token can be used to sign in the user
      UserCredential userCredential =
          await _auth.signInWithCredential(credential);

      // Here you can save user info to your database
      final user = userCredential.user;
      if (user != null) {
        ref.read(userProvider.notifier).saveUser(
              user.uid,
              user.email?.split('@')[0] ?? '',
              user.email ?? '',
            );
      }
      state = state.copyWith(navigate: true);
    } on FirebaseAuthException catch (e) {
      state = state.copyWith(
          firebaseErrorMessage: mapFirebaseErrorCodeToMessage(e));
    }
  }
}
