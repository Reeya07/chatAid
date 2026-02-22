import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'views/nav.dart';
import 'views/mood_history.dart';
import 'views/login.dart';
import 'views/register.dart';
import 'views/chat.dart';
import 'views/dashboard.dart';
import 'views/cbt_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: 'views/nav',
      routes: {
        'views/chat': (context) => Chat(),
        'views/login': (context) => Login(),
        'views/register': (context) => Register(),
        'views/dashboard': (context) => Dashboard(),
        'views/CbtScreen': (context) => CbtScreen(),
        'views/moodHistory': (context) => MoodHistory(),
        'views/nav': (context) => MainNav(),
      },
    );
  }
}
