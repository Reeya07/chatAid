import 'dart:async';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';

class GroundingScreen extends StatefulWidget {
  const GroundingScreen({super.key});

  @override
  State<GroundingScreen> createState() => _GroundingScreenState();
}

class _GroundingScreenState extends State<GroundingScreen> {
  static const Color navy = Color(0xFF0D3B66);
  static const Color ocean = Color(0xFF1E88E5);

  // Timer
  final List<int> durations = [60, 120, 300, 600];
  int selectedSeconds = 120;
  int remainingSeconds = 120;
  Timer? _timer;
  bool running = false;

  // Audio
  final AudioPlayer player = AudioPlayer();
  bool musicOn = false;

  String selectedSoundKey = "rain";
  final Map<String, String> soundAssets = const {
    "rain": "assets/audio/rain.mp3",
    "relax": "assets/audio/relaxing.mp3",
    "meditate": "assets/audio/meditating.mp3",
  };

  // Grounding steps
  final List<_StepDef> steps = const [
    _StepDef(
      count: 5,
      title: "5 things you can see",
      icon: Icons.visibility_outlined,
      hint: "e.g., window, phone, chair",
    ),
    _StepDef(
      count: 4,
      title: "4 things you can feel",
      icon: Icons.pan_tool_outlined,
      hint: "e.g., feet on floor, shirt fabric",
    ),
    _StepDef(
      count: 3,
      title: "3 things you can hear",
      icon: Icons.hearing_outlined,
      hint: "e.g., fan, birds, traffic",
    ),
    _StepDef(
      count: 2,
      title: "2 things you can smell",
      icon: Icons.air_outlined,
      hint: "e.g., perfume, coffee",
    ),
    _StepDef(
      count: 1,
      title: "1 thing you can taste",
      icon: Icons.restaurant_outlined,
      hint: "e.g., toothpaste, tea",
    ),
  ];

  int stepIndex = 0;
  late final List<List<String>> answers; // answers per step
  final TextEditingController inputC = TextEditingController();

  @override
  void initState() {
    super.initState();
    answers = List.generate(steps.length, (_) => <String>[]);
  }

  String fmt(int s) {
    final m = (s ~/ 60).toString().padLeft(2, '0');
    final ss = (s % 60).toString().padLeft(2, '0');
    return "$m:$ss";
  }

  // ---------- UI helpers ----------
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

