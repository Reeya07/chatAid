import 'package:flutter/material.dart';
import 'package:mental_health_app/views/grounding.dart';
import 'breathing.dart';

class Exercises extends StatelessWidget {
  final String? initialExerciseKey;
  const Exercises({super.key, this.initialExerciseKey});

  ThemeData oceanTheme(BuildContext context) {
    final base = Theme.of(context);
    return base.copyWith(
      colorScheme: base.colorScheme.copyWith(
        primary: const Color(0xFF1E88E5), // ocean blue
        secondary: const Color(0xFF4FC3F7), // aqua
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

  Widget exercise({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Color(0xE6FFFFFF),
      borderRadius: BorderRadius.circular(20),
      elevation: 2,
      shadowColor: const Color.fromRGBO(0, 0, 0, 0.08),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: Color(0xE6FFFFFF),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Icon(icon, color: const Color(0xFF0D3B66)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF0D3B66),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontSize: 13,
                        color: Color(0xFF0D3B66),
                        height: 1.25,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: Color(0xFF0D3B66)),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: oceanTheme(context),
      child: Builder(
        builder: (context) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (initialExerciseKey == null) return;

            if (initialExerciseKey == "breathing") {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const BreathingScreen()),
              );
            } else if (initialExerciseKey == "grounding") {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const GroundingScreen()),
              );
            }
          });
          return oceanBackground(
            child: Scaffold(
              backgroundColor: Colors.transparent,
              appBar: AppBar(
                backgroundColor: Colors.transparent,
                elevation: 0,
                title: const Text(
                  "Calm Tools",
                  style: TextStyle(
                    color: Color(0xFF0D3B66),
                    fontWeight: FontWeight.w700,
                  ),
                ),
                iconTheme: const IconThemeData(color: Color(0xFF0D3B66)),
              ),
              body: Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text(
                      "Pick one thing to try for a minute.",
                      style: TextStyle(color: Color(0xFF0D3B66), fontSize: 13),
                    ),
                    const SizedBox(height: 14),

                    exercise(
                      context: context,
                      icon: Icons.air,
                      title: "Breathing",
                      subtitle: "Guided breathing with timer + calm sound.",
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const BreathingScreen(),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 12),

                    exercise(
                      context: context,
                      icon: Icons.visibility_outlined,
                      title: "Grounding (5-4-3-2-1)",
                      subtitle: "Quick focus technique for anxiety/overwhelm.",
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const GroundingScreen(),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
