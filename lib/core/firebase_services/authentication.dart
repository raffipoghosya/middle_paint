import 'package:firebase_auth/firebase_auth.dart';
import 'package:middle_paint/core/resources/base_exception.dart';
import 'package:middle_paint/core/resources/response_state.dart';

/// A service class responsible for all Firebase Authentication operations.
/// This acts as a wrapper around [FirebaseAuth] to handle sign-up, sign-in,
/// and log-out logic, and to convert [FirebaseAuthException] errors
/// into our internal [BaseException] for consistent error handling across the app.
class AuthenticationService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  User? get currentUser => _auth.currentUser;

  /// Attempts to create a new user with email and password.
  /// Returns [DataState<UserCredential>] to handle success or failure with a [BaseException].
  Future<DataState<UserCredential>> signUpWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      return DataSuccess(userCredential);
    } on FirebaseAuthException catch (e) {
      return DataFailed(BaseException.fromFirebaseAuthException(e));
    } catch (e) {
      return DataFailed(
        BaseException(message: 'An unexpected error occurred: ${e.toString()}'),
      );
    }
  }

  /// Attempts to sign in an existing user with email and password.
  /// Returns [DataState<UserCredential>] to handle success or failure with a [BaseException].
  Future<DataState<UserCredential>> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      final userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return DataSuccess(userCredential);
    } on FirebaseAuthException catch (e) {
      return DataFailed(BaseException.fromFirebaseAuthException(e));
    } catch (e) {
      return DataFailed(
        BaseException(message: 'An unexpected error occurred: ${e.toString()}'),
      );
    }
  }

  /// Signs out the currently authenticated user.
  Future<void> logOut() async {
    await _auth.signOut();
  }
}