  Widget progressHeader() {
    final total = steps.length;
    final current = stepIndex + 1;
    final progress = current / total;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "Step $current of $total",
              style: const TextStyle(
                color: navy,
                fontWeight: FontWeight.w800,
                fontSize: 14,
              ),
            ),
            Text(
              "${(progress * 100).toInt()}%",
              style: const TextStyle(
                color: navy,
                fontWeight: FontWeight.w700,
                fontSize: 13,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        TweenAnimationBuilder<double>(
          tween: Tween(begin: 0, end: progress),
          duration: const Duration(milliseconds: 400),
          builder: (context, value, _) {
            return ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: value,
                minHeight: 6,
                backgroundColor: const Color(0x1A1E88E5),
                valueColor: const AlwaysStoppedAnimation(ocean),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget durationChips() {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      alignment: WrapAlignment.center,
      children: durations.map((sec) {
        final selected = sec == selectedSeconds;
        final label = sec == 60
            ? "1m"
            : sec == 120
            ? "2m"
            : sec == 300
            ? "5m"
            : "10m";
        return ChoiceChip(
          selected: selected,
          label: Text(label),
          onSelected: (_) => _applyDuration(sec),
          selectedColor: const Color(0x1A1E88E5),
          backgroundColor: const Color(0xE6FFFFFF),
          side: BorderSide(color: selected ? ocean : const Color(0x331E88E5)),
          labelStyle: TextStyle(
            color: navy,
            fontWeight: selected ? FontWeight.w700 : FontWeight.w600,
          ),
        );
      }).toList(),
    );
  }

  Widget soundPickerButton() {
    return TextButton.icon(
      onPressed: _openSoundPicker,
      icon: const Icon(Icons.library_music, color: navy),
      label: Text(
        "Sound: ${_soundLabel(selectedSoundKey)}",
        style: const TextStyle(color: navy, fontWeight: FontWeight.w700),
      ),
    );
  }

  // ---------- Audio ----------
  String _soundLabel(String key) {
    switch (key) {
      case "rain":
        return "Rain";
      case "relax":
        return "Relaxing";
      case "meditate":
        return "Meditation";
      default:
        return "Sound";
    }
  }

  Future<void> _loadSelectedSound() async {
    final path = soundAssets[selectedSoundKey]!;
    await player.setAsset(path);
    await player.setLoopMode(LoopMode.one);
  }

  Future<void> _startMusicIfOn() async {
    if (!musicOn) return;
    try {
      if (player.audioSource == null) {
        await _loadSelectedSound();
      }
      await player.play();
    } catch (_) {}
  }

  Future<void> _pauseMusic() async {
    try {
      await player.pause();
    } catch (_) {}
  }

  Future<void> _stopMusic() async {
    try {
      await player.stop();
    } catch (_) {}
  }

  Future<void> _changeSound(String key) async {
    setState(() => selectedSoundKey = key);

    final wasPlaying = player.playing;
    await _stopMusic();
    await player.setAudioSource(AudioSource.asset(soundAssets[key]!));
    await player.setLoopMode(LoopMode.one);

    if (musicOn && (running || wasPlaying)) {
      await player.play();
    }
  }

  void _openSoundPicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xE6FFFFFF),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
      ),
      builder: (ctx) {
        Widget tile(String key, IconData icon) {
          final selected = key == selectedSoundKey;
          return ListTile(
            leading: Icon(icon, color: navy),
            title: Text(_soundLabel(key), style: const TextStyle(color: navy)),
            trailing: selected ? const Icon(Icons.check, color: ocean) : null,
            onTap: () async {
              Navigator.pop(ctx);
              await _changeSound(key);
            },
          );
        }

        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 10),
              Container(
                width: 42,
                height: 5,
                decoration: BoxDecoration(
                  color: const Color(0x330D3B66),
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                "Choose a sound",
                style: TextStyle(color: navy, fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 8),
              tile("rain", Icons.grain),
              tile("relax", Icons.spa_outlined),
              tile("meditate", Icons.self_improvement),
              const SizedBox(height: 10),
            ],
          ),
        );
      },
    );
  }

  // ---------- Timer ----------
  void _applyDuration(int sec) async {
    _stopTimer();
    setState(() {
      selectedSeconds = sec;
      remainingSeconds = sec;
      running = false;
    });
    await _stopMusic();
  }

  void _startTimer() async {
    if (running) return;
    setState(() => running = true);
    await _startMusicIfOn();

    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) async {
      if (!mounted) return;

      if (remainingSeconds <= 1) {
        _stopTimer();
        setState(() {
          remainingSeconds = 0;
          running = false;
        });
        await _stopMusic();
        if (!mounted) return;
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text("Grounding complete ✅")));
        return;
      }

      setState(() => remainingSeconds -= 1);
    });
  }

  void _pauseTimer() async {
    _timer?.cancel();
    setState(() => running = false);
    await _pauseMusic();
  }

  void _stopTimer() {
    _timer?.cancel();
    _timer = null;
  }

  void _resetAll() async {
    _stopTimer();
    setState(() {
      running = false;
      remainingSeconds = selectedSeconds;
      stepIndex = 0;
      for (final a in answers) {
        a.clear();
      }
    });
    inputC.clear();
    await _stopMusic();
  }

  // ---------- Grounding interactions ----------
  void _addItem() {
    final txt = inputC.text.trim();
    if (txt.isEmpty) return;

    final need = steps[stepIndex].count;
    final list = answers[stepIndex];
    if (list.length >= need) return;

    setState(() => list.add(txt));
    inputC.clear();
  }

  void _removeItem(int idx) {
    setState(() => answers[stepIndex].removeAt(idx));
  }

  void _next() {
    final need = steps[stepIndex].count;
    if (answers[stepIndex].length < need) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "Add ${need - answers[stepIndex].length} more item(s) to continue.",
          ),
        ),
      );
      return;
    }
    if (stepIndex < steps.length - 1) {
      setState(() => stepIndex += 1);
      inputC.clear();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Nice work ✅ You finished the grounding steps."),
        ),
      );
    }
  }

  void _back() {
    if (stepIndex == 0) return;
    setState(() => stepIndex -= 1);
    inputC.clear();
  }

  @override
  void dispose() {
    _stopTimer();
    player.dispose();
    inputC.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final step = steps[stepIndex];
    final list = answers[stepIndex];

    return oceanBackground(
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          iconTheme: const IconThemeData(color: navy),
          title: const Text(
            "Grounding",
            style: TextStyle(color: navy, fontWeight: FontWeight.w800),
          ),
          actions: [
            IconButton(
              tooltip: "Music",
              onPressed: () async {
                setState(() => musicOn = !musicOn);
                if (musicOn && running) {
                  await _startMusicIfOn();
                } else {
                  await _pauseMusic();
                }
              },
              icon: Icon(
                musicOn ? Icons.music_note : Icons.music_off,
                color: navy,
              ),
            ),
            IconButton(
              tooltip: "Reset",
              onPressed: _resetAll,
              icon: const Icon(Icons.restart_alt, color: navy),
            ),
          ],
        ),
        body: Padding(
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
          child: Column(
            children: [
              // Timer header
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xE6FFFFFF),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: const Color(0x331E88E5)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.timer_outlined, color: navy),
                    const SizedBox(width: 10),
                    Text(
                      fmt(remainingSeconds),
                      style: const TextStyle(
                        color: navy,
                        fontWeight: FontWeight.w900,
                        fontSize: 18,
                      ),
                    ),
                    const Spacer(),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: ocean,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(22),
                        ),
                      ),
                      onPressed: running ? _pauseTimer : _startTimer,
                      child: Text(running ? "Pause" : "Start"),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),

              durationChips(),
              const SizedBox(height: 4),
              soundPickerButton(),
              const SizedBox(height: 12),

              // Step card
              Expanded(
                child: Material(
                  color: const Color(0xE6FFFFFF),
                  borderRadius: BorderRadius.circular(22),
                  elevation: 2,
                  shadowColor: const Color.fromRGBO(0, 0, 0, 0.08),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: SingleChildScrollView(
                      keyboardDismissBehavior:
                          ScrollViewKeyboardDismissBehavior.onDrag,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,

                        children: [
                          progressHeader(),
                          SizedBox(height: 14),
                          Row(
                            children: [
                              Container(
                                width: 44,
                                height: 44,
                                decoration: BoxDecoration(
                                  color: const Color(0x1A1E88E5),
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Icon(step.icon, color: navy),
                              ),
                              const SizedBox(width: 12),
                              Material(
                                child: Text(
                                  step.title,
                                  style: const TextStyle(
                                    color: navy,
                                    fontWeight: FontWeight.w900,
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                              Text(
                                "${stepIndex + 1}/${steps.length}",
                                style: const TextStyle(
                                  color: navy,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Text(
                            step.hint,
                            style: const TextStyle(color: navy, fontSize: 13),
                          ),
                          const SizedBox(height: 12),

                          // Input row
                          Row(
                            children: [
                              Expanded(
                                child: TextField(
                                  controller: inputC,
                                  onSubmitted: (_) => _addItem(),
                                  decoration: InputDecoration(
                                    hintText: "Type one item…",
                                    filled: true,
                                    fillColor: const Color(0xFFF4FBFF),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(16),
                                      borderSide: const BorderSide(
                                        color: Color(0x331E88E5),
                                      ),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(16),
                                      borderSide: const BorderSide(
                                        color: Color(0x331E88E5),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10),
                              SizedBox(
                                height: 48,
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: ocean,
                                    foregroundColor: Colors.white,
                                    elevation: 0,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                  ),
                                  onPressed: _addItem,
                                  child: const Text("Add"),
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 12),

                          // Chips list
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: List.generate(list.length, (i) {
                              return InputChip(
                                label: Text(list[i]),
                                onDeleted: () => _removeItem(i),
                                deleteIconColor: navy,
                                backgroundColor: const Color(0x1A1E88E5),
                                labelStyle: const TextStyle(
                                  color: navy,
                                  fontWeight: FontWeight.w700,
                                ),
                              );
                            }),
                          ),

                          SizedBox(height: 10),

                          // Back/Next
                          Row(
                            children: [
                              Material(
                                child: OutlinedButton(
                                  onPressed: stepIndex == 0 ? null : _back,
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: navy,
                                    side: const BorderSide(
                                      color: Color(0x331E88E5),
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(18),
                                    ),
                                    backgroundColor: const Color(0xE6FFFFFF),
                                  ),
                                  child: const Text(
                                    "Back",
                                    style: TextStyle(
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(width: 10),
                              Material(
                                child: ElevatedButton(
                                  onPressed: _next,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: ocean,
                                    foregroundColor: Colors.white,
                                    elevation: 0,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(18),
                                    ),
                                  ),
                                  child: Text(
                                    stepIndex == steps.length - 1
                                        ? "Finish"
                                        : "Next",
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StepDef {
  final int count;
  final String title;
  final IconData icon;
  final String hint;
  const _StepDef({
    required this.count,
    required this.title,
    required this.icon,
    required this.hint,
  });
}
