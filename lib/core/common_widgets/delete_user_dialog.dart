import 'package:flutter/material.dart';
import 'package:trivia/core/common_widgets/custom_button.dart';
import 'package:trivia/core/constants/app_constant.dart';
import 'package:trivia/core/extensions/empty_padding_extension.dart';
import 'package:trivia/core/navigation/route_extensions.dart';
import 'package:trivia/core/utils/size_config.dart';
import 'package:trivia/features/auth_screen/auth_screen.dart';

class DeleteUserDialog extends StatefulWidget {
  final Future<void> Function() onConfirmDelete;
  const DeleteUserDialog({super.key, required this.onConfirmDelete});

  @override
  State<DeleteUserDialog> createState() => _DeleteUserDialogState();
}

class _DeleteUserDialogState extends State<DeleteUserDialog> {
  bool _isLoading = false;

  Future<void> _handleConfirmDelete() async {
    setState(() => _isLoading = true);
    try {
      await widget.onConfirmDelete();
      if (!mounted) return;
      pop(); // Close the dialog
      goRoute(AuthScreen.routeName); // Navigate to auth screen
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Account deleted successfully."),
          backgroundColor: AppConstant.successColor,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      pop(); // Close the dialog before showing snackbar or it might not find scaffold
       ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString().contains("requires-recent-login")
              ? "This action requires you to have logged in recently. Please log out, log back in, and try again."
              : "Failed to delete account: ${e.toString()}"),
          backgroundColor: AppConstant.errorColor,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        padding: EdgeInsets.all(calcWidth(20)),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [AppConstant.secondaryColor, AppConstant.primaryColor],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              "Delete Account?",
              style: TextStyle(
                fontSize: calcWidth(22),
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
            ),
            calcHeight(16).ph,
            Text(
              "Are you sure you want to delete your account? This action is irreversible and will delete all your data.",
              style: TextStyle(
                fontSize: calcWidth(16),
                color: Colors.white70,
              ),
              textAlign: TextAlign.center,
            ),
            calcHeight(24).ph,
            if (_isLoading)
              const Center(child: CircularProgressIndicator(color: Colors.white))
            else
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Expanded(
                    child: CustomButton(
                      text: "No",
                      onTap: () {
                        pop(); // Close the dialog
                      },
                      color: AppConstant.errorColor.withOpacity(0.8),
                      textColor: Colors.white,
                    ),
                  ),
                  calcWidth(16).pw,
                  Expanded(
                    child: CustomButton(
                      text: "Yes",
                      onTap: _handleConfirmDelete,
                      color: AppConstant.successColor.withOpacity(0.8),
                      textColor: Colors.white,
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
