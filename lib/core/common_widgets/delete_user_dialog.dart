import 'package:flutter/material.dart';
import 'package:top_snackbar_flutter/custom_snack_bar.dart';
import 'package:top_snackbar_flutter/top_snack_bar.dart';
import 'package:trivia/core/common_widgets/custom_button.dart';
import 'package:trivia/core/constants/app_constant.dart';
import 'package:trivia/core/constants/constant_strings.dart';
import 'package:trivia/core/navigation/route_extensions.dart';
import 'package:trivia/core/utils/size_config.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:trivia/features/auth_screen/auth_screen.dart';
import 'package:trivia/features/auth_screen/widgets/custom_text_feild.dart';

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
  bool _showPassword = false;
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
      _showPassword = false;
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
      showTopSnackBar(
        Overlay.of(context),
        CustomSnackBar.info(
          message: Strings.accountDeletedSuccessfully,
          backgroundColor: AppConstant.secondaryColor,
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
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;
      if (e.code == 'requires-recent-login') {
        setState(() {
          _requiresRecentLogin = true;
          _errorMessage = Strings.needToReAuthenticate;
          _isLoading = false;
        });
      } else if (e.code == 'wrong-password' || e.code == 'invalid-credential') {
        setState(() {
          _errorMessage = Strings.incorrectPassword;
          _isLoading = false;
        });
      } else {
        pop();
        showTopSnackBar(
          Overlay.of(context),
          CustomSnackBar.info(
            message: "${Strings.error}: ${e.message ?? e.code}",
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
        _resetState(); // Ensure state is reset
      }
    } catch (e) {
      if (!mounted) return;
      pop(); // Close dialog for other errors
      showTopSnackBar(
        Overlay.of(context),
        CustomSnackBar.info(
          message: "${Strings.error}: ${e.toString()}",
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
      _resetState(); // Ensure state is reset
    } finally {
      if (mounted && _requiresRecentLogin == false) {
        // Only stop loading if not waiting for re-auth
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: !_isLoading,
      onPopInvokedWithResult: (_, __) {
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
                  _requiresRecentLogin
                      ? Strings.reAuthenticateToDelete
                      : Strings.deleteAccountQ,
                  style: TextStyle(
                    fontSize: calcWidth(20),
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(
                  height: calcHeight(12),
                ),
                if (_errorMessage != null) ...[
                  Text(
                    _errorMessage!,
                    style: TextStyle(
                        color: AppConstant.red,
                        fontSize: calcWidth(14),
                        shadows: [
                          Shadow(
                              color: Colors.black.withValues(alpha: 0.5),
                              offset: const Offset(0.5, 0.1),
                              blurRadius: 5)
                        ]),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(
                    height: calcHeight(10),
                  ),
                ],
                if (!_requiresRecentLogin)
                  Text(
                    Strings.sureDeleteAccountQ,
                    style: TextStyle(
                      fontSize: calcWidth(15),
                      color: Colors.white70,
                    ),
                    textAlign: TextAlign.center,
                  ),
                if (_requiresRecentLogin && !widget.isGoogleUser) ...[
                  CustomTextField(
                    label: Strings.password,
                    prefixIcon: Icons.lock_rounded,
                    suffixIcon: IconButton(
                      icon: Icon(
                        _showPassword
                            ? Icons.visibility_rounded
                            : Icons.visibility_off_rounded,
                        color: Colors.white,
                      ),
                      onPressed: () {
                        setState(() {
                          _showPassword = !_showPassword;
                        });
                      },
                    ),
                    controller: _passwordController,
                    focusNode: _passwordFocusNode,
                    obscureText: !_showPassword,
                  ),
                ],
                SizedBox(
                  height: calcHeight(20),
                ),
                if (_isLoading)
                  const Center(
                      child: CircularProgressIndicator(color: Colors.white))
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
              text: Strings.reAuthenticateWithGoogle,
              onTap: () =>
                  _processDeletion(widget.onReauthenticateWithGoogleAndDelete),
              color: AppConstant.primaryColor, // Or a Google-like color
            ),
            SizedBox(
              height: calcHeight(10),
            ),
            CustomButton(
              text: Strings.cancel,
              onTap: () {
                _resetState();
                pop();
              },
              color: AppConstant.highlightColor.withValues(alpha: 0.7),
            ),
          ],
        );
      } else {
        // Password re-authentication
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CustomButton(
              text: Strings.confirmDelete,
              onTap: () {
                if (_formKey.currentState!.validate()) {
                  _processDeletion(() => widget.onReauthenticateAndDelete(
                      _passwordController.text.trim()));
                }
              },
            ),
            SizedBox(
              height: calcHeight(10),
            ),
            CustomButton(
              text: Strings.cancel,
              onTap: () {
                _resetState();
                pop();
              },
              color: AppConstant.highlightColor.withValues(alpha: 0.7),
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
              text: Strings.no,
              onTap: () {
                _resetState();
                pop();
              },
              color: AppConstant.highlightColor.withValues(alpha: 0.8),
              textStyle: const TextStyle(
                color: Colors.white,
              ),
            ),
          ),
          SizedBox(
            width: calcWidth(16),
          ),
          Expanded(
            child: CustomButton(
              text: Strings.yesDelete,
              onTap: () => _processDeletion(widget.onConfirmDelete),
              textStyle: const TextStyle(
                color: Colors.white,
              ),
            ),
          ),
        ],
      );
    }
  }
}
