import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:Quizdom/core/constants/app_constant.dart';
import 'package:Quizdom/core/constants/app_routes.dart';
import 'package:Quizdom/core/constants/constant_strings.dart';
import 'package:Quizdom/core/navigation/route_extensions.dart';
import 'package:Quizdom/core/utils/size_config.dart';
import 'package:Quizdom/data/providers/user_provider.dart';
import 'package:Quizdom/features/auth_screen/auth_screen.dart';

class GuestLogoutWarningDialog extends ConsumerStatefulWidget {
  static const routeName = AppRoutes.guestLogoutWarning;

  const GuestLogoutWarningDialog({super.key});

  /// Navigate to the Guest Logout Warning Dialog screen
  static void show(BuildContext context) {
    goRoute(routeName);
  }

  @override
  ConsumerState<GuestLogoutWarningDialog> createState() =>
      _GuestLogoutWarningDialogState();
}

class _GuestLogoutWarningDialogState
    extends ConsumerState<GuestLogoutWarningDialog> {
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Container(
        color: Colors.black.withValues(alpha: 0.5),
        child: Center(
          child: GuestLogoutWarningContent(
            isLoading: _isLoading,
            onLogout: _handleLogout,
            onCancel: _handleCancel,
          ),
        ),
      ),
    );
  }

  void _handleCancel() {
    pop();
  }

  Future<void> _handleLogout() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Delete user data first
      await ref.read(authProvider.notifier).deleteUser();

      // Sign out from Firebase and Google
      await FirebaseAuth.instance.signOut();
      await GoogleSignIn().signOut();

      if (mounted) {
        // Navigate to auth screen
        goRoute(AuthScreen.routeName);
      }
    } catch (e) {
      // Handle error if needed
      setState(() {
        _isLoading = false;
      });

      // Show error message or handle appropriately
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error logging out: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}

class GuestLogoutWarningContent extends StatelessWidget {
  const GuestLogoutWarningContent({
    super.key,
    required this.isLoading,
    required this.onLogout,
    required this.onCancel,
  });

  final bool isLoading;
  final VoidCallback onLogout;
  final VoidCallback onCancel;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
      ),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppConstant.primaryColor,
              AppConstant.highlightColor,
            ],
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Warning Icon
            Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  width: calcWidth(80),
                  height: calcWidth(80),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.orange.withValues(alpha: 0.2),
                  ),
                ),
                const Icon(
                  Icons.warning_rounded,
                  color: Colors.orange,
                  size: 50,
                ),
              ],
            ),
            SizedBox(height: calcHeight(20)),

            // Title
            Text(
              Strings.warningTitle,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
            ),
            SizedBox(height: calcHeight(16)),

            // Warning Message
            Text(
              Strings.guestLogoutWarning,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.white,
                    height: 1.4,
                  ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: calcHeight(16)),

            // Info Container
            Container(
              padding: EdgeInsets.all(calcWidth(16)),
              decoration: BoxDecoration(
                color: AppConstant.highlightColor.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: AppConstant.goldColor.withValues(alpha: 0.3),
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.info_outline,
                    color: AppConstant.goldColor,
                    size: 24,
                  ),
                  SizedBox(width: calcWidth(12)),
                  Expanded(
                    child: Text(
                      Strings.saveProgressTip,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: calcHeight(24)),

            // Buttons
            Row(
              children: [
                // Cancel Button
                Expanded(
                  child: ElevatedButton(
                    onPressed: isLoading ? null : onCancel,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey[600],
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(
                        vertical: calcHeight(12),
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    child: const Text(
                      Strings.cancel, // "Cancel"
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                SizedBox(width: calcWidth(12)),

                // Logout Button
                Expanded(
                  child: ElevatedButton(
                    onPressed: isLoading ? null : onLogout,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red[600],
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(
                        vertical: calcHeight(12),
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    child: isLoading
                        ? SizedBox(
                            width: calcWidth(20),
                            height: calcHeight(20),
                            child: const CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : const Text(
                            Strings.logoutAnyway,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
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
