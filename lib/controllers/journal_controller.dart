import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/journal_info.dart';

class JournalController {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _database = FirebaseFirestore.instance;

  Future<void> saveJournalLog(JournalLog log) async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) throw Exception("User not logged in");

    await _database.collection("users").doc(uid).collection("journal_logs").add(
      {...log.toMap(), "createdAt": FieldValue.serverTimestamp()},
    );
  }

  Stream<List<JournalLog>> streamAllJournalLogs() {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return Stream.empty();

    return _database
        .collection("users")
        .doc(uid)
        .collection("journal_logs")
        .orderBy("createdAt", descending: true)
        .snapshots()
        .map(
          (snap) => snap.docs.map((d) => JournalLog.fromMap(d.data())).toList(),
        );
  }
}
