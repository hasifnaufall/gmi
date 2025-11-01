// lib/alphabet_q.dart
import 'package:flutter/material.dart';
import 'dart:math' as math;

import 'quest_status.dart';
import 'main.dart';

class AlphabetQuizScreen extends StatefulWidget {
  final int? startIndex;

  const AlphabetQuizScreen({super.key, this.startIndex});

  @override
  State<AlphabetQuizScreen> createState() => _AlphabetQuizScreenState();
}

class _AlphabetQuizScreenState extends State<AlphabetQuizScreen>
    with SingleTickerProviderStateMixin {
  static const int sessionSize = 5;

  late List<int> activeIndices;
  late int currentSlot;
  bool isOptionSelected = false;
  int? _pendingIndex;

  final Map<int, bool> _sessionAnswers = {};

  late AnimationController _controller;
  late Animation<Offset> _offsetAnimation;
  late Animation<double> _fadeAnimation;

  final List<Map<String, dynamic>> questions = [
    {"image": "assets/images/alphabet/Q1.jpg", "options": ["P", "A", "E", "S"], "correctIndex": 1},
    {"image": "assets/images/alphabet/Q2.jpg", "options": ["W", "U", "F", "B"], "correctIndex": 3},
    {"image": "assets/images/alphabet/Q3.jpg", "options": ["C", "Z", "R", "H"], "correctIndex": 0},
    {"image": "assets/images/alphabet/Q4.jpg", "options": ["U", "Y", "D", "L"], "correctIndex": 2},
    {"image": "assets/images/alphabet/Q5.jpg", "options": ["J", "E", "I", "O"], "correctIndex": 1},
    {"image": "assets/images/alphabet/Q6.jpg", "options": ["M", "F", "E", "S"], "correctIndex": 1},
    {"image": "assets/images/alphabet/Q7.jpg", "options": ["X", "N", "G", "D"], "correctIndex": 2},
    {"image": "assets/images/alphabet/Q8.jpg", "options": ["H", "O", "R", "Q"], "correctIndex": 0},
    {"image": "assets/images/alphabet/Q9.jpg", "options": ["U", "Y", "N", "I"], "correctIndex": 3},
    {"image": "assets/images/alphabet/Q10.jpg", "options": ["Z", "L", "I", "J"], "correctIndex": 3},
    {"image": "assets/images/alphabet/Q11.jpg", "options": ["O", "K", "E", "S"], "correctIndex": 1},
    {"image": "assets/images/alphabet/Q12.jpg", "options": ["L", "N", "F", "D"], "correctIndex": 0},
    {"image": "assets/images/alphabet/Q13.jpg", "options": ["K", "O", "M", "R"], "correctIndex": 2},
    {"image": "assets/images/alphabet/Q14.jpg", "options": ["Z", "Y", "N", "L"], "correctIndex": 2},
    {"image": "assets/images/alphabet/Q15.jpg", "options": ["J", "L", "I", "O"], "correctIndex": 3},
    {"image": "assets/images/alphabet/Q16.jpg", "options": ["R", "P", "E", "A"], "correctIndex": 1},
    {"image": "assets/images/alphabet/Q17.jpg", "options": ["Q", "V", "F", "D"], "correctIndex": 0},
    {"image": "assets/images/alphabet/Q18.jpg", "options": ["K", "O", "R", "H"], "correctIndex": 2},
    {"image": "assets/images/alphabet/Q19.jpg", "options": ["C", "Y", "N", "S"], "correctIndex": 3},
    {"image": "assets/images/alphabet/Q20.jpg", "options": ["J", "T", "I", "O"], "correctIndex": 1},
    {"image": "assets/images/alphabet/Q21.jpg", "options": ["U", "P", "E", "J"], "correctIndex": 0},
    {"image": "assets/images/alphabet/Q22.jpg", "options": ["V", "N", "F", "D"], "correctIndex": 0},
    {"image": "assets/images/alphabet/Q23.jpg", "options": ["K", "O", "R", "W"], "correctIndex": 3},
    {"image": "assets/images/alphabet/Q24.jpg", "options": ["U", "Y", "X", "L"], "correctIndex": 2},
    {"image": "assets/images/alphabet/Q25.jpg", "options": ["J", "Y", "I", "O"], "correctIndex": 1},
    {"image": "assets/images/alphabet/Q26.jpg", "options": ["A", "L", "I", "Z"], "correctIndex": 3},
  ];

  bool _isAnsweredInSession(int qIdx) => _sessionAnswers.containsKey(qIdx);

  int _firstUnansweredSlot() {
    for (int s = 0; s < activeIndices.length; s++) {
      if (!_isAnsweredInSession(activeIndices[s])) return s;
    }
    return 0;
  }

  bool _allAnsweredInSession() {
    for (final i in activeIndices) {
      if (!_sessionAnswers.containsKey(i)) return false;
    }
    return true;
  }

  int? _nextUnansweredSlotAfter(int fromSlot) {
    for (int s = fromSlot + 1; s < activeIndices.length; s++) {
      if (!_isAnsweredInSession(activeIndices[s])) return s;
    }
    return null;
  }

  @override
  void initState() {
    super.initState();

    // Mark quest 3 when alphabet quiz opens (no SFX here)
    if (!QuestStatus.alphabetQuizStarted) {
      QuestStatus.markAlphabetQuizStarted();
      if (QuestStatus.canClaimQuest3()) {
        QuestStatus.claimQuest3();
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted) return;
          _showAchievementToast(
            icon: Icons.auto_awesome,
            title: "Quest 3 Completed!",
            subtitle: "Started Alphabet Quiz! +80 keys",
          );
        });
      }
    }

    final all = List<int>.generate(questions.length, (i) => i)..shuffle();
    final takeCount = math.min(sessionSize, all.length);
    activeIndices = all.take(takeCount).toList();

    QuestStatus.ensureLevel1Length(activeIndices.length);
    QuestStatus.resetLevel1Answers();

    int startSlot = widget.startIndex ?? _firstUnansweredSlot();
    startSlot = startSlot.clamp(0, activeIndices.length - 1);
    currentSlot = startSlot;

    _controller = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _offsetAnimation = Tween<Offset>(
      begin: const Offset(0.0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

    _controller.forward();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (currentSlot > 0 && mounted) {
        _showFloatingMessage('Resumed where you left off');
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  // ---- FAST FINISH: play sfx, show popup, quick pop ----
  void _finishSessionFast({required int sessionScore}) {
    // 1) SFX immediately
    Sfx.playQuizComplete();

    // 2) Popup (non-blocking)
    showAnimatedPopup(
      icon: Icons.emoji_events,
      title: "Quiz Complete!",
      subtitle: "Score: $sessionScore/${activeIndices.length}",
      bgColor: const Color(0xFF2C5CB0),
    );

    // 3) Pop soon (don’t block on other work)
    Future.delayed(const Duration(milliseconds: 1200), () {
      if (mounted) Navigator.of(context).pop();
    });
  }

  Future<void> handleAnswer(int selectedIndex) async {
    if (isOptionSelected) return;

    final qIdx = activeIndices[currentSlot];
    if (_sessionAnswers.containsKey(qIdx)) return;

    setState(() {
      isOptionSelected = true;
      _pendingIndex = null;
    });

    final correctIndex = questions[qIdx]['correctIndex'] as int;
    final isCorrect = selectedIndex == correctIndex;

    _sessionAnswers[qIdx] = isCorrect;
    QuestStatus.level1Answers[currentSlot] = isCorrect;

    if (isCorrect) {
      final oldLvl = QuestStatus.level;
      final levels = QuestStatus.addXp(20);

      showAnimatedPopup(
        icon: Icons.star,
        title: "Correct!",
        subtitle: "You earned 20 XP${levels > 0 ? " & leveled up!" : ""}",
        bgColor: const Color(0xFF2C5CB0),
      );

      if (levels > 0) {
        final newlyUnlocked = QuestStatus.unlockedBetween(
          oldLvl,
          QuestStatus.level,
        );
        for (final key in newlyUnlocked) {
          showAnimatedPopup(
            icon: Icons.lock_open,
            title: "New Level Unlocked!",
            subtitle: QuestStatus.titleFor(key),
            bgColor: const Color(0xFFFF4B4A),
          );
          await Future.delayed(const Duration(milliseconds: 300));
        }
      }

      if (QuestStatus.level1BestStreak >= 3 && !QuestStatus.quest4Claimed) {
        if (QuestStatus.canClaimQuest4()) {
          QuestStatus.claimQuest4();
          showAnimatedPopup(
            icon: Icons.whatshot,
            title: "Quest 4 Complete!",
            subtitle: "3 correct in a row! +120 keys",
            bgColor: const Color(0xFFFF4B4A),
          );
          await Future.delayed(const Duration(milliseconds: 800));
        }
      }
    } else {
      final correctLetter =
      (questions[qIdx]['options'] as List<String>)[correctIndex];
      showAnimatedPopup(
        icon: Icons.close,
        title: "Incorrect",
        subtitle: "Correct: $correctLetter",
        bgColor: const Color(0xFFFF4B4A),
      );
    }

    await Future.delayed(const Duration(milliseconds: 250));

    // ====== FINISH SESSION (non-blocking) ======
    if (_allAnsweredInSession()) {
      if (!mounted) return;

      final sessionScore =
          activeIndices.where((i) => _sessionAnswers[i] == true).length;

      // Play quiz-complete sound and pop soon.
      _finishSessionFast(sessionScore: sessionScore);

      // Fire-and-forget achievements/quests AFTER we scheduled the pop.
      // ---------------------------------------------------------------
      // Round counter
      QuestStatus.alphabetRoundsCompleted += 1;

      // Quest 5 (3 rounds)
      if (QuestStatus.alphabetRoundsCompleted >= 3 && !QuestStatus.quest5Claimed) {
        if (QuestStatus.canClaimQuest5()) {
          QuestStatus.claimQuest5();
          showAnimatedPopup(
            icon: Icons.military_tech,
            title: "Quest 5 Complete!",
            subtitle: "3 rounds finished! +200 keys",
            bgColor: const Color(0xFFFF4B4A),
          );
        }
      }

      // Quest 6 (perfect round)
      if (sessionScore == activeIndices.length && !QuestStatus.quest6Claimed) {
        if (QuestStatus.canClaimQuest6()) {
          QuestStatus.claimQuest6();
          showAnimatedPopup(
            icon: Icons.stars,
            title: "Quest 6 Complete!",
            subtitle: "Perfect round! +250 keys",
            bgColor: const Color(0xFF2C5CB0),
          );
        }
      }

      // Medal (first quiz)
      final justEarned = QuestStatus.markFirstQuizMedalEarned();
      if (justEarned && mounted) {
        showAnimatedPopup(
          icon: Icons.military_tech,
          title: "Medal unlocked!",
          subtitle: "Finish your first quiz",
          bgColor: const Color(0xFFFF4B4A),
        );
      }

      // Streak increase (also plays SFX)
      final didIncrease = QuestStatus.addStreakForLevel();
      if (didIncrease && mounted) {
        Sfx.playStreak();
        showAnimatedPopup(
          icon: Icons.local_fire_department,
          title: "Streak +1!",
          subtitle:
          "Current streak: ${QuestStatus.streakDays} day${QuestStatus.streakDays == 1 ? '' : 's'}",
          bgColor: const Color(0xFF2C5CB0),
        );
      }

      // We already scheduled pop above.
      return;
    }

    // Continue to next question
    final nextSlot = _nextUnansweredSlotAfter(currentSlot);
    setState(() {
      currentSlot = (nextSlot ?? (currentSlot + 1)).clamp(
        0,
        activeIndices.length - 1,
      );
      isOptionSelected = false;
      _pendingIndex = null;
      _controller.reset();
      _controller.forward();
    });
  }

  void _showFloatingMessage(String message) {
    final overlay = Overlay.of(context);
    final entry = OverlayEntry(
      builder: (_) => Positioned(
        top: 100,
        left: 0,
        right: 0,
        child: Center(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: const Color(0xFF2C5CB0),
              borderRadius: BorderRadius.circular(22),
            ),
            child: Text(
              message,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ),
    );

    overlay.insert(entry);
    Future.delayed(const Duration(seconds: 2), () => entry.remove());
  }

  // -------------------- TWO-STEP SIMPLE CONFIRM UI --------------------
  Future<bool> _confirmExitQuiz() async {
    // Step 1 — soft warning
    final first = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (_) => const _CleanConfirmDialog(
        icon: Icons.logout_rounded,
        title: 'Leave quiz?',
        message: "Your current progress will be lost.",
        primaryLabel: 'Continue',
        secondaryLabel: 'Cancel',
      ),
    );
    if (first != true) return false;

    // Step 2 — final confirmation
    final second = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (_) => const _CleanConfirmDialog(
        icon: Icons.warning_amber_rounded,
        title: 'Are you sure?',
        message:
        "This action can’t be undone and your progress this round will be lost.",
        primaryLabel: 'Leave',
        secondaryLabel: 'Stay',
      ),
    );
    return second == true;
  }

  // Back handler used by the header back icon
  Future<void> _handleBackPressed() async {
    final shouldExit = await _confirmExitQuiz();
    if (shouldExit && mounted) {
      Navigator.pop(context);
    }
  }
  // -------------------------------------------------------------------

  void _showAchievementToast({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    final overlay = Overlay.of(context);
    final entry = OverlayEntry(
      builder: (_) => Positioned(
        top: 60,
        left: 20,
        right: 20,
        child: Material(
          elevation: 8,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF2C5CB0),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                Icon(icon, color: Colors.white),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title,
                          style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold)),
                      const SizedBox(height: 2),
                      Text(subtitle,
                          style: const TextStyle(
                              color: Colors.white70, fontSize: 12)),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );

    overlay.insert(entry);
    Future.delayed(const Duration(seconds: 3), () => entry.remove());
  }

  // Simple slide-in popup kept from your original flow
  void showAnimatedPopup({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color bgColor,
  }) {
    final overlay = Overlay.of(context);
    final entry = OverlayEntry(
      builder: (_) => Positioned(
        top: 60,
        right: 16,
        child: _SlideInBadge(
          icon: icon,
          title: title,
          subtitle: subtitle,
          color: bgColor,
        ),
      ),
    );
    overlay.insert(entry);
    Future.delayed(const Duration(seconds: 2), () => entry.remove());
  }

  @override
  Widget build(BuildContext context) {
    final qIdx = activeIndices[currentSlot];
    final question = questions[qIdx];
    final options = question['options'] as List<String>;

    return WillPopScope(
      onWillPop: () async => await _confirmExitQuiz(),
      child: Scaffold(
        backgroundColor: const Color(0xFFFAFFDC),
        body: SafeArea(
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: SlideTransition(
              position: _offsetAnimation,
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  children: [
                    _buildHeader(),
                    const SizedBox(height: 12),
                    _buildProgressBar(),
                    const SizedBox(height: 16),
                    _buildQuestionCard(question),
                    const SizedBox(height: 32),
                    _buildOptionsGrid(options, qIdx, question),
                    const SizedBox(height: 12),
                    if (_pendingIndex != null) _buildConfirmBar(options),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildConfirmBar(List<String> options) {
    final idx = _pendingIndex!;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF6F7FB),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE3E6EE)),
      ),
      child: Row(
        children: [
          const Icon(Icons.touch_app, size: 18, color: Color(0xFF2C5CB0)),
          const SizedBox(width: 8),
          Text('Selected: ${options[idx]}',
              style: const TextStyle(
                  color: Color(0xFF2C5CB0), fontWeight: FontWeight.w600)),
          const Spacer(),
          TextButton(
            onPressed: () => setState(() => _pendingIndex = null),
            child: const Text('Cancel'),
          ),
          const SizedBox(width: 8),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2C5CB0),
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            onPressed: () {
              final i = _pendingIndex;
              if (i != null) handleAnswer(i);
            },
            child: const Text('Confirm'),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        IconButton(
          onPressed: _handleBackPressed,
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFFEFF3FF),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.arrow_back_ios_new_rounded,
              color: Color(0xFF2C5CB0),
              size: 20,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Alphabet Quiz",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2C5CB0),
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                "Question ${currentSlot + 1} of ${activeIndices.length}",
                style: const TextStyle(fontSize: 14, color: Colors.black54),
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: const Color(0xFF2C5CB0),
            borderRadius: BorderRadius.circular(18),
          ),
          child: Row(
            children: [
              const Icon(Icons.bolt_rounded, color: Colors.white, size: 16),
              const SizedBox(width: 4),
              Text(
                "Lvl ${QuestStatus.level}",
                style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: Colors.white),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildProgressBar() {
    final total = activeIndices.length;
    int correct = 0;
    int wrong = 0;
    for (final i in activeIndices) {
      if (_sessionAnswers.containsKey(i)) {
        if (_sessionAnswers[i] == true) correct++;
        if (_sessionAnswers[i] == false) wrong++;
      }
    }
    final remaining = (total - correct - wrong).clamp(0, total);

    Widget segment({
      required Color color,
      required int flex,
      required BorderRadius radius,
    }) {
      if (flex <= 0) return const SizedBox.shrink();
      return Expanded(
        flex: flex,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          decoration: BoxDecoration(color: color, borderRadius: radius),
          height: 10,
        ),
      );
    }

    final hasCorrect = correct > 0;
    final hasWrong = wrong > 0;
    final hasRemaining = remaining > 0;

    final bars = <Widget>[];
    if (hasCorrect) {
      bars.add(
        segment(
          color: const Color(0xFF44b427),
          flex: correct,
          radius: hasWrong || hasRemaining
              ? const BorderRadius.horizontal(left: Radius.circular(8))
              : BorderRadius.circular(8),
        ),
      );
    }
    if (hasWrong) {
      if (bars.isNotEmpty) bars.add(const SizedBox(width: 1));
      bars.add(
        segment(
          color: const Color(0xFFFF4B4A),
          flex: wrong,
          radius: (!hasCorrect && !hasRemaining)
              ? BorderRadius.circular(8)
              : BorderRadius.zero,
        ),
      );
    }
    if (hasRemaining) {
      if (bars.isNotEmpty) bars.add(const SizedBox(width: 1));
      bars.add(
        segment(
          color: const Color(0xFFE8EEF9),
          flex: remaining,
          radius: (hasCorrect || hasWrong)
              ? const BorderRadius.horizontal(right: Radius.circular(8))
              : BorderRadius.circular(8),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 2),
          decoration: BoxDecoration(
            color: const Color(0xFFF2F6FF),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: const Color(0xFFE3E6EE)),
          ),
          child: Row(children: bars),
        ),
        const SizedBox(height: 6),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: const [
            _LegendDot(label: 'Correct', color: Color(0xFF44b427)),
            _LegendDot(label: 'Wrong', color: Color(0xFFFF4B4A)),
          ],
        ),
      ],
    );
  }

  Widget _buildQuestionCard(Map<String, dynamic> question) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FBFF),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFE3E6EE)),
      ),
      child: Column(
        children: [
          const Text(
            "What sign is shown?",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: Color(0xFF2C5CB0),
              letterSpacing: -0.3,
            ),
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFFE3E6EE)),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.asset(
                question['image'],
                fit: BoxFit.contain,
                height: 140,
                errorBuilder: (context, error, stack) {
                  return const SizedBox(
                    height: 140,
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.broken_image_rounded,
                              size: 36, color: Colors.grey),
                          SizedBox(height: 8),
                          Text('Image not found',
                              style: TextStyle(color: Colors.grey)),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOptionsGrid(
      List<String> options,
      int qIdx,
      Map<String, dynamic> question,
      ) {
    return Expanded(
      child: GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 1.6,
          mainAxisSpacing: 16,
          crossAxisSpacing: 16,
        ),
        itemCount: options.length,
        itemBuilder: (context, index) {
          final alreadyAnswered = _sessionAnswers.containsKey(qIdx);
          final isCorrect = index == question['correctIndex'];
          final wasSelected =
              alreadyAnswered && _sessionAnswers[qIdx] == isCorrect && isCorrect;
          final isPending = !alreadyAnswered && _pendingIndex == index;

          return OptionCard(
            option: options[index],
            number: index + 1,
            isSelected: wasSelected,
            isPending: isPending,
            onTap: alreadyAnswered
                ? null
                : () => setState(() => _pendingIndex = index),
          );
        },
      ),
    );
  }
}

