import 'package:firebase_auth/firebase_auth.dart';

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
      } else if (e.code == "Invalid-email") {
        return 'Invalid email address.';
      } else {
        return e.message ?? "Authentication error.";
      }
    } catch (e) {
      return "Unexpected error: $e";
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
