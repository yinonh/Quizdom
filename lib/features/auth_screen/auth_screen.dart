import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:top_snackbar_flutter/custom_snack_bar.dart';
import 'package:top_snackbar_flutter/top_snack_bar.dart';

import 'package:trivia/features/auth_screen/view_model/auth_page_manager.dart';
import 'package:trivia/features/auth_screen/widgets/custom_text_feild.dart';
import 'package:trivia/features/avatar_screen/avatar_screen.dart';
import 'package:trivia/utility/app_constant.dart';
import 'package:trivia/utility/color_utility.dart';

class AuthScreen extends ConsumerWidget {
  static const String routeName = "/login";

  const AuthScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authScreenManagerProvider);
    final authNotifier = ref.read(authScreenManagerProvider.notifier);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (authState.navigate) {
        Navigator.pushReplacementNamed(context, AvatarScreen.routeName);
        authNotifier.resetNavigate();
      }
      if (authState.firebaseErrorMessage != null) {
        final message = authState.firebaseErrorMessage!;
        authNotifier.deleteFirebaseMessage();
        showTopSnackBar(
          Overlay.of(context),
          CustomSnackBar.info(
            message: message,
            backgroundColor: AppConstant.onPrimary.toColor(),
            icon: Icon(
              Icons.warning_rounded,
              color: Colors.black.withOpacity(0.2),
              size: 120,
            ),
          ),
          snackBarPosition: SnackBarPosition.bottom,
          padding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 80,
          ),
          displayDuration: const Duration(seconds: 1, milliseconds: 500),
        );
      }
    });

    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Stack(
        children: [
          SvgPicture.asset(
            "assets/blob-scene-haikei.svg",
            fit: BoxFit.cover,
            height: MediaQuery.of(context).size.height,
            width: MediaQuery.of(context).size.width,
          ),
          Positioned(
            left: 30,
            top: 100,
            child: Text(
              !authState.isLogin ? 'Create Account' : 'Welcome Back',
              style: TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.bold,
                color: AppConstant.onPrimary.toColor(),
                shadows: [
                  BoxShadow(
                    color: Colors.white.withOpacity(0.3),
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
                          label: 'Email',
                          keyboardType: TextInputType.emailAddress,
                          prefixIcon: Icons.email,
                          onChanged: authNotifier.setEmail,
                          suffixIcon: authState.email.isNotEmpty &&
                                  EmailValidator.validate(authState.email)
                              ? const Icon(Icons.check_circle,
                                  color: Colors.white)
                              : const SizedBox.shrink(),
                          errorText: authState.emailErrorMessage.isNotEmpty
                              ? authState.emailErrorMessage
                              : null,
                        ),
                        const SizedBox(height: 20),
                        CustomTextField(
                          label: 'Password',
                          prefixIcon: Icons.lock,
                          onChanged: authNotifier.setPassword,
                          suffixIcon: IconButton(
                            icon: Icon(
                              authState.showPassword
                                  ? Icons.visibility
                                  : Icons.visibility_off,
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
                          const SizedBox(height: 20),
                          CustomTextField(
                            label: 'Confirm Password',
                            prefixIcon: Icons.lock,
                            onChanged: authNotifier.setConfirmPassword,
                            suffixIcon: IconButton(
                              icon: Icon(
                                authState.showConfirmPassword
                                    ? Icons.visibility
                                    : Icons.visibility_off,
                                color: Colors.white,
                              ),
                              onPressed: authNotifier.toggleShowConfirmPassword,
                            ),
                            errorText:
                                authState.confirmPasswordErrorMessage.isNotEmpty
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
            bottom: 10,
            child: Column(
              children: [
                if (authState.isLoading)
                  const CircularProgressIndicator()
                else
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 13.0),
                    child: GestureDetector(
                      onTap: authNotifier.submit,
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(30),
                          color: AppConstant.secondaryColor.toColor(),
                          boxShadow: [
                            BoxShadow(
                              color: AppConstant.secondaryColor
                                  .toColor()
                                  .withOpacity(0.5),
                              spreadRadius: 4,
                              blurRadius: 5,
                              offset: const Offset(1, 2),
                            ),
                          ],
                        ),
                        child: Text(
                          authState.isLogin ? 'Login' : 'Sign Up',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                          ),
                        ),
                      ),
                    ),
                  ),
                const SizedBox(height: 10),
                TextButton(
                  onPressed: authNotifier.toggleFormMode,
                  child: Text(
                    authState.isLogin
                        ? "Don't have an account? Sign Up"
                        : "Already have an account? Login",
                    style:
                        TextStyle(color: AppConstant.highlightColor.toColor()),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
