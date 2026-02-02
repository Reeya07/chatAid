import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';

class LoginController {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<String?> login({
    required String email,
    required String password,
  }) async {
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
      return null;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        return 'User not found with this email';
      } else if (e.code == "wrong-password") {
        return 'Incorrect Password';
      } else if (e.code == "invalid-email") {
        return 'Invalid email address.';
      } else if (e.code == "invalid-credential") {
        return 'Email or password is incorrect.';
      } else {
        return e.message ?? "Authentication error.";
      }
    } on PlatformException catch (e) {
      if (e.code == 'ERROR_INVALID_CREDENTIAL') {
        return 'Email or password is incorrect';
      }
      return e.message ?? 'Login failed. Please try again.';
    } catch (e) {
      return 'Unexpected error: $e';
    }
  }

  //To add anonymous
  Future<String?> anonymous() async {
    try {
      await _auth.signInAnonymously();
      return null;
    } on FirebaseAuthException catch (e) {
      return e.message ?? 'Failed to login anonymously.';
    } catch (e) {
      return 'Unexpected error occurred: $e';
    }
  }

  Future<String?> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
      return null;
    } on FirebaseAuthException catch (e) {
      return e.message ?? 'Failed to send resend password email.';
    } catch (e) {
      return 'Unexpected error occurred:$e';
    }
  }
}