// ---------- Minimal widgets ----------

class OptionCard extends StatelessWidget {
  final String option;
  final int number;
  final bool isSelected;
  final bool isPending;
  final VoidCallback? onTap;

  const OptionCard({
    super.key,
    required this.option,
    required this.number,
    this.isSelected = false,
    this.isPending = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isSelected
              ? const Color(0xFF2C5CB0)
              : (isPending ? const Color(0xFF311E76) : const Color(0xFFE3E6EE)),
          width: isSelected || isPending ? 2 : 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 16,
                  backgroundColor: const Color(0xFF2C5CB0),
                  child: Text(
                    number.toString(),
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    option,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: isSelected ? Colors.black : const Color(0xFF2C5CB0),
                    ),
                  ),
                ),
                if (isSelected) const Icon(Icons.check_circle, color: Color(0xFF2C5CB0)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _LegendDot extends StatelessWidget {
  final String label;
  final Color color;

  const _LegendDot({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(width: 10, height: 10, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 6),
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.black54, fontWeight: FontWeight.w600)),
      ],
    );
  }
}

class _SlideInBadge extends StatefulWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  const _SlideInBadge({required this.icon, required this.title, required this.subtitle, required this.color});

  @override
  State<_SlideInBadge> createState() => _SlideInBadgeState();
}

