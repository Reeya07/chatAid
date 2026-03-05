import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';
import '../models/chat_info.dart';
import '../repositories/chat_repository.dart';

class ChatController {
  final String baseUrl;
  final ChatRepository chatRep = ChatRepository();
  final FirebaseAuth auth = FirebaseAuth.instance;

  ChatController({required this.baseUrl});

  String _uid() {
    final user = auth.currentUser;
    if (user == null) {
      throw Exception("User not logged in. Please login again.");
    }
    return user.uid;
  }

  Future<Map<String, dynamic>> sendMessage(String message) async {
    final uid = _uid();

    // 1) Save USER message first (always)
    await chatRep.saveMessage(
      uid,
      Chatinfo(role: 'user', text: message, createdAt: Timestamp.now()),
    );

    // 2) Call backend
    final url = Uri.parse('$baseUrl/chat');
    final res = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'message': message}),
    );

    if (res.statusCode != 200) {
      await chatRep.saveMessage(
        uid,
        Chatinfo(
          role: 'assistant',
          text: "Sorry, I'm having trouble responding right now.",
          createdAt: Timestamp.now(),
        ),
      );
      throw Exception('Backend error: ${res.body}');
    }

    final data = jsonDecode(res.body) as Map<String, dynamic>;
    final reply = (data['reply'] ?? "").toString();
    final emotion = data['emotion']?.toString();
    final score = (data['score'] is num)
        ? (data['score'] as num).toDouble()
        : null;
    final rec = data['recommendation'] as Map<String, dynamic>?;

    // 3) Save BOT reply
    await chatRep.saveMessage(
      uid,
      Chatinfo(
        role: 'assistant',
        text: reply,
        emotion: emotion,
        score: score,
        createdAt: Timestamp.now(),
      ),
    );

    return {
      'reply': reply,
      'emotion': emotion,
      'score': score,
      'recommendation': rec,
    };
  }

  Future<Map<String, dynamic>> reframeThought({
    required String situation,
    required String thought,
    required String thinkingPattern,
    required String evidenceFor,
    required String advice,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/cbt/reframe'),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "situation": situation,
        "thought": thought,
        "thinking_pattern": thinkingPattern,
        "evidence_for": evidenceFor,
        "advice": advice,
      }),
    );

    if (response.statusCode != 200) {
      throw Exception("Failed to reframe: ${response.body}");
    }

    // FIX: you were jsonEncoding a string (wrong)
    return jsonDecode(response.body) as Map<String, dynamic>;
  }
}
