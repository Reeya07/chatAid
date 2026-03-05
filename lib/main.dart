import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'views/nav.dart';
import 'views/mood_history.dart';
import 'views/login.dart';
import 'views/register.dart';
import 'views/chat.dart';
import 'views/dashboard.dart';
import 'views/cbt_screen.dart';
import 'views/journal.dart';
import 'views/journal_history.dart';
import 'services/encrypt.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await CryptoService.instance.init();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }
          if (snapshot.hasData) {
            return MainNav();
          }
          return Login();
        },
      ),
      routes: {
        'views/chat': (context) => Chat(),
        'views/login': (context) => Login(),
        'views/register': (context) => Register(),
        'views/dashboard': (context) => Dashboard(),
        'views/CbtScreen': (context) => CbtScreen(),
        'views/moodHistory': (context) => MoodHistory(),
        'views/nav': (context) => MainNav(),
        'views/journal': (context) => JournalScreen(),
        'views/journalHistory': (context) => JournalHistoryScreen(),
      },
    );
  }
}
