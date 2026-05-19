import 'package:flutter/material.dart';
import 'dashboard.dart';
import 'chat.dart';
import 'exercises.dart';
import 'mood_history.dart';
import 'journal.dart';

class MainNav extends StatefulWidget {
  final int initialIndex;

  const MainNav({super.key, this.initialIndex = 0});

  @override
  State<MainNav> createState() => _MainNavState();
}

class _MainNavState extends State<MainNav> {
  late int _currentIndex;

  final List<Widget> _pages = [
    Dashboard(),
    Chat(),
    Exercises(),
    MoodHistory(),
    JournalScreen(),
  ];
  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: _pages),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        type: BottomNavigationBarType.fixed,
        selectedItemColor: const Color(0xFF1E88E5),
        unselectedItemColor: Colors.black54,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_rounded),
            label: "Home",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.chat_bubble_outline),
            label: "Chat",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.self_improvement),
            label: "Exercises",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.show_chart),
            label: "Tracker",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.edit_note_rounded),
            label: "Journal",
          ),
        ],
      ),
    );
  }
}
