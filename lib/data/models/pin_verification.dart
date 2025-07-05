import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'pin_verification.freezed.dart';
part 'pin_verification.g.dart';

@freezed
class PinVerification with _$PinVerification {
  const factory PinVerification({
    required String email,
    @PinHashConverter() required String pin,
    required DateTime createdAt,
    required DateTime expiresAt,
    @Default(false) bool isVerified,
    @Default(0) int attempts,
  }) = _PinVerification;

  const PinVerification._();

  factory PinVerification.fromJson(Map<String, dynamic> json) =>
      _$PinVerificationFromJson(json);

  /// Check if this PIN verification has expired
  bool get isExpired => DateTime.now().isAfter(expiresAt);

  /// Check if this PIN verification is still valid (not expired and not exceeded attempts)
  bool get isValid => !isExpired && attempts < 3;
}

class PinHashConverter implements JsonConverter<String, String> {
  const PinHashConverter();

  @override
  String fromJson(String json) {
    return json;
  }

  @override
  String toJson(String pin) {
    return hashPin(pin);
  }

  /// Hash a PIN using SHA-256
  static String hashPin(String pin) {
    final bytes = utf8.encode(pin);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }
}
