import 'package:cloud_firestore/cloud_firestore.dart';

class MoodLog {
  final String emoji;
  final String moodLabel;
  final int moodScore;
  final Timestamp? createdAt;

  MoodLog({
    required this.emoji,
    required this.moodLabel,
    required this.moodScore,
    this.createdAt,
  });
  Map<String, dynamic> toMap() => {
    "emoji": emoji,
    "moodLabel": moodLabel,
    "moodScore": moodScore,
  };
  static MoodLog fromMap(Map<String, dynamic> data) => MoodLog(
    emoji: (data["emoji"] ?? "") as String,
    moodLabel: (data["moodLabel"] ?? "") as String,
    moodScore: (data["moodScore"] ?? 3) as int,
    createdAt: data["createdAt"] as Timestamp?,
  );
}
