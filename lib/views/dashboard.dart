import 'package:flutter/material.dart';
import 'chat.dart';
import '../controllers/mood_controller.dart';
import '../models/mood_log.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({super.key});

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  final MoodController _moodC = MoodController();

  bool _saving = false;
  String? _selectedEmoji;

  final List<Map<String, String>> moods = const [
    //to add emoji thing
    {"emoji": "😄", "label": "happy"},
  ];

  Future<void> _saveMoodLog(
    String emoji,
    String moodLabel,
    // String detectedEmotion,
    // double detectedScore,
    // Timestamp createdAt,
  ) async {
    setState(() {
      _saving = true;
      _selectedEmoji = emoji;
    });
    try {
      await _moodC.saveMoodLog(
        MoodLog(
          emoji: emoji,
          moodLabel: moodLabel,
          //detectedEmotion: detectedEmotion,
          //detectedScore: detectedScore,
          //createdAt: createdAt,
        ),
      );
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Mood saved:$emoji($moodLabel)")));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Save failed:$e")));
    }
    if (!mounted) return;
    setState(() => _saving = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Dashboard")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            //Daily check-in card
            Card(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Daily check-ins",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 10),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: moods.map((mood) {
                        final emoji = mood["emoji"]!;
                        final label = mood["label"]!;
                        final selected = _selectedEmoji == emoji;

                        return GestureDetector(
                          onTap: _saving
                              ? null
                              : () => _saveMoodLog(emoji, label),
                          child: Container(
                            padding: EdgeInsets.all(10), //check this part
                            decoration: BoxDecoration(
                              color: selected
                                  ? Colors.purple.withOpacity(0.15)
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: selected
                                    ? Colors.purple
                                    : Colors.grey.shade300,
                              ),
                            ),
                            child: Text(
                              emoji,
                              style: const TextStyle(fontSize: 26),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      _saving
                          ? "Saving..."
                          : (_selectedEmoji) == null
                          ? "Tap an emoji to save your mood."
                          : "Selected:$_selectedEmoji",
                      style: const TextStyle(color: Colors.black54),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 16),

            // --- Go to Chat button ---
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const Chat()),
                );
              },
              child: const Text("Go to Chat"),
            ),
          ],
        ),
      ),
    );
  }
}
