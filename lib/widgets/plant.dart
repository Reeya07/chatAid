import 'package:flutter/material.dart';
import '../../controllers/plant_controller.dart';

class PlantCard extends StatefulWidget {
  const PlantCard({super.key});

  @override
  State<PlantCard> createState() => _PlantCardState();
}

class _PlantCardState extends State<PlantCard> {
  final PlantController plantCtrl = PlantController();

  bool loading = true;
  int growthPoints = 0;
  String lastWatered = "";
  bool todaySelfCareDone = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => loading = true);
    final data = await plantCtrl.getPlantData();
    setState(() {
      growthPoints = data['growthPoints'] as int;
      lastWatered = data['lastWatered'] as String;
      todaySelfCareDone = data['todaySelfCareDone'] as bool;
      loading = false;
    });
  }

  // Stage thresholds (tweak if you want)
  String plantAsset(int points) {
    if (points <= 2) return 'assets/plant/seed.png';
    if (points <= 6) return 'assets/plant/plant.png';
    return 'assets/plant/bloom.png';
  }

  String plantMessage(int points) {
    if (points <= 2) return "Small steps still count.";
    if (points <= 6) return "You're growing with consistency.";
    return "Look at you — you kept going.";
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Center(child: CircularProgressIndicator());
    }

    final canWater = plantCtrl.canWaterToday(lastWatered);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFFE3F2FD), // very light blue
            Colors.white,
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Text(
            "Your Growth",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          ),

          const SizedBox(height: 18),

          SizedBox(
            height: 180,
            child: Image.asset(plantAsset(growthPoints), fit: BoxFit.contain),
          ),

          const SizedBox(height: 12),

          Text(
            plantMessage(growthPoints),
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 14, color: Colors.black54),
          ),

          const SizedBox(height: 16),

          SizedBox(
            width: 160,
            height: 42,
            child: ElevatedButton(
              onPressed: canWater
                  ? () async {
                      await plantCtrl.waterPlant();
                      await _load();
                      if (!mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("You watered your plant 🌿"),
                        ),
                      );
                    }
                  : null,

              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1E88E5),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              child: Text(canWater ? "Water 🌿" : "Watered Today"),
            ),
          ),
        ],
      ),
    );
  }
}
