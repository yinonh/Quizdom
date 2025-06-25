import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:top_snackbar_flutter/custom_snack_bar.dart';
import 'package:top_snackbar_flutter/top_snack_bar.dart';
import 'package:trivia/core/common_widgets/base_screen.dart';
import 'package:trivia/core/constants/app_constant.dart';
import 'package:trivia/core/constants/app_routes.dart';
import 'package:trivia/core/constants/constant_strings.dart';
import 'package:trivia/core/utils/size_config.dart';
import 'package:trivia/features/auth_screen/view_model/auth_page_manager.dart';
import 'package:trivia/features/auth_screen/widgets/custom_text_feild.dart';

class AuthScreen extends ConsumerWidget {
  static const String routeName = AppRoutes.authRouteName;

  const AuthScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authScreenManagerProvider);
    final authNotifier = ref.read(authScreenManagerProvider.notifier);

    ref.listen<AuthState>(
      authScreenManagerProvider,
      (previous, next) {
        if (next.navigate && next.isNewUser) {
          // The router will handle the navigation automatically
          // Just reset the navigate flag
          authNotifier.resetNavigate();
        } else if (next.navigate) {
          // The router will handle the navigation automatically
          // Just reset the navigate flag
          authNotifier.resetNavigate();
        }
        if (next.firebaseErrorMessage != null) {
          final message = next.firebaseErrorMessage!;
          authNotifier.deleteFirebaseMessage();
          showTopSnackBar(
            Overlay.of(context),
            CustomSnackBar.info(
              message: message,
              backgroundColor: AppConstant.onPrimaryColor,
              icon: Icon(
                Icons.warning_rounded,
                color: Colors.black.withValues(alpha: 0.2),
                size: 120,
              ),
            ),
            snackBarPosition: SnackBarPosition.bottom,
            padding: EdgeInsets.symmetric(
              horizontal: calcWidth(20),
              vertical: calcHeight(80),
            ),
            displayDuration: const Duration(seconds: 1, milliseconds: 500),
          );
        }
      },
    );

    return BaseScreen(
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        body: Stack(
          children: [
            SvgPicture.asset(
              Strings.authBackground,
              fit: BoxFit.cover,
              height: double.infinity,
              width: double.infinity,
            ),
            Positioned(
              left: calcWidth(30),
              top: calcHeight(100),
              child: Text(
                !authState.isLogin
                    ? Strings.createAccount
                    : Strings.welcomeBack,
                style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                  color: AppConstant.onPrimaryColor,
                  shadows: [
                    BoxShadow(
                      color: Colors.white.withValues(alpha: 0.3),
                      spreadRadius: 4,
                      blurRadius: 5,
                      offset: const Offset(1, 2),
                    ),
                  ],
                ),
              ),
            ),
            Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    Form(
                      key: authState.formKey,
                      child: Column(
                        children: [
                          CustomTextField(
                            label: Strings.email,
                            keyboardType: TextInputType.emailAddress,
                            prefixIcon: Icons.email_rounded,
                            onChanged: authNotifier.setEmail,
                            suffixIcon: authState.email.isNotEmpty &&
                                    EmailValidator.validate(authState.email)
                                ? const Icon(Icons.check_circle_rounded,
                                    color: Colors.white)
                                : const SizedBox.shrink(),
                            errorText: authState.emailErrorMessage.isNotEmpty
                                ? authState.emailErrorMessage
                                : null,
                          ),
                          SizedBox(
                            height: calcHeight(20),
                          ),
                          CustomTextField(
                            label: Strings.password,
                            prefixIcon: Icons.lock_rounded,
                            onChanged: authNotifier.setPassword,
                            suffixIcon: IconButton(
                              icon: Icon(
                                authState.showPassword
                                    ? Icons.visibility_rounded
                                    : Icons.visibility_off_rounded,
                                color: Colors.white,
                              ),
                              onPressed: authNotifier.toggleShowPassword,
                            ),
                            errorText: authState.passwordErrorMessage.isNotEmpty
                                ? authState.passwordErrorMessage
                                : null,
                            obscureText: !authState.showPassword,
                          ),
                          if (!authState.isLogin) ...[
                            SizedBox(
                              height: calcHeight(20),
                            ),
                            CustomTextField(
                              label: Strings.confirmPassword,
                              prefixIcon: Icons.lock_rounded,
                              onChanged: authNotifier.setConfirmPassword,
                              suffixIcon: IconButton(
                                icon: Icon(
                                  authState.showConfirmPassword
                                      ? Icons.visibility_rounded
                                      : Icons.visibility_off_rounded,
                                  color: Colors.white,
                                ),
                                onPressed:
                                    authNotifier.toggleShowConfirmPassword,
                              ),
                              errorText: authState
                                      .confirmPasswordErrorMessage.isNotEmpty
                                  ? authState.confirmPasswordErrorMessage
                                  : null,
                              obscureText: !authState.showConfirmPassword,
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Positioned(
              left: 0,
              right: 0,
              bottom: calcHeight(10),
              child: Column(
                children: [
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: calcWidth(13)),
                    child: GestureDetector(
                      onTap: authNotifier.submit,
                      child: Container(
                        padding: EdgeInsets.symmetric(vertical: calcHeight(13)),
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(30),
                          color: AppConstant.secondaryColor,
                          boxShadow: [
                            BoxShadow(
                              color: AppConstant.secondaryColor
                                  .withValues(alpha: 0.5),
                              spreadRadius: 4,
                              blurRadius: 5,
                              offset: const Offset(1, 2),
                            ),
                          ],
                        ),
                        child: Text(
                          authState.isLogin ? Strings.login : Strings.signUp,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: calcHeight(10)),
                  TextButton(
                    onPressed: authNotifier.toggleFormMode,
                    child: Text(
                      authState.isLogin
                          ? Strings.switchToSignUp
                          : Strings.switchToLogin,
                      style: const TextStyle(color: AppConstant.highlightColor),
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      TextButton(
                        onPressed: authNotifier.signInWithGoogle,
                        child: const Text(
                          Strings.continueWithGoogle,
                          style: TextStyle(color: AppConstant.highlightColor),
                        ),
                      ),
                      TextButton(
                        onPressed: authNotifier.signInAsGuest,
                        child: const Text(
                          Strings.playAsGuest, // Used constant string
                          style: TextStyle(color: AppConstant.highlightColor),
                        ),
                      ),
                    ],
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
