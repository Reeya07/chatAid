import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/cbt_log.dart';
import '../services/encrypt.dart';

class CbtController {
  static const String baseUrl = "https://chataid-backend.onrender.com";
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<String> generateBalancedThought({
    required String situation,
    required String thought,
    required String thinkingPattern,
    required String evidenceFor,
    required String advice,
  }) async {
    final url = Uri.parse("$baseUrl/cbt/reframe");
    final res = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "situation": situation,
        "thought": thought,
        "thinking_pattern": thinkingPattern,
        "evidence_for": evidenceFor,
        "advice": advice,
      }),
    );
    if (res.statusCode != 200) {
      throw Exception("CBT backend error ${res.statusCode}:{res.body}");
    }
    final data = jsonDecode(res.body) as Map<String, dynamic>;
    return (data["balancedthought"] ?? "").toString();
  }

  String get _uid {
    final uid = _auth.currentUser?.uid;
    if (uid == null) throw Exception("User not logged in");
    return uid;
  }

  CollectionReference<Map<String, dynamic>> get _col =>
      _db.collection("users").doc(_uid).collection("cbt_logs");

  Future<String> create(CbtLog log) async {
    final data = await _encryptCbtMap(log);

    final doc = await _col.add({
      ...data,
      "createdAt": FieldValue.serverTimestamp(),
      "updatedAt": FieldValue.serverTimestamp(),
    });

    return doc.id;
  }

  Future<void> update(String cbtId, CbtLog log) async {
    final data = await _encryptCbtMap(log);

    await _col.doc(cbtId).set({
      ...data,
      "updatedAt": FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  Stream<CbtLog?> streamOne(String cbtId) {
    return _col.doc(cbtId).snapshots().asyncMap((doc) async {
      if (!doc.exists) return null;
      return _decryptCbtDoc(doc);
    });
  }

  Future<Map<String, dynamic>> _encryptCbtMap(CbtLog log) async {
    return {
      "situationEnc": await CryptoService.instance.encryptString(log.situation),
      "thoughtEnc": await CryptoService.instance.encryptString(log.thought),
      "thinkingPatternEnc": await CryptoService.instance.encryptString(
        log.thinkingPattern,
      ),
      "evidenceForEnc": await CryptoService.instance.encryptString(
        log.evidenceFor,
      ),
      "adviceEnc": await CryptoService.instance.encryptString(log.advice),
      "balancedThoughtEnc": await CryptoService.instance.encryptString(
        log.balancedThought,
      ),
      "beforeIntensity": log.beforeIntensity,
      "afterIntensity": log.afterIntensity,
      "done": log.done,
    };
  }

  Future<String> _safeDecrypt(Map<String, dynamic> data, String encKey, String plainKey) async {
    final enc = (data[encKey] ?? "") as String;
    if (enc.isEmpty) return (data[plainKey] ?? "") as String;
    return CryptoService.instance.decryptString(enc);
  }

  Future<CbtLog> _decryptCbtDoc(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) async {
    final data = doc.data() ?? {};

    final situation      = await _safeDecrypt(data, "situationEnc",      "situation");
    final thought        = await _safeDecrypt(data, "thoughtEnc",         "thought");
    final thinkingPattern= await _safeDecrypt(data, "thinkingPatternEnc", "thinkingPattern");
    final evidenceFor    = await _safeDecrypt(data, "evidenceForEnc",     "evidenceFor");
    final advice         = await _safeDecrypt(data, "adviceEnc",          "advice");
    final balancedThought= await _safeDecrypt(data, "balancedThoughtEnc", "balancedThought");

    return CbtLog(
      id: doc.id,
      situation: situation,
      thought: thought,
      thinkingPattern: thinkingPattern,
      evidenceFor: evidenceFor,
      advice: advice,
      balancedThought: balancedThought,
      beforeIntensity: (data["beforeIntensity"] ?? 3) as int,
      afterIntensity: (data["afterIntensity"] ?? 3) as int,
      done: (data["done"] ?? false) as bool,
      createdAt: data["createdAt"] as Timestamp?,
      updatedAt: data["updatedAt"] as Timestamp?,
    );
  }

  Future<void> updateFields(String cbtId, Map<String, dynamic> fields) async {
    final Map<String, dynamic> toSave = {};

    for (final entry in fields.entries) {
      if (entry.value is String) {
        toSave["${entry.key}Enc"] = await CryptoService.instance.encryptString(
          entry.value as String,
        );
      } else {
        toSave[entry.key] = entry.value;
      }
    }

    await _col.doc(cbtId).set({
      ...toSave,
      "updatedAt": FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  Stream<List<CbtLog>> streamAll() {
    return _col.orderBy("createdAt", descending: true).snapshots().asyncMap((
      snap,
    ) async {
      final List<CbtLog> list = [];
      for (final d in snap.docs) {
        list.add(await _decryptCbtDoc(d));
      }
      return list;
    });
  }
}
