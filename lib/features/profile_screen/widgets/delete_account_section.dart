import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trivia/core/common_widgets/custom_button.dart';
import 'package:trivia/core/common_widgets/delete_user_dialog.dart';
import 'package:trivia/core/constants/constant_strings.dart';
import 'package:trivia/core/utils/size_config.dart';
import 'package:trivia/data/providers/user_provider.dart';

class DeleteAccountSection extends ConsumerWidget {
  const DeleteAccountSection({super.key});

  void _showDeleteUserDialog(BuildContext context, WidgetRef ref) {
    final authNotifier = ref.read(authProvider.notifier);
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return DeleteUserDialog(
          isGoogleUser: authNotifier.isGoogleSignIn(),
          onConfirmDelete: () async {
            await authNotifier.deleteUser();
          },
          onReauthenticateAndDelete: (String password) async {
            await authNotifier.reauthenticateUserWithPassword(password);
            await authNotifier.deleteUser(isRetryAfterReauthentication: true);
          },
          onReauthenticateWithGoogleAndDelete: () async {
            await authNotifier.reauthenticateUserWithGoogle();
            await authNotifier.deleteUser(isRetryAfterReauthentication: true);
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: calcWidth(10)),
      decoration: const BoxDecoration(
        color: Colors.white,
      ),
      child:
          // Add the delete button here
          Padding(
        padding: EdgeInsets.all(calcWidth(16)),
        child: CustomButton(
          text: Strings.deleteAccount,
          onTap: () => _showDeleteUserDialog(context, ref),
          color: Colors.red,
          leadingIcon: Icons.delete_forever_rounded,
        ),
      ),
    );
  }
}
