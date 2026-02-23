import 'package:flutter/material.dart';
import '../controllers/mood_controller.dart';
import '../models/mood_log.dart';
import '../views/chat.dart';
import '../views/exercises.dart';
import '../controllers/progress_controller.dart';

class MoodHistory extends StatelessWidget {
  MoodHistory({super.key});

  final MoodController controller = MoodController();
  final ProgressController progressC = ProgressController();

  // --------- Helpers ----------
  DateTime dayOnly(DateTime dt) => DateTime(dt.year, dt.month, dt.day);

  bool suggest(List<MoodLog> moods) {
    if (moods.length < 3) return false;
    final recent = moods.take(3).toList();
    final lowCount = recent.where((m) => m.moodScore <= 2).length;
    return lowCount >= 2;
  }

  int streakDays(List<MoodLog> moods) {
    if (moods.isEmpty) return 0;

    final days = <DateTime>{};
    for (final m in moods) {
      final dt = m.createdAt?.toDate();
      if (dt == null) continue;
      days.add(dayOnly(dt));
    }

    int streak = 0;
    var day = dayOnly(DateTime.now());
    while (days.contains(day)) {
      streak++;
      day = day.subtract(const Duration(days: 1));
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

  // --------- Ocean theme ----------
  static const Color ocean = Color(0xFF1E88E5);
  static const Color aqua = Color(0xFF4FC3F7);
  static const Color navy = Color(0xFF0D3B66);

  ThemeData oceanTheme(BuildContext context) {
    final base = Theme.of(context);
    return base.copyWith(
      colorScheme: base.colorScheme.copyWith(
        primary: ocean,
        secondary: aqua,
        surface: Colors.white,
      ),
      scaffoldBackgroundColor: const Color(0xFFE6F4FA),
    );
  }

  Widget oceanBackground({required Widget child}) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFFE6F4FA), Color(0xFFCDEAF7), Color(0xFFB8E0F5)],
        ),
      ),
      child: child,
    );
  }

  // --------- UI bits ----------
  Widget pill(String text, {IconData? icon}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: ocean),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 14, color: navy),
            const SizedBox(width: 6),
          ],
          Text(
            text,
            style: const TextStyle(
              color: navy,
              fontWeight: FontWeight.w600,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget progressRow(bool done, String label, IconData icon) {
    return Row(
      children: [
        Icon(
          done ? Icons.check_circle : Icons.radio_button_unchecked,
          color: done ? ocean : Colors.grey,
          size: 20,
        ),
        const SizedBox(width: 10),
        Icon(icon, size: 18, color: navy),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            label,
            style: const TextStyle(color: navy, fontWeight: FontWeight.w500),
          ),
        ),
        if (done)
          const Text(
            "Done",
            style: TextStyle(color: ocean, fontWeight: FontWeight.w700),
          ),
      ],
    );
  }

  Widget sectionTitle(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.w800,
        color: navy,
      ),
    );
  }

  // --------- Main ----------
  @override
  Widget build(BuildContext context) {
    return Theme(
      data: oceanTheme(context),
      child: oceanBackground(
        child: Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            title: const Text(
              "Mood History",
              style: TextStyle(color: navy, fontWeight: FontWeight.w800),
            ),
            iconTheme: const IconThemeData(color: navy),
          ),
          body: StreamBuilder<List<MoodLog>>(
            stream: controller.streamAllMoodLogs(),
            builder: (context, snap) {
              if (snap.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              final moods = snap.data ?? [];
              final streak = streakDays(moods);
              final shouldSuggest = suggest(moods);

              return ListView(
                padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
                children: [
                  // -------- Today progress card --------
                  StreamBuilder<Map<String, dynamic>>(
                    stream: progressC.streamTodayProgress(),
                    builder: (context, actSnap) {
                      final data = actSnap.data ?? {};

                      final moodDone = data["mood"] == true;
                      final chatDone = data["chat"] == true;
                      final exercisesDone = data["exercises"] == true;

                      final total = 3;
                      final completed = [
                        moodDone,
                        chatDone,
                        exercisesDone,
                      ].where((x) => x).length;
                      final progress = completed / total;

                      return Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(18),
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [Colors.white, aqua],
                          ),
                          boxShadow: const [
                            BoxShadow(
                              color: Color.fromRGBO(0, 0, 0, 0.06),
                              blurRadius: 10,
                              offset: Offset(0, 5),
                            ),
                          ],
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  sectionTitle("Today’s Progress"),
                                  const Spacer(),
                                  pill(
                                    "$completed/$total",
                                    icon: Icons.flag_outlined,
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),

                              ClipRRect(
                                borderRadius: BorderRadius.circular(999),
                                child: LinearProgressIndicator(
                                  value: progress,
                                  minHeight: 10,
                                  backgroundColor: Colors.white,
                                  valueColor:
                                      const AlwaysStoppedAnimation<Color>(
                                        ocean,
                                      ),
                                ),
                              ),

                              const SizedBox(height: 14),
                              progressRow(
                                moodDone,
                                "Mood logged",
                                Icons.emoji_emotions_outlined,
                              ),
                              const SizedBox(height: 8),
                              progressRow(
                                chatDone,
                                "Chat used",
                                Icons.chat_bubble_outline,
                              ),
                              const SizedBox(height: 8),
                              progressRow(
                                exercisesDone,
                                "Exercise completed",
                                Icons.self_improvement,
                              ),

                              const SizedBox(height: 14),
                              Wrap(
                                spacing: 10,
                                runSpacing: 10,
                                children: [
                                  OutlinedButton.icon(
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) => Chat(),
                                        ),
                                      );
                                    },
                                    icon: const Icon(Icons.chat_bubble_outline),
                                    label: const Text("Chat"),
                                  ),
                                  OutlinedButton.icon(
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) => const Exercises(),
                                        ),
                                      );
                                    },
                                    icon: const Icon(Icons.self_improvement),
                                    label: const Text("Exercises"),
                                  ),
                                  if (!exercisesDone)
                                    ElevatedButton.icon(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: ocean,
                                        foregroundColor: Colors.white,
                                      ),
                                      onPressed: () {
                                        // Quick action: open exercises page
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (_) => const Exercises(),
                                          ),
                                        );
                                      },
                                      icon: const Icon(Icons.play_arrow),
                                      label: const Text("Do a quick calm tool"),
                                    ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 12),

                  // -------- Streak card --------
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(18),
                      color: Colors.white,
                      boxShadow: const [
                        BoxShadow(
                          color: Color.fromRGBO(0, 0, 0, 0.05),
                          blurRadius: 10,
                          offset: Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              color: aqua,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: const Icon(
                              Icons.local_fire_department,
                              color: ocean,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                sectionTitle("Streak"),
                                const SizedBox(height: 4),
                                Text(
                                  "$streak day${streak == 1 ? '' : 's'} in a row",
                                  style: const TextStyle(
                                    color: navy,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          pill("Keep going ✨"),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 12),

                  // -------- Suggestion card if low days --------
                  if (moods.isNotEmpty && shouldSuggest)
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(18),
                        color: Colors.white,
                        border: Border.all(color: ocean),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            sectionTitle("A gentle nudge 💙"),
                            const SizedBox(height: 8),
                            const Text(
                              "Looks like you’ve had a few low days recently. Want something quick to feel a little steadier?",
                              style: TextStyle(color: navy, height: 1.25),
                            ),
                            const SizedBox(height: 12),
                            ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: ocean,
                                foregroundColor: Colors.white,
                              ),
                              onPressed: () {
                                // Opens Exercises screen. If you want to auto-open grounding,
                                // you can pass initialExerciseKey: "grounding" once Exercises supports it everywhere.
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => const Exercises(),
                                  ),
                                );
                              },
                              icon: const Icon(Icons.visibility_outlined),
                              label: const Text("Try a grounding tool"),
                            ),
                          ],
                        ),
                      ),
                    ),

                  const SizedBox(height: 16),

                  // -------- Mood logs list --------
                  sectionTitle("Mood Logs"),
                  const SizedBox(height: 10),

                  if (moods.isEmpty)
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(18),
                        color: Colors.white,
                      ),
                      child: const Text(
                        "No mood logs yet. Save a mood from the dashboard to see your history here 😊",
                        style: TextStyle(color: navy),
                      ),
                    )
                  else
                    ...moods.map((m) {
                      final dt = m.createdAt?.toDate() ?? DateTime.now();

                      return Container(
                        margin: const EdgeInsets.only(bottom: 10),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(18),
                          color: Colors.white,
                          boxShadow: const [
                            BoxShadow(
                              color: Color.fromRGBO(0, 0, 0, 0.04),
                              blurRadius: 8,
                              offset: Offset(0, 4),
                            ),
                          ],
                        ),
                        child: ListTile(
                          leading: Text(
                            m.emoji,
                            style: const TextStyle(fontSize: 26),
                          ),
                          title: Text(
                            "${formatDate(dt)} • ${m.moodScore}/5",
                            style: const TextStyle(
                              color: navy,
                              fontWeight: FontWeight.w700,
                              fontSize: 14,
                            ),
                          ),
                          subtitle: Text(
                            m.moodLabel,
                            style: const TextStyle(color: Colors.black54),
                          ),
                        ),
                      );
                    }),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
