// lib/quiz_category.dart
import 'package:flutter/material.dart';

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

/// ===================
/// Top-level helper used in popup
/// ===================
class _BigChoiceButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _BigChoiceButton({
    Key? key,
    required this.label,
    required this.icon,
    required this.color,
    required this.onTap,
  }) : super(key: key);

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
      await _loadUserProgress();
      await _loadUserName();
      await _loadUnlocks();
    } catch (_) {
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
    } catch (_) {}
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

  // Mark Quest 1 progress when Alphabet is clicked (no auto-claim)
  void _triggerQuest1() {
    if (QuestStatus.completedQuestions == 0 && !QuestStatus.quest1Claimed) {
      if (QuestStatus.level1Answers.isEmpty ||
          QuestStatus.level1Answers.every((e) => e == null)) {
        QuestStatus.ensureLevel1Length(1);
        QuestStatus.level1Answers[0] = true;
      }
    }
  }

  /// Center popup (transparent outside) with back button + Learn/Quiz
  Future<void> _openLevelChoice({
    required String title,
    required VoidCallback onLearn,
    required VoidCallback onQuiz,
  }) {
    return showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Learn or Quiz',
      barrierColor: Colors.transparent, // invisible background
      transitionDuration: const Duration(milliseconds: 220),
      pageBuilder: (_, __, ___) {
        return GestureDetector(
          onTap: () => Navigator.of(context).pop(), // close on outside tap
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
      color: const Color(0xFFFAFFDC),
      child: SafeArea(
        child: Scaffold(
          backgroundColor: Colors.transparent,
          body: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Greeting + avatar
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Hi, $_userName',
                            style: const TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.w700,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            "Let's make this day productive",
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.black54,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const CircleAvatar(
                      radius: 22,
                      backgroundColor: Colors.white,
                      child: Icon(Icons.person, color: Colors.blueAccent),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Compact stats card
                _buildCompactStatsCard(
                  leftIcon: Icons.emoji_events_rounded,
                  leftLabel: 'Level',
                  leftValue: '${QuestStatus.level}',
                  rightIcon: Icons.attach_money_rounded,
                  rightLabel: 'Keys',
                  rightValue: '${QuestStatus.userPoints}',
                ),

                const SizedBox(height: 22),

                const Text(
                  "Let's play",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 14),

                // Category grid (images contained within cards)
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

  // ===== UI BUILDERS =====

  Widget _buildCompactStatsCard({
    required IconData leftIcon,
    required String leftLabel,
    required String leftValue,
    required IconData rightIcon,
    required String rightLabel,
    required String rightValue,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        children: [
          _statItem(leftIcon, leftLabel, leftValue),
          const VerticalDivider(thickness: 0.8, color: Color(0xFFECECEC)),
          _statItem(rightIcon, rightLabel, rightValue),
        ],
      ),
    );
  }

  Widget _statItem(IconData icon, String label, String value) {
    return Expanded(
      child: Row(
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: const Color(0xFFF3F7FF),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: Colors.amber[700], size: 22),
          ),
          const SizedBox(width: 10),
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
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Category card with contained image layout
  Widget _categoryTile({
    required String title,
    required int questions,
    String? imageAsset,
    double imageWidth = 92,
    double imagePeekUp = 12,
    double imageRightInset = 8,
    required bool isUnlocked,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: Stack(
          children: [
            // Card content
            Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Image area at top
                  SizedBox(
                    height: 70,
                    child: Stack(
                      children: [
                        // Soft badge background
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Container(
                            width: 56,
                            height: 56,
                            decoration: BoxDecoration(
                              color: const Color(0xFFF3F7FF),
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                        ),
                        // Image positioned on the right
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
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '$questions questions',
                    style: const TextStyle(fontSize: 12, color: Colors.black54),
                  ),
                ],
              ),
            ),

            // Lock overlay
            if (!isUnlocked)
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.65),
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Center(
                    child: Icon(Icons.lock, color: Colors.grey.shade600),
                  ),
                ),
              ),

            // Tap target
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

  // Glassy bottom navigation bar
  Widget _buildModernNavBar() {
    final navItems = [
      {
        'label': 'Home',
        'icon': Icons.home_outlined,
        'activeIcon': Icons.home_rounded,
        'color': const Color(0xFF2563EB),
        'emoji': '🏠',
      },
      {
        'label': 'Quest',
        'icon': Icons.menu_book_outlined,
        'activeIcon': Icons.menu_book_rounded,
        'color': const Color(0xFF22C55E),
        'emoji': '📚',
      },
      {
        'label': 'Ranking',
        'icon': Icons.leaderboard_outlined,
        'activeIcon': Icons.leaderboard,
        'color': const Color(0xFF63539C),
        'emoji': '🏆',
      },
      {
        'label': 'Profile',
        'icon': Icons.person_outline_rounded,
        'activeIcon': Icons.person_rounded,
        'color': const Color(0xFFF59E0B),
        'emoji': '👤',
      },
    ];

    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        child: Container(
          height: 67,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(25),
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFFE94057), Color(0xFF8A2387)],
            ),
            boxShadow: [
              BoxShadow(
                color: Color(0xFFE94057).withOpacity(0.4),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Row(
            children: List.generate(navItems.length, (i) {
              final active = i == _selectedIndex;
              final color = active
                  ? Colors.white
                  : Colors.white.withOpacity(0.7);
              final emoji = navItems[i]['emoji'] as String;

              return Expanded(
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(20),
                    onTap: () => _onItemTapped(i),
                    child: Container(
                      decoration: active
                          ? BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  Colors.white.withOpacity(0.2),
                                  Colors.white.withOpacity(0.1),
                                ],
                              ),
                              borderRadius: BorderRadius.circular(20),
                            )
                          : null,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(emoji, style: const TextStyle(fontSize: 20)),
                          const SizedBox(height: 4),
                          Text(
                            navItems[i]['label'] as String,
                            style: TextStyle(
                              color: color,
                              fontWeight: active
                                  ? FontWeight.w800
                                  : FontWeight.w600,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}
