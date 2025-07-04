import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:Quizdom/core/network/server.dart';
import 'package:Quizdom/data/models/pin_verification.dart';

class PinVerificationDataSource {
  static final _collection =
      FirebaseFirestore.instance.collection('pinVerifications');

  /// Saves PIN verification record
  static Future<void> savePinVerification({
    required String email,
    required String pin,
  }) async {
    try {
      final now = DateTime.now();
      final expiry = now.add(const Duration(minutes: 10)); // 10 minutes expiry

      final pinVerification = PinVerification(
        email: email,
        pin: pin, // In production, consider hashing this
        createdAt: now,
        expiresAt: expiry,
      );

      await _collection.doc(email).set(pinVerification.toJson());
      logger.i('PIN verification saved for email: $email');
    } catch (e) {
      logger.e('Error saving PIN verification: $e');
      rethrow;
    }
  }

  /// Verifies PIN
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

      // Check if PIN is expired
      if (DateTime.now().isAfter(pinData.expiresAt)) {
        logger.w('PIN expired for email: $email');
        await _collection.doc(email).delete(); // Clean up expired PIN
        return false;
      }

      // Check if PIN matches
      if (pinData.pin == enteredPin) {
        // Mark as verified and clean up
        await _collection.doc(email).update({
          'isVerified': true,
          'attempts': FieldValue.increment(1),
        });
        logger.i('PIN verified successfully for email: $email');
        return true;
      } else {
        // Increment attempts
        await _collection.doc(email).update({
          'attempts': FieldValue.increment(1),
        });
        logger.w('Invalid PIN entered for email: $email');
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

      return PinVerification.fromJson(doc.data()!);
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

  /// Resends PIN (with rate limiting)
  static Future<bool> canResendPin(String email) async {
    try {
      final doc = await _collection.doc(email).get();

      if (!doc.exists) {
        return true;
      }

      final pinData = PinVerification.fromJson(doc.data()!);
      final timeSinceCreated = DateTime.now().difference(pinData.createdAt);

      // Allow resend only after 1 minute
      return timeSinceCreated.inMinutes >= 1;
    } catch (e) {
      logger.e('Error checking resend eligibility: $e');
      return false;
    }
  }
}
