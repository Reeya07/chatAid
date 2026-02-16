import 'dart:convert';
import 'package:http/http.dart' as http;

class CbtController {
  static const String baseUrl = "http://127.0.0.1:3000";

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
}
