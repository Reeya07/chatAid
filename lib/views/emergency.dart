import 'package:flutter/material.dart';
import 'dart:async';
import 'package:url_launcher/url_launcher.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class EmergencyScreen extends StatefulWidget {
  const EmergencyScreen({super.key});

  @override
  State<EmergencyScreen> createState() => _EmergencyScreenState();
}

class _EmergencyScreenState extends State<EmergencyScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  String? _personalContactName;
  String? _personalContactPhone;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
      lowerBound: 0.85,
      upperBound: 1.15,
    )..repeat(reverse: true);
    _loadPersonalContact();
  }

  Future<void> _loadPersonalContact() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null || user.isAnonymous) return;
    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .get();
    final contact =
        (doc.data() ?? {})['emergencyContact'] as Map<String, dynamic>? ?? {};
    final name = contact['name']?.toString().trim() ?? '';
    final phone = contact['phone']?.toString().trim() ?? '';
    if (name.isNotEmpty && phone.isNotEmpty && mounted) {
      setState(() {
        _personalContactName = name;
        _personalContactPhone = phone;
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _callNumber(String number) async {
    final Uri uri = Uri(scheme: 'tel', path: number);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Support"),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      extendBodyBehindAppBar: true,
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF6EC6FF), Color(0xFF4A90E2)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const SizedBox(height: 20),

                Column(
                  children: const [
                    Text(
                      "Pause. Breathe with me.",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      "This moment will pass.",
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 16, color: Colors.white70),
                    ),
                  ],
                ),

                ScaleTransition(
                  scale: _controller,
                  child: Container(
                    width: 160,
                    height: 160,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.25),
                      shape: BoxShape.circle,
                    ),
                  ),
                ),

                Column(
                  children: [
                    // Befrienders Mauritius — always shown
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () => _callNumber("8009393"),
                        icon: const Icon(Icons.phone),
                        label: const Text("Befrienders Mauritius"),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: const Color(0xFF4A90E2),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                      ),
                    ),

                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () => _callNumber("188"),
                        icon: const Icon(Icons.phone),
                        label: const Text("Life Plus(24/7)"),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: const Color(0xFF4A90E2),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                      ),
                    ),

                    const SizedBox(height: 12),

                    // Personal contact — shown only if saved in profile
                    if (_personalContactName != null)
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: () => _callNumber(_personalContactPhone!),
                          icon: const Icon(Icons.person),
                          label: Text("Call $_personalContactName"),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white.withOpacity(0.85),
                            foregroundColor: const Color(0xFF4A90E2),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                        ),
                      ),

                    if (_personalContactName == null)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Text(
                          "Add a personal emergency contact in Profile > Settings",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.7),
                            fontSize: 12,
                          ),
                        ),
                      ),

                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Colors.white),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        child: const Text("Close"),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
