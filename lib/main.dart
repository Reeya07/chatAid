import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'views/login.dart';
import 'views/register.dart';
import 'views/chat.dart';

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
      initialRoute: 'views/login',
      routes: {
        'views/chat': (context) => Chat(),
        'views/login': (context) => Login(),
        'views/register': (context) => Register(),
      },
    );
  }
}
