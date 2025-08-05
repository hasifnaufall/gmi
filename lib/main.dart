import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'login.dart';
import 'quiz_category.dart';
import 'quiz.dart';
import 'profile.dart';
import 'quest.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const WaveActApp());
}

class WaveActApp extends StatelessWidget {
  const WaveActApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'WaveAct',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        fontFamily: 'Arial',
      ),
      initialRoute: '/login', // ✅ First screen
      routes: {
        '/login': (context) => const LoginScreen(),
        '/profile': (context) => const ProfileScreen(),
        '/quiz': (context) => const QuizScreen(),
        '/quests': (context) => const QuestScreen(),
        // You can also add '/home': (_) => HomePage() if you want to push there after login
      },
    );
  }
}
