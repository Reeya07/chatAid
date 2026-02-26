import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/cbt_log.dart';

class CbtController {
  static const String baseUrl = "http://127.0.0.1:3000";
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

  /// Create a CBT log doc and return its id
  Future<String> create(CbtLog log) async {
    final doc = await _col.add({
      ...log.toMap(),
      "createdAt": FieldValue.serverTimestamp(),
      "updatedAt": FieldValue.serverTimestamp(),
    });
    return doc.id;
  }

  /// Save/update an existing CBT log doc (merge)
  Future<void> update(String cbtId, CbtLog log) async {
    await _col.doc(cbtId).set({
      ...log.toMap(),
      "updatedAt": FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  Stream<CbtLog?> streamOne(String cbtId) {
    return _col.doc(cbtId).snapshots().map((doc) {
      if (!doc.exists) return null;
      return CbtLog.fromDoc(doc);
    });
  }

  Stream<List<CbtLog>> streamAll() {
    return _col
        .orderBy("createdAt", descending: true)
        .snapshots()
        .map((snap) => snap.docs.map((d) => CbtLog.fromDoc(d)).toList());
  }
}
