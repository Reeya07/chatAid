import 'package:flutter/material.dart';
import '../controllers/journal_controller.dart';
import '../models/journal_info.dart';
import 'cbt_screen.dart';
import 'dart:ui';

class JournalScreen extends StatefulWidget {
  const JournalScreen({super.key});

  @override
  State<JournalScreen> createState() => _JournalScreenState();
}

class _JournalScreenState extends State<JournalScreen> {
  final _textC = TextEditingController();
  final _journal = JournalController();
  bool _saving = false;

  @override
  void dispose() {
    _textC.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final text = _textC.text.trim();
    if (text.isEmpty || _saving) return;

    setState(() => _saving = true);
    try {
      await _journal.saveJournalLog(JournalLog(text: text));
      if (!mounted) return;
      _textC.clear();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Saved safely to your Ocean Journal 🌊")),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("$e")));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _saveAndOpenCbt() async {
    final text = _textC.text.trim();
    if (text.isEmpty || _saving) return;

    setState(() => _saving = true);
    try {
      await _journal.saveJournalLog(JournalLog(text: text));
      if (!mounted) return;

      // Open CBT with the same text
      await Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => CbtScreen(initialThought: text)),
      );

      // optional: clear after returning from CBT
      if (!mounted) return;
      _textC.clear();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("$e")));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          // 🌊 Ocean background
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xFF4FC3F7), Color.fromARGB(255, 6, 86, 157)],
              ),
            ),
          ),

          // subtle light "rays" glow
          Positioned(
            top: -120,
            left: -80,
            child: Container(
              width: 260,
              height: 260,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.10),
              ),
            ),
          ),
          Positioned(
            top: 80,
            right: -120,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.08),
              ),
            ),
          ),

          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(18, 10, 18, 16),
              child: Column(
                children: [
                  // Top bar
                  Row(
                    children: [
                      IconButton(
                        onPressed: () {
                          if (Navigator.of(context).canPop()) {
                            Navigator.pop(context);
                          } else {
                            Navigator.pushNamedAndRemoveUntil(
                              context,
                              'views/nav',
                              (route) => false,
                            );
                          }
                        },
                        icon: const Icon(Icons.arrow_back_ios_new_rounded),
                        color: Colors.white,
                      ),
                      const SizedBox(width: 6),
                      const Text(
                        "Ocean Journal",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const Spacer(),
                      IconButton(
                        onPressed: () => Navigator.pushNamed(
                          context,
                          'views/journalHistory',
                        ),
                        icon: const Icon(Icons.bubble_chart_outlined),
                        color: Colors.white,
                        tooltip: "Floating Thoughts",
                      ),
                    ],
                  ),

                  const SizedBox(height: 8),

                  // Cozy header text
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      "Let your thoughts drift safely.",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      "No pressure. Just type what’s in your mind.",
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                        height: 1.4,
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Glass card that "surrounds" the user
                  Flexible(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(26),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(26),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.18),
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // optional small prompt chip
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 8,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.14),
                                  borderRadius: BorderRadius.circular(18),
                                ),
                                child: const Text(
                                  "Prompt: What’s weighing on you today?",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 12.5,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 12),

                              // Soft writing area (not a harsh big square)
                              Expanded(
                                child: Container(
                                  padding: const EdgeInsets.all(14),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.10),
                                    borderRadius: BorderRadius.circular(18),
                                  ),
                                  child: TextField(
                                    controller: _textC,
                                    maxLines: null,
                                    expands: true,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                      height: 1.45,
                                    ),
                                    decoration: const InputDecoration(
                                      hintText:
                                          "Type here…\n\n(Everything is saved safely. )",
                                      hintStyle: TextStyle(
                                        color: Colors.white60,
                                        height: 1.4,
                                      ),
                                      border: InputBorder.none,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),

                  // Bottom comfy action area
                  AnimatedPadding(
                    duration: const Duration(milliseconds: 150),
                    padding: EdgeInsets.only(top: 14, bottom: 6 + bottomInset),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton(
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: Colors.white,
                                  side: BorderSide(
                                    color: Colors.white.withOpacity(0.35),
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(22),
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 14,
                                  ),
                                ),
                                onPressed: () => Navigator.pushNamed(
                                  context,
                                  'views/journalHistory',
                                ),
                                child: const Text("Floating Thoughts 🫧"),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.white,
                                  foregroundColor: const Color(0xFF0D3B66),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(22),
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 14,
                                  ),
                                  elevation: 0,
                                ),
                                onPressed: _saving ? null : _save,
                                child: Text(
                                  _saving ? "Saving..." : "Save to Ocean 🌊",
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 10),

                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white.withOpacity(0.16),
                              foregroundColor: Colors.white,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(22),
                                side: BorderSide(
                                  color: Colors.white.withOpacity(0.22),
                                ),
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 14),
                            ),
                            onPressed: _saving ? null : _saveAndOpenCbt,
                            icon: const Icon(Icons.psychology_alt_rounded),
                            label: Text(
                              _saving
                                  ? "Saving..."
                                  : "Save + CBT Reflection 🧠",
                              style: const TextStyle(
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
