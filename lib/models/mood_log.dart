import 'package:cloud_firestore/cloud_firestore.dart';

class MoodLog {
  final String emoji;
  final String moodLabel;
  final String? detectedEmotion;
  final double? detectedScore;
  final Timestamp? createdAt;

  MoodLog({
    required this.emoji,
    required this.moodLabel,
    this.detectedEmotion,
    this.detectedScore,
    this.createdAt,
  });
  Map<String, dynamic> toMap() => {
    "emoji": emoji,
    "moodLabel": moodLabel,
    "detectedEmotion": detectedEmotion,
    "detectedScore": detectedScore,
    "createdAt": createdAt ?? FieldValue.serverTimestamp(),
  };
}
