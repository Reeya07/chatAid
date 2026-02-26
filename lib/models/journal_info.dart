import 'package:cloud_firestore/cloud_firestore.dart';

class JournalLog {
  final String text;
  final bool released;
  final Timestamp? createdAt;

  JournalLog({required this.text, this.released = false, this.createdAt});

  Map<String, dynamic> toMap() => {"text": text, "released": released};

  static JournalLog fromMap(Map<String, dynamic> data) => JournalLog(
    text: (data["text"] ?? "") as String,
    released: (data["released"] ?? false) as bool,
    createdAt: data["createdAt"] as Timestamp?,
  );
}
