import 'package:flutter/material.dart';
import '../controllers/mood_controller.dart';
import '../models/mood_log.dart';
import '../views/chat.dart';

class MoodHistory extends StatelessWidget {
  MoodHistory({super.key});

  final MoodController controller = MoodController();

  bool suggest(List<MoodLog> moods) {
    if (moods.length < 3) return false;
    final recentmood = moods.take(3).toList();
    final lowCount = recentmood.where((m) => m.moodScore <= 2).length;
    return lowCount >= 2;
  }

  int streakDays(List<MoodLog> moods) {
    if (moods.isEmpty) return 0;
    final days = <DateTime>{};
    for (final m in moods) {
      final dt = m.createdAt?.toDate();
      if (dt == null) continue;
      days.add(DateTime(dt.year, dt.month, dt.day));
    }
    int streak = 0;
    var day = DateTime.now();
    day = DateTime(day.year, day.month, day.day);

    while (days.contains(day)) {
      streak++;
      day = day.subtract(Duration(days: 1));
    }
    return streak;
  }

  String formatDate(DateTime dt) {
    const months = [
      "Jan",
      "Feb",
      "Mar",
      "Apr",
      "May",
      "Jun",
      "Jul",
      "Aug",
      "Sep",
      "Oct",
      "Nov",
      "Dec",
    ];
    final dd = dt.day.toString().padLeft(2, '0');
    return "$dd ${months[dt.month - 1]} ${dt.year}";
  }

  Widget tick(bool b) =>
      Icon(b ? Icons.check_circle : Icons.radio_button_unchecked, size: 18);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Mood History")),
      body: StreamBuilder<List<MoodLog>>(
        stream: controller.streamAllMoodLogs(),
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          final moods = snap.data ?? [];

          final streak = streakDays(moods);
          final suggestion = suggest(moods);

          return ListView(
            padding: EdgeInsets.all(16),
            children: [
              StreamBuilder<Map<String, dynamic>>(
                stream: controller.streamTodayActivity(),
                builder: (context, actSnap) {
                  final data = actSnap.data ?? {};

                  final moodLog = data["moodLog"] == true;
                  final chatUsed = data["chatUsed"] == true;
                  final exerciseDone = data["exerciseDone"] == true;

                  return Card(
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Today",
                            style: TextStyle(fontWeight: FontWeight.w700),
                          ),
                          SizedBox(height: 10),

                          Row(
                            children: [
                              tick(moodLog),
                              SizedBox(width: 8),
                              Text("Mood logged"),
                            ],
                          ),
                          SizedBox(height: 6),
                          Row(
                            children: [
                              tick(chatUsed),
                              SizedBox(width: 8),
                              Text("Chat Used"),
                            ],
                          ),
                          SizedBox(height: 6),
                          Row(
                            children: [
                              tick(exerciseDone),
                              SizedBox(width: 8),
                              Text("Exercised Done"),
                            ],
                          ),
                          SizedBox(height: 12),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: [
                              OutlinedButton(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(builder: (_) => Chat()),
                                  );
                                },
                                child: Text("Talk to chatbot"),
                              ),
                              ElevatedButton(
                                onPressed: () {
                                  //navigate to exercise
                                },
                                child: Text("Do grounding exercise"),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),

              SizedBox(height: 12),
              Card(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Text(
                    "Current Streak:$streak day${streak == 1 ? '' : 's'}",
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
              ),

              if (moods.isNotEmpty && suggestion)
                Card(
                  child: Padding(
                    padding: EdgeInsetsGeometry.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Looks like you've had a few low days.",
                          style: TextStyle(fontWeight: FontWeight.w600),
                        ),
                        SizedBox(height: 8),
                        Text("Want a quick grounding exercise?"),
                        SizedBox(height: 12),
                        ElevatedButton(
                          onPressed: () {
                            //to add navigator for later
                          },
                          child: Text("Try Grounding"),
                        ),
                      ],
                    ),
                  ),
                ),
              SizedBox(height: 12),
              Text(
                "Mood Logs",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),

              ...moods.map((m) {
                final dt = m.createdAt?.toDate() ?? DateTime.now();
                return Card(
                  child: ListTile(
                    leading: Text(m.emoji, style: TextStyle(fontSize: 26)),
                    title: Text("${formatDate(dt)}.${m.moodScore}/5"),
                    subtitle: Text(m.moodLabel),
                  ),
                );
              }),
            ],
          );
        },
      ),
    );
  }
}
