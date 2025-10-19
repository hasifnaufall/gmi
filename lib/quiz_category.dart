import 'package:flutter/material.dart';
import 'dart:ui' as ui;

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
  String _userName = 'User';

  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    try {
      // Load user progress first
      await _loadUserProgress();
      // Load user's display name
      await _loadUserName();
      // Then load unlocks
      await _loadUnlocks();
    } catch (e) {
      print('Error during app initialization: $e');
      // Don't reset on error - preserve any existing progress
      if (mounted) {
        setState(() {
          _loadingProgress = false;
          _loadingUnlocks = false;
        });
      }
    }
  }

  Future<void> _loadUserName() async {
    try {
      final displayName = await UserProgressService().getDisplayName();
      if (mounted && displayName != null && displayName.isNotEmpty) {
        setState(() => _userName = displayName);
      }
    } catch (e) {
      print('Error loading display name: $e');
    }
  }

  Future<void> _loadUserProgress() async {
    try {
      final userId = UserProgressService().getCurrentUserId();
      if (userId != null) {
        // Only load progress if user ID doesn't match (different user or after logout)
        if (QuestStatus.currentUserId != userId) {
          print(
            'QuizCategoryScreen: Loading progress for user: $userId (different from current: ${QuestStatus.currentUserId})',
          );
          // Add timeout to prevent hanging
          await QuestStatus.loadProgressForUser(
            userId,
          ).timeout(const Duration(seconds: 10));
          print('User progress loaded successfully for user: $userId');
          print(
            'Loaded progress - Level: ${QuestStatus.level}, XP: ${QuestStatus.xp}, Chests: ${QuestStatus.chestsOpened}, Streak: ${QuestStatus.streakDays}',
          );
        } else {
          print(
            'QuizCategoryScreen: User progress already loaded for user: $userId',
          );
          print(
            'Current progress - Level: ${QuestStatus.level}, XP: ${QuestStatus.xp}, Chests: ${QuestStatus.chestsOpened}, Streak: ${QuestStatus.streakDays}',
          );
        }
      } else {
        print('No user logged in - using default progress');
        QuestStatus.resetToDefaults();
      }
    } catch (e) {
      print('Error loading user progress: $e');
      // Don't reset to defaults on error - keep existing progress
    }
    if (!mounted) return;
    setState(() => _loadingProgress = false);
  }

  Future<void> _loadUnlocks() async {
    try {
      await QuestStatus.ensureUnlocksLoaded().timeout(
        const Duration(seconds: 5),
      );
    } catch (e) {
      print('Error loading unlocks: $e');
    }
    if (!mounted) return;
    setState(() => _loadingUnlocks = false);
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
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const ProfileScreen()),
        );
        break;
    }
  }

  // ✅✅ NEW: Mark Quest 1 progress when Alphabet is clicked (no auto-claim)
  void _triggerQuest1() {
    if (QuestStatus.completedQuestions == 0 && !QuestStatus.quest1Claimed) {
      if (QuestStatus.level1Answers.isEmpty ||
          QuestStatus.level1Answers.every((e) => e == null)) {
        QuestStatus.ensureLevel1Length(1);
        QuestStatus.level1Answers[0] = true;
      }
      // Quest 1 is now claimable, but user must claim it manually from Quest screen
    }
  }

  void _openLevelChoice({
    required String title,
    required VoidCallback onLearn,
    required VoidCallback onQuiz,
  }) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                height: 4,
                width: 40,
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: Colors.black26,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pop(context);
                        onLearn();
                      },
                      icon: const Icon(Icons.school),
                      label: const Text("Learn"),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        backgroundColor: const Color(0xFF22D3EE),
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pop(context);
                        onQuiz();
                      },
                      icon: const Icon(Icons.quiz),
                      label: const Text("Quiz"),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        backgroundColor: const Color(0xFF60A5FA),
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
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

  // Show clear requirements when content is locked
  void _showRequirementsDialog({required String title, required String key}) {
    final requiredLevel = QuestStatus.requiredLevelFor(key);
    final haveLevel = QuestStatus.level >= requiredLevel;
    final cost = QuestStatus.unlockCost;
    final haveKeys = QuestStatus.userPoints >= cost;

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text("$title is locked"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  haveLevel ? Icons.check_circle : Icons.cancel,
                  color: haveLevel ? Colors.green : Colors.redAccent,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    "Reach Level $requiredLevel (current: ${QuestStatus.level})",
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Icon(
                  haveKeys ? Icons.check_circle : Icons.cancel,
                  color: haveKeys ? Colors.green : Colors.redAccent,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    "Have $cost keys (current: ${QuestStatus.userPoints})",
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
          if (haveLevel && haveKeys)
            ElevatedButton(
              onPressed: () async {
                Navigator.pop(context);
                final result = await QuestStatus.attemptUnlock(key);
                if (!mounted) return;
                switch (result) {
                  case UnlockStatus.success:
                    setState(() {});
                    ScaffoldMessenger.of(
                      context,
                    ).showSnackBar(SnackBar(content: Text('$title unlocked!')));
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
                      ),
                    );
                    break;
                  case UnlockStatus.needKeys:
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('You need $cost keys to unlock $title'),
                      ),
                    );
                    break;
                }
              },
              child: const Text('Unlock now'),
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

    // If not eligible, show a requirements dialog instead of silently blocking
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
    final points = QuestStatus.userPoints;
    final level = QuestStatus.level;

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

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header with user greeting and profile
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Hi, $_userName',
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          "Let's make this day productive",
                          style: TextStyle(fontSize: 14, color: Colors.black54),
                        ),
                      ],
                    ),
                    CircleAvatar(
                      radius: 28,
                      backgroundColor: Colors.orange.shade300,
                      child: const Icon(
                        Icons.person,
                        size: 32,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Stats cards - Ranking and Points
                Row(
                  children: [
                    Expanded(
                      child: _buildStatCard(
                        icon: Icons.emoji_events,
                        iconColor: Colors.amber,
                        label: 'Level',
                        value: level.toString(),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildStatCard(
                        icon: Icons.stars,
                        iconColor: Colors.amber,
                        label: 'Keys',
                        value: points.toString(),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _buildStatCard(
                        icon: Icons.local_fire_department,
                        iconColor: Colors.deepOrange,
                        label: 'Streak',
                        value: '${QuestStatus.streakDays} days',
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Expanded(child: SizedBox.shrink()),
                  ],
                ),
                const SizedBox(height: 24),

                // "Let's play" title
                const Text(
                  "Let's play",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 16),

                // Category grid (2 columns)
                GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: 2,
                  mainAxisSpacing: 16,
                  crossAxisSpacing: 16,
                  childAspectRatio: 0.85,
                  children: [
                    _buildCategoryCard(
                      context: context,
                      title: 'Alphabet',
                      icon: Icons.abc,
                      iconColor: const Color(0xFF2a5dad),
                      bgColor: const Color(0xFF2a5dad),
                      textColor: Colors.white,
                      questions: 26,
                      isUnlocked: true,
                      onTap: () async {
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
                            await Navigator.push(
                              context,
                              _buildImmersiveRoute(const AlphabetQuizScreen()),
                            );
                            await QuestStatus.autoSaveProgress();
                            if (!mounted) return;
                            setState(() {});
                          },
                        );
                      },
                    ),
                    _buildCategoryCard(
                      context: context,
                      title: 'Number',
                      icon: Icons.calculate,
                      iconColor: Colors.purple.shade400,
                      bgColor: Colors.purple.shade50,
                      questions: 10,
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
                    _buildCategoryCard(
                      context: context,
                      title: 'Colour',
                      icon: Icons.palette,
                      iconColor: Colors.pink.shade400,
                      bgColor: Colors.pink.shade50,
                      questions: 12,
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
                    _buildCategoryCard(
                      context: context,
                      title: 'Fruits',
                      icon: Icons.apple,
                      iconColor: Colors.red.shade400,
                      bgColor: Colors.red.shade50,
                      questions: 15,
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
                    _buildCategoryCard(
                      context: context,
                      title: 'Animals',
                      icon: Icons.pets,
                      iconColor: Colors.green.shade400,
                      bgColor: Colors.green.shade50,
                      questions: 20,
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
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: _buildModernNavBar(),
    );
  }

  // Build stat card (Ranking/Points)
  Widget _buildStatCard({
    required IconData icon,
    required Color iconColor,
    required String label,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(icon, color: iconColor, size: 28),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(fontSize: 12, color: Colors.black54),
              ),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Build category card for grid
  Widget _buildCategoryCard({
    required BuildContext context,
    required String title,
    required IconData icon,
    required Color iconColor,
    required Color bgColor,
    Color textColor = Colors.black87,
    required int questions,
    required bool isUnlocked,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: isUnlocked
          ? onTap
          : () {
              // Show requirements dialog when locked card is tapped
              _showRequirementsDialog(title: title, key: _mapTitleToKey(title));
            },
      child: Container(
        decoration: BoxDecoration(
          // Soft pastel tint derived from the icon color for a minimalist colorful card
          color: _pastelFrom(iconColor),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Stack(
            children: [
              // Main content with extra bottom padding to make room for the bottom band
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 64),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Icon container
                    Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        color: iconColor,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(icon, size: 32, color: Colors.white),
                    ),
                    const Spacer(),
                  ],
                ),
              ),
              // Full-width bottom color band with title and question count
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: Container(
                  padding: const EdgeInsets.fromLTRB(16, 10, 16, 12),
                  decoration: BoxDecoration(
                    // Subtle left-to-right gradient for the label band
                    gradient: LinearGradient(
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                      colors: [_darkenColor(bgColor, 0.06), bgColor],
                    ),
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(16),
                      bottomRight: Radius.circular(16),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: isUnlocked ? textColor : Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '$questions questions',
                        style: TextStyle(
                          fontSize: 12,
                          color: isUnlocked
                              ? textColor.withOpacity(0.9)
                              : Colors.grey.shade400,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              // Lock overlay if not unlocked
              if (!isUnlocked)
                Positioned.fill(
                  child: Container(
                    color: Colors.white.withOpacity(0.7),
                    child: Center(
                      child: Icon(
                        Icons.lock,
                        size: 32,
                        color: Colors.grey.shade500,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  // Map visible title to the QuestStatus content key
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
      default:
        return title; // fallback
    }
  }

  // Create a soft pastel from a base color (keeps hue, reduces saturation, increases lightness)
  Color _pastelFrom(
    Color base, {
    double lightness = 0.96,
    double satFactor = 0.25,
  }) {
    final hsl = HSLColor.fromColor(base);
    final adjusted = hsl
        .withSaturation((hsl.saturation * satFactor).clamp(0.0, 1.0))
        .withLightness(lightness.clamp(0.0, 1.0));
    return adjusted.toColor();
  }

  // Slightly darken a color (amount: 0..1 of lightness to subtract)
  Color _darkenColor(Color color, double amount) {
    final hsl = HSLColor.fromColor(color);
    final lightness = (hsl.lightness - amount).clamp(0.0, 1.0);
    return hsl.withLightness(lightness).toColor();
  }

  // Build an immersive route transition (fade + slight slide + scale)
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

  // Modern glassy bottom navigation bar with animated active pill
  Widget _buildModernNavBar() {
    final navItems = [
      {
        'label': 'Home',
        'icon': Icons.home_outlined,
        'activeIcon': Icons.home_rounded,
        'color': const Color(0xFF2563EB), // blue
      },
      {
        'label': 'Task',
        'icon': Icons.menu_book_outlined,
        'activeIcon': Icons.menu_book_rounded,
        'color': const Color(0xFF22C55E), // green
      },
      {
        'label': 'Profile',
        'icon': Icons.person_outline_rounded,
        'activeIcon': Icons.person_rounded,
        'color': const Color(0xFFF59E0B), // amber
      },
    ];

    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        child: Container(
          height: 72,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: BackdropFilter(
              filter: ui.ImageFilter.blur(sigmaX: 12, sigmaY: 12),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.55),
                  border: Border.all(color: Colors.white.withOpacity(0.7)),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final itemWidth = constraints.maxWidth / navItems.length;
                    final accent = navItems[_selectedIndex]['color'] as Color;
                    return Stack(
                      children: [
                        // Active pill background
                        AnimatedPositioned(
                          duration: const Duration(milliseconds: 260),
                          curve: Curves.easeOutCubic,
                          left: _selectedIndex * itemWidth,
                          top: 8,
                          bottom: 8,
                          child: Container(
                            width: itemWidth,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  accent.withOpacity(0.18),
                                  accent.withOpacity(0.08),
                                ],
                              ),
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                        ),
                        // Nav items row
                        Row(
                          children: List.generate(navItems.length, (i) {
                            final active = i == _selectedIndex;
                            final icon =
                                (active
                                        ? navItems[i]['activeIcon']
                                        : navItems[i]['icon'])
                                    as IconData;
                            final color = active
                                ? navItems[i]['color'] as Color
                                : Colors.black54;
                            return Expanded(
                              child: Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  borderRadius: BorderRadius.circular(16),
                                  onTap: () => _onItemTapped(i),
                                  child: SizedBox(
                                    height: 72,
                                    child: Center(
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(icon, size: 24, color: color),
                                          AnimatedSwitcher(
                                            duration: const Duration(
                                              milliseconds: 180,
                                            ),
                                            switchInCurve: Curves.easeOut,
                                            switchOutCurve: Curves.easeIn,
                                            child: active
                                                ? Padding(
                                                    key: ValueKey('lbl$i'),
                                                    padding:
                                                        const EdgeInsets.only(
                                                          left: 8,
                                                        ),
                                                    child: Text(
                                                      navItems[i]['label']
                                                          as String,
                                                      style: TextStyle(
                                                        color: color,
                                                        fontWeight:
                                                            FontWeight.w600,
                                                      ),
                                                    ),
                                                  )
                                                : const SizedBox(
                                                    key: ValueKey('empty'),
                                                  ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            );
                          }),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
