import 'package:cloud_firestore/cloud_firestore.dart';

class Chatinfo {
  final String role;
  final String text;
  final String? emotion;
  final double? score;
  final Timestamp? createdAt;

  Chatinfo({
    required this.role,
    required this.text,
    this.emotion,
    this.score,
    this.createdAt,
  });

  Map<String, dynamic> toMap() => {
    'role': role,
    'text': text,
    'emotion': emotion,
    'score': score,
    'createdAt': createdAt ?? FieldValue.serverTimestamp(),
  };
  factory Chatinfo.fromMap(Map<String, dynamic> map) {
    return Chatinfo(
      role: map['role'],
      text: map['text'],
      emotion: map['emotion'],
      score: map['score']?.toDouble(),
      createdAt: map['createdAt'],
    );
  }
}
