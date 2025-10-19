import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'quest_status.dart';

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

    // Mark quest 3 when alphabet quiz opens
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
            gradient: const LinearGradient(
              colors: [Color(0xFFFF4B4A), Color(0xFF2C5CB0)],
            ),
          );
        });
      }
    }

    final all = List<int>.generate(questions.length, (i) => i)..shuffle();
    // Cap the session to the number of available questions to avoid range issues
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

    if (isCorrect) {
      final oldLvl = QuestStatus.level;
      final levels = QuestStatus.addXp(20);

      showAnimatedPopup(
        icon: Icons.star,
        iconColor: Colors.white,
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
            iconColor: Colors.white,
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
            iconColor: Colors.white,
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
        iconColor: Colors.white,
        title: "Incorrect",
        subtitle: "Correct: $correctLetter",
        bgColor: const Color(0xFFFF4B4A),
      );
    }

    await Future.delayed(const Duration(milliseconds: 250));

    if (_allAnsweredInSession()) {
      if (!mounted) return;

      final sessionScore = activeIndices
          .where((i) => _sessionAnswers[i] == true)
          .length;

      showAnimatedPopup(
        icon: Icons.emoji_events,
        iconColor: Colors.white,
        title: "Quiz Complete!",
        subtitle: "Score: $sessionScore/${activeIndices.length}",
        bgColor: const Color(0xFF2C5CB0),
      );

      QuestStatus.alphabetRoundsCompleted += 1;

      if (QuestStatus.alphabetRoundsCompleted >= 3 &&
          !QuestStatus.quest5Claimed) {
        if (QuestStatus.canClaimQuest5()) {
          QuestStatus.claimQuest5();
          await Future.delayed(const Duration(milliseconds: 500));
          showAnimatedPopup(
            icon: Icons.military_tech,
            iconColor: Colors.white,
            title: "Quest 5 Complete!",
            subtitle: "3 rounds finished! +200 keys",
            bgColor: const Color(0xFFFF4B4A),
          );
          await Future.delayed(const Duration(seconds: 2));
        }
      }

      if (sessionScore == activeIndices.length && !QuestStatus.quest6Claimed) {
        if (QuestStatus.canClaimQuest6()) {
          QuestStatus.claimQuest6();
          await Future.delayed(const Duration(milliseconds: 500));
          showAnimatedPopup(
            icon: Icons.stars,
            iconColor: Colors.white,
            title: "Quest 6 Complete!",
            subtitle: "Perfect round! +250 keys",
            bgColor: const Color(0xFF2C5CB0),
          );
          await Future.delayed(const Duration(seconds: 2));
        }
      }

      final justEarned = await QuestStatus.markFirstQuizMedalEarned();
      if (justEarned && mounted) {
        showAnimatedPopup(
          icon: Icons.military_tech,
          iconColor: Colors.white,
          title: "Medal unlocked!",
          subtitle: "Finish your first quiz",
          bgColor: const Color(0xFFFF4B4A),
        );
        await Future.delayed(const Duration(seconds: 2));
      }

      final didIncrease = QuestStatus.addStreakForLevel();
      if (didIncrease && mounted) {
        showAnimatedPopup(
          icon: Icons.local_fire_department,
          iconColor: Colors.white,
          title: "Streak +1!",
          subtitle:
              "Current streak: ${QuestStatus.streakDays} day${QuestStatus.streakDays == 1 ? '' : 's'}",
          bgColor: const Color(0xFF2C5CB0),
        );
        await Future.delayed(const Duration(seconds: 2));
      }

      if (!mounted) return;
      Navigator.pop(context);
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

  void _showFloatingMessage(String message) {
    final overlay = Overlay.of(context);
    final entry = OverlayEntry(
      builder: (_) => Positioned(
        top: 100,
        left: 0,
        right: 0,
        child: Center(
          child: FloatingMessage(
            message: message,
            backgroundColor: const Color(0xFF2C5CB0).withOpacity(0.9),
          ),
        ),
      ),
    );

    overlay.insert(entry);
    Future.delayed(const Duration(seconds: 2), () {
      entry.remove();
    });
  }

  // Double confirmation before leaving the quiz
  Future<bool> _confirmExitQuiz() async {
    final first =
        await showDialog<bool>(
          context: context,
          barrierDismissible: false,
          builder: (_) => AlertDialog(
            title: const Text('Leave quiz?'),
            content: const Text('You\'ll lose your current round progress.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Continue'),
              ),
            ],
          ),
        ) ??
        false;

    if (!first) return false;

    final second =
        await showDialog<bool>(
          context: context,
          barrierDismissible: false,
          builder: (_) => AlertDialog(
            title: const Text('Are you sure?'),
            content: const Text(
              'This action can\'t be undone and your progress this round will be lost.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Stay'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Leave'),
              ),
            ],
          ),
        ) ??
        false;

    return second;
  }

  Future<void> _handleBackPressed() async {
    final shouldExit = await _confirmExitQuiz();
    if (shouldExit && mounted) {
      Navigator.pop(context);
    }
  }

  void _showAchievementToast({
    required IconData icon,
    required String title,
    required String subtitle,
    required Gradient gradient,
  }) {
    final overlay = Overlay.of(context);
    final entry = OverlayEntry(
      builder: (_) => Positioned(
        top: 60,
        left: 20,
        right: 20,
        child: AchievementToast(
          icon: icon,
          title: title,
          subtitle: subtitle,
          gradient: gradient,
        ),
      ),
    );

    overlay.insert(entry);
    Future.delayed(const Duration(seconds: 3), () {
      entry.remove();
    });
  }

  // Original popup style used by the quiz (kept for functionality parity)
  void showAnimatedPopup({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required Color bgColor,
  }) {
    final overlay = Overlay.of(context);
    final entry = OverlayEntry(
      builder: (_) => Positioned(
        top: 60,
        right: 16,
        child: SlideInPopup(
          icon: icon,
          iconColor: iconColor,
          title: title,
          subtitle: subtitle,
          bgColor: bgColor,
        ),
      ),
    );

    overlay.insert(entry);
    Future.delayed(const Duration(seconds: 2), () {
      entry.remove();
    });
  }

  @override
  Widget build(BuildContext context) {
    final qIdx = activeIndices[currentSlot];
    final question = questions[qIdx];
    final options = question['options'] as List<String>;

    return WillPopScope(
      onWillPop: () async => await _confirmExitQuiz(),
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: SlideTransition(
              position: _offsetAnimation,
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  children: [
                    // Header with progress
                    _buildHeader(),
                    const SizedBox(height: 12),
                    _buildProgressBar(),
                    const SizedBox(height: 16),

                    // Question Card
                    _buildQuestionCard(question),
                    const SizedBox(height: 32),

                    // Options Grid
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
        color: const Color(0xFFF0F4FF),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF2C5CB0).withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: const Color(0xFF2C5CB0).withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFF2C5CB0),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                const Icon(Icons.touch_app, color: Colors.white, size: 18),
                const SizedBox(width: 8),
                Text(
                  'Selected: ${options[idx]}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          const Spacer(),
          TextButton(
            onPressed: () {
              setState(() => _pendingIndex = null);
            },
            style: TextButton.styleFrom(
              foregroundColor: const Color(0xFF2C5CB0),
            ),
            child: const Text('Cancel'),
          ),
          const SizedBox(width: 8),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF4AFF7C),
              foregroundColor: Colors.black,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 0,
            ),
            onPressed: () {
              final confirmIndex = _pendingIndex;
              if (confirmIndex != null) {
                handleAnswer(confirmIndex);
              }
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
              color: const Color(0xFF2C5CB0).withOpacity(0.1),
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
              Text(
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
                style: TextStyle(fontSize: 14, color: Colors.black54),
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFFFF4B4A), Color(0xFF2C5CB0)],
            ),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            children: [
              Icon(Icons.bolt_rounded, color: Colors.white, size: 16),
              const SizedBox(width: 4),
              Text(
                "Lvl ${QuestStatus.level}",
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
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
          duration: const Duration(milliseconds: 250),
          decoration: BoxDecoration(color: color, borderRadius: radius),
          height: 10,
        ),
      );
    }

    final hasCorrect = correct > 0;
    final hasWrong = wrong > 0;
    final hasRemaining = remaining > 0;

    List<Widget> bars = [];
    if (hasCorrect) {
      bars.add(
        segment(
          color: const Color(0xFF44b427),
          flex: correct,
          radius: hasWrong || hasRemaining
              ? const BorderRadius.only(
                  topLeft: Radius.circular(8),
                  bottomLeft: Radius.circular(8),
                )
              : BorderRadius.circular(8),
        ),
      );
    }
    if (hasWrong) {
      bars.add(const SizedBox(width: 1));
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
      bars.add(const SizedBox(width: 1));
      bars.add(
        segment(
          color: const Color(0xFFE8EEF9),
          flex: remaining,
          radius: (hasCorrect || hasWrong)
              ? const BorderRadius.only(
                  topRight: Radius.circular(8),
                  bottomRight: Radius.circular(8),
                )
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
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF2C5CB0).withOpacity(0.08),
                blurRadius: 6,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Row(children: bars),
        ),
        const SizedBox(height: 6),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _legendDot(
              label: 'Correct',
              count: correct,
              color: const Color(0xFF44b427),
            ),
            _legendDot(
              label: 'Wrong',
              count: wrong,
              color: const Color(0xFFFF4B4A),
            ),
          ],
        ),
      ],
    );
  }

  Widget _legendDot({
    required String label,
    required int count,
    required Color color,
  }) {
    return Row(
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Text(
          '$label: $count',
          style: const TextStyle(
            fontSize: 12,
            color: Colors.black54,
            fontWeight: FontWeight.w600,
          ),
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
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFE8F0FF), Color(0xFFF0F4FF)],
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF2C5CB0).withOpacity(0.1),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
        border: Border.all(color: const Color(0xFF2C5CB0).withOpacity(0.1)),
      ),
      child: Column(
        children: [
          Text(
            "What sign is shown?",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
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
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF2C5CB0).withOpacity(0.08),
                  blurRadius: 12,
                  offset: const Offset(0, 6),
                ),
              ],
              border: Border.all(
                color: const Color(0xFF2C5CB0).withOpacity(0.1),
              ),
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
                            color: Color(0xFF2C5CB0).withOpacity(0.5),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Image not found',
                            style: TextStyle(
                              color: Color(0xFF2C5CB0).withOpacity(0.7),
                            ),
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
            isCorrect: isCorrect,
            isAnswered: alreadyAnswered,
            isPending: isPending,
            onTap: alreadyAnswered
                ? null
                : () {
                    setState(() {
                      _pendingIndex = index;
                    });
                  },
          );
        },
      ),
    );
  }
}

