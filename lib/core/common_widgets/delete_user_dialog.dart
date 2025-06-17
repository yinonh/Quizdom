import 'package:flutter/material.dart';
import 'package:trivia/core/common_widgets/custom_button.dart';
import 'package:trivia/core/constants/app_constant.dart';
import 'package:trivia/core/extensions/empty_padding_extension.dart';
import 'package:trivia/core/navigation/route_extensions.dart';
import 'package:trivia/core/utils/size_config.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:trivia/core/common_widgets/custom_button.dart';
import 'package:trivia/core/common_widgets/custom_text_field.dart';
import 'package:trivia/core/constants/app_constant.dart';
import 'package:trivia/core/extensions/empty_padding_extension.dart';
import 'package:trivia/core/navigation/route_extensions.dart';
import 'package:trivia/core/utils/size_config.dart';
import 'package:trivia/features/auth_screen/auth_screen.dart';

class DeleteUserDialog extends StatefulWidget {
  final Future<void> Function() onConfirmDelete;
  final Future<void> Function(String password) onReauthenticateAndDelete;
  final Future<void> Function() onReauthenticateWithGoogleAndDelete;
  final bool isGoogleUser;

  const DeleteUserDialog({
    super.key,
    required this.onConfirmDelete,
    required this.onReauthenticateAndDelete,
    required this.onReauthenticateWithGoogleAndDelete,
    required this.isGoogleUser,
  });

  @override
  State<DeleteUserDialog> createState() => _DeleteUserDialogState();
}

class _DeleteUserDialogState extends State<DeleteUserDialog> {
  bool _isLoading = false;
  bool _requiresRecentLogin = false;
  String? _errorMessage;

  final _passwordController = TextEditingController();
  final _passwordFocusNode = FocusNode();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _passwordController.dispose();
    _passwordFocusNode.dispose();
    super.dispose();
  }

  void _resetState() {
    setState(() {
      _isLoading = false;
      _requiresRecentLogin = false;
      _errorMessage = null;
      _passwordController.clear();
    });
  }

  Future<void> _processDeletion(Future<void> Function() action) async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      await action();
      if (!mounted) return;
      pop(); // Close the dialog
      goRoute(AuthScreen.routeName);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Account deleted successfully."),
          backgroundColor: AppConstant.successColor,
        ),
      );
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;
      if (e.code == 'requires-recent-login') {
        setState(() {
          _requiresRecentLogin = true;
          _errorMessage =
              "This action requires recent authentication. Please provide your credentials below.";
          _isLoading = false;
        });
      } else if (e.code == 'wrong-password' || e.code == 'invalid-credential') {
         setState(() {
          _errorMessage = "Incorrect password. Please try again.";
          _isLoading = false;
        });
      } else {
        pop(); // Close dialog for other errors
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Error: ${e.message ?? e.code}"),
            backgroundColor: AppConstant.errorColor,
          ),
        );
         _resetState(); // Ensure state is reset
      }
    } catch (e) {
      if (!mounted) return;
      pop(); // Close dialog for other errors
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("An unexpected error occurred: ${e.toString()}"),
          backgroundColor: AppConstant.errorColor,
        ),
      );
      _resetState(); // Ensure state is reset
    } finally {
      if (mounted && _requiresRecentLogin == false) { // Only stop loading if not waiting for re-auth
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: !_isLoading,
      onPopInvoked: (_) {
        if (_isLoading) return;
        _resetState();
      },
      child: Dialog(
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
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  _requiresRecentLogin ? "Re-authenticate to Delete" : "Delete Account?",
                  style: TextStyle(
                    fontSize: calcWidth(20),
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                ),
                calcHeight(12).ph,
                if (_errorMessage != null) ...[
                  Text(
                    _errorMessage!,
                    style: TextStyle(color: AppConstant.errorColor, fontSize: calcWidth(14)),
                    textAlign: TextAlign.center,
                  ),
                  calcHeight(10).ph,
                ],
                if (!_requiresRecentLogin)
                  Text(
                    "Are you sure you want to delete your account? This action is irreversible and will delete all your data.",
                    style: TextStyle(
                      fontSize: calcWidth(15),
                      color: Colors.white70,
                    ),
                    textAlign: TextAlign.center,
                  ),
                if (_requiresRecentLogin && !widget.isGoogleUser) ...[
                  CustomTextField(
                    label: "Password",
                    controller: _passwordController,
                    focusNode: _passwordFocusNode,
                    isPassword: true,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return "Password is required";
                      }
                      return null;
                    },
                  ),
                ],
                calcHeight(20).ph,
                if (_isLoading)
                  const Center(child: CircularProgressIndicator(color: Colors.white))
                else
                  _buildActionButtons(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    if (_requiresRecentLogin) {
      if (widget.isGoogleUser) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CustomButton(
              text: "Re-authenticate with Google",
              onTap: () => _processDeletion(widget.onReauthenticateWithGoogleAndDelete),
              color: AppConstant.primaryColor, // Or a Google-like color
            ),
            calcHeight(10).ph,
            CustomButton(
              text: "Cancel",
              onTap: () {
                _resetState();
                pop();
              },
              color: AppConstant.errorColor.withOpacity(0.7),
            ),
          ],
        );
      } else {
        // Password re-authentication
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CustomButton(
              text: "Confirm Delete",
              onTap: () {
                if (_formKey.currentState!.validate()) {
                  _processDeletion(() => widget.onReauthenticateAndDelete(_passwordController.text.trim()));
                }
              },
            ),
            calcHeight(10).ph,
            CustomButton(
              text: "Cancel",
              onTap: () {
                _resetState();
                pop();
              },
              color: AppConstant.errorColor.withOpacity(0.7),
            ),
          ],
        );
      }
    } else {
      // Initial confirmation
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Expanded(
            child: CustomButton(
              text: "No",
              onTap: () {
                _resetState();
                pop();
              },
              color: AppConstant.errorColor.withOpacity(0.8),
              textColor: Colors.white,
            ),
          ),
          calcWidth(16).pw,
          Expanded(
            child: CustomButton(
              text: "Yes, Delete",
              onTap: () => _processDeletion(widget.onConfirmDelete),
              color: AppConstant.successColor.withOpacity(0.8),
              textColor: Colors.white,
            ),
          ),
        ],
      );
    }
  }
}
