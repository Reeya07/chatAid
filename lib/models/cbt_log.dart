import 'package:cloud_firestore/cloud_firestore.dart';

class CbtLog {
  final String? id; // Firestore doc id (optional in model)
  final String? journalId;

  final String situation;
  final String thought;
  final String thinkingPattern;
  final String evidenceFor;
  final String advice;
  final String balancedThought;

  final int beforeIntensity;
  final int afterIntensity;

  final bool done;
  final Timestamp? createdAt;
  final Timestamp? updatedAt;

  CbtLog({
    this.id,
    this.journalId,
    required this.situation,
    required this.thought,
    required this.thinkingPattern,
    required this.evidenceFor,
    required this.advice,
    required this.balancedThought,
    required this.beforeIntensity,
    required this.afterIntensity,
    required this.done,
    this.createdAt,
    this.updatedAt,
  });

  /// For creating a new record with defaults
  factory CbtLog.empty({String? journalId, String initialThought = ""}) {
    return CbtLog(
      journalId: journalId,
      situation: "",
      thought: initialThought,
      thinkingPattern: "Unclear",
      evidenceFor: "",
      advice: "",
      balancedThought: "",
      beforeIntensity: 3,
      afterIntensity: 3,
      done: false,
    );
  }

  Map<String, dynamic> toMap() => {
    "journalId": journalId,
    "situation": situation,
    "thought": thought,
    "thinkingPattern": thinkingPattern,
    "evidenceFor": evidenceFor,
    "advice": advice,
    "balancedThought": balancedThought,
    "beforeIntensity": beforeIntensity,
    "afterIntensity": afterIntensity,
    "done": done,
  };

  static CbtLog fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};
    return CbtLog(
      id: doc.id,
      journalId: data["journalId"] as String?,
      situation: (data["situation"] ?? "") as String,
      thought: (data["thought"] ?? "") as String,
      thinkingPattern: (data["thinkingPattern"] ?? "Unclear") as String,
      evidenceFor: (data["evidenceFor"] ?? "") as String,
      advice: (data["advice"] ?? "") as String,
      balancedThought: (data["balancedThought"] ?? "") as String,
      beforeIntensity: (data["beforeIntensity"] ?? 3) as int,
      afterIntensity: (data["afterIntensity"] ?? 3) as int,
      done: (data["done"] ?? false) as bool,
      createdAt: data["createdAt"] as Timestamp?,
      updatedAt: data["updatedAt"] as Timestamp?,
    );
  }

  CbtLog copyWith({
    String? id,
    String? journalId,
    String? situation,
    String? thought,
    String? thinkingPattern,
    String? evidenceFor,
    String? advice,
    String? balancedThought,
    int? beforeIntensity,
    int? afterIntensity,
    bool? done,
    Timestamp? createdAt,
    Timestamp? updatedAt,
  }) {
    return CbtLog(
      id: id ?? this.id,
      journalId: journalId ?? this.journalId,
      situation: situation ?? this.situation,
      thought: thought ?? this.thought,
      thinkingPattern: thinkingPattern ?? this.thinkingPattern,
      evidenceFor: evidenceFor ?? this.evidenceFor,
      advice: advice ?? this.advice,
      balancedThought: balancedThought ?? this.balancedThought,
      beforeIntensity: beforeIntensity ?? this.beforeIntensity,
      afterIntensity: afterIntensity ?? this.afterIntensity,
      done: done ?? this.done,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
