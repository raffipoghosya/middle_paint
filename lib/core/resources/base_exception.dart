import 'package:firebase_auth/firebase_auth.dart';

/// It wraps native exceptions (like [FirebaseAuthException]) and maps them
/// to user-friendly messages.
class BaseException implements Exception {
  final String? message;
  final String? code;
  final dynamic error;

  BaseException({this.message, this.code, this.error});

  /// Factory constructor to translate common [FirebaseAuthException] codes
  /// into localized, user-readable messages.
  factory BaseException.fromFirebaseAuthException(FirebaseAuthException e) {
    String userFriendlyMessage = 'An unknown error occurred.';

    switch (e.code) {
      case 'weak-password':
        userFriendlyMessage = 'The password provided is too weak.';
        break;
      case 'email-already-in-use':
        userFriendlyMessage = 'An account already exists for that email.';
        break;
      case 'invalid-email':
        userFriendlyMessage = 'The email address is not valid.';
        break;
      case 'user-not-found':
        userFriendlyMessage = 'No user found for that email.';
        break;
      case 'wrong-password':
        userFriendlyMessage = 'Wrong password provided for that user.';
        break;
      case 'network-request-failed':
        userFriendlyMessage = 'Network error. Please check your connection.';
        break;
      default:
        userFriendlyMessage = 'Authentication failed. Code: ${e.code}';
        break;
    }

    return BaseException(message: userFriendlyMessage, code: e.code, error: e);
  }

  @override
  String toString() => 'BaseException: $message (Code: $code)';
}
