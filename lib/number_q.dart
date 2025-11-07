// lib/number_q.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'quest_status.dart';
import 'quiz_category.dart'; // <-- navigate back to category
import 'services/sfx_service.dart'; // <-- sound service

class NumberQuizScreen extends StatefulWidget {
  final int? startIndex;
  const NumberQuizScreen({super.key, this.startIndex});

  @override
  State<NumberQuizScreen> createState() => _NumberQuizScreenState();
}

class _NumberQuizScreenState extends State<NumberQuizScreen>
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
      "image": "assets/images/number/N1.jpg",
      "options": ["11", "7", "1", "10"],
      "correctIndex": 2,
    },
    {
      "image": "assets/images/number/N2.jpg",
      "options": ["2", "5", "8", "3"],
      "correctIndex": 0,
    },
    {
      "image": "assets/images/number/N3.jpg",
      "options": ["9", "3", "6", "12"],
      "correctIndex": 1,
    },
    {
      "image": "assets/images/number/N4.jpg",
      "options": ["11", "14", "20", "4"],
      "correctIndex": 3,
    },
    {
      "image": "assets/images/number/N5.jpg",
      "options": ["6", "10", "5", "15"],
      "correctIndex": 2,
    },
    {
      "image": "assets/images/number/N6.jpg",
      "options": ["3", "18", "6", "19"],
      "correctIndex": 2,
    },
    {
      "image": "assets/images/number/N7.jpg",
      "options": ["14", "12", "10", "7"],
      "correctIndex": 3,
    },
    {
      "image": "assets/images/number/N8.jpg",
      "options": ["7", "12", "8", "20"],
      "correctIndex": 2,
    },
    {
      "image": "assets/images/number/N9.jpg",
      "options": ["9", "19", "18", "8"],
      "correctIndex": 0,
    },
    {
      "image": "assets/images/number/N10.jpg",
      "options": ["6", "10", "15", "20"],
      "correctIndex": 1,
    },
    {
      "image": "assets/images/number/N11.jpg",
      "options": ["10", "16", "1", "11"],
      "correctIndex": 3,
    },
    {
      "image": "assets/images/number/N12.jpg",
      "options": ["14", "2", "12", "20"],
      "correctIndex": 2,
    },
    {
      "image": "assets/images/number/N13.jpg",
      "options": ["18", "3", "13", "16"],
      "correctIndex": 2,
    },
    {
      "image": "assets/images/number/N14.jpg",
      "options": ["4", "12", "7", "14"],
      "correctIndex": 3,
    },
    {
      "image": "assets/images/number/N15.jpg",
      "options": ["5", "10", "15", "20"],
      "correctIndex": 2,
    },
    {
      "image": "assets/images/number/N16.jpg",
      "options": ["16", "4", "7", "19"],
      "correctIndex": 0,
    },
    {
      "image": "assets/images/number/N17.jpg",
      "options": ["11", "1", "17", "9"],
      "correctIndex": 2,
    },
    {
      "image": "assets/images/number/N18.jpg",
      "options": ["8", "13", "6", "18"],
      "correctIndex": 3,
    },
    {
      "image": "assets/images/number/N19.jpg",
      "options": ["16", "20", "19", "7"],
      "correctIndex": 2,
    },
    {
      "image": "assets/images/number/N20.jpg",
      "options": ["15", "10", "20", "14"],
      "correctIndex": 2,
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

    // Prepare sound effects (safe to call more than once)
    Sfx().init();

    final all = List<int>.generate(questions.length, (i) => i)..shuffle();
    final take = all.length < sessionSize ? all.length : sessionSize;
    activeIndices = all.take(take).toList();

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
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<bool> _confirmExitQuiz() async {
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

    final second = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (_) => const _CleanConfirmDialog(
        icon: Icons.warning_amber_rounded,
        title: 'Are you sure?',
        message:
            "This action can't be undone and your progress this round will be lost.",
        primaryLabel: 'Leave',
        secondaryLabel: 'Stay',
      ),
    );
    return second == true;
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

    if (isCorrect) {
      final oldLvl = QuestStatus.level;
      final levels = QuestStatus.addXp(20);
      _showToast(
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
          _showToast(
            icon: Icons.lock_open,
            title: "New Level Unlocked!",
            subtitle: QuestStatus.titleFor(key),
            bgColor: const Color(0xFFFF4B4A),
          );
          await Future.delayed(const Duration(milliseconds: 300));
        }
      }
    } else {
      final correctValue =
          (questions[qIdx]['options'] as List<dynamic>)[correctIndex]
              .toString();
      _showToast(
        icon: Icons.close,
        title: "Incorrect",
        subtitle: "Correct: $correctValue",
        bgColor: const Color(0xFFFF4B4A),
      );
    }

    await Future.delayed(const Duration(milliseconds: 250));

    if (_allAnsweredInSession()) {
      if (!mounted) return;

      final sessionScore = activeIndices
          .where((i) => _sessionAnswers[i] == true)
          .length;
      _showToast(
        icon: Icons.emoji_events,
        title: "Quiz Complete!",
        subtitle: "Score: $sessionScore/${activeIndices.length}",
        bgColor: const Color(0xFF2C5CB0),
      );

      // Play "level complete" SFX
      await Sfx().playLevelComplete();

      final total = activeIndices.length;
      final isPerfect = sessionScore == total;
      QuestStatus.numbersRoundsCompleted += 1;

      if (isPerfect) {
        QuestStatus.numbersPerfectRounds += 1;
        if (QuestStatus.canClaimQuest9()) {
          QuestStatus.claimQuest9();
          await Future.delayed(const Duration(milliseconds: 500));
          _showToast(
            icon: Icons.stars,
            title: "Quest 9 Complete!",
            subtitle: "Perfect round! +200 keys",
            bgColor: const Color(0xFF2C5CB0),
          );
          await Future.delayed(const Duration(seconds: 2));
        }
      }

      if (QuestStatus.numbersRoundsCompleted >= 3 &&
          !QuestStatus.quest10Claimed) {
        if (QuestStatus.canClaimQuest10()) {
          QuestStatus.claimQuest10();
          await Future.delayed(const Duration(milliseconds: 500));
          _showToast(
            icon: Icons.military_tech,
            title: "Quest 10 Complete!",
            subtitle: "3 rounds finished! +200 keys",
            bgColor: const Color(0xFFFF4B4A),
          );
          await Future.delayed(const Duration(seconds: 2));
        }
      }

      final justEarned = QuestStatus.markFirstQuizMedalEarned();
      if (justEarned && mounted) {
        _showToast(
          icon: Icons.military_tech,
          title: "Medal unlocked!",
          subtitle: "Finish your first quiz",
          bgColor: const Color(0xFF2C5CB0),
        );
        await Future.delayed(const Duration(seconds: 2));
      }

      final didIncrease = QuestStatus.addStreakForLevel();
      if (didIncrease && mounted) {
        _showToast(
          icon: Icons.local_fire_department,
          title: "Streak +1!",
          subtitle: "Current streak: ${QuestStatus.streakDays}",
          bgColor: const Color(0xFFFF4B4A),
        );
        await Sfx().playStreak();
        await Future.delayed(const Duration(seconds: 2));
      }

      // === NEW: show "Great Work!" results popup with Return button ===
      if (!mounted) return;
      await _showGreatWorkDialog(
        score: sessionScore,
        total: activeIndices.length,
        level: QuestStatus.level,
        streakDays: QuestStatus.streakDays,
      );

      // After dialog’s Return button, user is already navigated back.
      return;
    } else {
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
  }

  void _showToast({
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
        child: _NumberSlideInPopup(
          icon: icon,
          title: title,
          subtitle: subtitle,
          bgColor: bgColor,
        ),
      ),
    );
    overlay.insert(entry);
    Future.delayed(const Duration(seconds: 2), () => entry.remove());
  }

  // ---- Great Work Dialog launcher ----
  Future<void> _showGreatWorkDialog({
    required int score,
    required int total,
    required int level,
    required int streakDays,
  }) async {
    if (_allAnsweredInSession()) {
      if (!mounted) return;

      final int sessionScore = activeIndices
          .where((i) => _sessionAnswers[i] == true)
          .length;

      await showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => _GreatWorkDialog(
          score: sessionScore,
          total: activeIndices.length,
          onReturn: () {
            Navigator.of(context).pop();
            Navigator.of(context).pop();
          },
        ),
      );

      return; // optional
    }
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
        backgroundColor: const Color(0xFFCFFFF7),
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

  Widget _buildHeader() {
    return Row(
      children: [
        IconButton(
          onPressed: () async {
            final shouldExit = await _confirmExitQuiz();
            if (shouldExit && mounted) Navigator.pop(context);
          },
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFF0FDFA), Color(0xFFFFFFFF)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: const Color(0xFF69D3E4).withOpacity(0.4),
                width: 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF69D3E4).withOpacity(0.2),
                  blurRadius: 6,
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
                "Number Level",
                style: GoogleFonts.montserrat(
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF1E1E1E),
                  letterSpacing: -0.6,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                "Question ${currentSlot + 1} of ${activeIndices.length}",
                style: GoogleFonts.montserrat(
                  fontSize: 14,
                  color: Colors.black54,
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
              const Icon(Icons.bolt_rounded, color: Colors.white, size: 18),
              const SizedBox(width: 4),
              Text(
                "Lvl ${QuestStatus.level}",
                style: GoogleFonts.montserrat(
                  fontSize: 14,
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
    int correct = 0, wrong = 0;
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
        const Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
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
            "What number is shown?",
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
          Expanded(
            child: Text(
              'Selected: ${options[idx]}',
              style: const TextStyle(
                color: Color(0xFF2C5CB0),
                fontWeight: FontWeight.w600,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: 8),
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
}

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
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    option,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: isSelected
                          ? Colors.black
                          : const Color(0xFF2C5CB0),
                    ),
                  ),
                ),
                if (isSelected)
                  const Icon(Icons.check_circle, color: Color(0xFF2C5CB0)),
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
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.black54,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class _NumberSlideInPopup extends StatefulWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color bgColor;

  const _NumberSlideInPopup({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.bgColor,
  });

  @override
  State<_NumberSlideInPopup> createState() => _NumberSlideInPopupState();
}

class _NumberSlideInPopupState extends State<_NumberSlideInPopup>
    with SingleTickerProviderStateMixin {
  late final AnimationController controller = AnimationController(
    duration: const Duration(milliseconds: 280),
    vsync: this,
  )..forward();
  late final Animation<Offset> offsetAnimation = Tween<Offset>(
    begin: const Offset(1.1, 0),
    end: Offset.zero,
  ).animate(CurvedAnimation(parent: controller, curve: Curves.easeOut));

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: offsetAnimation,
      child: Material(
        elevation: 6,
        borderRadius: BorderRadius.circular(12),
        color: widget.bgColor,
        child: Container(
          padding: const EdgeInsets.all(12),
          width: 280,
          child: Row(
            children: [
              Icon(widget.icon, color: Colors.white, size: 28),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      widget.subtitle,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
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

class _CleanConfirmDialog extends StatelessWidget {
  final IconData icon;
  final String title;
  final String message;
  final String primaryLabel;
  final String secondaryLabel;

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

// =======================
// GREAT WORK! DIALOG (Simplified)
// =======================
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
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      backgroundColor: const Color(0xFFF9FBFF),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 32, 20, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Trophy Icon
            Container(
              width: 100,
              height: 100,
              decoration: const BoxDecoration(
                color: Color(0xFFE8EEFF),
                shape: BoxShape.circle,
              ),
              child: ClipOval(
                child: Image.asset(
                  'assets/gifs/trophy_quiz.gif',
                  fit: BoxFit.cover,
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Title
            Text(
              isPerfect ? "Perfection!" : "Great Work!",
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.w900,
                color: Color(0xFF2C5CB0),
              ),
            ),
            const SizedBox(height: 10),

            // Subtitle
            Text(
              isPerfect
                  ? "You answered every question flawlessly."
                  : "You completed this quiz successfully!",
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 16,
                color: Color(0xFF4B5563),
                height: 1.4,
              ),
            ),
            const SizedBox(height: 24),

            // Score Display
            Container(
              padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFE5E7EB)),
              ),
              child: Center(
                child: Text(
                  "$score / $total",
                  style: const TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1F2937),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 30),

            // Return button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: onReturn,
                icon: const Icon(Icons.arrow_back_rounded, size: 22),
                label: const Text(
                  'Return',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2C5CB0),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
