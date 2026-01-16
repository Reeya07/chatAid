import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';
import '../models/chat_info.dart';
import '../repositories/chat_repository.dart';

class ChatController {
  final String baseUrl;
  final ChatRepository chatRep = ChatRepository();
  final FirebaseAuth auth = FirebaseAuth.instance;

  ChatController({required this.baseUrl});

  Future<String> _userid() async {
    final user = auth.currentUser;
    if (user != null) return user.uid;

    final cred = await auth.signInAnonymously();
    return cred.user!.uid;
  }

  Future<Map<String, dynamic>> sendMessage(String message) async {
    final uid = await _userid();
    final url = Uri.parse('$baseUrl/chat');

    final res = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'message': message}),
    );
    if (res.statusCode != 200) {
      throw Exception('Backend error: ${res.body}');
    }
    final data = jsonDecode(res.body) as Map<String, dynamic>;
    final reply = data['reply'];
    final emotion = data['emotion'];
    final score = data['score']?.toDouble();

    await chatRep.saveMessage(
      uid,
      Chatinfo(role: 'user', text: message, emotion: emotion, score: score),
    );
    await chatRep.saveMessage(uid, Chatinfo(role: 'assistant', text: reply));
    return {'reply': reply, 'emotion': emotion, 'score': score};
  }
}
