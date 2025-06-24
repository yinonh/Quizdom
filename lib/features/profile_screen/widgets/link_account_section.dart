import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:top_snackbar_flutter/custom_snack_bar.dart';
import 'package:top_snackbar_flutter/top_snack_bar.dart';
import 'package:trivia/core/constants/app_constant.dart';
import 'package:trivia/core/constants/constant_strings.dart';
import 'package:trivia/core/extensions/empty_padding_extension.dart';
import 'package:trivia/core/utils/size_config.dart';
import 'package:trivia/features/auth_screen/widgets/custom_text_feild.dart'; // Reusing the text field
import 'package:trivia/features/profile_screen/view_modle/profile_screen_manager.dart';

class LinkAccountSection extends ConsumerWidget {
  const LinkAccountSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileManager = ref.watch(profileScreenManagerProvider);
    final profileNotifier = ref.read(profileScreenManagerProvider.notifier);

    ref.listen<ProfileState>(
      profileScreenManagerProvider,
      (previous, next) {
        if (next.firebaseErrorMessage != null) {
          final message = next.firebaseErrorMessage!;
          profileNotifier.deleteFirebaseMessage(); // Clear the message after showing
          showTopSnackBar(
            Overlay.of(context),
            CustomSnackBar.error(
              message: message,
            ),
          );
        }
      },
    );

    // Only show this section if the user is anonymous
    if (!(profileManager.currentUser?.isAnonymous ?? false)) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: calcWidth(20), vertical: calcHeight(10)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            Strings.saveYourProgress, // Used constant
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: calcWidth(20),
              fontWeight: FontWeight.bold,
              color: AppConstant.infoColor,
            ),
          ),
          calcHeight(10).ph,
          Text(
            Strings.createAccountToSaveStats, // Used constant
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: calcWidth(14),
              color: AppConstant.onPrimaryColor.withOpacity(0.8),
            ),
          ),
          calcHeight(20).ph,
          CustomTextField(
            label: Strings.email,
            prefixIcon: Icons.email_rounded,
            controller: profileManager.linkEmailController,
            errorText: profileManager.linkEmailErrorMessage.isNotEmpty
                ? profileManager.linkEmailErrorMessage
                : null,
            keyboardType: TextInputType.emailAddress,
          ),
          calcHeight(15).ph,
          CustomTextField(
            label: Strings.password,
            prefixIcon: Icons.lock_rounded,
            controller: profileManager.linkPasswordController,
            obscureText: !profileManager.showPassword,
            errorText: profileManager.linkPasswordErrorMessage.isNotEmpty
                ? profileManager.linkPasswordErrorMessage
                : null,
            suffixIcon: IconButton(
              icon: Icon(
                profileManager.showPassword
                    ? Icons.visibility_rounded
                    : Icons.visibility_off_rounded,
                color: Colors.white,
              ),
              onPressed: profileNotifier.toggleShowPassword,
            ),
          ),
          calcHeight(15).ph,
          CustomTextField(
            label: Strings.confirmPassword,
            prefixIcon: Icons.lock_rounded,
            controller: profileManager.linkConfirmPasswordController,
            obscureText: !profileManager.showConfirmPassword,
            errorText: profileManager.linkConfirmPasswordErrorMessage.isNotEmpty
                ? profileManager.linkConfirmPasswordErrorMessage
                : null,
            suffixIcon: IconButton(
              icon: Icon(
                profileManager.showConfirmPassword
                    ? Icons.visibility_rounded
                    : Icons.visibility_off_rounded,
                color: Colors.white,
              ),
              onPressed: profileNotifier.toggleShowConfirmPassword,
            ),
          ),
          calcHeight(25).ph,
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppConstant.secondaryColor,
              padding: EdgeInsets.symmetric(vertical: calcHeight(12)),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
            ),
            onPressed: profileNotifier.linkAccount,
            child: Text(
              Strings.saveAccount, // Used constant
              style: TextStyle(fontSize: calcWidth(16), color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}
