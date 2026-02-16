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
    await tickMoodLogged();
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

  //for mood history
  Stream<List<MoodLog>> streamAllMoodLogs() {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return Stream.empty();

    return _database
        .collection("users")
        .doc(uid)
        .collection("mood_logs")
        .orderBy("createdAt", descending: true)
        .snapshots()
        .map(
          (snap) => snap.docs.map((d) => MoodLog.fromMap(d.data())).toList(),
        );
  }

  String dayId(DateTime dt) {
    final year = dt.year.toString().padLeft(4, '0');
    final month = dt.month.toString().padLeft(2, '0');
    final day = dt.day.toString().padLeft(2, '0');
    return "$year-$month-$day";
  }

  DocumentReference<Map<String, dynamic>> todayActivity(String uid) {
    final id = dayId(DateTime.now());
    return _database
        .collection("users")
        .doc(uid)
        .collection("daily_activity")
        .doc(id);
  }

  Future<void> dailyFlag({required String field, required bool value}) async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) throw Exception("User not logged in");

    await todayActivity(uid).set({
      field: value,
      "lastUpdatedAt": FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  Future<void> tickChatUsed() async {
    await dailyFlag(field: "chatUsed", value: true);
  }

  Future<void> tickExerciseDone() async {
    await dailyFlag(field: "exerciseDone", value: true);
  }

  Future<void> tickMoodLogged() async {
    await dailyFlag(field: "moodLogged", value: true);
  }

  Stream<Map<String, dynamic>> streamTodayActivity() {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return Stream.empty();

    return todayActivity(uid).snapshots().map((doc) => doc.data() ?? {});
  }
}
