import 'package:cloud_firestore/cloud_firestore.dart';

class DailyProgress {
  final bool mood;
  final bool chat;
  final bool exercises;
  final Timestamp? lastUpdatedAt;

  DailyProgress({
    required this.mood,
    required this.chat,
    required this.exercises,
    this.lastUpdatedAt,
  });

  Map<String, dynamic> toMap() => {
    "mood": mood,
    "chat": chat,
    "exercises": exercises,
    "lastUpdatedAt": lastUpdatedAt,
  };

  static DailyProgress fromMap(Map<String, dynamic> data) => DailyProgress(
    mood: (data["mood"] ?? false) as bool,
    chat: (data["chat"] ?? false) as bool,
    exercises: (data["exercises"] ?? false) as bool,
    lastUpdatedAt: data["lastUpdatedAt"] as Timestamp?,
  );
}
