// lib/main.dart
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:responsive_framework/responsive_framework.dart';
import 'package:google_fonts/google_fonts.dart';

// Audio
import 'package:audioplayers/audioplayers.dart';

// Your files
import 'firebase_options.dart';
import 'login.dart';
import 'quiz_category.dart';
import 'quiz.dart';
import 'profile.dart';
import 'quest.dart';
import 'leaderboard.dart';
import 'quest_status.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const WaveActApp());
}

/// =====================================================
/// SFX helper (quiz complete + streak)
/// IMPORTANT: pubspec.yaml lists:
///   - audio/streak.wav
///   - audio/level_complete.wav
/// So we load AssetSource('audio/....wav') here.
/// =====================================================
class Sfx {
  Sfx._();
  static final Sfx I = Sfx._();

  final AudioPlayer _quizPlayer = AudioPlayer(playerId: 'sfx_quiz');
  final AudioPlayer _streakPlayer = AudioPlayer(playerId: 'sfx_streak');

  bool _initialized = false;

  Future<void> _init() async {
    if (_initialized) return;

    // Ensure one-shot behavior (do not loop)
    await _quizPlayer.setReleaseMode(ReleaseMode.stop);
    await _streakPlayer.setReleaseMode(ReleaseMode.stop);

    // Ensure audible volume (emulator media volume must also be up)
    await _quizPlayer.setVolume(1.0);
    await _streakPlayer.setVolume(1.0);

    _initialized = true;
    // Debug
    // ignore: avoid_print
    print('[SFX] Initialized');
  }

  Future<void> _play(AudioPlayer p, String assetPath) async {
    await _init();

    try {
      await p.stop(); // stop any current sound so the next play is instant
    } catch (_) {}

    // Debug
    // ignore: avoid_print
    print('[SFX] play -> $assetPath');
    await p.play(AssetSource(assetPath));
  }

  /// Play when a quiz (any round) completes
  static Future<void> playQuizComplete() =>
      Sfx.I._play(Sfx.I._quizPlayer, 'audio/level_complete.wav');

  /// Play when streak increases
  static Future<void> playStreak() =>
      Sfx.I._play(Sfx.I._streakPlayer, 'audio/streak.wav');
}

/// =====================================================

class WaveActApp extends StatelessWidget {
  const WaveActApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'WaveAct',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        textTheme: GoogleFonts.montserratTextTheme(
          Theme.of(context).textTheme,
        ),
        fontFamily: GoogleFonts.montserrat().fontFamily,
        pageTransitionsTheme: const PageTransitionsTheme(
          builders: <TargetPlatform, PageTransitionsBuilder>{
            TargetPlatform.android: _SmoothFadeScaleTransitionsBuilder(),
            TargetPlatform.iOS: _SmoothFadeScaleTransitionsBuilder(),
            TargetPlatform.windows: _SmoothFadeScaleTransitionsBuilder(),
            TargetPlatform.macOS: _SmoothFadeScaleTransitionsBuilder(),
            TargetPlatform.linux: _SmoothFadeScaleTransitionsBuilder(),
            TargetPlatform.fuchsia: _SmoothFadeScaleTransitionsBuilder(),
          },
        ),
      ),
      builder: (context, child) => ResponsiveBreakpoints.builder(
        child: child!,
        breakpoints: const [
          Breakpoint(start: 0, end: 450, name: MOBILE),
          Breakpoint(start: 451, end: 800, name: TABLET),
          Breakpoint(start: 801, end: 1920, name: DESKTOP),
          Breakpoint(start: 1921, end: double.infinity, name: '4K'),
        ],
      ),
      home: const SplashScreen(),
      routes: {
        '/login': (context) => const LoginScreen(),
        '/profile': (context) => const ProfileScreen(),
        '/quiz': (context) => const QuizScreen(),
        '/quests': (context) => const QuestScreen(),
        '/quest': (context) => const QuestScreen(),
        '/leaderboard': (context) => const LeaderboardPage(),
      },
    );
  }
}

// A subtle, immersive fade+scale transition used globally
class _SmoothFadeScaleTransitionsBuilder extends PageTransitionsBuilder {
  const _SmoothFadeScaleTransitionsBuilder();

  @override
  Widget buildTransitions<T>(
      PageRoute<T> route,
      BuildContext context,
      Animation<double> animation,
      Animation<double> secondaryAnimation,
      Widget child,
      ) {
    final curved = CurvedAnimation(
      parent: animation,
      curve: Curves.easeOutCubic,
      reverseCurve: Curves.easeInCubic,
    );
    return FadeTransition(
      opacity: curved,
      child: ScaleTransition(
        scale: Tween<double>(begin: 0.98, end: 1.0).animate(curved),
        child: child,
      ),
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
          // ignore: avoid_print
          print('Progress loaded for persistent user: ${user.uid}');
        } catch (e) {
          // ignore: avoid_print
          print('Error loading progress for persistent user: $e');
        }
      }

      if (!mounted) return;
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
