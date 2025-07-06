import 'package:Quizdom/core/constants/constant_strings.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pinput/pinput.dart';
import 'package:Quizdom/core/common_widgets/base_screen.dart';
import 'package:Quizdom/core/common_widgets/custom_button.dart';
import 'package:Quizdom/core/constants/app_constant.dart';
import 'package:Quizdom/core/utils/size_config.dart';
import 'package:Quizdom/data/providers/pin_verification_provider.dart';

class PinVerificationScreen extends ConsumerStatefulWidget {
  final String email;
  final String userName;
  final VoidCallback onVerified;

  const PinVerificationScreen({
    super.key,
    required this.email,
    required this.userName,
    required this.onVerified,
  });

  @override
  ConsumerState<PinVerificationScreen> createState() =>
      _PinVerificationScreenState();
}

class _PinVerificationScreenState extends ConsumerState<PinVerificationScreen> {
  final TextEditingController _pinController = TextEditingController();
  final FocusNode _pinFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    // Send PIN when screen initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(pinVerificationNotifierProvider.notifier).sendPin(
            email: widget.email,
            userName: widget.userName,
          );
    });
  }

  @override
  void dispose() {
    _pinController.dispose();
    _pinFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final pinState = ref.watch(pinVerificationNotifierProvider);
    final pinNotifier = ref.read(pinVerificationNotifierProvider.notifier);

    ref.listen(pinVerificationNotifierProvider, (previous, next) {
      if (next.isVerified) {
        widget.onVerified();
      }
    });

    return BaseScreen(
      child: Scaffold(
        backgroundColor: AppConstant.primaryColor,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          iconTheme: const IconThemeData(color: Colors.white),
          title: const Text(
            Strings.emailVerification,
            style: TextStyle(color: Colors.white),
          ),
        ),
        body: Container(
          height: double.infinity,
          width: double.infinity,
          margin: EdgeInsets.only(top: calcHeight(20)),
          padding: const EdgeInsets.all(20),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(35.0),
              topRight: Radius.circular(35.0),
            ),
          ),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(height: calcHeight(40)),

                // Email icon
                Container(
                  width: calcWidth(100),
                  height: calcWidth(100),
                  decoration: BoxDecoration(
                    color: AppConstant.secondaryColor.withValues(alpha: 0.3),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.email_outlined,
                    size: 50,
                    color: AppConstant.primaryColor,
                  ),
                ),

                SizedBox(height: calcHeight(30)),

                // Title
                const Text(
                  Strings.verifyYourEmail,
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: AppConstant.primaryColor,
                  ),
                ),

                SizedBox(height: calcHeight(15)),

                // Description
                Text(
                  '${Strings.weSentPITo}\n${widget.email}',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[600],
                  ),
                ),

                SizedBox(height: calcHeight(40)),

                // PIN Input
                if (pinState.isPinSent) ...[
                  Pinput(
                    controller: _pinController,
                    focusNode: _pinFocusNode,
                    length: 6,
                    enabled: !pinState.isLoading,
                    onCompleted: (pin) {
                      pinNotifier.verifyPin(pin);
                    },
                    defaultPinTheme: PinTheme(
                      width: calcWidth(50),
                      height: calcHeight(50),
                      textStyle: const TextStyle(
                        fontSize: 20,
                        color: AppConstant.onPrimaryColor,
                        fontWeight: FontWeight.w600,
                      ),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey[300]!),
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    focusedPinTheme: PinTheme(
                      width: calcWidth(50),
                      height: calcHeight(50),
                      textStyle: const TextStyle(
                        fontSize: 20,
                        color: AppConstant.onPrimaryColor,
                        fontWeight: FontWeight.w600,
                      ),
                      decoration: BoxDecoration(
                        border: Border.all(color: AppConstant.onPrimaryColor),
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    submittedPinTheme: PinTheme(
                      width: calcWidth(50),
                      height: calcHeight(50),
                      textStyle: const TextStyle(
                        fontSize: 20,
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                      decoration: BoxDecoration(
                        color: AppConstant.onPrimaryColor,
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),

                  SizedBox(height: calcHeight(20)),

                  // Error message
                  if (pinState.errorMessage != null) ...[
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.red[50],
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.red[200]!),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.error_outline, color: Colors.red[600]),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              pinState.errorMessage!,
                              style: TextStyle(color: Colors.red[600]),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: calcHeight(20)),
                  ],

                  // Remaining attempts
                  if (pinState.remainingAttempts > 0) ...[
                    Text(
                      '${Strings.remainingAttempts} ${pinState.remainingAttempts}',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 14,
                      ),
                    ),
                    SizedBox(height: calcHeight(20)),
                  ],

                  // Verify button
                  CustomButton(
                    text: pinState.isLoading
                        ? Strings.verifying
                        : Strings.verifyPIN,
                    onTap: pinState.isLoading || pinState.remainingAttempts < 1
                        ? null
                        : () {
                            if (_pinController.text.length == 6) {
                              pinNotifier.verifyPin(_pinController.text);
                            }
                          },
                    color: AppConstant.primaryColor,
                    padding: EdgeInsets.symmetric(vertical: calcHeight(15)),
                  ),

                  SizedBox(height: calcHeight(20)),

                  // Resend button
                  TextButton(
                    onPressed: pinState.isLoading
                        ? null
                        : () {
                            _pinController.clear();
                            pinNotifier.resendPin();
                          },
                    child: const Text(
                      Strings.resendPIN,
                      style: TextStyle(
                        color: AppConstant.highlightColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ] else ...[
                  // Loading state while sending PIN
                  const CircularProgressIndicator(),
                  SizedBox(height: calcHeight(20)),
                  const Text(Strings.sendingPINToYourEmail),
                ],

                SizedBox(height: calcHeight(40)),

                // Help text
                Text(
                  Strings.didntReceiveCheckSpam,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.grey[500],
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
