import 'dart:convert';
import 'dart:math';

import 'package:Quizdom/core/network/server.dart';
import 'package:crypto/crypto.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

class EmailServiceDataSource {
  static final String _emailJsServiceId =
      dotenv.env['EMAILJS_SERVICE_ID'] ?? '';
  static final String _emailJsTemplateId =
      dotenv.env['EMAILJS_TEMPLATE_ID'] ?? '';
  static final String _emailJsUserId = dotenv.env['EMAILJS_USER_ID'] ?? '';

  /// Generates a 6-digit PIN
  static String generatePin() {
    final random = Random();
    return (100000 + random.nextInt(900000)).toString();
  }

  /// Sends PIN via EmailJS
  static Future<bool> sendPinViaEmailJS({
    required String email,
    required String pin,
    required String userName,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('https://api.emailjs.com/api/v1.0/email/send'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'service_id': _emailJsServiceId,
          'template_id': _emailJsTemplateId,
          'user_id': _emailJsUserId,
          'template_params': {
            'to_email': email,
            'to_name': userName,
            'pin_code': pin,
          },
        }),
      );

      if (response.statusCode == 200) {
        logger.i('PIN sent successfully via EmailJS');
        return true;
      } else {
        logger.e('Failed to send PIN: ${response.body}');
        return false;
      }
    } catch (e) {
      logger.e('Error sending PIN via EmailJS: $e');
      return false;
    }
  }

  /// Alternative: Send PIN via Resend API
  static Future<bool> sendPinViaResend({
    required String email,
    required String pin,
    required String userName,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('https://api.resend.com/emails'),
        headers: {
          'Authorization': 'Bearer YOUR_RESEND_API_KEY',
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'from': 'noreply@yourdomain.com',
          'to': [email],
          'subject': 'Quizdom - Email Verification PIN',
          'html': '''
            <h2>Welcome to Quizdom!</h2>
            <p>Hi $userName,</p>
            <p>Your verification PIN is: <strong style="font-size: 24px; color: #007bff;">$pin</strong></p>
            <p>This PIN will expire in 10 minutes.</p>
            <p>If you didn't request this, please ignore this email.</p>
          ''',
        }),
      );

      if (response.statusCode == 200) {
        logger.i('PIN sent successfully via Resend');
        return true;
      } else {
        logger.e('Failed to send PIN: ${response.body}');
        return false;
      }
    } catch (e) {
      logger.e('Error sending PIN via Resend: $e');
      return false;
    }
  }

  /// Hash PIN for storage (optional security measure)
  static String hashPin(String pin) {
    final bytes = utf8.encode(pin);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }
}
