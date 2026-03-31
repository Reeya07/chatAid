import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/journal_info.dart';
import '../services/encrypt.dart';

class JournalController {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _database = FirebaseFirestore.instance;

  Future<void> saveJournalLog(JournalLog log) async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) throw Exception("User not logged in");

    final textEnc = await CryptoService.instance.encryptString(log.text);

    final data = {
      "textEnc": textEnc,
      "released": log.released,
      "createdAt": FieldValue.serverTimestamp(),
    };

    await _database
        .collection("users")
        .doc(uid)
        .collection("journal_logs")
        .add(data);
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
        .asyncMap((snap) async {
          final List<JournalLog> list = [];

          for (final d in snap.docs) {
            final data = d.data();
            String text;

            try {
              text = await CryptoService.instance.decryptString(
                (data["textEnc"] ?? "") as String,
              );
            } catch (e) {
              print("Decryption failed for doc ${d.id}: $e");
              text = "[Unable to decrypt this journal entry]";
            }

            list.add(
              JournalLog(
                text: text,
                released: (data["released"] ?? false) as bool,
                createdAt: data["createdAt"] as Timestamp?,
              ),
            );
          }

          return list;
        });
  }
}
