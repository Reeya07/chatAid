import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/daily_progress.dart';

class ProgressController {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  String todayKey() {
    final now = DateTime.now();
    return "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";
  }

  DocumentReference<Map<String, dynamic>> _todayDoc() {
    final uid = _auth.currentUser?.uid;
    if (uid == null) throw Exception("User not logged in");
    return _db
        .collection('users')
        .doc(uid)
        .collection('dailyProgress')
        .doc(todayKey());
  }

  Stream<DailyProgress> streamTodayProgress() {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return const Stream.empty();

    return _db
        .collection('users')
        .doc(uid)
        .collection('dailyProgress')
        .doc(todayKey())
        .snapshots()
        .map(
          (doc) => doc.exists
              ? DailyProgress.fromMap(doc.data()!)
              : DailyProgress(mood: false, chat: false, exercises: false),
        );
  }

  Future<void> markDone(String key) async {
    await _todayDoc().set({key: true}, SetOptions(merge: true));
  }
}
