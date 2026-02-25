import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/user.dart';

class UserController {
  final FirebaseAuth _auth;
  final FirebaseFirestore _db;

  UserController({FirebaseAuth? auth, FirebaseFirestore? db})
    : _auth = auth ?? FirebaseAuth.instance,
      _db = db ?? FirebaseFirestore.instance;

  User? get currentUser => _auth.currentUser;

  Stream<AppUser> appUserStream() {
    final user = currentUser;
    if (user == null) {
      return Stream.error("Not logged in");
    }

    return _db.collection('users').doc(user.uid).snapshots().map((doc) {
      final data = doc.data() ?? {};
      // fallback: if name missing, use email prefix
      final email = (data['email'] ?? user.email ?? '').toString();
      final name = (data['name'] ?? '').toString().trim();
      final fallbackName = email.contains('@')
          ? email.split('@').first
          : 'User';

      return AppUser(
        uid: user.uid,
        email: email,
        name: name.isEmpty ? fallbackName : name,
      );
    });
  }
}
