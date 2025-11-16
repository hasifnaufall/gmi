// lib/quiz_category.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';

import 'leaderboard.dart';
import 'profile.dart';
import 'quest.dart';
import 'quest_status.dart';
import 'user_progress_service.dart';
import 'theme_manager.dart';

// Learn + Quiz screens
import 'alphabet_learn.dart';
import 'alphabet_q.dart' show showAlphabetQuizSelection;
import 'number_learn.dart';
import 'number_q.dart' show showNumberQuizSelection;
import 'colour_learn.dart';
import 'colour_q.dart' show showColourQuizSelection;
import 'fruits_learn.dart';
import 'fruits_q.dart' show showFruitQuizSelection;
import 'animals_learn.dart';
import 'animals_q.dart' show showAnimalQuizSelection;
import 'verb_learn.dart';
import 'verb_q.dart' show showVerbQuizSelection;
import 'speech_learn.dart';
import 'speech_q.dart' show showSpeechQuizSelection;

// TODO: Import speech_learn.dart and speech_q.dart when you create them
// import 'speech_learn.dart';
// import 'speech_q.dart' show showSpeechQuizSelection;

/// ===================
/// Candy Crush Path Painter
/// ===================
/// ===================
/// Top-level helper used in popup
/// ===================
class _ModernChoiceButton extends StatelessWidget {
  final String label;
  final String subtitle;
  final IconData icon;
  final LinearGradient gradient;
  final bool isDark;
  final VoidCallback onTap;

