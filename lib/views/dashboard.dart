import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'chat.dart';
import '../controllers/mood_controller.dart';
import '../models/mood_log.dart';
import '../widgets/mood_graph.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({super.key});

  @override
  State<Dashboard> createState() => DashboardState();
}

class DashboardState extends State<Dashboard> {
  final MoodController _moodC = MoodController();

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

  Widget topHeader() {
    final name = userName();
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: Colors.purple, width: 2),
          ),
          child: Icon(Icons.favorite, color: Colors.purple),
        ),
        SizedBox(width: 12),
        Expanded(
          child: Column(
            children: [
              Text(
                "Hi $name,Welcome to your",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),
            ],
          ),
        ),
        SizedBox(width: 12),
        Text(
          "Mental Health Companion",
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
      ],
    );
  }

  Widget chatCard() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: AlignmentGeometry.bottomRight,
          colors: [Color.fromARGB(255, 150, 110, 218), Color(0xFF6F8BFF)],
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
                  "How can I assist tou today",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ),
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
                foregroundColor: Colors.black87,
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

  Widget dailyCheckIn() {
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
                  color: Colors.grey.shade200,
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.star_border, size: 18),
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
                    color: selected ? Colors.purple : Colors.transparent,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: selected ? Colors.purple : Colors.grey.shade300,
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

  Widget moodGraph() {
    return box(
      onTap: () {},
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  "Your mood this week",
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                ),
              ),
              TextButton(onPressed: () {}, child: Text("View insights")),
            ],
          ),
          SizedBox(height: 10),
          SizedBox(
            height: 200,
            child: StreamBuilder<List<MoodLog>>(
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
                return MoodGraph(moodLogs: logs);
              },
            ),
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
              border: Border.all(color: Colors.purple, width: 1.2),
              color: Colors.white,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Color.fromRGBO(128, 0, 128, 0.12),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(icon, color: Colors.purple),
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
              onTap: () {},
            ),
            tile(icon: Icons.show_chart, label: "Tracker", onTap: () {}),
          ],
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF6F3FF),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(16, 12, 16, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              topHeader(),
              SizedBox(height: 14),
              chatCard(),
              SizedBox(height: 14),
              dailyCheckIn(),
              SizedBox(height: 14),
              moodGraph(),
              SizedBox(height: 14),
              quickAccess(),
              SizedBox(height: 14),
            ],
          ),
        ),
      ),
    );
  }
}
