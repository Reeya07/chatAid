import 'dart:math';
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:just_audio/just_audio.dart';
import '../controllers/progress_controller.dart';

class BreathingScreen extends StatefulWidget {
  const BreathingScreen({super.key});

  @override
  State<BreathingScreen> createState() => _BreathingScreenState();
}

class _BreathingScreenState extends State<BreathingScreen>
    with SingleTickerProviderStateMixin {
  static const Color navy = Color(0xFF0D3B66);
  static const Color ocean = Color(0xFF1E88E5);

  final ProgressController _progressC = ProgressController();

  late final AnimationController breathCtrl;
  late final Animation<double> scale;
  final AudioPlayer player = AudioPlayer();

  String selectedSoundKey = "rain";

  final Map<String, String> soundAssets = const {
    "rain": "assets/audio/rain.mp3",
    "relax": "assets/audio/relaxing.mp3",
    "meditate": "assets/audio/meditating.mp3",
  };

  Future<void> loadSelectedSound() async {
    final path = soundAssets[selectedSoundKey]!;
    await player.setAsset(path);
    await player.setLoopMode(LoopMode.one);
  }

  Future<void> startMusicIfOn() async {
    if (!musicOn) return;
    try {
      if (player.audioSource == null) {
        await loadSelectedSound();
      }
      await player.play();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Audio error: $e")));
    }
  }

  Future<void> pauseMusic() async {
    try {
      await player.pause();
    } catch (_) {}
  }

  Future<void> stopMusic() async {
    try {
      await player.stop();
    } catch (_) {}
  }

  Future<void> changeSound(String key) async {
    setState(() => selectedSoundKey = key);

    // If music is on, switch immediately
    final wasPlaying = player.playing;
    await stopMusic();
    await player.setAudioSource(AudioSource.asset(soundAssets[key]!));
    await player.setLoopMode(LoopMode.one);

    if (musicOn && (running || wasPlaying)) {
      await player.play();
    }
  }

  String _soundLabel(String key) {
    switch (key) {
      case "rain":
        return "Rain";
      case "relax":
        return "relaxing";
      case "meditate":
        return "meditating";
      default:
        return "Sound";
    }
  }

  void openSoundPicker() {
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
              await changeSound(key); // ✅ this must exist from Step 6C
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

  String phase = "Ready"; // Inhale / Hold / Exhale / Ready
  int phaseIndex = 0;

  // Balanced pattern (seconds):
  final List<Map<String, dynamic>> pattern = const [
    {"label": "Inhale", "seconds": 4},
    {"label": "Hold", "seconds": 2},
    {"label": "Exhale", "seconds": 6},
  ];

  @override
  void initState() {
    super.initState();

    breathCtrl = AnimationController(
      vsync: this,
      duration: Duration(seconds: 4),
    );

    scale = Tween<double>(
      begin: 0.92,
      end: 1.06,
    ).animate(CurvedAnimation(parent: breathCtrl, curve: Curves.easeInOut));

    // Start in a calm idle state (not moving)
    breathCtrl.value = 0.0;
  }

  void _startBreathing() {
    phaseIndex = 0;
    runPhase();
  }

  void _pauseBreathing() {
    pauseMusic();
    breathCtrl.stop();
  }

  void _resetBreathing() {
    breathCtrl.stop();
    breathCtrl.value = 0.0;
    setState(() => phase = "Ready");
  }

  void runPhase() {
    if (!mounted || !running) return;

    final current = pattern[phaseIndex];
    final label = current["label"] as String;
    final secs = current["seconds"] as int;

    setState(() => phase = label);

    if (label == "Inhale") {
      breathCtrl.duration = Duration(seconds: secs);
      breathCtrl.forward(from: 0.0).whenComplete(() {
        phaseIndex = (phaseIndex + 1) % pattern.length;
        runPhase();
      });
    } else if (label == "Exhale") {
      breathCtrl.duration = Duration(seconds: secs);
      breathCtrl.reverse(from: 1.0).whenComplete(() {
        phaseIndex = (phaseIndex + 1) % pattern.length;
        runPhase();
      });
    } else {
      // Hold phase: keep current scale still for secs
      Future.delayed(Duration(seconds: secs), () {
        if (!mounted || !running) return;
        phaseIndex = (phaseIndex + 1) % pattern.length;
        runPhase();
      });
    }
  }

  final List<int> durations = [60, 120, 300, 600];
  int selectedSeconds = 120;
  int remainingSeconds = 120;
  int elapsedSeconds = 0;

  Timer? _timer;
  bool running = false;
  bool musicOn = false;

  String fmt(int s) {
    final m = (s ~/ 60).toString().padLeft(2, '0');
    final ss = (s % 60).toString().padLeft(2, '0');
    return "$m:$ss";
  }

  void _applyDuration(int seconds) async {
    _stopTimer();
    setState(() {
      selectedSeconds = seconds;
      remainingSeconds = seconds;
      elapsedSeconds = 0;
      running = false;
    });
    await stopMusic();
    _resetBreathing();
  }

  void _startTimer() {
    if (running) return;
    setState(() => running = true);
    _startBreathing();
    startMusicIfOn();

    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;

      if (remainingSeconds <= 1) {
        _stopTimer();
        setState(() {
          remainingSeconds = 0;
          elapsedSeconds = selectedSeconds;
          running = false;
        });
        stopMusic();
        _resetBreathing();
        _progressC.markDone('exercises');

        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text("Session complete ")));
        return;
      }

      setState(() {
        remainingSeconds -= 1;
        elapsedSeconds += 1;
      });
    });
  }

  void _pauseTimer() {
    _timer?.cancel();
    setState(() => running = false);
    _pauseBreathing();
    pauseMusic();
  }

  void _stopTimer() {
    _timer?.cancel();
    _timer = null;
  }

  void _resetTimer() async {
    _stopTimer();
    setState(() {
      running = false;
      remainingSeconds = selectedSeconds;
      elapsedSeconds = 0;
    });
    await stopMusic();
    _resetBreathing();
  }

  @override
  void dispose() {
    _stopTimer();
    breathCtrl.dispose();
    player.dispose();
    super.dispose();
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

          selectedColor: Color(0x1A1E88E5),
          backgroundColor: Color(0xE6FFFFFF),
          side: BorderSide(color: selected ? ocean : Color(0x331E88E5)),
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
      onPressed: openSoundPicker,
      icon: const Icon(Icons.library_music, color: navy),
      label: Text(
        "Sound: ${_soundLabel(selectedSoundKey)}",
        style: const TextStyle(color: navy, fontWeight: FontWeight.w700),
      ),
    );
  }

  Widget dotRing({
    required int dotCount,
    required int filled,
    required double radius,
  }) {
    return SizedBox(
      width: radius * 2 + 40,
      height: radius * 2 + 40,
      child: Stack(
        alignment: Alignment.center,
        children: List.generate(dotCount, (i) {
          final ang = (2 * pi * i) / dotCount - pi / 2;
          final dx = radius * cos(ang);
          final dy = radius * sin(ang);

          final active = i < filled;
          final size = active ? 7.0 : 6.0;

          return Transform.translate(
            offset: Offset(dx, dy),
            child: Container(
              width: size,
              height: size,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: active ? ocean : Color(0xFFD6ECF8),
              ),
            ),
          );
        }),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final remaining = remainingSeconds;
    final dotCount = 60;

    final progress = selectedSeconds == 0
        ? 0.0
        : (elapsedSeconds / selectedSeconds);
    final filled = (progress * dotCount)
        .clamp(0.0, dotCount.toDouble())
        .floor();

    return oceanBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          iconTheme: const IconThemeData(color: navy),
          title: const Text(
            "Breathing",
            style: TextStyle(color: navy, fontWeight: FontWeight.w800),
          ),
          actions: [
            IconButton(
              tooltip: "Music",
              onPressed: () async {
                setState(() => musicOn = !musicOn);
                if (musicOn) {
                  await startMusicIfOn();
                } else {
                  await pauseMusic();
                }
              },
              icon: Icon(
                musicOn ? Icons.music_note : Icons.music_off,
                color: navy,
              ),
            ),
          ],
        ),
        body: Padding(
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
          child: Column(
            children: [
              const Text(
                "Follow the circle. Stay gentle with yourself.",
                style: TextStyle(color: navy, fontSize: 13),
              ),
              const SizedBox(height: 18),

              Expanded(
                child: Center(
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      dotRing(dotCount: dotCount, filled: filled, radius: 135),

                      // Center orb
                      ScaleTransition(
                        scale: scale,
                        child: Container(
                          width: 180,
                          height: 180,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Color(0x334FC3F7),
                            boxShadow: const [
                              BoxShadow(
                                color: Color.fromRGBO(0, 0, 0, 0.10),
                                blurRadius: 18,
                                offset: Offset(0, 10),
                              ),
                            ],
                            border: Border.all(
                              color: Color(0x334FC3F7),
                              width: 2,
                            ),
                          ),
                          child: Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  fmt(remaining),
                                  style: const TextStyle(
                                    fontSize: 36,
                                    fontWeight: FontWeight.w900,
                                    color: Color(0xFF0D3B66),
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  phase,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                    color: Color(0xFF0D3B66),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              durationChips(),
              soundPickerButton(),
              const SizedBox(height: 14),

              Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 52,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: ocean,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(26),
                          ),
                        ),
                        onPressed: () {
                          if (running) {
                            _pauseTimer();
                          } else {
                            _startTimer();
                          }
                        },
                        child: Text(
                          running ? "Pause" : "Start Session",
                          style: const TextStyle(fontWeight: FontWeight.w800),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  SizedBox(
                    height: 52,
                    width: 90,
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: navy,
                        side: const BorderSide(color: Color(0x331E88E5)),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(26),
                        ),
                        backgroundColor: const Color(0xE6FFFFFF),
                      ),
                      onPressed: _resetTimer,
                      child: const Text(
                        "Reset",
                        style: TextStyle(fontWeight: FontWeight.w800),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
