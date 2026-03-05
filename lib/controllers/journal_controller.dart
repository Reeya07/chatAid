import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/journal_info.dart';
import '../services/encrypt.dart';
import '../config/security.dart';

class JournalController {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _database = FirebaseFirestore.instance;

  Future<void> saveJournalLog(JournalLog log) async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) throw Exception("User not logged in");

    Map<String, dynamic> data;

    if (SecurityConfig.encryptionEnabled) {
      final textEnc = await CryptoService.instance.encryptString(log.text);

      data = {
        "textEnc": textEnc,
        "released": log.released,
        "createdAt": FieldValue.serverTimestamp(),
      };
    } else {
      // 🔹 testing mode (plaintext)
      data = {
        "text": log.text,
        "released": log.released,
        "createdAt": FieldValue.serverTimestamp(),
      };
    }

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

            final enc = (data["textEnc"] ?? "") as String;

            final String text = enc.isEmpty
                ? ((data["text"] ?? "") as String) // old docs fallback
                : await CryptoService.instance.decryptString(enc);

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
