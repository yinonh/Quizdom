import 'package:freezed_annotation/freezed_annotation.dart';

part 'pin_verification.freezed.dart';
part 'pin_verification.g.dart';

@freezed
class PinVerification with _$PinVerification {
  const factory PinVerification({
    required String email,
    required String pin,
    required DateTime createdAt,
    required DateTime expiresAt,
    @Default(false) bool isVerified,
    @Default(0) int attempts,
  }) = _PinVerification;

  factory PinVerification.fromJson(Map<String, dynamic> json) =>
      _$PinVerificationFromJson(json);
}

@freezed
class PinVerificationState with _$PinVerificationState {
  const factory PinVerificationState({
    @Default('') String email,
    @Default('') String pin,
    @Default(false) bool isLoading,
    @Default(false) bool isPinSent,
    @Default(false) bool isVerified,
    String? errorMessage,
    @Default(0) int remainingAttempts,
  }) = _PinVerificationState;
}
