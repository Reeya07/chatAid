import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../controllers/user_controller.dart';
import '../models/user.dart';
import '../services/notification_service.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  static const Color primary = Color(0xFF1E88E5);
  final UserController _userC = UserController();
  bool notificationsEnabled = true;

  @override
  void initState() {
    super.initState();
    _loadPrefs();
  }

  Future<void> _loadPrefs() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null || user.isAnonymous) return;
    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .get();
    final data = doc.data() ?? {};
    if (mounted) {
      setState(() {
        notificationsEnabled = data['notificationsEnabled'] ?? true;
      });
    }
  }

  Future<void> _saveNotificationPref(bool value) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    setState(() => notificationsEnabled = value);
    if (value) {
      await NotificationService.scheduleDailyReminder();
    } else {
      await NotificationService.cancelDailyReminder();
    }
    await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .set({'notificationsEnabled': value}, SetOptions(merge: true));
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          value ? 'Daily reminder set' : 'Notifications disabled',
        ),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  Future<void> _showEmergencyContactDialog() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .get();
    final existing =
        (doc.data() ?? {})['emergencyContact'] as Map<String, dynamic>? ?? {};

    final nameCtrl =
        TextEditingController(text: existing['name']?.toString() ?? '');
    final phoneCtrl =
        TextEditingController(text: existing['phone']?.toString() ?? '');

    if (!mounted) return;
    await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Emergency Contact'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameCtrl,
              decoration: const InputDecoration(
                labelText: 'Contact Name',
                prefixIcon: Icon(Icons.person_outline),
              ),
              textCapitalization: TextCapitalization.words,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: phoneCtrl,
              decoration: const InputDecoration(
                labelText: 'Phone Number',
                prefixIcon: Icon(Icons.phone_outlined),
              ),
              keyboardType: TextInputType.phone,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: primary),
            onPressed: () async {
              await FirebaseFirestore.instance
                  .collection('users')
                  .doc(user.uid)
                  .set(
                {
                  'emergencyContact': {
                    'name': nameCtrl.text.trim(),
                    'phone': phoneCtrl.text.trim(),
                  }
                },
                SetOptions(merge: true),
              );
              if (!ctx.mounted) return;
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Emergency contact saved'),
                  duration: Duration(seconds: 2),
                ),
              );
            },
            child: const Text('Save', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showInfoDialog(String title, String content) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(title),
        content: SingleChildScrollView(child: Text(content)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    // Not logged in at all
    if (user == null) {
      return Scaffold(
        appBar: AppBar(title: const Text("Profile")),
        body: Center(
          child: ElevatedButton(
            onPressed: () {
              Navigator.pushNamed(context, 'views/login');
            },
            child: const Text("Log in"),
          ),
        ),
      );
    }

    // Anonymous user -> show sign-up prompt
    if (user.isAnonymous) {
      return Scaffold(
        backgroundColor: const Color(0xFFF6F3FF),
        appBar: AppBar(
          backgroundColor: primary,
          title: const Text("Profile & Settings"),
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.lock_outline, size: 56, color: primary),
                const SizedBox(height: 16),
                const Text(
                  "Sign up to access your profile",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF0D3B66),
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                const Text(
                  "Create a free account to save your data, track your progress, and personalise your experience.",
                  style: TextStyle(color: Color(0xFF0D3B66), height: 1.4),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(22),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    onPressed: () => Navigator.pushReplacementNamed(
                      context,
                      "views/register",
                    ),
                    child: const Text("Sign up"),
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: TextButton(
                    onPressed: () async {
                      await FirebaseAuth.instance.signOut();
                      if (!context.mounted) return;
                      Navigator.pushNamedAndRemoveUntil(
                        context,
                        "views/login",
                        (r) => false,
                      );
                    },
                    child: const Text(
                      "Exit guest mode",
                      style: TextStyle(color: Colors.black54),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF6F3FF),
      appBar: AppBar(
        backgroundColor: primary,
        title: const Text("Profile & Settings"),
      ),
      body: StreamBuilder<AppUser>(
        stream: _userC.appUserStream(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          }
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final appUser = snapshot.data!;
          final name = appUser.name;
          final email = appUser.email;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(18),
                    boxShadow: const [
                      BoxShadow(
                        color: Color.fromRGBO(0, 0, 0, 0.06),
                        blurRadius: 10,
                        offset: Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 28,
                        backgroundColor: primary.withOpacity(0.15),
                        child: Icon(Icons.person, color: primary),
                      ),
                      const SizedBox(width: 16),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            name,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            email,
                            style: TextStyle(color: Colors.grey.shade600),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                const Text(
                  "Settings",
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 12),

                _settingTile(
                  icon: Icons.notifications_outlined,
                  title: "Notifications",
                  trailing: Switch(
                    value: notificationsEnabled,
                    activeThumbColor: primary,
                    onChanged: _saveNotificationPref,
                  ),
                ),

                _settingTile(
                  icon: Icons.warning_amber_outlined,
                  title: "Emergency Contact",
                  onTap: _showEmergencyContactDialog,
                ),

                _settingTile(
                  icon: Icons.lock_outline,
                  title: "Privacy & Security",
                  onTap: () => _showInfoDialog(
                    'Privacy & Security',
                    'Your data is encrypted and stored securely. We never share your personal information with third parties.\n\n'
                        '• All journal entries are private to your account.\n'
                        '• Mood data is only visible to you.\n'
                        '• You can delete your account and all associated data at any time.\n\n'
                        'For security, use a strong password and keep your account credentials private.',
                  ),
                ),

                const SizedBox(height: 24),

                const Text(
                  "Legal",
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 12),

                _settingTile(
                  icon: Icons.description_outlined,
                  title: "Privacy Policy",
                  onTap: () => _showInfoDialog(
                    'Privacy Policy',
                    'Effective date: January 1, 2025\n\n'
                        'We collect only the information necessary to provide the Mental Health App experience, '
                        'including your name, email address, journal entries, and mood logs.\n\n'
                        'Your data is stored securely using Firebase services and is never sold or shared with '
                        'advertisers or third parties.\n\n'
                        'You may request deletion of your account and all associated data at any time by contacting support.\n\n'
                        'By using this app you agree to this policy.',
                  ),
                ),

                _settingTile(
                  icon: Icons.article_outlined,
                  title: "Terms of Service",
                  onTap: () => _showInfoDialog(
                    'Terms of Service',
                    'By using Mental Health App you agree to the following:\n\n'
                        '1. This app is for personal wellness tracking only and is not a substitute for professional mental health care.\n\n'
                        '2. You are responsible for maintaining the confidentiality of your account credentials.\n\n'
                        '3. You agree not to misuse the app or attempt to access other users\' data.\n\n'
                        '4. We reserve the right to update these terms at any time. Continued use constitutes acceptance.\n\n'
                        'If you are in crisis, please contact a licensed professional or emergency services immediately.',
                  ),
                ),

                const SizedBox(height: 30),

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    onPressed: () async {
                      await FirebaseAuth.instance.signOut();
                      if (!context.mounted) return;
                      Navigator.pushNamedAndRemoveUntil(
                        context,
                        "views/login",
                        (_) => false,
                      );
                    },
                    child: const Text("Logout"),
                  ),
                ),

                const SizedBox(height: 20),

                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF1E88E5), Color(0xFF4FC3F7)],
                    ),
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: const Column(
                    children: [
                      Text(
                        "\"It's okay to not be okay.\"",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        "Taking care of your mental health is a journey.",
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.white70),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _settingTile({
    required IconData icon,
    required String title,
    Widget? trailing,
    VoidCallback? onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: ListTile(
        leading: Icon(icon, color: primary),
        title: Text(title),
        trailing: trailing ?? const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: onTap,
      ),
    );
  }
}

