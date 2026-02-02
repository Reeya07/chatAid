import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/mood_log.dart';

class MoodController {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _database = FirebaseFirestore.instance;

  Future<void> saveMoodLog(MoodLog log) async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) throw Exception("User not logged in");

    await _database.collection("users").doc(uid).collection("mood_logs").add({
      ...log.toMap(),
      "createdAt": FieldValue.serverTimestamp(),
    });
  }

  Stream<List<MoodLog>> streamLast7Days() {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return const Stream.empty();

    final now = DateTime.now();
    final start = DateTime(
      now.year,
      now.month,
      now.day,
    ).subtract(Duration(days: 6));

    return _database
        .collection("users")
        .doc(uid)
        .collection("mood_logs")
        .where("createdAt", isGreaterThanOrEqualTo: Timestamp.fromDate(start))
        .orderBy("createdAt", descending: false)
        .snapshots()
        .map(
          (snap) => snap.docs.map((d) => MoodLog.fromMap(d.data())).toList(),
        );
  }
}
