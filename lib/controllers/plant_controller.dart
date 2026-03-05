import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

class PlantController {
  final _auth = FirebaseAuth.instance;
  final _db = FirebaseFirestore.instance;

  String _todayKey() => DateFormat('yyyy-MM-dd').format(DateTime.now());

  Future<Map<String, dynamic>> getPlantData() async {
    final user = _auth.currentUser;
    if (user == null) {
      return {'growthPoints': 0, 'lastWatered': ''};
    }

    final doc = await _db.collection('users').doc(user.uid).get();
    final data = doc.data() ?? {};

    return {
      'growthPoints': (data['growthPoints'] ?? 0) as int,
      'lastWatered': (data['lastWatered'] ?? '') as String,
    };
  }

  bool canWaterToday(String lastWatered) {
    return lastWatered != _todayKey();
  }

  /// Water once per day:
  /// - +1 point normally

  Future<int> waterPlant() async {
    final user = _auth.currentUser;
    if (user == null) return 0;
    final uid = user.uid;
    final ref = _db.collection('users').doc(uid);

    int pointsAdded = 0;

    await _db.runTransaction((tx) async {
      final snap = await tx.get(ref);
      final data = snap.data() ?? {};

      final int growthPoints = (data['growthPoints'] ?? 0) as int;
      final String lastWatered = (data['lastWatered'] ?? '') as String;

      // Already watered today -> do nothing
      if (!canWaterToday(lastWatered)) {
        pointsAdded = 0;
        return;
      }
      pointsAdded = 1;
      tx.set(ref, {
        'growthPoints': growthPoints + pointsAdded,
        'lastWatered': _todayKey(),
      }, SetOptions(merge: true));
    });

    return pointsAdded;
  }
}
