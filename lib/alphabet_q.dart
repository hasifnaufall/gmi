// lib/alphabet_q.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:math' as math;

import 'quest_status.dart';
import 'services/sfx_service.dart'; // <-- uses your singleton Sfx()

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
    {
      "image": "assets/images/alphabet/Q1.jpg",
      "options": ["P", "A", "E", "S"],
      "correctIndex": 1,
    },
    {
      "image": "assets/images/alphabet/Q2.jpg",
      "options": ["W", "U", "F", "B"],
      "correctIndex": 3,
    },
    {
      "image": "assets/images/alphabet/Q3.jpg",
      "options": ["C", "Z", "R", "H"],
      "correctIndex": 0,
    },
    {
      "image": "assets/images/alphabet/Q4.jpg",
      "options": ["U", "Y", "D", "L"],
      "correctIndex": 2,
    },
    {
      "image": "assets/images/alphabet/Q5.jpg",
      "options": ["J", "E", "I", "O"],
      "correctIndex": 1,
    },
    {
      "image": "assets/images/alphabet/Q6.jpg",
      "options": ["M", "F", "E", "S"],
      "correctIndex": 1,
    },
    {
      "image": "assets/images/alphabet/Q7.jpg",
      "options": ["X", "N", "G", "D"],
      "correctIndex": 2,
    },
    {
      "image": "assets/images/alphabet/Q8.jpg",
      "options": ["H", "O", "R", "Q"],
      "correctIndex": 0,
    },
    {
      "image": "assets/images/alphabet/Q9.jpg",
      "options": ["U", "Y", "N", "I"],
      "correctIndex": 3,
    },
    {
      "image": "assets/images/alphabet/Q10.jpg",
      "options": ["Z", "L", "I", "J"],
      "correctIndex": 3,
    },
    {
      "image": "assets/images/alphabet/Q11.jpg",
      "options": ["O", "K", "E", "S"],
      "correctIndex": 1,
    },
    {
      "image": "assets/images/alphabet/Q12.jpg",
      "options": ["L", "N", "F", "D"],
      "correctIndex": 0,
    },
    {
      "image": "assets/images/alphabet/Q13.jpg",
      "options": ["K", "O", "M", "R"],
      "correctIndex": 2,
    },
    {
      "image": "assets/images/alphabet/Q14.jpg",
      "options": ["Z", "Y", "N", "L"],
      "correctIndex": 2,
    },
    {
      "image": "assets/images/alphabet/Q15.jpg",
      "options": ["J", "L", "I", "O"],
      "correctIndex": 3,
    },
    {
      "image": "assets/images/alphabet/Q16.jpg",
      "options": ["R", "P", "E", "A"],
      "correctIndex": 1,
    },
    {
      "image": "assets/images/alphabet/Q17.jpg",
      "options": ["Q", "V", "F", "D"],
      "correctIndex": 0,
    },
    {
      "image": "assets/images/alphabet/Q18.jpg",
      "options": ["K", "O", "R", "H"],
      "correctIndex": 2,
    },
    {
      "image": "assets/images/alphabet/Q19.jpg",
      "options": ["C", "Y", "N", "S"],
      "correctIndex": 3,
    },
    {
      "image": "assets/images/alphabet/Q20.jpg",
      "options": ["J", "T", "I", "O"],
      "correctIndex": 1,
    },
    {
      "image": "assets/images/alphabet/Q21.jpg",
      "options": ["U", "P", "E", "J"],
      "correctIndex": 0,
    },
    {
      "image": "assets/images/alphabet/Q22.jpg",
      "options": ["V", "N", "F", "D"],
      "correctIndex": 0,
    },
    {
      "image": "assets/images/alphabet/Q23.jpg",
      "options": ["K", "O", "R", "W"],
      "correctIndex": 3,
    },
    {
      "image": "assets/images/alphabet/Q24.jpg",
      "options": ["U", "Y", "X", "L"],
      "correctIndex": 2,
    },
    {
      "image": "assets/images/alphabet/Q25.jpg",
      "options": ["J", "Y", "I", "O"],
      "correctIndex": 1,
    },
    {
      "image": "assets/images/alphabet/Q26.jpg",
      "options": ["A", "L", "I", "Z"],
      "correctIndex": 3,
    },
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

    // Init SFX once (safe to call multiple times)
    Sfx().init();

    // Mark quest 3 when alphabet quiz opens (no extra popups here)
    if (!QuestStatus.alphabetQuizStarted) {
      QuestStatus.markAlphabetQuizStarted();
      if (QuestStatus.canClaimQuest3()) {
        QuestStatus.claimQuest3();
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

    // Visual feedback only (Option B = no per-answer sound)
    if (isCorrect) {
      showAnimatedPopup(
        icon: Icons.star,
        title: "Correct!",
        subtitle: "You earned 20 XP",
        bgColor: const Color(0xFF2C5CB0),
      );
      QuestStatus.addXp(20);
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

    // ====== FINISH SESSION (Option B sounds here) ======
    if (_allAnsweredInSession()) {
      if (!mounted) return;

      final sessionScore = activeIndices
          .where((i) => _sessionAnswers[i] == true)
          .length;

      // ---- Update counters/quests silently ----
      QuestStatus.alphabetRoundsCompleted += 1;

      if (QuestStatus.alphabetRoundsCompleted >= 3 &&
          !QuestStatus.quest5Claimed) {
        if (QuestStatus.canClaimQuest5()) {
          QuestStatus.claimQuest5();
        }
      }

      if (sessionScore == activeIndices.length && !QuestStatus.quest6Claimed) {
        if (QuestStatus.canClaimQuest6()) {
          QuestStatus.claimQuest6();
        }
      }

      QuestStatus.markFirstQuizMedalEarned();

      // Streak increase check
      final didIncrease = QuestStatus.addStreakForLevel();
      if (didIncrease) {
        // Play the streak sound (Option B)
        await Sfx().playStreak();
      }

      // Play end-of-round jingle (Option B)
      await Sfx().playLevelComplete();

      // Show the big result dialog (Score only, “Perfection” if perfect)
      await showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => _GreatWorkDialog(
          score: sessionScore,
          total: activeIndices.length,
          onReturn: () {
            Navigator.of(context).pop(); // close dialog
            Navigator.of(context).pop(); // back to QuizCategory
          },
        ),
      );

      return;
    }

    // Move to next question
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

  // Simple slide-in popup (small badge)
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
    final options = (question['options'] as List)
        .map((e) => e.toString())
        .toList();

    return WillPopScope(
      onWillPop: () async => await _confirmExitQuiz(),
      child: Scaffold(
        backgroundColor: const Color(0xFFCFFFF7), // Light mint background
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
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFFFFFFF), Color(0xFFF0FDFA)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF69D3E4), width: 2),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF69D3E4).withOpacity(0.2),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF69D3E4), Color(0xFF4FC3E4)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.touch_app, size: 18, color: Colors.white),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'Selected: ${options[idx]}',
              style: GoogleFonts.montserrat(
                color: const Color(0xFF69D3E4),
                fontWeight: FontWeight.w700,
                fontSize: 15,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: 8),
          TextButton(
            onPressed: () => setState(() => _pendingIndex = null),
            child: Text(
              'Cancel',
              style: GoogleFonts.montserrat(color: Colors.grey.shade600),
            ),
          ),
          const SizedBox(width: 8),
          ElevatedButton(
            style:
                ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ).copyWith(
                  backgroundColor: MaterialStateProperty.all(
                    Colors.transparent,
                  ),
                ),
            onPressed: () {
              final i = _pendingIndex;
              if (i != null) handleAnswer(i);
            },
            child: Ink(
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF69D3E4), Color(0xFF4FC3E4)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
                child: Text(
                  'Confirm',
                  style: GoogleFonts.montserrat(fontWeight: FontWeight.w700),
                ),
              ),
            ),
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
              gradient: const LinearGradient(
                colors: [Color(0xFFFFFFFF), Color(0xFFF0FDFA)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: const Color(0xFF69D3E4).withOpacity(0.3),
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF69D3E4).withOpacity(0.15),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: const Icon(
              Icons.arrow_back_ios_new_rounded,
              color: Color(0xFF69D3E4),
              size: 20,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Alphabet Quiz",
                style: GoogleFonts.montserrat(
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF69D3E4),
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                "Question ${currentSlot + 1} of ${activeIndices.length}",
                style: GoogleFonts.montserrat(
                  fontSize: 14,
                  color: Colors.black54,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF69D3E4), Color(0xFF4FC3E4)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF69D3E4).withOpacity(0.3),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              const Icon(Icons.bolt_rounded, color: Colors.white, size: 16),
              const SizedBox(width: 4),
              Text(
                "Lvl ${QuestStatus.level}",
                style: GoogleFonts.montserrat(
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
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
          height: 12,
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
          color: const Color(0xFF22C55E),
          flex: correct,
          radius: hasWrong || hasRemaining
              ? const BorderRadius.horizontal(left: Radius.circular(10))
              : BorderRadius.circular(10),
        ),
      );
    }
    if (hasWrong) {
      if (bars.isNotEmpty) bars.add(const SizedBox(width: 2));
      bars.add(
        segment(
          color: const Color(0xFFFF4B4A),
          flex: wrong,
          radius: (!hasCorrect && !hasRemaining)
              ? BorderRadius.circular(10)
              : BorderRadius.zero,
        ),
      );
    }
    if (hasRemaining) {
      if (bars.isNotEmpty) bars.add(const SizedBox(width: 2));
      bars.add(
        segment(
          color: const Color(0xFFE0F2F1),
          flex: remaining,
          radius: (hasCorrect || hasWrong)
              ? const BorderRadius.horizontal(right: Radius.circular(10))
              : BorderRadius.circular(10),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          padding: const EdgeInsets.all(3),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.white, const Color(0xFFF0FDFA)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFF69D3E4).withOpacity(0.3)),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF69D3E4).withOpacity(0.1),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(children: bars),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _LegendDot(label: 'Correct', color: Color(0xFF22C55E)),
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
        gradient: const LinearGradient(
          colors: [Color(0xFFFFFFFF), Color(0xFFF0FDFA)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: const Color(0xFF69D3E4).withOpacity(0.3),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF69D3E4).withOpacity(0.15),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            "What sign is shown?",
            textAlign: TextAlign.center,
            style: GoogleFonts.montserrat(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: const Color(0xFF69D3E4),
              letterSpacing: -0.3,
            ),
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: const Color(0xFF69D3E4).withOpacity(0.2),
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF69D3E4).withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.asset(
                question['image'],
                fit: BoxFit.contain,
                height: 140,
                errorBuilder: (context, error, stack) {
                  return SizedBox(
                    height: 140,
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.broken_image_rounded,
                            size: 36,
                            color: Colors.grey,
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Image not found',
                            style: TextStyle(color: Colors.grey),
                          ),
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
              alreadyAnswered &&
              _sessionAnswers[qIdx] == isCorrect &&
              isCorrect;
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
        gradient: isSelected || isPending
            ? const LinearGradient(
                colors: [Color(0xFFFFFFFF), Color(0xFFF0FDFA)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              )
            : const LinearGradient(
                colors: [Color(0xFFFFFFFF), Color(0xFFFAFAFA)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isSelected
              ? const Color(0xFF69D3E4)
              : (isPending ? const Color(0xFF4FC3E4) : const Color(0xFFE3E6EE)),
          width: isSelected || isPending ? 2.5 : 1.5,
        ),
        boxShadow: [
          if (isSelected || isPending)
            BoxShadow(
              color: const Color(0xFF69D3E4).withOpacity(0.25),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
        ],
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
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF69D3E4), Color(0xFF4FC3E4)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF69D3E4).withOpacity(0.3),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      number.toString(),
                      style: GoogleFonts.montserrat(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                        fontSize: 15,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    option,
                    style: GoogleFonts.montserrat(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: isSelected || isPending
                          ? const Color(0xFF69D3E4)
                          : const Color(0xFF2D5263),
                    ),
                  ),
                ),
                if (isSelected)
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF69D3E4), Color(0xFF4FC3E4)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.check,
                      color: Colors.white,
                      size: 18,
                    ),
                  ),
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
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.3),
                blurRadius: 4,
                offset: const Offset(0, 1),
              ),
            ],
          ),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: GoogleFonts.montserrat(
            fontSize: 12,
            color: Colors.black54,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

class _SlideInBadge extends StatefulWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  const _SlideInBadge({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
  });

  @override
  State<_SlideInBadge> createState() => _SlideInBadgeState();
}