class OptionCard extends StatelessWidget {
  final String option;
  final int number;
  final bool isSelected;
  final bool isCorrect;
  final bool isAnswered;
  final bool isPending;
  final VoidCallback? onTap;

  const OptionCard({
    super.key,
    required this.option,
    required this.number,
    this.isSelected = false,
    this.isCorrect = false,
    this.isAnswered = false,
    this.isPending = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      decoration: BoxDecoration(
        color: isSelected ? null : const Color(0xFF2C5CB0).withOpacity(0.1),
        gradient: isSelected
            ? const LinearGradient(
                colors: [Color(0xFF2C5CB0), Color(0xFFFF4B4A)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              )
            : null,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: isSelected
                ? const Color(0xFF2C5CB0).withOpacity(0.35)
                : const Color(0xFF2C5CB0).withOpacity(0.1),
            blurRadius: isSelected ? 14 : 10,
            offset: const Offset(0, 6),
          ),
        ],
        border: isSelected
            ? Border.all(color: const Color(0xFF2C5CB0), width: 2)
            : Border.all(
                color: isPending
                    ? const Color(0xFF311E76)
                    : const Color(0xFF2C5CB0).withOpacity(0.3),
                width: isPending ? 2 : 1.2,
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
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: isSelected
                        ? Colors.white
                        : (isPending
                              ? const Color(0xFF311E76)
                              : const Color(0xFF2C5CB0)),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      number.toString(),
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: isSelected
                            ? const Color(0xFF2C5CB0)
                            : Colors.white,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    option,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: isSelected
                          ? Colors.white
                          : const Color(0xFF2C5CB0),
                      letterSpacing: -0.3,
                    ),
                  ),
                ),
                if (isSelected)
                  const Icon(
                    Icons.check_circle_rounded,
                    color: Colors.white,
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

class AchievementToast extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Gradient gradient;

  const AchievementToast({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.gradient,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 8,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: gradient,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: Colors.white, size: 28),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.9),
                      fontSize: 14,
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

class FloatingMessage extends StatelessWidget {
  final String message;
  final String? subtitle;
  final Color backgroundColor;
  final IconData? icon;

  const FloatingMessage({
    super.key,
    required this.message,
    this.subtitle,
    required this.backgroundColor,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 8,
      borderRadius: BorderRadius.circular(25),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(25),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(icon, color: Colors.white, size: 20),
              const SizedBox(width: 8),
            ],
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  message,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    subtitle!,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.9),
                      fontSize: 12,
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class SessionCompleteDialog extends StatelessWidget {
  final int score;
  final int total;
  final VoidCallback onContinue;

  const SessionCompleteDialog({
    super.key,
    required this.score,
    required this.total,
    required this.onContinue,
  });

  @override
  Widget build(BuildContext context) {
    final percentage = (score / total * 100).round();
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF2C5CB0), Color(0xFFFF4B4A)],
          ),
          borderRadius: BorderRadius.circular(32),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.4),
              blurRadius: 30,
              offset: const Offset(0, 20),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.emoji_events_rounded,
                color: Color(0xFF2C5CB0),
                size: 40,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              "Quiz Complete!",
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              "You scored $score out of $total",
              style: TextStyle(fontSize: 18, color: Colors.white70),
            ),
            const SizedBox(height: 8),
            Text(
              "$percentage% Correct",
              style: TextStyle(fontSize: 16, color: Colors.white60),
            ),
            const SizedBox(height: 32),
            Container(
              width: double.infinity,
              height: 50,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(25),
              ),
              child: Material(
                color: Colors.transparent,
                borderRadius: BorderRadius.circular(25),
                child: InkWell(
                  onTap: onContinue,
                  borderRadius: BorderRadius.circular(25),
                  child: Center(
                    child: Text(
                      "Continue",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2C5CB0),
                      ),
                    ),
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

// Slide-in toast notification used by original quiz flow
class SlideInPopup extends StatefulWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final Color bgColor;

  const SlideInPopup({
    super.key,
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.bgColor,
  });

  @override
  State<SlideInPopup> createState() => _SlideInPopupState();
}

class _SlideInPopupState extends State<SlideInPopup>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _offsetAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _offsetAnimation = Tween<Offset>(
      begin: const Offset(1.2, 0),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: _offsetAnimation,
      child: Material(
        elevation: 8,
        borderRadius: BorderRadius.circular(12),
        color: widget.bgColor,
        child: Container(
          padding: const EdgeInsets.all(12),
          width: 280,
          child: Row(
            children: [
              Icon(widget.icon, color: widget.iconColor, size: 32),
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
