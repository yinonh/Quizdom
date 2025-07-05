import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:Quizdom/core/network/server.dart';
import 'package:Quizdom/data/data_source/email_service_data_source.dart';
import 'package:Quizdom/data/data_source/pin_verification_data_source.dart';

part 'pin_verification_provider.g.dart';
part 'pin_verification_provider.freezed.dart';

@freezed
class PinVerificationState with _$PinVerificationState {
  const factory PinVerificationState({
    @Default('') String email,
    @Default('') String pin,
    @Default(false) bool isLoading,
    @Default(false) bool isPinSent,
    @Default(false) bool isVerified,
    String? errorMessage,
    @Default(3) int remainingAttempts,
  }) = _PinVerificationState;
}

@riverpod
class PinVerificationNotifier extends _$PinVerificationNotifier {
  @override
  PinVerificationState build() {
    return const PinVerificationState();
  }

  /// Sends PIN to email
  Future<bool> sendPin({
    required String email,
    required String userName,
  }) async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      // Check if can resend
      final canResend = await PinVerificationDataSource.canResendPin(email);
      if (!canResend) {
        state = state.copyWith(
          isLoading: false,
          errorMessage: 'Please wait before requesting another PIN',
        );
        return false;
      }

      // Generate PIN
      final pin = EmailServiceDataSource.generatePin();

      // Send email (try EmailJS first, fallback to Resend)
      bool emailSent = await EmailServiceDataSource.sendPinViaEmailJS(
        email: email,
        pin: pin,
        userName: userName,
      );

      if (emailSent) {
        // Save PIN to Firestore
        await PinVerificationDataSource.savePinVerification(
          email: email,
          plainPin: pin,
        );

        state = state.copyWith(
          email: email,
          isLoading: false,
          isPinSent: true,
          remainingAttempts: 3,
        );

        logger.i('PIN sent successfully to $email');
        return true;
      } else {
        state = state.copyWith(
          isLoading: false,
          errorMessage: 'Failed to send PIN. Please try again.',
        );
        return false;
      }
    } catch (e) {
      logger.e('Error sending PIN: $e');
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'An error occurred. Please try again.',
      );
      return false;
    }
  }

  /// Verifies entered PIN
  Future<bool> verifyPin(String enteredPin) async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      final isValid = await PinVerificationDataSource.verifyPin(
        email: state.email,
        enteredPin: enteredPin,
      );

      if (isValid) {
        state = state.copyWith(
          isLoading: false,
          isVerified: true,
          pin: enteredPin,
        );

        // Clean up PIN verification record
        await PinVerificationDataSource.cleanupPinVerification(state.email);

        logger.i('PIN verified successfully for ${state.email}');
        return true;
      } else {
        final newAttempts = state.remainingAttempts - 1;

        if (newAttempts <= 0) {
          state = state.copyWith(
            isLoading: false,
            errorMessage: 'Too many failed attempts. Please request a new PIN.',
            remainingAttempts: 0,
          );

          // Clean up PIN verification record
          await PinVerificationDataSource.cleanupPinVerification(state.email);
        } else {
          state = state.copyWith(
            isLoading: false,
            errorMessage: 'Invalid PIN. $newAttempts attempts remaining.',
            remainingAttempts: newAttempts,
          );
        }

        return false;
      }
    } catch (e) {
      logger.e('Error verifying PIN: $e');
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'An error occurred. Please try again.',
      );
      return false;
    }
  }

  /// Resends PIN
  Future<bool> resendPin() async {
    if (state.email.isEmpty) return false;

    return await sendPin(
      email: state.email,
      userName: state.email.split('@')[0], // Use email prefix as fallback name
    );
  }

  /// Resets state
  void reset() {
    state = const PinVerificationState();
  }

  /// Sets email
  void setEmail(String email) {
    state = state.copyWith(email: email);
  }

  /// Clears error message
  void clearError() {
    state = state.copyWith(errorMessage: null);
  }
}
