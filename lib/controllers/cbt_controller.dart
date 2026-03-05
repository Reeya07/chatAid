import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/cbt_log.dart';
import '../services/encrypt.dart';
import '../config/security.dart';

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

  /// Create a CBT log doc and return its id also encrypt
  Future<String> create(CbtLog log) async {
    final data = await _encryptCbtMap(log);

    final doc = await _col.add({
      ...data,
      "createdAt": FieldValue.serverTimestamp(),
      "updatedAt": FieldValue.serverTimestamp(),
    });

    return doc.id;
  }

  /// Save/update an existing CBT log doc (merge)
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
    if (SecurityConfig.encryptionEnabled) {
      return {
        "journalId": log.journalId,

        "situationEnc": await CryptoService.instance.encryptString(
          log.situation,
        ),
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
    } else {
      // 🔹 testing mode (plaintext)
      return {
        "journalId": log.journalId,

        "situation": log.situation,
        "thought": log.thought,
        "thinkingPattern": log.thinkingPattern,
        "evidenceFor": log.evidenceFor,
        "advice": log.advice,
        "balancedThought": log.balancedThought,

        "beforeIntensity": log.beforeIntensity,
        "afterIntensity": log.afterIntensity,
        "done": log.done,
      };
    }
  }

  Future<CbtLog> _decryptCbtDoc(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) async {
    final data = doc.data() ?? {};

    final situation = await CryptoService.instance.decryptString(
      (data["situationEnc"] ?? "") as String,
    );
    final thought = await CryptoService.instance.decryptString(
      (data["thoughtEnc"] ?? "") as String,
    );
    final thinkingPattern = await CryptoService.instance.decryptString(
      (data["thinkingPatternEnc"] ?? "") as String,
    );
    final evidenceFor = await CryptoService.instance.decryptString(
      (data["evidenceForEnc"] ?? "") as String,
    );
    final advice = await CryptoService.instance.decryptString(
      (data["adviceEnc"] ?? "") as String,
    );
    final balancedThought = await CryptoService.instance.decryptString(
      (data["balancedThoughtEnc"] ?? "") as String,
    );

    return CbtLog(
      id: doc.id,
      journalId: data["journalId"] as String?,
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
