import 'package:firebase_auth/firebase_auth.dart';
import 'package:Quizdom/core/constants/constant_strings.dart';

String mapFirebaseErrorCodeToMessage(FirebaseAuthException e) {
  switch (e.code) {
    case 'invalid-email':
      return Strings.invalidEmail;
    case 'user-disabled':
      return Strings.userDisabled;
    case 'user-not-found':
      return Strings.userNotFound;
    case 'wrong-password':
      return Strings.wrongPassword;
    case 'email-already-in-use':
      return Strings.emailAlreadyUse;
    case 'operation-not-allowed':
      return Strings.operationNotAllowed;
    case 'weak-password':
      return Strings.passwordTooWeak;
    case 'invalid-credential':
      return Strings.invalidCredential;
    case 'account-exists-with-different-credential':
      return Strings.accountExistsWithDifferentCredential;
    case 'invalid-verification-code':
      return Strings.invalidVerificationCode;
    case 'invalid-verification-id':
      return Strings.invalidVerificationID;
    case 'session-cookie-expired':
      return Strings.sessionCookieExpired;
    case 'session-cookie-revoked':
      return Strings.sessionCookieRevoked;
    case 'too-many-requests':
      return Strings.tooManyRequests;
    case 'missing-email':
      return Strings.missingEmail;
    default:
      return Strings.undefinedError;
  }
}
