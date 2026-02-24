import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

class PlantController {
  final _auth = FirebaseAuth.instance;
  final _db = FirebaseFirestore.instance;

  String _todayKey() => DateFormat('yyyy-MM-dd').format(DateTime.now());

  Future<Map<String, dynamic>> getPlantData() async {
    final uid = _auth.currentUser!.uid;
    final doc = await _db.collection('users').doc(uid).get();
    final data = doc.data() ?? {};

    return {
      'growthPoints': (data['growthPoints'] ?? 0) as int,
      'lastWatered': (data['lastWatered'] ?? '') as String,
      'todaySelfCareDone': (data['todaySelfCareDone'] ?? false) as bool,
    };
  }

  bool canWaterToday(String lastWatered) {
    return lastWatered != _todayKey();
  }

  /// Water once per day:
  /// - +1 point normally
  /// - +2 points if user completed a self-care action today
  Future<int> waterPlant() async {
    final uid = _auth.currentUser!.uid;
    final ref = _db.collection('users').doc(uid);

    int pointsAdded = 0;

    await _db.runTransaction((tx) async {
      final snap = await tx.get(ref);
      final data = snap.data() ?? {};

      final int growthPoints = (data['growthPoints'] ?? 0) as int;
      final String lastWatered = (data['lastWatered'] ?? '') as String;
      final bool todaySelfCareDone =
          (data['todaySelfCareDone'] ?? false) as bool;

      // Already watered today -> do nothing
      if (!canWaterToday(lastWatered)) {
        pointsAdded = 0;
        return;
      }

      pointsAdded = todaySelfCareDone ? 2 : 1;

      tx.set(ref, {
        'growthPoints': growthPoints + pointsAdded,
        'lastWatered': _todayKey(),
        // Optional: reset bonus so user needs a new action tomorrow for bonus
        'todaySelfCareDone': false,
      }, SetOptions(merge: true));
    });

    return pointsAdded;
  }
}