class _SlideInBadgeState extends State<_SlideInBadge> with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(vsync: this, duration: const Duration(milliseconds: 280))..forward();
  late final Animation<Offset> _a = Tween<Offset>(begin: const Offset(1.1, 0), end: Offset.zero).animate(CurvedAnimation(parent: _c, curve: Curves.easeOut));

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: _a,
      child: Material(
        elevation: 6,
        borderRadius: BorderRadius.circular(12),
        color: widget.color,
        child: Container(
          width: 280,
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Icon(widget.icon, color: Colors.white),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(widget.title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    Text(widget.subtitle, style: const TextStyle(color: Colors.white70)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ---------- Clean, Simple Confirm Dialog ----------
class _CleanConfirmDialog extends StatelessWidget {
  final IconData icon;
  final String title;
  final String message;
  final String primaryLabel;   // right button
  final String secondaryLabel; // left button

  const _CleanConfirmDialog({
    required this.icon,
    required this.title,
    required this.message,
    required this.primaryLabel,
    required this.secondaryLabel,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Soft circular icon
            Container(
              width: 64,
              height: 64,
              decoration: const BoxDecoration(
                color: Color(0xFFF4F7FF),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 34, color: Color(0xFF2C5CB0)),
            ),
            const SizedBox(height: 16),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: Color(0xFF1E1E1E),
                letterSpacing: -0.2,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 14.5,
                color: Color(0xFF6B7280),
                height: 1.35,
              ),
            ),
            const SizedBox(height: 18),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context, false),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Color(0xFFE5E7EB)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      foregroundColor: const Color(0xFF2C5CB0),
                    ),
                    child: Text(
                      secondaryLabel,
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context, true),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFF4B4A),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: Text(
                      primaryLabel,
                      style: const TextStyle(fontWeight: FontWeight.w800),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
