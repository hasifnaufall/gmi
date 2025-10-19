import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'firebase_options.dart';
import 'package:responsive_framework/responsive_framework.dart';
import 'login.dart';
import 'quiz_category.dart';
import 'quiz.dart';
import 'profile.dart';
import 'quest.dart';
import 'quest_status.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const WaveActApp());
}

class WaveActApp extends StatelessWidget {
  const WaveActApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'WaveAct',
      theme: ThemeData(primarySwatch: Colors.blue, fontFamily: 'Arial'),
      builder: (context, child) => ResponsiveBreakpoints.builder(
        child: child!,
        breakpoints: [
          const Breakpoint(start: 0, end: 450, name: MOBILE),
          const Breakpoint(start: 451, end: 800, name: TABLET),
          const Breakpoint(start: 801, end: 1920, name: DESKTOP),
          const Breakpoint(start: 1921, end: double.infinity, name: '4K'),
        ],
      ),
      home: const SplashScreen(),
      routes: {
        '/login': (context) => const LoginScreen(),
        '/profile': (context) => const ProfileScreen(),
        '/quiz': (context) => const QuizScreen(),
        '/quests': (context) => const QuestScreen(),
      },
    );
  }
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();

    Future.delayed(const Duration(seconds: 2), () async {
      final user = FirebaseAuth.instance.currentUser;

      if (user == null) {
        // Reset quest status if no user is logged in
        QuestStatus.resetToDefaults();
        QuestStatus.clearCurrentUser();
      } else {
        // Load progress for the current user
        try {
          await QuestStatus.loadProgressForUser(user.uid);
          print('Progress loaded for persistent user: ${user.uid}');
        } catch (e) {
          print('Error loading progress for persistent user: $e');
        }
      }

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) =>
              user != null ? QuizCategoryScreen() : const LoginScreen(),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Image(image: AssetImage('assets/images/logo.png'), width: 180),
      ),
    );
  }
}