  const _ModernChoiceButton({
    required this.label,
    required this.subtitle,
    required this.icon,
    required this.gradient,
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: Container(
          height: 85,
          decoration: BoxDecoration(
            gradient: gradient,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: gradient.colors.first.withOpacity(0.4),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Row(
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(icon, size: 32, color: Colors.white),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        label,
                        style: GoogleFonts.montserrat(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                          letterSpacing: -0.5,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        style: GoogleFonts.montserrat(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: Colors.white.withOpacity(0.85),
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  color: Colors.white.withOpacity(0.8),
                  size: 20,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class QuizCategoryScreen extends StatefulWidget {
  const QuizCategoryScreen({super.key});

  @override
  _QuizCategoryScreenState createState() => _QuizCategoryScreenState();
}

class _QuizCategoryScreenState extends State<QuizCategoryScreen> {
  static const bool kUnlocksDisabled = false;

  int _selectedIndex = 0;
  bool _loadingUnlocks = true;
  bool _loadingProgress = true;
  String _userName = '';
  int? _userRank;
  bool _loadingRank = true;
  int _unlockedCategoryCount = 0;
  String _selectedDifficulty = 'Easy'; // Default difficulty
  int _avatarIndex = 0;

  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    try {
      // Load critical data first
      await _loadUserProgress();
      await _loadUserName();
      await _loadAvatarIndex();
      await _loadUnlocks();

      // Load user rank from leaderboard
      _loadUserRank();
    } catch (_) {
      if (mounted) {
        setState(() {
          _loadingProgress = false;
          _loadingUnlocks = false;
          _loadingRank = false;
        });
      }
    }
  }

  Future<void> _loadUserName() async {
    try {
      final name = await UserProgressService().getDisplayName();
      if (name != null && name.isNotEmpty) {
        setState(() => _userName = name);
      } else {
        // Fallback to email username
        final user = FirebaseAuth.instance.currentUser;
        if (user?.email != null) {
          setState(() => _userName = user!.email!.split('@').first);
        }
      }
    } catch (e) {
      print('Error loading username: $e');
    }
  }

  Future<void> _loadAvatarIndex() async {
    try {
      final index = await UserProgressService().getAvatarIndex();
      if (mounted) {
        setState(() => _avatarIndex = index);
      }
    } catch (e) {
      print('Error loading avatar index: $e');
    }
  }

  List<List<Color>> get _avatarGradients => [
    // 0: Cyan-Purple (default)
    const [Color(0xFF0891B2), Color(0xFF7C7FCC)],
    // 1: Pink-Orange
    const [Color(0xFFEC4899), Color(0xFFF97316)],
    // 2: Green-Blue
    const [Color(0xFF10B981), Color(0xFF06B6D4)],
    // 3: Purple-Pink
    const [Color(0xFF8B5CF6), Color(0xFFEC4899)],
    // 4: Yellow-Red
    const [Color(0xFFFBBF24), Color(0xFFEF4444)],
    // 5: Indigo-Purple
    const [Color(0xFF6366F1), Color(0xFF8B5CF6)],
    // 6: Teal-Green
    const [Color(0xFF14B8A6), Color(0xFF22C55E)],
    // 7: Orange-Pink
    const [Color(0xFFF97316), Color(0xFFEC4899)],
    // 8: Blue-Cyan
    const [Color(0xFF3B82F6), Color(0xFF06B6D4)],
    // 9: Rose-Red
    const [Color(0xFFF43F5E), Color(0xFFDC2626)],
  ];

  Future<void> _loadUserProgress() async {
    try {
      final userId = UserProgressService().getCurrentUserId();
      if (userId != null) {
        if (QuestStatus.currentUserId != userId) {
          await QuestStatus.loadProgressForUser(
            userId,
          ).timeout(const Duration(seconds: 10));
        }
      } else {
        QuestStatus.resetToDefaults();
      }
    } catch (_) {}
    if (!mounted) return;
    setState(() => _loadingProgress = false);
  }

  Future<void> _loadUnlocks() async {
    try {
      await QuestStatus.ensureUnlocksLoaded().timeout(
        const Duration(seconds: 5),
      );
    } catch (_) {}
    // compute how many categories user has unlocked (alphabet always unlocked)
    final keys = [
      QuestStatus.levelAlphabet,
      QuestStatus.levelNumbers,
      QuestStatus.levelColour,
      QuestStatus.levelGreetings,
      QuestStatus.levelCommonVerb,
      QuestStatus.levelVerbs,
    ];
    final cnt = keys.where((k) => QuestStatus.isContentUnlocked(k)).length;
    if (!mounted) return;
    setState(() {
      _loadingUnlocks = false;
      _unlockedCategoryCount = cnt;
    });
  }

  Future<void> _loadUserRank() async {
    try {
      final currentUserId = FirebaseAuth.instance.currentUser?.uid;
      if (currentUserId == null) {
        if (mounted) setState(() => _loadingRank = false);
        return;
      }

      // Listen to real-time updates from progress collection
      FirebaseFirestore.instance
          .collection('progress')
          .snapshots()
          .listen(
            (snapshot) async {
              try {
                // Create a list of users with their level and score
                List<Map<String, dynamic>> allUsers = [];
                for (var doc in snapshot.docs) {
                  final data = doc.data();
                  allUsers.add({
                    'userId': doc.id,
                    'level': data['level'] ?? 0,
                    'score': data['score'] ?? 0,
                  });
                }

                // Sort users by level (descending), then by score (descending)
                allUsers.sort((a, b) {
                  int levelCompare = (b['level'] as int).compareTo(
                    a['level'] as int,
                  );
                  if (levelCompare != 0) return levelCompare;
                  return (b['score'] as int).compareTo(a['score'] as int);
                });

                // Find current user's rank
                int rank = 1;
                for (var user in allUsers) {
                  if (user['userId'] == currentUserId) {
                    break;
                  }
                  rank++;
                }

                if (mounted) {
                  setState(() {
                    _userRank = rank;
                    _loadingRank = false;
                  });
                }
              } catch (e) {
                print('Error calculating rank: $e');
                if (mounted) setState(() => _loadingRank = false);
              }
            },
            onError: (e) {
              print('Error listening to rank updates: $e');
              if (mounted) setState(() => _loadingRank = false);
            },
          );
    } catch (e) {
      print('Error loading user rank: $e');
      if (mounted) setState(() => _loadingRank = false);
    }
  }

  void _onItemTapped(int index) {
    if (index == _selectedIndex) return;
    setState(() => _selectedIndex = index);

    switch (index) {
      case 0:
        break;
      case 1:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const QuestScreen()),
        );
        break;
      case 2:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const LeaderboardPage()),
        );
        break;
      case 3:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const ProfileScreen()),
        );
        break;
    }
  }

  void _showLevelInfo() {
    final themeManager = Provider.of<ThemeManager>(context, listen: false);
    final isDark = themeManager.isDarkMode;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDark ? const Color(0xFF2C2C2E) : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Icon(
              Icons.emoji_events,
              color: isDark ? const Color(0xFFD23232) : const Color(0xFF5A7A8A),
              size: 28,
            ),
            SizedBox(width: 12),
            Text(
              'Level ${QuestStatus.level}',
              style: GoogleFonts.montserrat(
                color: isDark
                    ? const Color(0xFFD23232)
                    : const Color(0xFF0891B2),
                fontWeight: FontWeight.w700,
                fontSize: 20,
              ),
            ),
          ],
        ),
        content: Text(
          'Your current level shows your overall progress in WaveAct!\n\n'
          '📚 Complete quizzes to earn XP\n'
          '🎯 Each correct answer gives you XP\n'
          '⬆️ Level up to unlock new quiz categories\n\n'
          'Keep learning to reach higher levels!',
          style: GoogleFonts.montserrat(
            color: isDark ? const Color(0xFFE8E8E8) : const Color(0xFF2D5263),
            fontSize: 15,
            height: 1.5,
          ),
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: isDark
                  ? const Color(0xFFD23232)
                  : const Color(0xFF0891B2),
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(
              'Got it!',
              style: GoogleFonts.montserrat(
                fontWeight: FontWeight.w600,
                fontSize: 15,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showStreakInfo() {
    final themeManager = Provider.of<ThemeManager>(context, listen: false);
    final isDark = themeManager.isDarkMode;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDark ? const Color(0xFF2C2C2E) : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Icon(
              Icons.local_fire_department,
              color: isDark ? const Color(0xFFD23232) : const Color(0xFFFF6B35),
              size: 28,
            ),
            SizedBox(width: 12),
            Text(
              'Streak Days',
              style: GoogleFonts.montserrat(
                color: isDark
                    ? const Color(0xFFD23232)
                    : const Color(0xFF0891B2),
                fontWeight: FontWeight.w700,
                fontSize: 20,
              ),
            ),
          ],
        ),
        content: Text(
          'Your current streak: ${QuestStatus.streakDays} day${QuestStatus.streakDays != 1 ? "s" : ""}!\n\n'
          '🔥 Come back daily to maintain your streak\n'
          '📚 Complete at least one quiz per day\n'
          '🏆 Build longer streaks for consistency\n\n'
          'Keep learning every day to build your sign language skills and maintain your streak!',
          style: GoogleFonts.montserrat(
            color: isDark ? const Color(0xFFE8E8E8) : const Color(0xFF2D5263),
            fontSize: 15,
            height: 1.5,
          ),
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: isDark
                  ? const Color(0xFFD23232)
                  : const Color(0xFF0891B2),
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(
              'Got it!',
              style: GoogleFonts.montserrat(
                fontWeight: FontWeight.w600,
                fontSize: 15,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showRankInfo() {
    final themeManager = Provider.of<ThemeManager>(context, listen: false);
    final isDark = themeManager.isDarkMode;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDark ? const Color(0xFF2C2C2E) : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Icon(
              Icons.leaderboard,
              color: isDark ? const Color(0xFFD23232) : const Color(0xFF2C5263),
              size: 28,
            ),
            SizedBox(width: 12),
            Text(
              _userRank != null ? 'Rank #$_userRank' : 'Your Rank',
              style: GoogleFonts.montserrat(
                color: isDark
                    ? const Color(0xFFD23232)
                    : const Color(0xFF0891B2),
                fontWeight: FontWeight.w700,
                fontSize: 20,
              ),
            ),
          ],
        ),
        content: Text(
          _userRank != null
              ? 'You are ranked #$_userRank among all WaveAct learners!\n\n'
                    '🏆 Your rank is based on your total XP\n'
                    '⚡ Complete quizzes to earn more XP\n'
                    '📊 Tap "Ranking" tab to see the full leaderboard\n\n'
                    'Keep practicing to climb higher!'
              : 'Your ranking is being calculated...\n\n'
                    '🏆 Rankings are based on total XP earned\n'
                    '⚡ Complete quizzes to earn XP and improve your rank\n'
                    '📊 Check the "Ranking" tab to see all learners\n\n'
                    'Start your journey to the top!',
          style: GoogleFonts.montserrat(
            color: isDark ? const Color(0xFFE8E8E8) : const Color(0xFF2D5263),
            fontSize: 15,
            height: 1.5,
          ),
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: isDark
                  ? const Color(0xFFD23232)
                  : const Color(0xFF0891B2),
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(
              'Got it!',
              style: GoogleFonts.montserrat(
                fontWeight: FontWeight.w600,
                fontSize: 15,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _triggerQuest1() {
    if (QuestStatus.completedQuestions == 0 && !QuestStatus.quest1Claimed) {
      if (QuestStatus.level1Answers.isEmpty ||
          QuestStatus.level1Answers.every((e) => e == null)) {
        QuestStatus.ensureLevel1Length(1);
        QuestStatus.level1Answers[0] = true;
      }
    }
  }

  Future<void> _openLevelChoice({
    required String title,
    required VoidCallback onLearn,
    required VoidCallback onQuiz,
  }) {
    final themeManager = Provider.of<ThemeManager>(context, listen: false);
    final isDark = themeManager.isDarkMode;
    return showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Learn or Quiz',
      barrierColor: Colors.black54,
      transitionDuration: const Duration(milliseconds: 350),
      pageBuilder: (_, __, ___) {
        return Align(
          alignment: Alignment.bottomCenter,
          child: GestureDetector(
            onTap: () => Navigator.of(context).pop(),
            child: Material(
              type: MaterialType.transparency,
              child: Container(
                width: double.infinity,
                margin: const EdgeInsets.only(top: 100),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1C1C1E) : Colors.white,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(32),
                    topRight: Radius.circular(32),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.3),
                      blurRadius: 40,
                      offset: const Offset(0, -10),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Drag indicator
                    Container(
                      margin: const EdgeInsets.only(top: 12),
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: isDark
                            ? const Color(0xFF3C3C3E)
                            : Colors.grey[300],
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const SizedBox(height: 24),
                    // Title
                    Text(
                      title,
                      style: GoogleFonts.montserrat(
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                        color: isDark
                            ? const Color(0xFFE8E8E8)
                            : const Color(0xFF1C1C1E),
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Choose your learning mode',
                      style: GoogleFonts.montserrat(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: isDark
                            ? const Color(0xFF8E8E93)
                            : const Color(0xFF636366),
                      ),
                    ),
                    const SizedBox(height: 32),
                    // Buttons
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Column(
                        children: [
                          _ModernChoiceButton(
                            label: 'Learn',
                            subtitle: 'Study and practice',
                            icon: Icons.school_rounded,
                            gradient: LinearGradient(
                              colors: isDark
                                  ? [
                                      const Color(0xFF0891B2),
                                      const Color(0xFF06B6D4),
                                    ]
                                  : [
                                      const Color(0xFF22D3EE),
                                      const Color(0xFF06B6D4),
                                    ],
                            ),
                            isDark: isDark,
                            onTap: () {
                              Navigator.of(context).pop();
                              onLearn();
                            },
                          ),
                          const SizedBox(height: 16),
                          _ModernChoiceButton(
                            label: 'Quiz',
                            subtitle: 'Test your knowledge',
                            icon: Icons.quiz_rounded,
                            gradient: LinearGradient(
                              colors: isDark
                                  ? [
                                      const Color(0xFF8B1F1F),
                                      const Color(0xFFD23232),
                                    ]
                                  : [
                                      const Color(0xFF3B82F6),
                                      const Color(0xFF60A5FA),
                                    ],
                            ),
                            isDark: isDark,
                            onTap: () {
                              Navigator.of(context).pop();
                              onQuiz();
                            },
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
          ),
        );
      },
      transitionBuilder: (_, anim, __, child) {
        final slideAnimation =
            Tween<Offset>(begin: const Offset(0, 1), end: Offset.zero).animate(
              CurvedAnimation(
                parent: anim,
                curve: Curves.easeOutCubic,
                reverseCurve: Curves.easeInCubic,
              ),
            );

        return SlideTransition(
          position: slideAnimation,
          child: FadeTransition(opacity: anim, child: child),
        );
      },
    );
  }

  void _showUnlockDialog({
    required String title,
    required VoidCallback onConfirm,
  }) {
    final cost = QuestStatus.unlockCost;
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text("Unlock $title?"),
        content: Text("Spend $cost keys to unlock this level."),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              onConfirm();
            },
            child: const Text("Unlock"),
          ),
        ],
      ),
    );
  }

  // Fun and friendly requirements dialog
  void _showRequirementsDialog({required String title, required String key}) {
    final themeManager = Provider.of<ThemeManager>(context, listen: false);
    final isDark = themeManager.isDarkMode;
    final requiredLevel = QuestStatus.requiredLevelFor(key);
    final haveLevel = QuestStatus.level >= requiredLevel;
    final cost = QuestStatus.unlockCost;
    final haveKeys = QuestStatus.userPoints >= cost;

    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (_) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        elevation: 0,
        backgroundColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: isDark
                  ? [const Color(0xFF3C3C3E), const Color(0xFF2C2C2E)]
                  : [const Color(0xFFFFF4E6), const Color(0xFFFFE8CC)],
            ),
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: isDark
                    ? Colors.black.withOpacity(0.5)
                    : Colors.orange.withOpacity(0.3),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Lock emoji
              Container(
                width: 70,
                height: 70,
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1C1C1E) : Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: isDark
                          ? Colors.black.withOpacity(0.3)
                          : Colors.orange.withOpacity(0.2),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: const Center(
                  child: Text('🔒', style: TextStyle(fontSize: 36)),
                ),
              ),
              const SizedBox(height: 16),

              // Title
              Text(
                '$title is locked!',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: isDark
                      ? const Color(0xFFE8E8E8)
                      : const Color(0xFF2D3748),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'Complete these to unlock:',
                style: TextStyle(
                  fontSize: 14,
                  color: isDark
                      ? const Color(0xFF8E8E93)
                      : Colors.grey.shade700,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),

              // Requirements with emojis
              _buildFunRequirementRow(
                emoji: '🏆',
                text: 'Level $requiredLevel',
                subtext: 'You\'re at level ${QuestStatus.level}',
                isCompleted: haveLevel,
                isDark: isDark,
              ),
              const SizedBox(height: 12),
              _buildFunRequirementRow(
                emoji: '🔑',
                text: '$cost Keys',
                subtext: 'You have ${QuestStatus.userPoints} keys',
                isCompleted: haveKeys,
                isDark: isDark,
              ),
              const SizedBox(height: 24),

              // Action buttons
              if (haveLevel && haveKeys)
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () async {
                      Navigator.pop(context);
                      final result = await QuestStatus.attemptUnlock(key);
                      if (!mounted) return;
                      switch (result) {
                        case UnlockStatus.success:
                          setState(() {});
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Row(
                                children: [
                                  const Text('🎉  '),
                                  Text('$title unlocked!'),
                                ],
                              ),
                              backgroundColor: const Color(0xFF22C55E),
                              behavior: SnackBarBehavior.floating,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          );
                          await QuestStatus.autoSaveProgress();
                          break;
                        case UnlockStatus.alreadyUnlocked:
                          setState(() {});
                          break;
                        case UnlockStatus.needLevel:
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                'Reach Level $requiredLevel to unlock $title',
                              ),
                              backgroundColor: const Color(0xFFF87171),
                            ),
                          );
                          break;
                        case UnlockStatus.needKeys:
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                'You need $cost keys to unlock $title',
                              ),
                              backgroundColor: const Color(0xFFF87171),
                            ),
                          );
                          break;
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFF6B35),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 0,
                      shadowColor: Colors.transparent,
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          '✨ Unlock Now',
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              else
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                  ),
                  child: const Text(
                    'Got it!',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFFFF6B35),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFunRequirementRow({
    required String emoji,
    required String text,
    required String subtext,
    required bool isCompleted,
    required bool isDark,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1C1C1E) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isCompleted
              ? (isDark
                    ? const Color(0xFF22C55E).withOpacity(0.5)
                    : const Color(0xFF22C55E).withOpacity(0.3))
              : (isDark ? const Color(0xFF636366) : Colors.grey.shade300),
          width: 2,
        ),
      ),
      child: Row(
        children: [
          // Emoji
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: isCompleted
                  ? const Color(0xFF22C55E).withOpacity(0.1)
                  : (isDark ? const Color(0xFF2C2C2E) : Colors.grey.shade100),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(emoji, style: const TextStyle(fontSize: 24)),
            ),
          ),
          const SizedBox(width: 14),
          // Text
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  text,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: isCompleted
                        ? (isDark
                              ? const Color(0xFFE8E8E8)
                              : const Color(0xFF2D3748))
                        : (isDark
                              ? const Color(0xFF8E8E93)
                              : Colors.grey.shade600),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtext,
                  style: TextStyle(
                    fontSize: 13,
                    color: isDark
                        ? const Color(0xFF8E8E93)
                        : Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
          // Check mark
          if (isCompleted)
            Container(
              width: 28,
              height: 28,
              decoration: const BoxDecoration(
                color: Color(0xFF22C55E),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.check, color: Colors.white, size: 18),
            )
          else
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF2C2C2E) : Colors.grey.shade200,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.close,
                color: isDark ? const Color(0xFF636366) : Colors.grey.shade500,
                size: 18,
              ),
            ),
        ],
      ),
    );
  }

  Future<void> _handleOpenOrUnlock({
    required String key,
    required String title,
    required Future<void> Function() onOpen,
  }) async {
    if (kUnlocksDisabled) {
      await onOpen();
      return;
    }

    if (key == QuestStatus.levelAlphabet ||
        QuestStatus.isContentUnlocked(key)) {
      await onOpen();
      return;
    }

    final requiredLevel = QuestStatus.requiredLevelFor(key);
    final hasLevel = QuestStatus.level >= requiredLevel;
    final hasKeys = QuestStatus.userPoints >= QuestStatus.unlockCost;

    if (!hasLevel || !hasKeys) {
      _showRequirementsDialog(title: title, key: key);
      return;
    }

    _showUnlockDialog(
      title: title,
      onConfirm: () async {
        final result = await QuestStatus.attemptUnlock(key);
        if (!mounted) return;

        switch (result) {
          case UnlockStatus.success:
            setState(() {});
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text('$title unlocked!')));
            await onOpen();
            await QuestStatus.autoSaveProgress();
            break;
          case UnlockStatus.alreadyUnlocked:
            await onOpen();
            break;
          case UnlockStatus.needLevel:
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Reach Level $requiredLevel to unlock $title'),
              ),
            );
            break;
          case UnlockStatus.needKeys:
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'You need ${QuestStatus.unlockCost} keys to unlock $title',
                ),
              ),
            );
            break;
        }
      },
    );
  }

  // Build category grid based on selected difficulty
  Widget _buildCategoryGrid(ThemeManager themeManager) {
    if (_selectedDifficulty == 'Easy') {
      return _buildEasyCategories(themeManager);
    } else if (_selectedDifficulty == 'Medium') {
      return _buildMediumCategories(themeManager);
    } else {
      // Hard difficulty - will add later
      return _buildHardCategories(themeManager);
    }
  }

  // Easy difficulty - Original 6 categories
  Widget _buildEasyCategories(ThemeManager themeManager) {
    final isNumbersUnlocked =
        kUnlocksDisabled ||
        QuestStatus.isContentUnlocked(QuestStatus.levelNumbers);
    final isColourUnlocked =
        kUnlocksDisabled ||
        QuestStatus.isContentUnlocked(QuestStatus.levelColour);
    final isFruitsUnlocked =
        kUnlocksDisabled ||
        QuestStatus.isContentUnlocked(QuestStatus.levelGreetings);
    final isAnimalsUnlocked =
        kUnlocksDisabled ||
        QuestStatus.isContentUnlocked(QuestStatus.levelCommonVerb);

    return GridView.count(
      crossAxisCount: 2,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      childAspectRatio: 1.05,
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      children: [
        _categoryTile(
          title: 'Alphabet',
          questions: 26,
          imageAsset: 'assets/images/alphabet/ABC.png',
          imageWidth: 96,
          isUnlocked: true,
          themeManager: themeManager,
          onTap: () {
            _triggerQuest1();
            _openLevelChoice(
              title: "Alphabet",
              onLearn: () async {
                await Navigator.push(
                  context,
                  _buildImmersiveRoute(const AlphabetLearnScreen()),
                );
                await QuestStatus.autoSaveProgress();
              },
              onQuiz: () async {
                await showAlphabetQuizSelection(context);
                await QuestStatus.autoSaveProgress();
                if (!mounted) return;
                setState(() {});
              },
            );
          },
        ),
        _categoryTile(
          title: 'Numbers',
          questions: 10,
          imageAsset: 'assets/images/number/NUMBERS.png',
          imageWidth: 92,
          isUnlocked: isNumbersUnlocked,
          themeManager: themeManager,
          onTap: () {
            _handleOpenOrUnlock(
              key: QuestStatus.levelNumbers,
              title: "Numbers",
              onOpen: () async {
                _openLevelChoice(
                  title: "Numbers",
                  onLearn: () async {
                    await Navigator.push(
                      context,
                      _buildImmersiveRoute(const NumberLearnScreen()),
                    );
                    await QuestStatus.autoSaveProgress();
                  },
                  onQuiz: () async {
                    await showNumberQuizSelection(context);
                    await QuestStatus.autoSaveProgress();
                    if (!mounted) return;
                    setState(() {});
                  },
                );
              },
            );
          },
        ),
        _categoryTile(
          title: 'Colour',
          questions: 12,
          imageAsset: 'assets/images/colour/COLOURS.png',
          imageWidth: 92,
          isUnlocked: isColourUnlocked,
          themeManager: themeManager,
          onTap: () {
            _handleOpenOrUnlock(
              key: QuestStatus.levelColour,
              title: "Colour",
              onOpen: () async {
                _openLevelChoice(
                  title: "Colour",
                  onLearn: () async {
                    await Navigator.push(
                      context,
                      _buildImmersiveRoute(const ColourLearnScreen()),
                    );
                    await QuestStatus.autoSaveProgress();
                  },
                  onQuiz: () async {
                    await showColourQuizSelection(context);
                    await QuestStatus.autoSaveProgress();
                    if (!mounted) return;
                    setState(() {});
                  },
                );
              },
            );
          },
        ),
        _categoryTile(
          title: 'Fruits',
          questions: 15,
          imageAsset: 'assets/images/fruit/FRUITS.png',
          imageWidth: 92,
          isUnlocked: isFruitsUnlocked,
          themeManager: themeManager,
          onTap: () {
            _handleOpenOrUnlock(
              key: QuestStatus.levelGreetings,
              title: "Fruits",
              onOpen: () async {
                _openLevelChoice(
                  title: "Fruits",
                  onLearn: () async {
                    await Navigator.push(
                      context,
                      _buildImmersiveRoute(const FruitsLearnScreen()),
                    );
                    await QuestStatus.autoSaveProgress();
                  },
                  onQuiz: () async {
                    await showFruitQuizSelection(context);
                    await QuestStatus.autoSaveProgress();
                    if (!mounted) return;
                    setState(() {});
                  },
                );
              },
            );
          },
        ),
        _categoryTile(
          title: 'Animals',
          questions: 20,
          imageAsset: 'assets/images/animal/ANIMALS.png',
          imageWidth: 92,
          isUnlocked: isAnimalsUnlocked,
          themeManager: themeManager,
          onTap: () {
            _handleOpenOrUnlock(
              key: QuestStatus.levelCommonVerb,
              title: "Animals",
              onOpen: () async {
                _openLevelChoice(
                  title: "Animals",
                  onLearn: () async {
                    await Navigator.push(
                      context,
                      _buildImmersiveRoute(const AnimalsLearnScreen()),
                    );
                    await QuestStatus.autoSaveProgress();
                  },
                  onQuiz: () async {
                    await showAnimalQuizSelection(context);
                    await QuestStatus.autoSaveProgress();
                    if (!mounted) return;
                    setState(() {});
                  },
                );
              },
            );
          },
        ),
        _categoryTile(
          title: 'Verbs',
          questions: 15,
          imageAsset: 'assets/images/verb/VERBS.png',
          imageWidth: 92,
          isUnlocked:
              kUnlocksDisabled ||
              QuestStatus.isContentUnlocked(QuestStatus.levelVerbs),
          themeManager: themeManager,
          onTap: () {
            _handleOpenOrUnlock(
              key: QuestStatus.levelVerbs,
              title: "Verbs",
              onOpen: () async {
                _openLevelChoice(
                  title: "Verbs",
                  onLearn: () async {
                    await Navigator.push(
                      context,
                      _buildImmersiveRoute(const VerbLearnScreen()),
                    );
                    await QuestStatus.autoSaveProgress();
                  },
                  onQuiz: () async {
                    await showVerbQuizSelection(context);
                    await QuestStatus.autoSaveProgress();
                    if (!mounted) return;
                    setState(() {});
                  },
                );
              },
            );
          },
        ),
      ],
    );
  }

  // Medium difficulty - Speech category (you can add more later)
  // Medium difficulty - Speech category (can add more later)
  Widget _buildMediumCategories(ThemeManager themeManager) {
    // If you later add QuestStatus.levelSpeech and an unlock flow,
    // you can replace `true` with a real check:
    // final isSpeechUnlocked = kUnlocksDisabled || QuestStatus.isContentUnlocked(QuestStatus.levelSpeech);
    final isSpeechUnlocked = true;

    return GridView.count(
      crossAxisCount: 2,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      childAspectRatio: 1.05,
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      children: [
        _categoryTile(
          title: 'Speech',
          questions: 20,
          imageAsset: 'assets/images/speech/SPEECH.png',
          imageWidth: 92,
          isUnlocked: isSpeechUnlocked,
          themeManager: themeManager,
          onTap: () {
            _handleOpenOrUnlock(
              key: QuestStatus.levelSpeech, // ✅ use the new key
              title: "Speech",
              onOpen: () async {
                _openLevelChoice(
                  title: "Speech",
                  onLearn: () async {
                    await Navigator.push(
                      context,
                      _buildImmersiveRoute(const SpeechLearnScreen()),
                    );
                    await QuestStatus.autoSaveProgress();
                  },
                  onQuiz: () async {
                    await showSpeechQuizSelection(context);
                    await QuestStatus.autoSaveProgress();
                    if (!mounted) return;
                    setState(() {});
                  },
                );
              },
            );
          },
        ),
        // (Optional) add more Medium tiles later…
      ],
    );
  }

  /* When you create speech_learn.dart and speech_q.dart, use this:
            _openLevelChoice(
              title: "Speech",
              onLearn: () async {
                await Navigator.push(
                  context,
                  _buildImmersiveRoute(
                    const SpeechLearnScreen(),
                  ),
                );
                await QuestStatus.autoSaveProgress();
              },
              onQuiz: () async {
                await showSpeechQuizSelection(context);
                await QuestStatus.autoSaveProgress();
                if (!mounted) return;
                setState(() {});
              },
            );
            */

  // TODO: Add more medium difficulty categories here

  // Hard difficulty - Will be implemented later
  Widget _buildHardCategories(ThemeManager themeManager) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.construction,
              size: 64,
              color: themeManager.isDarkMode
                  ? Color(0xFF8E8E93)
                  : Color(0xFF0891B2).withOpacity(0.5),
            ),
            SizedBox(height: 16),
            Text(
              'Hard Mode',
              style: GoogleFonts.montserrat(
                fontSize: 24,
                fontWeight: FontWeight.w700,
                color: themeManager.isDarkMode
                    ? Color(0xFFE8E8E8)
                    : Color(0xFF2D5263),
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Coming Soon! 🔥',
              textAlign: TextAlign.center,
              style: GoogleFonts.montserrat(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: themeManager.isDarkMode
                    ? Color(0xFF8E8E93)
                    : Color(0xFF2D5263).withOpacity(0.7),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeManager>(
      builder: (context, themeManager, child) {
        if (_loadingUnlocks || _loadingProgress) {
          return Scaffold(
            backgroundColor: themeManager.backgroundColor,
            body: Center(
              child: CircularProgressIndicator(color: themeManager.primary),
            ),
          );
        }

        return Container(
          decoration: BoxDecoration(color: themeManager.backgroundColor),
          child: SafeArea(
            child: Scaffold(
              backgroundColor: Colors.transparent,
              body: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(
                  16,
                  12,
                  16,
                  100,
                ), // Extra bottom padding for nav bar
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Top bar with logo and points
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // WaveAct branding
                        Row(
                          children: [
                            Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: themeManager.primary.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: themeManager.isDarkMode
                                    ? ColorFiltered(
                                        colorFilter: ColorFilter.mode(
                                          Colors.white,
                                          BlendMode.srcIn,
                                        ),
                                        child: Image.asset(
                                          'assets/images/logo.png',
                                          fit: BoxFit.contain,
                                        ),
                                      )
                                    : Image.asset(
                                        'assets/images/logo.png',
                                        fit: BoxFit.contain,
                                      ),
                              ),
                            ),
                            SizedBox(width: 12),
                            Text(
                              'WaveAct',
                              style: GoogleFonts.montserrat(
                                fontSize: 20,
                                fontWeight: FontWeight.w700,
                                color: themeManager.isDarkMode
                                    ? const Color(0xFFD23232)
                                    : const Color(0xFF0891B2),
                              ),
                            ),
                          ],
                        ),
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 10,
                          ),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: themeManager.isDarkMode
                                  ? [Color(0xFF636366), Color(0xFF8E8E93)]
                                  : [Color(0xFFF5E6C8), Color(0xFFF0DDB8)],
                            ),
                            borderRadius: BorderRadius.circular(25),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.vpn_key,
                                color: themeManager.isDarkMode
                                    ? Color(0xFFE8E8E8)
                                    : Color(0xFF8B6914),
                                size: 20,
                              ),
                              SizedBox(width: 8),
                              Text(
                                '${QuestStatus.userPoints}',
                                style: TextStyle(
                                  color: themeManager.isDarkMode
                                      ? Color(0xFFE8E8E8)
                                      : Color(0xFF8B6914),
                                  fontWeight: FontWeight.w700,
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),

                    // Premium banner
                    Container(
                      padding: EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: themeManager.isDarkMode
                              ? [Color(0xFF2C2C2E), Color(0xFF3A3A3C)]
                              : [
                                  Color(0xFFCFFFF7),
                                  Color(0xFFA4A9FC).withOpacity(0.3),
                                ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: themeManager.isDarkMode
                                ? Color(0xFFD23232).withOpacity(0.3)
                                : Color(0xFF0891B2).withOpacity(0.15),
                            blurRadius: 15,
                            offset: Offset(0, 5),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Welcome message
                                Text(
                                  'Welcome to WaveAct',
                                  style: GoogleFonts.montserrat(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                    color: themeManager.isDarkMode
                                        ? Color(0xFFD23232)
                                        : Color(0xFF0891B2),
                                  ),
                                ),
                                SizedBox(height: 8),
                                // User greeting
                                Text(
                                  'Hi, ${_userName.isNotEmpty ? _userName : 'User'}',
                                  style: GoogleFonts.montserrat(
                                    fontSize: 28,
                                    fontWeight: FontWeight.w700,
                                    color: themeManager.isDarkMode
                                        ? Color(0xFFE8E8E8)
                                        : Color(0xFF1A202C),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(width: 16),
                          // User profile picture
                          Container(
                            width: 80,
                            height: 80,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: _avatarGradients[_avatarIndex],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: _avatarGradients[_avatarIndex][0]
                                      .withOpacity(0.3),
                                  blurRadius: 20,
                                  offset: const Offset(0, 8),
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.person,
                              size: 45,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Three icon buttons row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildIconButton(
                          icon: Icons.emoji_events,
                          label: 'Level',
                          color: themeManager.isDarkMode
                              ? Color(0xFF8B1F1F)
                              : Color(0xFF5A7A8A),
                          displayText: '${QuestStatus.level}',
                          textColor: Colors.white,
                          labelTextColor: themeManager.isDarkMode
                              ? Color(0xFFE8E8E8)
                              : Color(0xFF2D5263),
                          onTap: _showLevelInfo,
                        ),
                        _buildIconButton(
                          icon: Icons.local_fire_department,
                          label: 'Streak',
                          color: themeManager.isDarkMode
                              ? Color(0xFFFF6B35)
                              : Color(0xFFFF6B35),
                          gradient: themeManager.isDarkMode
                              ? LinearGradient(
                                  colors: [
                                    Color(0xFFFF6B35),
                                    Color(0xFFFF4500),
                                  ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                )
                              : null,
                          iconColor: Colors.white,
                          displayText: '${QuestStatus.streakDays}',
                          textColor: Colors.white,
                          labelTextColor: themeManager.isDarkMode
                              ? Color(0xFFE8E8E8)
                              : Color(0xFF2D5263),
                          onTap: _showStreakInfo,
                        ),
                        _buildRankButton(),
                      ],
                    ),

                    const SizedBox(height: 24),

                    // Difficulty selector buttons (replacing "Today's Quiz" text)
                    Row(
                      children: [
                        Expanded(
                          child: _difficultyButton(
                            label: 'Easy',
                            icon: Icons
                                .sentiment_satisfied_alt, // Keep this or change to Icons.check_circle
                            color: Color(0xFF22C55E),
                            isSelected: _selectedDifficulty == 'Easy',
                            themeManager: themeManager,
                            onTap: () {
                              setState(() => _selectedDifficulty = 'Easy');
                            },
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _difficultyButton(
                            label: 'Medium',
                            icon: Icons
                                .sentiment_neutral, // Keep this or change to Icons.flash_on
                            color: Color(0xFFFB923C),
                            isSelected: _selectedDifficulty == 'Medium',
                            themeManager: themeManager,
                            onTap: () {
                              setState(() => _selectedDifficulty = 'Medium');
                            },
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _difficultyButton(
                            label: 'Hard',
                            icon: Icons
                                .sentiment_very_dissatisfied, // Keep this or change to Icons.whatshot
                            color: Color(0xFFEF4444),
                            isSelected: _selectedDifficulty == 'Hard',
                            themeManager: themeManager,
                            onTap: () {
                              setState(() => _selectedDifficulty = 'Hard');
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Category grid - changes based on selected difficulty
                    _buildCategoryGrid(themeManager),
                  ],
                ),
              ),
              bottomNavigationBar: _buildModernNavBar(themeManager),
            ),
          ),
        );
      },
    );
  }

  // Modern Bottom Navigation Bar
  Widget _buildModernNavBar(ThemeManager themeManager) {
    return Container(
      decoration: BoxDecoration(
        color: themeManager.isDarkMode ? const Color(0xFF2C2C2E) : Colors.white,
        border: Border.all(
          color: themeManager.isDarkMode
              ? const Color(0xFFD23232).withOpacity(0.3)
              : const Color(0xFF0891B2).withOpacity(0.3),
          width: 1.5,
        ),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
        boxShadow: [
          BoxShadow(
            color: themeManager.isDarkMode
                ? const Color(0xFFD23232).withOpacity(0.15)
                : const Color(0xFF0891B2).withOpacity(0.15),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(
                emoji: '🏠',
                label: 'Home',
                isSelected: _selectedIndex == 0,
                onTap: () => _onItemTapped(0),
                themeManager: themeManager,
              ),
              _buildNavItem(
                emoji: '📚',
                label: 'Quest',
                isSelected: _selectedIndex == 1,
                onTap: () => _onItemTapped(1),
                themeManager: themeManager,
              ),
              _buildNavItem(
                emoji: '🏆',
                label: 'Ranking',
                isSelected: _selectedIndex == 2,
                onTap: () => _onItemTapped(2),
                themeManager: themeManager,
              ),
              _buildNavItem(
                emoji: '👤',
                label: 'Profile',
                isSelected: _selectedIndex == 3,
                onTap: () => _onItemTapped(3),
                themeManager: themeManager,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required String emoji,
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
    required ThemeManager themeManager,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: isSelected
                ? (themeManager.isDarkMode
                      ? const Color(0xFFD23232).withOpacity(0.1)
                      : const Color(0xFF0891B2).withOpacity(0.1))
                : Colors.transparent,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(emoji, style: TextStyle(fontSize: isSelected ? 28 : 24)),
              SizedBox(height: 4),
              Text(
                label,
                style: GoogleFonts.montserrat(
                  fontSize: 11,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                  color: isSelected
                      ? (themeManager.isDarkMode
                            ? const Color(0xFFD23232)
                            : const Color(0xFF0891B2))
                      : (themeManager.isDarkMode
                            ? const Color(0xFF8E8E93)
                            : const Color(0xFF2D5263).withOpacity(0.6)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ===== UI BUILDERS =====

  Widget _difficultyButton({
    required String label,
    required IconData icon,
    required Color color,
    required bool isSelected,
    required ThemeManager themeManager,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: Duration(milliseconds: 200),
        curve: Curves.easeOutCubic,
        padding: EdgeInsets.symmetric(vertical: 16, horizontal: 12),
        decoration: BoxDecoration(
          color: isSelected
              ? color
              : (themeManager.isDarkMode ? Color(0xFF2C2C2E) : Colors.white),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected
                ? color
                : (themeManager.isDarkMode
                      ? Color(0xFF3C3C3E)
                      : Color(0xFFE5E7EB)),
            width: 2,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: color.withOpacity(0.3),
                    blurRadius: 12,
                    offset: Offset(0, 4),
                  ),
                ]
              : [
                  BoxShadow(
                    color: themeManager.isDarkMode
                        ? Colors.black.withOpacity(0.2)
                        : Colors.black.withOpacity(0.05),
                    blurRadius: 6,
                    offset: Offset(0, 2),
                  ),
                ],
        ),
        child: Center(
          child: Text(
            label,
            style: GoogleFonts.montserrat(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: isSelected
                  ? Colors.white
                  : (themeManager.isDarkMode
                        ? Color(0xFFE8E8E8)
                        : Color(0xFF2D5263)),
              letterSpacing: 0.5,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildIconButton({
    required IconData icon,
    required String label,
    required Color color,
    Color? iconColor,
    String? displayText,
    Color? textColor,
    Color? labelTextColor,
    Gradient? gradient,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: gradient == null ? color : null,
              gradient: gradient,
              boxShadow: [
                BoxShadow(
                  color: color.withOpacity(0.4),
                  blurRadius: 10,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: Center(
              child: displayText != null
                  ? Text(
                      displayText,
                      style: GoogleFonts.montserrat(
                        color: textColor ?? Colors.white,
                        fontSize: 26,
                        fontWeight: FontWeight.w900,
                      ),
                    )
                  : Icon(icon, color: iconColor ?? Colors.white, size: 32),
            ),
          ),
          SizedBox(height: 8),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                label,
                style: GoogleFonts.montserrat(
                  color: labelTextColor ?? Colors.grey[600],
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
              SizedBox(width: 4),
              Icon(Icons.info_outline, size: 14, color: Color(0xFF0891B2)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRankButton() {
    return GestureDetector(
      onTap: _showRankInfo,
      child: Column(
        children: [
          Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Color(0xFF2C5263), // Very dark teal for maximum contrast
              boxShadow: [
                BoxShadow(
                  color: Color(0xFF2C5263).withOpacity(0.4),
                  blurRadius: 10,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: Center(
              child: _loadingRank
                  ? SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : _userRank != null
                  ? Text(
                      '#$_userRank',
                      style: GoogleFonts.montserrat(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                      ),
                    )
                  : Icon(Icons.leaderboard, color: Colors.white, size: 32),
            ),
          ),
          SizedBox(height: 8),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Rank',
                style: GoogleFonts.montserrat(
                  color: Color(0xFF0891B2), // Darker cyan for better visibility
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(width: 4),
              Icon(Icons.info_outline, size: 14, color: Color(0xFF0891B2)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _categoryTile({
    required String title,
    required int questions,
    String? imageAsset,
    double imageWidth = 92,
    required bool isUnlocked,
    required VoidCallback onTap,
    required ThemeManager themeManager,
  }) {
    return Transform(
      transform: Matrix4.identity()
        ..setEntry(3, 2, 0.001) // perspective
        ..rotateX(-0.05), // slight 3D tilt
      alignment: Alignment.center,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: themeManager.isDarkMode
                ? [Color(0xFF2C2C2E), Color(0xFF1C1C1E)]
                : [Colors.white, Color(0xFFF7F5F0)],
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: themeManager.isDarkMode
                ? Color(0xFFD23232).withOpacity(0.2)
                : Color(0xFF0891B2).withOpacity(0.2),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: themeManager.isDarkMode
                  ? Color(0xFFD23232).withOpacity(0.25)
                  : Color(0xFF0891B2).withOpacity(0.2),
              blurRadius: 20,
              offset: const Offset(0, 10),
              spreadRadius: -5,
            ),
            BoxShadow(
              color: themeManager.isDarkMode
                  ? Colors.black.withOpacity(0.3)
                  : Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Stack(
            children: [
              // Background gradient accent
              Positioned(
                top: -20,
                right: -20,
                child: Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        themeManager.isDarkMode
                            ? Color(0xFFD23232).withOpacity(0.1)
                            : Color(0xFF0891B2).withOpacity(0.1),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 3D Image container
                    if (imageAsset != null)
                      Center(
                        child: Transform(
                          transform: Matrix4.identity()
                            ..setEntry(3, 2, 0.002)
                            ..rotateY(0.1)
                            ..rotateX(-0.1),
                          alignment: Alignment.center,
                          child: Container(
                            height: 85,
                            width: imageWidth,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: themeManager.isDarkMode
                                      ? Color(0xFFD23232).withOpacity(0.3)
                                      : Color(0xFF0891B2).withOpacity(0.3),
                                  blurRadius: 15,
                                  offset: Offset(0, 8),
                                  spreadRadius: -3,
                                ),
                              ],
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(16),
                              child: Image.asset(
                                imageAsset,
                                fit: BoxFit.contain,
                                errorBuilder: (context, error, stackTrace) {
                                  return Container(
                                    decoration: BoxDecoration(
                                      color: themeManager.isDarkMode
                                          ? Color(0xFF3C3C3E)
                                          : Color(0xFFEAF5F9),
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    child: Icon(
                                      Icons.image_not_supported,
                                      color: themeManager.isDarkMode
                                          ? Color(0xFF8E8E93)
                                          : Color(0xFF0891B2).withOpacity(0.3),
                                      size: 40,
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                        ),
                      ),
                    const Spacer(),
                    Text(
                      title,
                      style: GoogleFonts.montserrat(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: themeManager.isDarkMode
                            ? Color(0xFFD23232)
                            : Color(0xFF0891B2),
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          Icons.quiz_outlined,
                          size: 14,
                          color: themeManager.isDarkMode
                              ? Color(0xFF8E8E93)
                              : Color(0xFF0891B2).withOpacity(0.7),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '$questions questions',
                          style: GoogleFonts.montserrat(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: themeManager.isDarkMode
                                ? Color(0xFF8E8E93)
                                : Color(0xFF0891B2).withOpacity(0.7),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              // Lock overlay for locked categories
              if (!isUnlocked)
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      color:
                          (themeManager.isDarkMode
                                  ? Color(0xFF1C1C1E)
                                  : Colors.white)
                              .withOpacity(0.95),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: themeManager.isDarkMode
                            ? Color(0xFF636366)
                            : Color(0xFF0891B2).withOpacity(0.3),
                        width: 2,
                      ),
                    ),
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.lock_rounded,
                            color: themeManager.isDarkMode
                                ? Color(0xFF8E8E93)
                                : Color(0xFF0891B2).withOpacity(0.5),
                            size: 40,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'LOCKED',
                            style: GoogleFonts.montserrat(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: themeManager.isDarkMode
                                  ? Color(0xFF8E8E93)
                                  : Color(0xFF0891B2).withOpacity(0.5),
                              letterSpacing: 1,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              // Tap area
              Positioned.fill(
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(20),
                    onTap: onTap,
                    splashColor: themeManager.isDarkMode
                        ? Color(0xFFD23232).withOpacity(0.1)
                        : Color(0xFF0891B2).withOpacity(0.1),
                    highlightColor: themeManager.isDarkMode
                        ? Color(0xFFD23232).withOpacity(0.05)
                        : Color(0xFF0891B2).withOpacity(0.05),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Route _buildImmersiveRoute(Widget page) {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        final curved = CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutCubic,
          reverseCurve: Curves.easeInCubic,
        );
        return FadeTransition(
          opacity: curved,
          child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0.02, 0.02),
              end: Offset.zero,
            ).animate(curved),
            child: ScaleTransition(
              scale: Tween<double>(begin: 0.985, end: 1).animate(curved),
              child: child,
            ),
          ),
        );
      },
      transitionDuration: const Duration(milliseconds: 260),
      reverseTransitionDuration: const Duration(milliseconds: 220),
    );
  }
}
