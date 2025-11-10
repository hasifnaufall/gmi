// lib/main.dart
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:responsive_framework/responsive_framework.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

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
import 'theme_manager.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    ).timeout(const Duration(seconds: 10));
  } catch (e) {
    print('Firebase initialization error: $e');
  }

  runApp(
    ChangeNotifierProvider(
      create: (_) => ThemeManager(),
      child: const WaveActApp(),
    ),
  );
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
    return Consumer<ThemeManager>(
      builder: (context, themeManager, child) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'WaveAct',
          theme: ThemeData(
            brightness: Brightness.light,
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
          darkTheme: ThemeData(
            brightness: Brightness.dark,
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
          themeMode: themeManager.isDarkMode ? ThemeMode.dark : ThemeMode.light,
          builder: (context, child) {
            ErrorWidget.builder = (FlutterErrorDetails details) => Container();
            return ResponsiveBreakpoints.builder(
              child: child!,
              breakpoints: const [
                Breakpoint(start: 0, end: 450, name: MOBILE),
                Breakpoint(start: 451, end: 800, name: TABLET),
                Breakpoint(start: 801, end: 1920, name: DESKTOP),
                Breakpoint(start: 1921, end: double.infinity, name: '4K'),
              ],
            );
          },
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

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();

    // Initialize animations
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
      ),
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.8, curve: Curves.elasticOut),
      ),
    );

    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _animationController,
            curve: const Interval(0.2, 1.0, curve: Curves.easeOutCubic),
          ),
        );

    // Start animation
    _animationController.forward();

    // Initialize app and navigate
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    // Reduced delay for faster startup
    await Future.delayed(const Duration(milliseconds: 1000));

    if (!mounted) return;

    final user = FirebaseAuth.instance.currentUser;

    // Don't load progress here - let screens do it themselves
    // This prevents blocking the app startup
    if (user == null) {
      QuestStatus.resetToDefaults();
      QuestStatus.clearCurrentUser();
    }

    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) =>
            user != null ? QuizCategoryScreen() : const LoginScreen(),
      ),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFFCFFFF7), // Light mint
              Color(0xFF69D3E4), // Bright cyan
              Color(0xFF4FC3E4), // Lighter cyan
            ],
            stops: [0.0, 0.6, 1.0],
          ),
        ),
        child: Stack(
          children: [
            // Animated gradient orbs in background
            Positioned(
              top: -100,
              right: -100,
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: Container(
                  width: 300,
                  height: 300,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        const Color(0xFF69D3E4).withOpacity(0.3),
                        const Color(0xFF69D3E4).withOpacity(0.0),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: -150,
              left: -150,
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: Container(
                  width: 400,
                  height: 400,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        const Color(0xFFCFFFF7).withOpacity(0.4),
                        const Color(0xFFCFFFF7).withOpacity(0.0),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            // Main content
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Logo with animation
                  ScaleTransition(
                    scale: _scaleAnimation,
                    child: FadeTransition(
                      opacity: _fadeAnimation,
                      child: Container(
                        padding: const EdgeInsets.all(32),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: const LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [Color(0xFFFFFFFF), Color(0xFFF0FDFA)],
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF69D3E4).withOpacity(0.4),
                              blurRadius: 30,
                              offset: const Offset(0, 10),
                              spreadRadius: 5,
                            ),
                          ],
                        ),
                        child: Image.asset(
                          'assets/images/logo.png',
                          width: 140,
                          height: 140,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                  // App name with slide animation
                  SlideTransition(
                    position: _slideAnimation,
                    child: FadeTransition(
                      opacity: _fadeAnimation,
                      child: ShaderMask(
                        shaderCallback: (bounds) => const LinearGradient(
                          colors: [Color(0xFFFFFFFF), Color(0xFFF0FDFA)],
                        ).createShader(bounds),
                        child: Text(
                          'WaveAct',
                          style: GoogleFonts.montserrat(
                            fontSize: 48,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                            letterSpacing: -1.5,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Tagline
                  SlideTransition(
                    position: _slideAnimation,
                    child: FadeTransition(
                      opacity: _fadeAnimation,
                      child: Text(
                        'Wave To Act , Learn To Connect',
                        style: GoogleFonts.montserrat(
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                          color: Colors.white.withOpacity(0.9),
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 60),
                  // Loading indicator
                  FadeTransition(
                    opacity: _fadeAnimation,
                    child: SizedBox(
                      width: 40,
                      height: 40,
                      child: CircularProgressIndicator(
                        strokeWidth: 3,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          Colors.white.withOpacity(0.8),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
