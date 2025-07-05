import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:Quizdom/core/network/server.dart';
import 'package:Quizdom/data/models/pin_verification.dart';

class PinVerificationDataSource {
  static final _collection =
      FirebaseFirestore.instance.collection('pinVerifications');

  /// Saves PIN verification record (PIN will be automatically hashed by converter)
  static Future<void> savePinVerification({
    required String email,
    required String plainPin,
    int expiryMinutes = 10,
  }) async {
    try {
      final now = DateTime.now();
      final expiry = now.add(Duration(minutes: expiryMinutes));

      final pinVerification = PinVerification(
        email: email,
        pin: plainPin, // Will be automatically hashed by the converter
        createdAt: now,
        expiresAt: expiry,
      );

      await _collection.doc(email).set(pinVerification.toJson());
      logger.i(
          'PIN verification saved for email: $email (PIN automatically hashed)');
    } catch (e) {
      logger.e('Error saving PIN verification: $e');
      rethrow;
    }
  }

  /// Verifies PIN by hashing the entered PIN and comparing with stored hash
  static Future<bool> verifyPin({
    required String email,
    required String enteredPin,
  }) async {
    try {
      final doc = await _collection.doc(email).get();

      if (!doc.exists) {
        logger.w('No PIN verification found for email: $email');
        return false;
      }

      final pinData = PinVerification.fromJson(doc.data()!);

      // Check if PIN verification is still valid
      if (!pinData.isValid) {
        logger.w(
            'PIN verification expired or too many attempts for email: $email');
        await _collection.doc(email).delete(); // Clean up expired/invalid PIN
        return false;
      }

      // Hash the entered PIN and compare with stored hash
      final enteredPinHash = PinHashConverter.hashPin(enteredPin);
      if (enteredPinHash == pinData.pin) {
        // PIN matches - mark as verified and clean up
        await _collection.doc(email).update({
          'isVerified': true,
          'attempts': FieldValue.increment(1),
        });
        logger.i('PIN verified successfully for email: $email');
        return true;
      } else {
        // PIN doesn't match - increment attempts
        final newAttempts = pinData.attempts + 1;
        await _collection.doc(email).update({
          'attempts': newAttempts,
        });

        // If max attempts reached, clean up
        if (newAttempts >= 3) {
          logger.w('Max attempts reached for email: $email, cleaning up');
          await _collection.doc(email).delete();
        }

        logger.w(
            'Invalid PIN entered for email: $email (attempt $newAttempts/3)');
        return false;
      }
    } catch (e) {
      logger.e('Error verifying PIN: $e');
      return false;
    }
  }

  /// Gets PIN verification status
  static Future<PinVerification?> getPinVerification(String email) async {
    try {
      final doc = await _collection.doc(email).get();

      if (!doc.exists) {
        return null;
      }

      final pinVerification = PinVerification.fromJson(doc.data()!);

      // Clean up if expired
      if (pinVerification.isExpired) {
        await _collection.doc(email).delete();
        return null;
      }

      return pinVerification;
    } catch (e) {
      logger.e('Error getting PIN verification: $e');
      return null;
    }
  }

  /// Cleans up PIN verification record
  static Future<void> cleanupPinVerification(String email) async {
    try {
      await _collection.doc(email).delete();
      logger.i('PIN verification cleaned up for email: $email');
    } catch (e) {
      logger.e('Error cleaning up PIN verification: $e');
    }
  }

  /// Checks if user can resend PIN (with rate limiting)
  static Future<bool> canResendPin(String email) async {
    try {
      final pinVerification = await getPinVerification(email);

      if (pinVerification == null) {
        return true; // No existing PIN, can send
      }

      final timeSinceCreated =
          DateTime.now().difference(pinVerification.createdAt);

      // Allow resend only after 1 minute
      return timeSinceCreated.inMinutes >= 1;
    } catch (e) {
      logger.e('Error checking resend eligibility: $e');
      return false;
    }
  }

  /// Get remaining attempts for a PIN verification
  static Future<int> getRemainingAttempts(String email) async {
    try {
      final pinVerification = await getPinVerification(email);

      if (pinVerification == null) {
        return 3; // Default attempts
      }

      return 3 - pinVerification.attempts;
    } catch (e) {
      logger.e('Error getting remaining attempts: $e');
      return 0;
    }
  }
}
