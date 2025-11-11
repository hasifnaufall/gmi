// lib/quiz_category.dart
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'leaderboard.dart';
import 'profile.dart';
import 'quest.dart';
import 'quest_status.dart';
import 'user_progress_service.dart';

// Learn + Quiz screens
import 'alphabet_learn.dart';
import 'alphabet_q.dart';
import 'number_learn.dart';
import 'number_q.dart';
import 'colour_learn.dart';
import 'colour_q.dart';
import 'fruits_learn.dart';
import 'fruits_q.dart';
import 'animals_learn.dart';
import 'animals_q.dart';
import 'verb_learn.dart';
import 'verb_q.dart';

/// ===================
/// Candy Crush Path Painter
/// ===================
class _LevelPathPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.7)
      ..strokeWidth = 8
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final dottedPaint = Paint()
      ..color = Color(0xFF69D3E4)
          .withOpacity(0.5) // Bright cyan theme
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    // Define path points (matching the positioned widgets) - Creating a smooth S-curve
    final path = Path();

    // Start from bottom left (Alphabet - 40, 30)
    path.moveTo(82, size.height - 72);

    // Smooth curve to Numbers (middle center - 140, 130)
    path.cubicTo(
      100,
      size.height - 100, // control point 1
      120,
      size.height - 150, // control point 2
      182,
      size.height - 172, // end point (Numbers)
    );

    // Smooth curve to Colour (right side - right:30, 220)
    path.cubicTo(
      220,
      size.height - 190, // control point 1
      size.width - 80,
      size.height - 210, // control point 2
      size.width - 72,
      size.height - 262, // end point (Colour)
    );

    // Smooth curve back to Fruits (middle left - 100, 320)
    path.cubicTo(
      size.width - 100,
      size.height - 290, // control point 1
      180,
      size.height - 310, // control point 2
      142,
      size.height - 362, // end point (Fruits)
    );

    // Smooth curve to Animals (right side upper - right:45, 420)
    path.cubicTo(
      170,
      size.height - 390, // control point 1
      size.width - 100,
      size.height - 410, // control point 2
      size.width - 87,
      size.height - 462, // end point (Animals)
    );

    // Smooth curve to Verbs (top center - 130, 510)
    path.cubicTo(
      size.width - 120,
      size.height - 490, // control point 1
      200,
      size.height - 510, // control point 2
      172,
      size.height - 552, // end point (Verbs)
    );

    // Draw white base path
    canvas.drawPath(path, paint);

    // Draw pink dotted overlay
    final metrics = path.computeMetrics().toList();
    for (var metric in metrics) {
      double distance = 0.0;
      final dashWidth = 15.0;
      final dashSpace = 10.0;

      while (distance < metric.length) {
        final start = distance;
        final end = (distance + dashWidth).clamp(0.0, metric.length);

        final extractPath = metric.extractPath(start, end);
        canvas.drawPath(extractPath, dottedPaint);

        distance += dashWidth + dashSpace;
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// ===================
/// Top-level helper used in popup
/// ===================
class _BigChoiceButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _BigChoiceButton({
    super.key,
    required this.label,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: onTap,
      child: Ink(
        height: 120,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          color: color.withOpacity(0.12),
          border: Border.all(color: color.withOpacity(0.35)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 34, color: color),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                letterSpacing: 0.6,
                fontWeight: FontWeight.w800,
                color: color.withOpacity(0.95),
              ),
            ),
          ],
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
  static const bool kUnlocksDisabled = true;

  int _selectedIndex = 0;
  bool _loadingUnlocks = true;
  bool _loadingProgress = true;
  String _userName = '';
  int? _userRank;
  bool _loadingRank = true;
  int _unlockedCategoryCount = 0;

  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    try {
      await _loadUserProgress();
      await _loadUserName();
      await _loadUnlocks();
      await _loadUserRank();
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

      // Fetch all users and calculate rank locally
      final allUsersSnapshot = await FirebaseFirestore.instance
          .collection('progress')
          .get();

      // Create a list of users with their level and score
      List<Map<String, dynamic>> allUsers = [];
      for (var doc in allUsersSnapshot.docs) {
        final data = doc.data();
        allUsers.add({
          'userId': doc.id,
          'level': data['level'] ?? 0,
          'score': data['score'] ?? 0,
        });
      }

      // Sort users by level (descending), then by score (descending)
      allUsers.sort((a, b) {
        int levelCompare = (b['level'] as int).compareTo(a['level'] as int);
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
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Icon(Icons.emoji_events, color: Color(0xFF5A7A8A), size: 28),
            SizedBox(width: 12),
            Text(
              'Level ${QuestStatus.level}',
              style: GoogleFonts.montserrat(
                color: Color(0xFF0891B2),
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
            color: Color(0xFF2D5263),
            fontSize: 15,
            height: 1.5,
          ),
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFF0891B2),
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

  void _showLivequizInfo() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Icon(Icons.star, color: Color(0xFF8B6914), size: 28),
            SizedBox(width: 12),
            Text(
              'Unlocked Categories',
              style: GoogleFonts.montserrat(
                color: Color(0xFF0891B2),
                fontWeight: FontWeight.w700,
                fontSize: 20,
              ),
            ),
          ],
        ),
        content: Text(
          'You have unlocked $_unlockedCategoryCount out of 6 quiz categories!\n\n'
              '🔑 Complete quests to earn keys\n'
              '🎮 Use 200 keys to unlock new categories\n'
              '📈 Reach required levels to access locked content\n\n'
              'Play more quizzes and complete quests to unlock all categories and become a sign language master!',
          style: GoogleFonts.montserrat(
            color: Color(0xFF2D5263),
            fontSize: 15,
            height: 1.5,
          ),
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFF0891B2),
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
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Icon(Icons.leaderboard, color: Color(0xFF2C5263), size: 28),
            SizedBox(width: 12),
            Text(
              _userRank != null ? 'Rank #$_userRank' : 'Your Rank',
              style: GoogleFonts.montserrat(
                color: Color(0xFF0891B2),
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
            color: Color(0xFF2D5263),
            fontSize: 15,
            height: 1.5,
          ),
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFF0891B2),
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
    return showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Learn or Quiz',
      barrierColor: Colors.transparent,
      transitionDuration: const Duration(milliseconds: 220),
      pageBuilder: (_, __, ___) {
        return GestureDetector(
          onTap: () => Navigator.of(context).pop(),
          child: Material(
            type: MaterialType.transparency,
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 360),
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 20),
                  padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.15),
                        blurRadius: 28,
                        offset: const Offset(0, 16),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        children: [
                          IconButton(
                            splashRadius: 22,
                            icon: const Icon(Icons.arrow_back_rounded),
                            onPressed: () => Navigator.of(context).pop(),
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              title,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                          const SizedBox(width: 48),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: _BigChoiceButton(
                              label: 'LEARN',
                              icon: Icons.school_rounded,
                              color: const Color(0xFF22D3EE),
                              onTap: () {
                                Navigator.of(context).pop();
                                onLearn();
                              },
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _BigChoiceButton(
                              label: 'QUIZ',
                              icon: Icons.quiz_rounded,
                              color: const Color(0xFF60A5FA),
                              onTap: () {
                                Navigator.of(context).pop();
                                onQuiz();
                              },
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
      transitionBuilder: (_, anim, __, child) {
        final curved = CurvedAnimation(
          parent: anim,
          curve: Curves.easeOutCubic,
        );
        return FadeTransition(
          opacity: curved,
          child: ScaleTransition(
            scale: Tween<double>(begin: 0.96, end: 1.0).animate(curved),
            child: child,
          ),
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
              colors: [const Color(0xFFFFF4E6), const Color(0xFFFFE8CC)],
            ),
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.orange.withOpacity(0.3),
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
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.orange.withOpacity(0.2),
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
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF2D3748),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'Complete these to unlock:',
                style: TextStyle(fontSize: 14, color: Colors.grey.shade700),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),

              // Requirements with emojis
              _buildFunRequirementRow(
                emoji: '🏆',
                text: 'Level $requiredLevel',
                subtext: 'You\'re at level ${QuestStatus.level}',
                isCompleted: haveLevel,
              ),
              const SizedBox(height: 12),
              _buildFunRequirementRow(
                emoji: '🔑',
                text: '$cost Keys',
                subtext: 'You have ${QuestStatus.userPoints} keys',
                isCompleted: haveKeys,
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
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isCompleted
              ? const Color(0xFF22C55E).withOpacity(0.3)
              : Colors.grey.shade300,
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
                  : Colors.grey.shade100,
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
                        ? const Color(0xFF2D3748)
                        : Colors.grey.shade600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtext,
                  style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
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
                color: Colors.grey.shade200,
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.close, color: Colors.grey.shade500, size: 18),
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

  @override
  Widget build(BuildContext context) {
    if (_loadingUnlocks || _loadingProgress) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

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

    return Container(
      decoration: BoxDecoration(
        color: Color(0xFFCFFFF7), // Light mint background
      ),
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
                            color: Color(0xFF0891B2).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: Image.asset(
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
                            color: Color(0xFF0891B2),
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
                          colors: [
                            Color(0xFFF5E6C8),
                            Color(0xFFF0DDB8),
                          ], // Cream/beige from screenshot
                        ),
                        borderRadius: BorderRadius.circular(25),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.vpn_key,
                            color: Color(
                              0xFF8B6914,
                            ), // Darker brown for better visibility
                            size: 20,
                          ),
                          SizedBox(width: 8),
                          Text(
                            '${QuestStatus.userPoints}',
                            style: TextStyle(
                              color: Color(
                                0xFF8B6914,
                              ), // Darker brown for better visibility
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
                      colors: [
                        Color(0xFFCFFFF7),
                        Color(0xFFA4A9FC).withOpacity(0.3),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Color(
                          0xFF0891B2,
                        ).withOpacity(0.15), // Darker cyan shadow
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
                                color: Color(
                                  0xFF0891B2,
                                ), // Darker cyan for better visibility
                              ),
                            ),
                            SizedBox(height: 8),
                            // User greeting
                            Text(
                              'Hi, ${_userName.isNotEmpty ? _userName : 'User'}',
                              style: GoogleFonts.montserrat(
                                fontSize: 28,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF1A202C),
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
                          gradient: const LinearGradient(
                            colors: [Color(0xFF0891B2), Color(0xFF7C7FCC)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF0891B2).withOpacity(0.3),
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
                      color: Color(
                        0xFF5A7A8A,
                      ), // Darker blue-gray for better visibility
                      displayText: '${QuestStatus.level}',
                      textColor: Colors.white,
                      onTap: _showLevelInfo,
                    ),
                    _buildIconButton(
                      icon: Icons.star,
                      label: 'Livequiz',
                      color: Color(
                        0xFFFFEB99,
                      ), // Slightly darker yellow for better contrast
                      iconColor: Color(
                        0xFF8B6914,
                      ), // Darker brown for better visibility
                      displayText: '$_unlockedCategoryCount',
                      textColor: Color(
                        0xFF5D4A0E,
                      ), // Much darker brown for better visibility
                      onTap: _showLivequizInfo,
                    ),
                    _buildRankButton(),
                  ],
                ),

                const SizedBox(height: 24),

                Text(
                  "Today's Quiz",
                  style: GoogleFonts.montserrat(
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    color: Color(
                      0xFF2D5263,
                    ), // Darker blue-gray for better visibility
                  ),
                ),
                const SizedBox(height: 14),

                // Category grid
                GridView.count(
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
                                  _buildImmersiveRoute(
                                    const NumberLearnScreen(),
                                  ),
                                );
                                await QuestStatus.autoSaveProgress();
                              },
                              onQuiz: () async {
                                await Navigator.push(
                                  context,
                                  _buildImmersiveRoute(
                                    const NumberQuizScreen(),
                                  ),
                                );
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
                                  _buildImmersiveRoute(
                                    const ColourLearnScreen(),
                                  ),
                                );
                                await QuestStatus.autoSaveProgress();
                              },
                              onQuiz: () async {
                                await Navigator.push(
                                  context,
                                  _buildImmersiveRoute(
                                    const ColourQuizScreen(),
                                  ),
                                );
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
                                  _buildImmersiveRoute(
                                    const FruitsLearnScreen(),
                                  ),
                                );
                                await QuestStatus.autoSaveProgress();
                              },
                              onQuiz: () async {
                                await Navigator.push(
                                  context,
                                  _buildImmersiveRoute(
                                    const FruitsQuizScreen(),
                                  ),
                                );
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
                                  _buildImmersiveRoute(
                                    const AnimalsLearnScreen(),
                                  ),
                                );
                                await QuestStatus.autoSaveProgress();
                              },
                              onQuiz: () async {
                                await Navigator.push(
                                  context,
                                  _buildImmersiveRoute(
                                    const AnimalQuizScreen(),
                                  ),
                                );
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
                      imageAsset: 'assets/images/verb/VERBS.jpg',
                      imageWidth: 92,
                      isUnlocked:
                      kUnlocksDisabled ||
                          QuestStatus.isContentUnlocked(QuestStatus.levelVerbs),
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
                                await Navigator.push(
                                  context,
                                  _buildImmersiveRoute(const VerbQuizScreen()),
                                );
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
                ),
              ],
            ),
          ),
          bottomNavigationBar: _buildModernNavBar(),
        ),
      ),
    );
  }

  // Modern Bottom Navigation Bar
  Widget _buildModernNavBar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(
          color: Color(0xFF0891B2).withOpacity(0.3),
          width: 1.5,
        ),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
        boxShadow: [
          BoxShadow(
            color: Color(0xFF0891B2).withOpacity(0.15),
            blurRadius: 20,
            offset: Offset(0, -5),
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
              ),
              _buildNavItem(
                emoji: '📚',
                label: 'Quest',
                isSelected: _selectedIndex == 1,
                onTap: () => _onItemTapped(1),
              ),
              _buildNavItem(
                emoji: '🏆',
                label: 'Ranking',
                isSelected: _selectedIndex == 2,
                onTap: () => _onItemTapped(2),
              ),
              _buildNavItem(
                emoji: '👤',
                label: 'Profile',
                isSelected: _selectedIndex == 3,
                onTap: () => _onItemTapped(3),
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
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: isSelected
                ? Color(0xFF0891B2).withOpacity(0.1)
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
                      ? Color(0xFF0891B2)
                      : Color(0xFF2D5263).withOpacity(0.6),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ===== UI BUILDERS =====

  Widget _buildCandyCrushLevel({
    required int level,
    required String title,
    required String imageAsset,
    required bool isUnlocked,
    required bool isCompleted,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 85,
            height: 85,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: isUnlocked
                  ? LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: isCompleted
                    ? [
                  Color(0xFFFFFFD0),
                  Color(0xFFFFF7D1),
                ] // Yellow theme for completed
                    : [
                  Color(0xFF69D3E4),
                  Color(0xFFA4A9FC),
                ], // Cyan to periwinkle theme
              )
                  : LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFFD0D0D0),
                  Color(0xFFB0B0B0),
                ], // Gray for locked
              ),
              border: Border.all(color: Colors.white, width: 4),
              boxShadow: [
                BoxShadow(
                  color: isUnlocked
                      ? Color(0xFF69D3E4).withOpacity(0.4)
                      : Colors.grey.withOpacity(0.3),
                  blurRadius: 15,
                  offset: Offset(0, 5),
                ),
              ],
            ),
            child: Stack(
              children: [
                // Lock overlay for locked levels
                if (!isUnlocked)
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.black.withOpacity(0.3),
                      ),
                    ),
                  ),
                Center(
                  child: isUnlocked
                      ? Image.asset(
                    imageAsset,
                    width: 55,
                    height: 55,
                    fit: BoxFit.contain,
                  )
                      : Icon(Icons.lock, color: Colors.white, size: 40),
                ),
                if (isCompleted)
                  Positioned(
                    top: 5,
                    right: 5,
                    child: Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        color: Color(0xFF4CAF50),
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                      child: Icon(Icons.check, color: Colors.white, size: 14),
                    ),
                  ),
              ],
            ),
          ),
          SizedBox(height: 8),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 5,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (!isUnlocked)
                  Padding(
                    padding: EdgeInsets.only(right: 4),
                    child: Icon(
                      Icons.lock,
                      size: 12,
                      color: Color(0xFF6B5D42),
                    ), // Darker brown for better visibility
                  ),
                Text(
                  title,
                  style: GoogleFonts.montserrat(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: isUnlocked
                        ? Color(0xFF0891B2)
                        : Color(
                      0xFF6B5D42,
                    ), // Darker colors for better visibility
                  ),
                ),
              ],
            ),
          ),
        ],
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
              color: color,
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
                  color: Color(
                    0xFF2D5263,
                  ), // Darker blue-gray for better visibility
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
  }) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFFCFCFC), Color(0xFFF7F5F0)],
        ),
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Color(0xFF0891B2).withOpacity(0.25), // Darker cyan shadow
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    height: 70,
                    child: Stack(
                      children: [
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Container(
                            width: 56,
                            height: 56,
                            decoration: BoxDecoration(
                              color: Color(0xFFEAF5F9),
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                        ),
                        if (imageAsset != null)
                          Positioned(
                            right: 0,
                            top: 0,
                            bottom: 0,
                            child: Image.asset(
                              imageAsset,
                              width: imageWidth,
                              fit: BoxFit.contain,
                            ),
                          ),
                      ],
                    ),
                  ),
                  const Spacer(),
                  Text(
                    title,
                    style: GoogleFonts.montserrat(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: Color(
                        0xFF0891B2,
                      ), // Darker cyan for better visibility
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '$questions questions',
                    style: GoogleFonts.montserrat(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: Color(
                        0xFF0891B2,
                      ).withOpacity(0.7), // Darker cyan for better visibility
                    ),
                  ),
                ],
              ),
            ),
            if (!isUnlocked)
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    color: Color(0xFFFCFCFC).withOpacity(0.92),
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Center(
                    child: Icon(
                      Icons.lock,
                      color: Color(0xFF6B9BAF),
                      size: 32,
                    ), // Darker lock icon
                  ),
                ),
              ),
            Positioned.fill(
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(18),
                  onTap: isUnlocked
                      ? onTap
                      : () => _showRequirementsDialog(
                    title: title,
                    key: _mapTitleToKey(title),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _mapTitleToKey(String title) {
    switch (title.toLowerCase()) {
      case 'alphabet':
        return QuestStatus.levelAlphabet;
      case 'number':
      case 'numbers':
        return QuestStatus.levelNumbers;
      case 'colour':
      case 'colors':
      case 'colours':
        return QuestStatus.levelColour;
      case 'fruits':
        return QuestStatus.levelGreetings;
      case 'animals':
        return QuestStatus.levelCommonVerb;
      case 'verbs':
        return QuestStatus.levelVerbs;
      default:
        return title;
    }
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