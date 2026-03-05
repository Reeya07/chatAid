import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../views/profile.dart';
import '../views/mood_history.dart';
import '../views/chat.dart';
import '../views/exercises.dart';
import '../views/journal.dart';
import '../controllers/mood_controller.dart';
import '../controllers/progress_controller.dart';
import '../controllers/user_controller.dart';
import '../models/mood_log.dart';
import '../models/user.dart';
import '../widgets/mood_graph.dart';
import '../widgets/plant.dart';
import '../widgets/emergencyButton.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({super.key});

  @override
  State<Dashboard> createState() => DashboardState();
}

class DashboardState extends State<Dashboard> {
  final MoodController _moodC = MoodController();
  final ProgressController _progressC = ProgressController();
  final UserController _userC = UserController();
  static const Color primary = Color(0xFF1E88E5); // ocean blue
  static const Color secondary = Color(0xFF4FC3F7);

  String userName() {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return "there";
    if ((user.displayName ?? "").isNotEmpty) return user.displayName!;

    final email = user.email ?? "";
    if (email.contains("@")) return email.split("@").first;

    return "there";
  }

  bool _saving = false;
  String? _selectedEmoji;

  final List<Map<String, String>> moods = const [
    {"emoji": "😄", "label": "happy"},
    {"emoji": "🙂", "label": "okay"},
    {"emoji": "😐", "label": "neutral"},
    {"emoji": "😢", "label": "sad"},
    {"emoji": "😡", "label": "angry"},
  ];
  int scorelabel(String label) {
    switch (label) {
      case "happy":
        return 5;
      case "okay":
        return 4;
      case "neutral":
        return 3;
      case "sad":
        return 2;
      case "angry":
        return 1;
      default:
        return 3;
    }
  }

  String timeGreet() {
    final hour = DateTime.now().hour;
    if (hour < 12) return " Good morning";
    if (hour < 17) return " Good afternoon";
    return "Good evening";
  }