class _SlideInBadgeState extends State<_SlideInBadge>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 280),
  )..forward();
  late final Animation<Offset> _a = Tween<Offset>(
    begin: const Offset(1.1, 0),
    end: Offset.zero,
  ).animate(CurvedAnimation(parent: _c, curve: Curves.easeOut));

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
        elevation: 8,
        borderRadius: BorderRadius.circular(16),
        color: Colors.transparent,
        child: Container(
          width: 300,
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: widget.color == const Color(0xFF2C5CB0)
                  ? [const Color(0xFF69D3E4), const Color(0xFF4FC3E4)]
                  : [widget.color, widget.color.withOpacity(0.8)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: widget.color == const Color(0xFF2C5CB0)
                    ? const Color(0xFF69D3E4).withOpacity(0.4)
                    : widget.color.withOpacity(0.4),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(widget.icon, color: Colors.white, size: 24),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.title,
                      style: GoogleFonts.montserrat(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                        fontSize: 16,
                      ),
                    ),
                    Text(
                      widget.subtitle,
                      style: GoogleFonts.montserrat(
                        color: Colors.white.withOpacity(0.9),
                        fontSize: 13,
                      ),
                    ),
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
  final String primaryLabel; // right button
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
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      backgroundColor: Colors.transparent,
      child: Container(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFFFAFAFA), Color(0xFFF0FDFA)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: const Color(0xFF69D3E4).withOpacity(0.3),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF69D3E4).withOpacity(0.2),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 28, 20, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Gradient circular icon
              Container(
                width: 110,
                height: 110,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: icon == Icons.warning_amber_rounded
                        ? [const Color(0xFFFF4B4A), const Color(0xFFFF6B6A)]
                        : [const Color(0xFF69D3E4), const Color(0xFF4FC3E4)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color:
                          (icon == Icons.warning_amber_rounded
                                  ? const Color(0xFFFF4B4A)
                                  : const Color(0xFF69D3E4))
                              .withOpacity(0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Icon(icon, size: 56, color: Colors.white),
              ),

              const SizedBox(height: 20),
              Text(
                title,
                textAlign: TextAlign.center,
                style: GoogleFonts.montserrat(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF1E1E1E),
                  letterSpacing: -0.3,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                message,
                textAlign: TextAlign.center,
                style: GoogleFonts.montserrat(
                  fontSize: 15,
                  color: const Color(0xFF6B7280),
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 22),
              Row(
                children: [
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFFFAFAFA), Color(0xFFFFFFFF)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: const Color(0xFF69D3E4).withOpacity(0.5),
                          width: 2,
                        ),
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () => Navigator.pop(context, false),
                          borderRadius: BorderRadius.circular(14),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            alignment: Alignment.center,
                            child: Text(
                              secondaryLabel,
                              style: GoogleFonts.montserrat(
                                fontWeight: FontWeight.w700,
                                fontSize: 15,
                                color: const Color(0xFF69D3E4),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFFFF4B4A), Color(0xFFFF6B6A)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFFFF4B4A).withOpacity(0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () => Navigator.pop(context, true),
                          borderRadius: BorderRadius.circular(14),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            alignment: Alignment.center,
                            child: Text(
                              primaryLabel,
                              style: GoogleFonts.montserrat(
                                fontWeight: FontWeight.w800,
                                fontSize: 15,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
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
}

class _GreatWorkDialog extends StatelessWidget {
  final int score;
  final int total;
  final VoidCallback onReturn;

  const _GreatWorkDialog({
    required this.score,
    required this.total,
    required this.onReturn,
  });

  bool get isPerfect => score == total;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
      backgroundColor: Colors.transparent,
      child: Container(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFFFAFAFA), Color(0xFFF0FDFA)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(28),
          border: Border.all(
            color: const Color(0xFF69D3E4).withOpacity(0.3),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF69D3E4).withOpacity(0.25),
              blurRadius: 24,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 36, 24, 28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Trophy Icon with gradient
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: isPerfect
                        ? [const Color(0xFFFFD700), const Color(0xFFFFA500)]
                        : [const Color(0xFF69D3E4), const Color(0xFF4FC3E4)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color:
                          (isPerfect
                                  ? const Color(0xFFFFD700)
                                  : const Color(0xFF69D3E4))
                              .withOpacity(0.4),
                      blurRadius: 16,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: ClipOval(
                  child: Image.asset(
                    'assets/gifs/trophy_quiz.gif',
                    fit: BoxFit.cover,
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Title with gradient text
              ShaderMask(
                shaderCallback: (bounds) => LinearGradient(
                  colors: isPerfect
                      ? [const Color(0xFFFFD700), const Color(0xFFFFA500)]
                      : [const Color(0xFF69D3E4), const Color(0xFF4FC3E4)],
                ).createShader(bounds),
                child: Text(
                  isPerfect ? "Perfection!" : "Great Work!",
                  textAlign: TextAlign.center,
                  style: GoogleFonts.montserrat(
                    fontSize: 34,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                    letterSpacing: -0.5,
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // Subtitle
              Text(
                isPerfect
                    ? "You answered every question flawlessly."
                    : "You completed this quiz successfully!",
                textAlign: TextAlign.center,
                style: GoogleFonts.montserrat(
                  fontSize: 16,
                  color: const Color(0xFF4B5563),
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 26),

              // Score Display with gradient
              Container(
                padding: const EdgeInsets.symmetric(
                  vertical: 24,
                  horizontal: 28,
                ),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFFFFFFF), Color(0xFFF0FDFA)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: const Color(0xFF69D3E4).withOpacity(0.3),
                    width: 1.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF69D3E4).withOpacity(0.15),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Center(
                  child: ShaderMask(
                    shaderCallback: (bounds) => const LinearGradient(
                      colors: [Color(0xFF69D3E4), Color(0xFF4FC3E4)],
                    ).createShader(bounds),
                    child: Text(
                      "$score / $total",
                      style: GoogleFonts.montserrat(
                        fontSize: 40,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                        letterSpacing: -1,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 32),

              // Return button with gradient
              SizedBox(
                width: double.infinity,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF69D3E4), Color(0xFF4FC3E4)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF69D3E4).withOpacity(0.4),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: onReturn,
                      borderRadius: BorderRadius.circular(16),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.arrow_back_rounded,
                              size: 24,
                              color: Colors.white,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Return',
                              style: GoogleFonts.montserrat(
                                fontSize: 18,
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
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
}
