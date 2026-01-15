import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class RegisterController {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _database = FirebaseFirestore.instance;

  Future<String?> register({
    required String name,
    required String email,
    required String password,
  }) async {
    try {
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      final user = userCredential.user;
      if (user == null) {
        return "Registration failed. Try again.";
      }
      await _database.collection("Users").doc(user.uid).set({
        "uid": user.uid,
        "Name": name,
        "Email": email,
        "CreatedAt": FieldValue.serverTimestamp(),
      });
      return null;
    } on FirebaseAuthException catch (e) {
      if (e.code == "email-already-in-use") {
        return "This email is already registered";
      } else if (e.code == "invalid-email") {
        return "Invalid email format";
      } else if (e.code == "weak-password") {
        return "Password is too weak.";
      } else {
        return e.message ?? "Authentication error.";
      }
    } on FirebaseException catch (e) {
      return e.message ?? "Database error.";
    } catch (e) {
      return "Unexpected error: $e";
    }
  }
}
