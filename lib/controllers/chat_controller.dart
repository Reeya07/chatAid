import 'dart:convert';
import 'package:http/http.dart' as http;

class ChatController {
  final String baseUrl;
  ChatController({required this.baseUrl});

  Future<String> sendMessage(String message) async {
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
    return (data['reply'] ?? '').toString();
  }
}
