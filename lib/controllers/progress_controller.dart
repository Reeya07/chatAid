import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ProgressController {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  String todayKey() {
    final now = DateTime.now();
    return "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";
  }

  DocumentReference<Map<String, dynamic>> _todayDoc() {
    final uid = _auth.currentUser?.uid;
    if (uid == null) {
      throw Exception("User not logged in");
    }
    return _db
        .collection('users')
        .doc(uid)
        .collection('dailyProgress')
        .doc(todayKey());
  }

  Stream<Map<String, dynamic>> streamTodayProgress() {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return const Stream.empty();

    return _db
        .collection('users')
        .doc(uid)
        .collection('dailyProgress')
        .doc(todayKey())
        .snapshots()
        .map((doc) => doc.data() ?? {});
  }

  Future<void> markDone(String key) async {
    await _todayDoc().set({key: true}, SetOptions(merge: true));
  }
}
