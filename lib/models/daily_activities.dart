import 'package:cloud_firestore/cloud_firestore.dart';

class DailyActivity {
  final bool moodLogged;
  final bool chatUsed;
  final bool exerciseDone;
  final Timestamp? lastUpdatedAt;

  DailyActivity({
    required this.moodLogged,
    required this.chatUsed,
    required this.exerciseDone,
    this.lastUpdatedAt,
  });
  Map<String, dynamic> toMap() => {
    "moodLoogged": moodLogged,
    "chatUsed": chatUsed,
    "exercisedDone": exerciseDone,
    "lastUpdatedAt": lastUpdatedAt,
  };
  static DailyActivity fromMap(Map<String, dynamic> data) => DailyActivity(
    moodLogged: (data["moodLoogged"] ?? false) as bool,
    chatUsed: (data["chatUsed"] ?? false) as bool,
    exerciseDone: (data["exerciseDone"] ?? false) as bool,
    lastUpdatedAt: data["lastUpdatedAt"] as Timestamp?,
  );
}