  Future<void> _saveMoodLog(String emoji, String moodLabel) async {
    setState(() {
      _saving = true;
      _selectedEmoji = emoji;
    });
    try {
      await _moodC.saveMoodLog(
        MoodLog(
          emoji: emoji,
          moodLabel: moodLabel,
          moodScore: scorelabel(moodLabel),
        ),
      );
      await _progressC.markDone('mood');
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

  Widget doneDot(bool done) {
    return Container(
      width: 22,
      height: 22,
      decoration: BoxDecoration(
        color: done ? Colors.green : Colors.grey.shade300,
        shape: BoxShape.circle,
      ),
      child: Icon(
        done ? Icons.check : Icons.circle,
        size: done ? 16 : 8,
        color: done ? Colors.white : Colors.grey.shade500,
      ),
    );
  }

  Widget topHeader() {
    return StreamBuilder<AppUser>(
      stream: _userC.appUserStream(),
      builder: (context, snapshot) {
        final name = snapshot.data?.name ?? "User";

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Hi, $name 👋",
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "Welcome back to your safe space",
                    style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
                  ),
                ],
              ),
            ),
            InkWell(
              borderRadius: BorderRadius.circular(30),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const ProfileScreen()),
                );
              },
              child: Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: primary.withOpacity(0.12),
                ),
                child: Icon(Icons.account_circle, color: primary, size: 26),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget chatCard({required bool done}) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: AlignmentGeometry.bottomRight,
          colors: [primary, secondary],
        ),
        boxShadow: [
          BoxShadow(
            color: Color.fromRGBO(0, 0, 0, 0.08),
            blurRadius: 12,
            offset: Offset(0, 6),
          ),
        ],
      ),
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: Color.fromRGBO(0, 0, 0, 0.08),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(Icons.chat_bubble_outline, color: Colors.white),
              ),
              SizedBox(width: 10),
              Expanded(
                child: Text(
                  "How can I assist you today",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ),
              doneDot(done),
            ],
          ),
          SizedBox(height: 12),
          Text(
            "I am here to listen and support you 24/7 on your mental health wellness journey.",
            style: TextStyle(color: Colors.white, fontSize: 13, height: 1.3),
          ),
          SizedBox(height: 14),

          SizedBox(
            width: double.infinity,
            height: 44,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: primary,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => Chat()),
                );
              },
              child: Text("Start a chat"),
            ),
          ),
        ],
      ),
    );
  }

  Widget box({required Widget child, VoidCallback? onTap}) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      elevation: 2,
      shadowColor: Color.fromRGBO(0, 0, 0, 0.08),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(padding: EdgeInsets.all(16), child: child),
      ),
    );
  }

  Widget dailyCheckIn({required bool done}) {
    return box(
      onTap: null,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: secondary.withOpacity(0.22),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.star_border, size: 18, color: primary),
              ),
              SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Daily Check-in",
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: 6),
                    Text(
                      "How are you feeling today?",
                      style: TextStyle(color: Colors.black54, fontSize: 13),
                    ),
                  ],
                ),
              ),
              doneDot(done),
            ],
          ),
          SizedBox(height: 12),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: moods.map((mood) {
              final emoji = mood["emoji"]!;
              final label = mood["label"]!;
              final selected = _selectedEmoji == emoji;

              return GestureDetector(
                onTap: _saving ? null : () => _saveMoodLog(emoji, label),
                child: Container(
                  padding: EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: selected ? primary : Colors.transparent,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: selected ? primary : Colors.grey.shade300,
                    ),
                  ),
                  child: Text(emoji, style: TextStyle(fontSize: 26)),
                ),
              );
            }).toList(),
          ),
          SizedBox(height: 10),
          Text(
            _saving
                ? "Saving..."
                : _selectedEmoji == null
                ? "Tap an emoji to save your mood."
                : "Selected:$_selectedEmoji",
            style: TextStyle(color: Colors.black54),
          ),
        ],
      ),
    );
  }

  Widget moodGraph({required bool done}) {
    return box(
      onTap: () {},
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              TextButton(
                style: TextButton.styleFrom(foregroundColor: primary),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => MoodHistory()),
                  );
                },
                child: Text("View insights"),
              ),
              doneDot(done),
            ],
          ),
          SizedBox(height: 10),
          StreamBuilder<List<MoodLog>>(
            stream: _moodC.streamLast7Days(),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return Text("Graph error:${snapshot.error}");
              }
              if (!snapshot.hasData) {
                return Center(child: Text("Loading graph..."));
              }
              final logs = snapshot.data!;
              if (logs.isEmpty) {
                return Center(
                  child: Text("No mood data yet.Save a mood to see graph."),
                );
              }

              //mood graph suggest an exercise as needed
              return MoodGraph(
                moodLogs: logs,
                onRecommendTap: (exerciseKey) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          Exercises(initialExerciseKey: exerciseKey),
                    ),
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }

  Widget quickAccess() {
    Widget tile({
      required IconData icon,
      required String label,
      required VoidCallback onTap,
    }) {
      return Expanded(
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: Container(
            height: 86,
            margin: EdgeInsets.symmetric(horizontal: 6),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: primary, width: 1.2),
              color: Colors.white,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: secondary.withOpacity(0.22),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(icon, color: primary),
                ),
                SizedBox(height: 8),
                Text(label, style: TextStyle(fontSize: 12)),
              ],
            ),
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Quick access",
          style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
        ),
        SizedBox(height: 10),
        Row(
          children: [
            tile(
              icon: Icons.chat_bubble_outline,
              label: "Start a chat",
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => Chat()),
                );
              },
            ),
            tile(
              icon: Icons.menu_book_outlined,
              label: "Resource",
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => Exercises()),
                );
              },
            ),
            tile(
              icon: Icons.show_chart,
              label: "Tracker",
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => MoodHistory()),
                );
              },
            ),
            tile(
              icon: Icons.edit_note_rounded,
              label: "Journal",
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => JournalScreen()),
                );
              },
            ),
          ],
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF6F3FF),
      floatingActionButton: const EmergencyFab(),

      body: SafeArea(
        child: StreamBuilder<Map<String, dynamic>>(
          stream: _progressC.streamTodayProgress(),
          builder: (context, snapshot) {
            final progress = snapshot.data ?? {};

            final moodDone = progress['mood'] == true;
            final chatDone = progress['chat'] == true;
            return SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(16, 12, 16, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  topHeader(),
                  SizedBox(height: 14),
                  chatCard(done: chatDone),
                  SizedBox(height: 14),
                  dailyCheckIn(done: moodDone),
                  SizedBox(height: 14),
                  PlantCard(),
                  SizedBox(height: 22),
                  moodGraph(done: moodDone),
                  SizedBox(height: 14),
                  quickAccess(),
                  SizedBox(height: 14),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
