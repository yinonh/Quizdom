import 'dart:convert';
import 'dart:math';

import 'package:Quizdom/core/network/server.dart';
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
            'to_name': userName.isNotEmpty ? userName : 'there',
            'pin_code': pin,
            'app_name': 'Quizdom',
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
}
