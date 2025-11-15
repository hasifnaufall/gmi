// lib/verb_q.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'badges/badges_engine.dart';

import 'quest_status.dart';
import 'services/sfx_service.dart';
import 'theme_manager.dart';

enum QuizType { multipleChoice, mixMatch, both }

// NEW: Cute Bottom Sheet Quiz Type Selection
Future<void> showVerbQuizSelection(BuildContext context) {
  final themeManager = ThemeManager.of(context, listen: false);
  return showModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    builder: (_) => Container(
      decoration: BoxDecoration(
        color: themeManager.isDarkMode ? const Color(0xFF2C2C2E) : Colors.white,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(28),
          topRight: Radius.circular(28),
        ),
      ),
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag handle
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: themeManager.isDarkMode
                  ? const Color(0xFF8E8E93)
                  : Colors.grey.shade300,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 20),

          // Header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: themeManager.isDarkMode
                        ? const [Color(0xFF8B1F1F), Color(0xFFD23232)]
                        : const [Color(0xFFEF4444), Color(0xFFDC2626)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color:
                          (themeManager.isDarkMode
                                  ? const Color(0xFFD23232)
                                  : const Color(0xFFEF4444))
                              .withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: const Icon(Icons.quiz, color: Colors.white, size: 24),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Select Quiz Mode',
                  style: GoogleFonts.montserrat(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: themeManager.isDarkMode
                        ? const Color(0xFFE8E8E8)
                        : const Color(0xFF1E1E1E),
                    letterSpacing: -0.3,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Quiz Type Cards (Compact)
          _CompactQuizCard(
            icon: Icons.quiz_rounded,
            title: 'Multiple Choice',
            description: '10 questions',
            gradient: const [Color(0xFFEF4444), Color(0xFFDC2626)],
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) =>
                      const VerbQuizScreen(quizType: QuizType.multipleChoice),
                ),
              );
            },
          ),
          const SizedBox(height: 12),
          _CompactQuizCard(
            icon: Icons.swap_horiz_rounded,
            title: 'Mix & Match',
            description: '6 pairs',
            gradient: const [Color(0xFF22C55E), Color(0xFF16A34A)],
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) =>
                      const VerbQuizScreen(quizType: QuizType.mixMatch),
                ),
              );
            },
          ),
          const SizedBox(height: 12),
          _CompactQuizCard(
            icon: Icons.stars_rounded,
            title: 'Both Modes',
            description: '10 MC + 6 Mix&Match',
            gradient: const [Color(0xFFFFD700), Color(0xFFFFA500)],
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const VerbQuizScreen(quizType: QuizType.both),
                ),
              );
            },
          ),
        ],
      ),
    ),
  );
}

// Compact Quiz Type Card Widget for Bottom Sheet
class _CompactQuizCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final List<Color> gradient;
  final VoidCallback onTap;

  const _CompactQuizCard({
    required this.icon,
    required this.title,
    required this.description,
    required this.gradient,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final themeManager = ThemeManager.of(context, listen: false);
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: themeManager.isDarkMode
                  ? [const Color(0xFF3C3C3E), const Color(0xFF2C2C2E)]
                  : [Colors.grey.shade50, Colors.grey.shade100],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: gradient[0].withOpacity(0.3), width: 2),
          ),
          child: Row(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: gradient,
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: gradient[0].withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Icon(icon, color: Colors.white, size: 28),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: GoogleFonts.montserrat(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: themeManager.isDarkMode
                            ? const Color(0xFFE8E8E8)
                            : const Color(0xFF1E1E1E),
                        letterSpacing: -0.2,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      description,
                      style: GoogleFonts.montserrat(
                        fontSize: 12,
                        color: themeManager.isDarkMode
                            ? const Color(0xFF8E8E93)
                            : const Color(0xFF6B7280),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: gradient[0].withOpacity(0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.arrow_forward_rounded,
                  color: gradient[0],
                  size: 18,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class VerbQuizScreen extends StatefulWidget {
  final int? startIndex;
  final QuizType quizType;

  const VerbQuizScreen({
    super.key,
    this.startIndex,
    this.quizType = QuizType.both,
  });

  @override
  State<VerbQuizScreen> createState() => _VerbQuizScreenState();
}

class _VerbQuizScreenState extends State<VerbQuizScreen>
    with SingleTickerProviderStateMixin {
  int _answerChangesThisQuiz = 0;
  bool _gotAnyUnder1sCorrect = false;
  DateTime? _questionShownAt;

  // Session sizes
  static const int multipleChoiceSize = 10;
  static const int mixMatchSize = 6;

  // Mix & Match visual sizing
  static const double mmRowGap = 10;
  static const double mmImageHeight = 95; // hand sign box
  static const double mmLetterHeight = 70; // letter box

  // Multiple choice state
  late List<int> activeIndices;
  late int currentSlot;
  bool isOptionSelected = false;
  int? _pendingIndex;
  final Map<int, bool> _sessionAnswers = {};

  // MCQ Review mode state
  bool _mcqReviewMode = false;
  Map<int, int> _userSelectedIndex = {};
  int _mmCorrectCount = 0;

  // Mix & Match state
  late List<int> mixMatchIndices;
  bool _isInMixMatchRound = false;
  final Map<String, String> _currentMatches = {}; // leftId -> rightId
  List<String> _mmLettersOrder = [];
  List<String> _mmImagesOrder = [];
  Map<String, String> _imageForLetter = {}; // letter -> imagePath
  final ScrollController _mmScroll = ScrollController();

  // NEW: Review mode (show correct/wrong for 7s)
  bool _mmReviewMode = false;
  final Set<String> _mmCorrectRightIds = {}; // e.g. right_A
  final Set<String> _mmWrongRightIds = {};

  // Animations
  late AnimationController _controller;
  late Animation<Offset> _offsetAnimation;
  late Animation<double> _fadeAnimation;

  final List<Map<String, dynamic>> questions = [
    {
      "image": "assets/images/verb/V1.jpg",
      "correctVerb": "Lift",
      "options": ["Lift", "Follow", "Discuss", "Wash"],
    },
    {
      "image": "assets/images/verb/V2.jpg",
      "correctVerb": "Read",
      "options": ["Wait", "Read", "Chat", "Lift"],
    },
    {
      "image": "assets/images/verb/V3.jpg",
      "correctVerb": "Wash",
      "options": ["Select", "Rest", "Wash", "Borrow"],
    },
    {
      "image": "assets/images/verb/V4.jpg",
      "correctVerb": "Bring",
      "options": ["Sleep", "Follow", "Drink", "Bring"],
    },
    {
      "image": "assets/images/verb/V5.jpg",
      "correctVerb": "Eat",
      "options": ["Eat", "Select", "Read", "Chat"],
    },
    {
      "image": "assets/images/verb/V6.jpg",
      "correctVerb": "Drink",
      "options": ["Read", "Drink", "Discuss", "Rest"],
    },
    {
      "image": "assets/images/verb/V7.jpg",
      "correctVerb": "Select",
      "options": ["Wash", "Borrow", "Select", "Lift"],
    },
    {
      "image": "assets/images/verb/V8.jpg",
      "correctVerb": "Borrow",
      "options": ["Chat", "Sleep", "Bring", "Borrow"],
    },
    {
      "image": "assets/images/verb/V9.jpg",
      "correctVerb": "Rest",
      "options": ["Rest", "Lift", "Wash", "Wait"],
    },
    {
      "image": "assets/images/verb/V10.jpg",
      "correctVerb": "Sleep",
      "options": ["Select", "Sleep", "Read", "Ride"],
    },
    {
      "image": "assets/images/verb/V11.jpg",
      "correctVerb": "Wait",
      "options": ["Eat", "Lift", "Wait", "Borrow"],
    },
    {
      "image": "assets/images/verb/V12.jpg",
      "correctVerb": "Ride",
      "options": ["Eat", "Bring", "Lift", "Ride"],
    },
    {
      "image": "assets/images/verb/V13.jpg",
      "correctVerb": "Discuss",
      "options": ["Discuss", "Drink", "Eat", "Rest"],
    },
    {
      "image": "assets/images/verb/V14.jpg",
      "correctVerb": "Chat",
      "options": ["Lift", "Chat", "Bring", "Select"],
    },
    {
      "image": "assets/images/verb/V15.jpg",
      "correctVerb": "Follow",
      "options": ["Eat", "Read", "Follow", "Bring"],
    },
  ];

  // Cache for generated options per question
  final Map<int, List<String>> _questionOptions = {};
  final Map<int, int> _questionCorrectIndex = {};

  bool _isAnsweredInSession(int qIdx) => _sessionAnswers.containsKey(qIdx);
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

  // NEW: Generate randomized options for a question
  List<String> _generateOptions(int qIdx) {
    if (_questionOptions.containsKey(qIdx)) {
      return _questionOptions[qIdx]!;
    }

    // Use pre-defined options from question data
    final options = questions[qIdx]['options'] as List<String>;
    final correctVerb = questions[qIdx]['correctVerb'] as String;
    _questionOptions[qIdx] = options;
    _questionCorrectIndex[qIdx] = options.indexOf(correctVerb);

    return options;
  }

  @override
  void initState() {
    super.initState();
    Sfx().init();

    if (!QuestStatus.alphabetQuizStarted) {
      QuestStatus.markAlphabetQuizStarted();
      if (QuestStatus.canClaimQuest3()) QuestStatus.claimQuest3();
    }

    final all = List<int>.generate(questions.length, (i) => i)..shuffle();

    // Adjust based on quiz type
    if (widget.quizType == QuizType.multipleChoice) {
      activeIndices = all.take(multipleChoiceSize).toList();
      mixMatchIndices = [];
    } else if (widget.quizType == QuizType.mixMatch) {
      activeIndices = [];
      mixMatchIndices = all.take(mixMatchSize).toList();
    } else {
      // QuizType.both
      activeIndices = all.take(multipleChoiceSize).toList();
      final remaining = all.skip(multipleChoiceSize).toList()..shuffle();
      mixMatchIndices = remaining.take(mixMatchSize).toList();
    }

    // Pre-generate options for all active questions
    for (final idx in activeIndices) {
      _generateOptions(idx);
    }

    // Adjust quest status length based on mode
    final totalQuestions =
        activeIndices.length + (mixMatchIndices.isEmpty ? 0 : 1);
    QuestStatus.ensureLevel1Length(totalQuestions);
    QuestStatus.resetLevel1Answers();

    int startSlot = widget.startIndex ?? 0;
    if (activeIndices.isNotEmpty) {
      startSlot = startSlot.clamp(0, activeIndices.length - 1);
      currentSlot = startSlot;
    } else {
      currentSlot = 0;
    }

    // Start directly in Mix&Match if that's the only mode
    _isInMixMatchRound = widget.quizType == QuizType.mixMatch;
    if (_isInMixMatchRound) _prepareMixMatchRound();

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
    _mmScroll.dispose();
    super.dispose();
  }

  // Freeze orders for Mix&Match
  void _prepareMixMatchRound() {
    _imageForLetter.clear();
    for (final idx in mixMatchIndices) {
      final verb = questions[idx]['correctVerb'] as String;
      final image = questions[idx]['image'] as String;
      _imageForLetter[verb] = image;
    }
    final verbs = mixMatchIndices
        .map((i) => questions[i]['correctVerb'] as String)
        .toList();
    final images = mixMatchIndices
        .map((i) => questions[i]['image'] as String)
        .toList();
    _mmLettersOrder = List<String>.from(verbs)..shuffle();
    _mmImagesOrder = List<String>.from(images)..shuffle();
  }

  // MULTIPLE CHOICE handler
  Future<void> handleAnswer(int selectedIndex) async {
    if (isOptionSelected) return;
    final qIdx = activeIndices[currentSlot];
    if (_sessionAnswers.containsKey(qIdx)) return;

    setState(() {
      isOptionSelected = true;
      _pendingIndex = null;
      _userSelectedIndex[qIdx] = selectedIndex;
    });

    final correctIndex = _questionCorrectIndex[qIdx]!;
    final isCorrect = selectedIndex == correctIndex;

    _sessionAnswers[qIdx] = isCorrect;
    QuestStatus.level1Answers[currentSlot] = isCorrect;

    if (isCorrect) {
      showAnimatedPopup(
        icon: Icons.star,
        title: "Correct!",
        subtitle: "You earned 20 XP",
        bgColor: const Color(0xFF2C5CB0),
      );
      QuestStatus.addXp(20);
    } else {
      final correctVerb = _questionOptions[qIdx]![correctIndex];
      showAnimatedPopup(
        icon: Icons.close,
        title: "Incorrect",
        subtitle: "Correct: $correctVerb",
        bgColor: const Color(0xFFFF4B4A),
      );
    }

    await Future.delayed(const Duration(milliseconds: 250));

    if (_allAnsweredInSession()) {
      if (!mounted) return;

      await Future.delayed(const Duration(milliseconds: 300));
      setState(() => _mcqReviewMode = true);
      await Future.delayed(const Duration(milliseconds: 1000));

      await _showMCQReviewDialog();

      if (!mounted) return;
      setState(() => _mcqReviewMode = false);

      // If "both" mode, transition to Mix&Match
      if (widget.quizType == QuizType.both && mixMatchIndices.isNotEmpty) {
        await Future.delayed(const Duration(milliseconds: 500));
        await showDialog(
          context: context,
          barrierDismissible: false,
          builder: (_) => const _BonusRoundDialog(),
        );
        setState(() {
          _prepareMixMatchRound();
          _isInMixMatchRound = true;
          currentSlot = 0;
          _controller.reset();
          _controller.forward();
        });
      } else {
        // Multiple choice only mode - finish session
        await Future.delayed(const Duration(milliseconds: 500));
        _finishSession();
      }
      return;
    }

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

  Future<void> _showMCQReviewDialog() async {
    final reviewData = <Map<String, dynamic>>[];
    int correctCount = 0;

    for (final qIdx in activeIndices) {
      final userIndex = _userSelectedIndex[qIdx];
      final correctIndex = _questionCorrectIndex[qIdx]!;
      final isCorrect = userIndex == correctIndex;
      if (isCorrect) correctCount++;

      reviewData.add({
        'image': questions[qIdx]['image'],
        'correctVerb': questions[qIdx]['correctVerb'],
        'options': _questionOptions[qIdx]!,
        'userIndex': userIndex,
        'isCorrect': isCorrect,
      });
    }

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => _MCQReviewDialog(
        reviewData: reviewData,
        correctCount: correctCount,
        totalCount: activeIndices.length,
        onContinue: () {
          Navigator.of(context).pop();
        },
      ),
    );
  }

  Future<void> _showMixMatchReviewDialog(bool allCorrect) async {
    if (!mounted) return;

    // Build review data - for each verb, show what user matched and what's correct
    final List<Map<String, dynamic>> reviewData = [];

    // For each verb in the left side (what user dragged)
    for (final verb in _mmLettersOrder) {
      final leftId = "left_$verb";
      final correctImage = _imageForLetter[verb]!;

      // Find what image the user matched this verb to
      String? userMatchedImage;
      if (_currentMatches.containsKey(leftId)) {
        final rightId = _currentMatches[leftId]!;
        final rightVerb = rightId.replaceFirst('right_', '');
        userMatchedImage = _imageForLetter[rightVerb];
      }

      final isCorrect = userMatchedImage == correctImage;

      reviewData.add({
        'verb': verb,
        'correctImage': correctImage,
        'userImage': userMatchedImage,
        'isCorrect': isCorrect,
      });
    }

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => _MixMatchReviewDialog(
        reviewData: reviewData,
        allCorrect: allCorrect,
        onContinue: () {
          Navigator.of(context).pop();
          _completeMixMatch(allCorrect);
        },
      ),
    );
  }

  // NEW: Undo a specific match in Mix & Match
  void _undoMatch(String rightId) {
    setState(() {
      _currentMatches.removeWhere((key, value) => value == rightId);
    });
  }

  // MIX & MATCH: After all pairs filled → automatically show results
  void _onAllPairsFilled() {
    _evaluateMixMatchAndReview();
  }

  // NEW: Evaluate + enter review mode (7s), then finish
  void _evaluateMixMatchAndReview() {
    _mmCorrectRightIds.clear();
    _mmWrongRightIds.clear();

    bool allCorrect = true;
    for (final idx in mixMatchIndices) {
      final verb = questions[idx]['correctVerb'] as String;
      final leftId = "left_$verb";
      final rightId = "right_$verb";
      if (_currentMatches[leftId] == rightId) {
        _mmCorrectRightIds.add(rightId);
      } else {
        allCorrect = false;
        _mmWrongRightIds.add(rightId);
      }
    }

    // Save result - position depends on mode
    final mmResultIndex = activeIndices.isEmpty ? 0 : activeIndices.length;
    QuestStatus.level1Answers[mmResultIndex] = allCorrect;

    // Store the correct count for final score
    _mmCorrectCount = _mmCorrectRightIds.length;

    // Enter review mode (disable dragging; show colors)
    setState(() => _mmReviewMode = true);

    // After 1s → show review dialog
    Future.delayed(const Duration(milliseconds: 1000), () {
      if (!mounted) return;
      _showMixMatchReviewDialog(allCorrect);
    });
  }

  // Separate finisher (used after review)
  void _completeMixMatch(bool allCorrect) {
    // Exit review mode
    setState(() => _mmReviewMode = false);

    // Award XP based on correct pairs (10 XP per correct pair)
    final xpEarned = _mmCorrectCount * 10;

    if (allCorrect) {
      showAnimatedPopup(
        icon: Icons.star,
        title: "Perfect Match!",
        subtitle: "You earned ${xpEarned} XP",
        bgColor: const Color(0xFF2C5CB0),
      );
      QuestStatus.addXp(xpEarned);
    } else {
      showAnimatedPopup(
        icon: Icons.close,
        title: "Some Incorrect",
        subtitle: "You earned ${xpEarned} XP",
        bgColor: const Color(0xFFFF4B4A),
      );
      QuestStatus.addXp(xpEarned);
    }
    Future.delayed(const Duration(milliseconds: 500), () => _finishSession());
  }

  // Session Completion
  Future<void> _finishSession() async {
    if (!mounted) return;

    int sessionScore = 0;

    // Count MC correct answers
    for (final i in activeIndices) {
      if (_sessionAnswers[i] == true) sessionScore++;
    }

    // Count Mix&Match correct pairs individually
    sessionScore += _mmCorrectCount;

    final totalQuestions = activeIndices.length + mixMatchIndices.length;

    // ========= BADGES: update counters for this completed quiz =========
    // Count this quiz
    QuestStatus.quizzesCompleted++;

    // Perfect run (all correct, no hints used here — you can add your own 'usedHints' flag if needed)
    if (sessionScore == totalQuestions) {
      QuestStatus.perfectQuizzes++;
    }

    // Mark modes completed
    if (widget.quizType == QuizType.multipleChoice ||
        widget.quizType == QuizType.both) {
      QuestStatus.completedMC = true;
    }
    if (widget.quizType == QuizType.mixMatch ||
        widget.quizType == QuizType.both) {
      QuestStatus.completedMM = true;
    }

    // Mark category played
    QuestStatus.playedAlphabet = true;

    // Evaluate & show any newly unlocked badge popup
    await BadgeEngine.checkAndToast(context);
    // ========= END BADGES =========

    // Your existing quest logic
    QuestStatus.alphabetRoundsCompleted += 1;

    if (QuestStatus.alphabetRoundsCompleted >= 3 &&
        !QuestStatus.quest5Claimed) {
      if (QuestStatus.canClaimQuest5()) QuestStatus.claimQuest5();
    }
    if (sessionScore == totalQuestions && !QuestStatus.quest6Claimed) {
      if (QuestStatus.canClaimQuest6()) QuestStatus.claimQuest6();
    }

    QuestStatus.markFirstQuizMedalEarned();

    final didIncrease = QuestStatus.addStreakForLevel();
    if (didIncrease) await Sfx().playStreak();
    await Sfx().playLevelComplete();

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => _GreatWorkDialog(
        score: sessionScore,
        total: totalQuestions,
        onReturn: () {
          Navigator.of(context).pop();
          Navigator.of(context).pop();
        },
      ),
    );
  }

  // Back helpers
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

  Future<void> _handleBackPressed() async {
    final shouldExit = await _confirmExitQuiz();
    if (shouldExit && mounted) Navigator.pop(context);
  }

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

  // BUILD
  @override
  Widget build(BuildContext context) {
    return _isInMixMatchRound
        ? _buildMixMatchQuiz()
        : _buildMultipleChoiceQuiz();
  }

  // MULTIPLE CHOICE UI
  Widget _buildMultipleChoiceQuiz() {
    final qIdx = activeIndices[currentSlot];
    final question = questions[qIdx];
    final options = _questionOptions[qIdx]!;

    return Consumer<ThemeManager>(
      builder: (context, themeManager, child) {
        return WillPopScope(
          onWillPop: () async => await _confirmExitQuiz(),
          child: Scaffold(
            backgroundColor: themeManager.backgroundColor,
            body: SafeArea(
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: SlideTransition(
                  position: _offsetAnimation,
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      children: [
                        _buildHeader("Verb Quiz", themeManager),
                        const SizedBox(height: 12),
                        _buildProgressBar(themeManager),
                        const SizedBox(height: 16),
                        _buildQuestionCard(question, themeManager),
                        const SizedBox(height: 32),
                        _buildOptionsGrid(options, qIdx, themeManager),
                        const SizedBox(height: 12),
                        if (_pendingIndex != null)
                          _buildConfirmBar(options, themeManager),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  // MIX & MATCH UI
  Widget _buildMixMatchQuiz() {
    if (_mmLettersOrder.isEmpty || _mmImagesOrder.isEmpty) {
      _prepareMixMatchRound();
    }

    final totalPairs = mixMatchIndices.length;

    return Consumer<ThemeManager>(
      builder: (context, themeManager, child) {
        return WillPopScope(
          onWillPop: () async => await _confirmExitQuiz(),
          child: Scaffold(
            backgroundColor: themeManager.backgroundColor,
            body: SafeArea(
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: SlideTransition(
                  position: _offsetAnimation,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        _buildHeader("Mix & Match", themeManager),
                        const SizedBox(height: 8),
                        _buildStableMixMatchProgress(totalPairs, themeManager),
                        const SizedBox(height: 12),
                        _buildMixMatchInstruction(themeManager),
                        const SizedBox(height: 16),
                        Expanded(
                          child: Scrollbar(
                            controller: _mmScroll,
                            thumbVisibility: true,
                            child: SingleChildScrollView(
                              controller: _mmScroll,
                              physics: const AlwaysScrollableScrollPhysics(),
                              child: _buildMatchingAreaStable(
                                lettersOrder: _mmLettersOrder,
                                imagesOrder: _mmImagesOrder,
                                themeManager: themeManager,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader(String title, ThemeManager themeManager) {
    return Row(
      children: [
        IconButton(
          onPressed: _handleBackPressed,
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: themeManager.isDarkMode
                    ? [const Color(0xFF3C3C3E), const Color(0xFF2C2C2E)]
                    : [const Color(0xFFFFFFFF), const Color(0xFFF0FDFA)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: themeManager.primary.withOpacity(0.3)),
              boxShadow: [
                BoxShadow(
                  color: themeManager.primary.withOpacity(0.15),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Icon(
              Icons.arrow_back_ios_new_rounded,
              color: themeManager.primary,
              size: 20,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            title,
            style: GoogleFonts.montserrat(
              fontSize: 24,
              fontWeight: FontWeight.w800,
              color: themeManager.primary,
              letterSpacing: -0.5,
            ),
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            gradient: themeManager.primaryGradient,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: themeManager.primary.withOpacity(0.3),
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

  // Progress (MC)
  Widget _buildProgressBar(ThemeManager themeManager) {
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
          height: 12,
        ),
      );
    }

    final hasCorrect = correct > 0,
        hasWrong = wrong > 0,
        hasRemaining = remaining > 0;
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
          color: themeManager.isDarkMode
              ? const Color(0xFF636366)
              : const Color(0xFFE0F2F1),
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
              colors: themeManager.isDarkMode
                  ? [const Color(0xFF3C3C3E), const Color(0xFF2C2C2E)]
                  : [Colors.white, const Color(0xFFF0FDFA)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: themeManager.primary.withOpacity(0.3)),
            boxShadow: [
              BoxShadow(
                color: themeManager.primary.withOpacity(0.1),
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
            _LegendDot(
              label: 'Correct',
              color: Color(0xFF22C55E),
              themeManager: themeManager,
            ),
            _LegendDot(
              label: 'Wrong',
              color: Color(0xFFFF4B4A),
              themeManager: themeManager,
            ),
          ],
        ),
      ],
    );
  }

  // Progress (Mix&Match)
  Widget _buildStableMixMatchProgress(int total, ThemeManager themeManager) {
    final matched = _currentMatches.length;
    final value = total == 0 ? 0.0 : matched / total;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SizedBox(
          height: 10,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: value,
              backgroundColor: themeManager.isDarkMode
                  ? const Color(0xFF636366)
                  : const Color(0xFFE0F2F1),
              valueColor: const AlwaysStoppedAnimation(Color(0xFFFFA726)),
              minHeight: 10,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          "$matched / $total matched",
          textAlign: TextAlign.center,
          style: GoogleFonts.montserrat(
            fontSize: 13,
            color: Colors.black54,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildMixMatchInstruction(ThemeManager themeManager) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: themeManager.isDarkMode
              ? const [Color(0xFF3C3C3E), Color(0xFF2C2C2E)]
              : const [Color(0xFFFFFFFF), Color(0xFFF0FDFA)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: themeManager.primary.withOpacity(0.3),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: themeManager.primary.withOpacity(0.15),
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
              gradient: themeManager.primaryGradient,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.swap_horiz_rounded,
              color: Colors.white,
              size: 20,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              "Drag letters to their matching signs",
              style: GoogleFonts.montserrat(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: themeManager.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Matching area (organized rows; right is bigger) - NOW WITH UNDO BUTTON
  Widget _buildMatchingAreaStable({
    required List<String> lettersOrder,
    required List<String> imagesOrder,
    required ThemeManager themeManager,
  }) {
    assert(
      lettersOrder.length == imagesOrder.length,
      "lettersOrder and imagesOrder must be same length",
    );

    return Column(
      children: List.generate(lettersOrder.length, (i) {
        final letter = lettersOrder[i];
        final leftId = "left_$letter";
        final isLeftMatched = _currentMatches.containsKey(leftId);

        final imagePath = imagesOrder[i];
        final rightLetter = _imageForLetter.entries
            .firstWhere((e) => e.value == imagePath)
            .key;
        final rightId = "right_$rightLetter";
        final isRightMatched = _currentMatches.values.contains(rightId);

        // During review, compute status for this right target
        final showCorrect =
            _mmReviewMode && _mmCorrectRightIds.contains(rightId);
        final showWrong = _mmReviewMode && _mmWrongRightIds.contains(rightId);

        return Padding(
          key: ValueKey('ROW_$i'),
          padding: const EdgeInsets.only(bottom: mmRowGap),
          child: SizedBox(
            height: mmImageHeight,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Left: draggable letter (disabled in review)
                Expanded(
                  flex: 1,
                  child: Center(
                    child: SizedBox(
                      height: mmLetterHeight,
                      child: Opacity(
                        opacity: (isLeftMatched || _mmReviewMode) ? 0.5 : 1.0,
                        child: IgnorePointer(
                          ignoring: isLeftMatched || _mmReviewMode,
                          child: Draggable<String>(
                            data: leftId,
                            feedback: Material(
                              elevation: 8,
                              borderRadius: BorderRadius.circular(16),
                              child: _LetterCard(
                                letter: letter,
                                themeManager: themeManager,
                                isFloating: true,
                              ),
                            ),
                            childWhenDragging: Opacity(
                              opacity: 0.3,
                              child: _LetterCard(
                                letter: letter,
                                themeManager: themeManager,
                              ),
                            ),
                            child: _LetterCard(
                              letter: letter,
                              themeManager: themeManager,
                              isMatched: isLeftMatched,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(width: 10),

                // Right: drag target (disabled in review) with UNDO button
                Expanded(
                  flex: 4,
                  child: Stack(
                    children: [
                      DragTarget<String>(
                        onWillAccept: (data) =>
                            !_mmReviewMode && data != null && !isRightMatched,
                        onAccept: (draggedLeftId) {
                          setState(() {
                            _currentMatches[draggedLeftId] = rightId;
                          });
                          if (_currentMatches.length >=
                              mixMatchIndices.length) {
                            _onAllPairsFilled();
                          }
                        },
                        builder: (context, candidate, rejected) {
                          final isHovering =
                              !_mmReviewMode &&
                              candidate.isNotEmpty &&
                              !isRightMatched;

                          // Get matched letter for this image
                          String? matchedLetter;
                          if (isRightMatched) {
                            final matchEntry = _currentMatches.entries
                                .firstWhere((e) => e.value == rightId);
                            matchedLetter = matchEntry.key.replaceFirst(
                              'left_',
                              '',
                            );
                          }

                          return SizedBox(
                            height: mmImageHeight,
                            child: _ImageCard(
                              imagePath: imagePath,
                              isMatched: isRightMatched,
                              isHovering: isHovering,
                              reviewCorrect: showCorrect,
                              reviewWrong: showWrong,
                              matchedLetter: matchedLetter,
                            ),
                          );
                        },
                      ),
                      // NEW: Undo button (top-right corner) - only show when matched and NOT in review
                      if (isRightMatched && !_mmReviewMode)
                        Positioned(
                          top: 4,
                          right: 4,
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              onTap: () => _undoMatch(rightId),
                              borderRadius: BorderRadius.circular(20),
                              child: Container(
                                padding: const EdgeInsets.all(6),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.9),
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: const Color(0xFFFF4B4A),
                                    width: 2,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.2),
                                      blurRadius: 4,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: const Icon(
                                  Icons.refresh_rounded,
                                  size: 16,
                                  color: Color(0xFFFF4B4A),
                                ),
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
      }),
    );
  }

  // Question Card (MC)
  Widget _buildQuestionCard(
    Map<String, dynamic> question,
    ThemeManager themeManager,
  ) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: themeManager.isDarkMode
              ? const [Color(0xFF3C3C3E), Color(0xFF2C2C2E)]
              : const [Color(0xFFFFFFFF), Color(0xFFF0FDFA)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: themeManager.primary.withOpacity(0.3),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: themeManager.primary.withOpacity(0.15),
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
              color: themeManager.primary,
              letterSpacing: -0.3,
            ),
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: themeManager.isDarkMode
                  ? const Color(0xFF636366)
                  : Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: themeManager.primary.withOpacity(0.2)),
              boxShadow: [
                BoxShadow(
                  color: themeManager.primary.withOpacity(0.1),
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
                errorBuilder: (context, error, stack) => const SizedBox(
                  height: 140,
                  child: Center(
                    child: Icon(
                      Icons.broken_image_rounded,
                      size: 36,
                      color: Colors.grey,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Options Grid (MC)
  Widget _buildOptionsGrid(
    List<String> options,
    int qIdx,
    ThemeManager themeManager,
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
          final correctIndex = _questionCorrectIndex[qIdx]!;
          final isCorrect = index == correctIndex;
          final wasSelected =
              alreadyAnswered &&
              _sessionAnswers[qIdx] == isCorrect &&
              isCorrect;
          final isPending = !alreadyAnswered && _pendingIndex == index;

          final userSelectedIndex = _userSelectedIndex[qIdx];
          final reviewCorrect = _mcqReviewMode && isCorrect;
          final reviewWrong =
              _mcqReviewMode &&
              userSelectedIndex != null &&
              userSelectedIndex == index &&
              !isCorrect;

          return OptionCard(
            option: options[index],
            number: index + 1,
            isSelected: wasSelected,
            isPending: isPending,
            reviewCorrect: reviewCorrect,
            reviewWrong: reviewWrong,
            themeManager: themeManager,
            onTap: alreadyAnswered
                ? null
                : () => setState(() => _pendingIndex = index),
          );
        },
      ),
    );
  }

  // Confirm Bar (MC)
  Widget _buildConfirmBar(List<String> options, ThemeManager themeManager) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: themeManager.isDarkMode
              ? const [Color(0xFF3C3C3E), Color(0xFF2C2C2E)]
              : const [Color(0xFFFFFFFF), Color(0xFFF0FDFA)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: themeManager.primary, width: 2),
        boxShadow: [
          BoxShadow(
            color: themeManager.primary.withOpacity(0.2),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: () => setState(() => _pendingIndex = null),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                side: BorderSide(
                  color: themeManager.isDarkMode
                      ? const Color(0xFF636366)
                      : Colors.grey.shade400,
                  width: 1.5,
                ),
              ),
              child: Text(
                'Cancel',
                style: GoogleFonts.montserrat(
                  color: themeManager.isDarkMode
                      ? const Color(0xFF8E8E93)
                      : Colors.grey.shade700,
                  fontWeight: FontWeight.w600,
                  fontSize: 15,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: ElevatedButton(
              onPressed: () {
                final i = _pendingIndex;
                if (i != null) handleAnswer(i);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                foregroundColor: Colors.white,
                elevation: 0,
                padding: EdgeInsets.zero,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                shadowColor: Colors.transparent,
              ),
              child: Ink(
                decoration: BoxDecoration(
                  gradient: themeManager.isDarkMode
                      ? LinearGradient(
                          colors: [
                            themeManager.primary.withOpacity(0.8),
                            themeManager.primary,
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        )
                      : themeManager.primaryGradient,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  alignment: Alignment.center,
                  child: Text(
                    'Confirm',
                    style: GoogleFonts.montserrat(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ---------- Small widgets ----------

class OptionCard extends StatelessWidget {
  final String option;
  final int number;
  final bool isSelected;
  final bool isPending;
  final ThemeManager themeManager;
  final VoidCallback? onTap;
  final bool reviewCorrect;
  final bool reviewWrong;

  const OptionCard({
    super.key,
    required this.option,
    required this.number,
    required this.themeManager,
    this.isSelected = false,
    this.isPending = false,
    this.onTap,
    this.reviewCorrect = false,
    this.reviewWrong = false,
  });

  @override
  Widget build(BuildContext context) {
    // Determine colors based on review mode
    List<Color> gradientColors;
    Color borderColor;

    if (reviewCorrect) {
      gradientColors = const [Color(0xFF22C55E), Color(0xFF16A34A)];
      borderColor = const Color(0xFF16A34A);
    } else if (reviewWrong) {
      gradientColors = const [Color(0xFFFF6B6A), Color(0xFFFF4B4A)];
      borderColor = const Color(0xFFFF4B4A);
    } else if (isSelected || isPending) {
      gradientColors = themeManager.isDarkMode
          ? const [Color(0xFF3C3C3E), Color(0xFF2C2C2E)]
          : const [Color(0xFFFFFFFF), Color(0xFFF0FDFA)];
      borderColor = isSelected ? themeManager.primary : themeManager.secondary;
    } else {
      gradientColors = themeManager.isDarkMode
          ? const [Color(0xFF2C2C2E), Color(0xFF1C1C1E)]
          : const [Color(0xFFFFFFFF), Color(0xFFFAFAFA)];
      borderColor = themeManager.isDarkMode
          ? const Color(0xFF636366)
          : const Color(0xFFE3E6EE);
    }

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: gradientColors,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: borderColor,
          width: isSelected || isPending || reviewCorrect || reviewWrong
              ? 2.5
              : 1.5,
        ),
        boxShadow: [
          if (isSelected || isPending || reviewCorrect || reviewWrong)
            BoxShadow(
              color:
                  (reviewCorrect
                          ? const Color(0xFF16A34A)
                          : reviewWrong
                          ? const Color(0xFFFF4B4A)
                          : themeManager.primary)
                      .withOpacity(0.3),
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
                    gradient: themeManager.primaryGradient,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: themeManager.primary.withOpacity(0.3),
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
                          ? themeManager.primary
                          : themeManager.textPrimary,
                    ),
                  ),
                ),
                if (isSelected)
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      gradient: themeManager.primaryGradient,
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
  final ThemeManager themeManager;
  const _LegendDot({
    required this.label,
    required this.color,
    required this.themeManager,
  });
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
            color: themeManager.isDarkMode
                ? const Color(0xFFE5E5EA)
                : Colors.black54,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

// ========== Mix & Match Widgets ==========

class _LetterCard extends StatelessWidget {
  final String letter;
  final bool isMatched;
  final bool isFloating;
  final ThemeManager themeManager;

  const _LetterCard({
    required this.letter,
    required this.themeManager,
    this.isMatched = false,
    this.isFloating = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: isFloating ? 140 : double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isMatched
              ? [const Color(0xFFFBBF24), const Color(0xFFF59E0B)]
              : themeManager.isDarkMode
              ? [const Color(0xFF3C3C3E), const Color(0xFF2C2C2E)]
              : [const Color(0xFFFFFFFF), const Color(0xFFF0FDFA)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isMatched
              ? const Color(0xFFFBBF24)
              : themeManager.primary.withOpacity(0.3),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: (isMatched ? const Color(0xFFFBBF24) : themeManager.primary)
                .withOpacity(0.2),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Text(
            letter,
            textAlign: TextAlign.center,
            style: GoogleFonts.montserrat(
              fontSize: 13,
              fontWeight: FontWeight.w800,
              color: isMatched ? Colors.white : themeManager.primary,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ),
    );
  }
}

class _ImageCard extends StatelessWidget {
  final String imagePath;
  final bool isMatched;
  final bool isHovering;
  final bool reviewCorrect;
  final bool reviewWrong;
  final String? matchedLetter;

  const _ImageCard({
    required this.imagePath,
    this.isMatched = false,
    this.isHovering = false,
    this.reviewCorrect = false,
    this.reviewWrong = false,
    this.matchedLetter,
  });

  @override
  Widget build(BuildContext context) {
    List<Color> colors;
    if (reviewCorrect) {
      colors = const [Color(0xFF22C55E), Color(0xFF16A34A)];
    } else if (reviewWrong) {
      colors = const [Color(0xFFFF6B6A), Color(0xFFFF4B4A)];
    } else if (isHovering) {
      colors = const [Color(0xFF06B6D4), Color(0xFF0891B2)];
    } else if (isMatched) {
      colors = const [Color(0xFFFBBF24), Color(0xFFF59E0B)];
    } else {
      colors = const [Color(0xFFFFFFFF), Color(0xFFF0FDFA)];
    }

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: colors,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF1B3C73), width: 1.0),
        boxShadow: [
          BoxShadow(
            color:
                (reviewWrong
                        ? const Color(0xFFFF4B4A)
                        : reviewCorrect
                        ? const Color(0xFF22C55E)
                        : isHovering
                        ? const Color(0xFF06B6D4)
                        : const Color(0xFFEF4444))
                    .withOpacity(isHovering ? 0.3 : 0.15),
            blurRadius: isHovering ? 12 : 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Stack(
          children: [
            Positioned.fill(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.asset(
                  imagePath,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stack) => const Center(
                    child: Icon(
                      Icons.broken_image_rounded,
                      size: 32,
                      color: Colors.grey,
                    ),
                  ),
                ),
              ),
            ),
            if (matchedLetter != null && !reviewCorrect && !reviewWrong)
              Positioned(
                right: 8,
                top: 8,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 6,
                  ),
                  constraints: const BoxConstraints(
                    maxWidth: 80,
                    minHeight: 35,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF59E0B),
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFF59E0B).withOpacity(0.4),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      matchedLetter!,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.montserrat(
                        fontSize: 11,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
              ),
            if (reviewCorrect || reviewWrong)
              Positioned(
                right: 8,
                top: 8,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.85),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    reviewCorrect ? Icons.check_rounded : Icons.close_rounded,
                    size: 18,
                    color: reviewCorrect
                        ? const Color(0xFF16A34A)
                        : const Color(0xFFD90416),
                  ),
                ),
              ),
          ],
        ),
      ),
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
                  ? const [Color(0xFFEF4444), Color(0xFFDC2626)]
                  : [widget.color, widget.color.withOpacity(0.8)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: widget.color == const Color(0xFF2C5CB0)
                    ? const Color(0xFFEF4444).withOpacity(0.4)
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

// Clean Confirm Dialog
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
    final themeManager = ThemeManager.of(context, listen: false);
    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      backgroundColor: Colors.transparent,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: themeManager.isDarkMode
                ? [const Color(0xFF2C2C2E), const Color(0xFF1C1C1E)]
                : [const Color(0xFFFAFAFA), const Color(0xFFF0FDFA)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: themeManager.primary.withOpacity(0.3),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: themeManager.primary.withOpacity(0.2),
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
              Container(
                width: 110,
                height: 110,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: icon == Icons.warning_amber_rounded
                        ? const [Color(0xFFFF4B4A), Color(0xFFFF6B6A)]
                        : themeManager.isDarkMode
                        ? [const Color(0xFF8B1F1F), const Color(0xFFD23232)]
                        : [const Color(0xFFEF4444), const Color(0xFFDC2626)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color:
                          (icon == Icons.warning_amber_rounded
                                  ? const Color(0xFFFF4B4A)
                                  : themeManager.primary)
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
                  color: themeManager.textPrimary,
                  letterSpacing: -0.3,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                message,
                textAlign: TextAlign.center,
                style: GoogleFonts.montserrat(
                  fontSize: 15,
                  color: themeManager.isDarkMode
                      ? const Color(0xFF8E8E93)
                      : const Color(0xFF6B7280),
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 22),
              Row(
                children: [
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: themeManager.isDarkMode
                              ? [
                                  const Color(0xFF3C3C3E),
                                  const Color(0xFF2C2C2E),
                                ]
                              : [
                                  const Color(0xFFFAFAFA),
                                  const Color(0xFFFFFFFF),
                                ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: themeManager.isDarkMode
                              ? const Color(0xFF636366)
                              : themeManager.primary.withOpacity(0.5),
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
                                color: themeManager.primary,
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
                        gradient: themeManager.primaryGradient,
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: [
                          BoxShadow(
                            color: themeManager.primary.withOpacity(0.3),
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

class _MCQReviewDialog extends StatelessWidget {
  final List<Map<String, dynamic>> reviewData;
  final int correctCount;
  final int totalCount;
  final VoidCallback onContinue;

  const _MCQReviewDialog({
    required this.reviewData,
    required this.correctCount,
    required this.totalCount,
    required this.onContinue,
  });

  @override
  Widget build(BuildContext context) {
    final themeManager = ThemeManager.of(context, listen: false);
    final isPerfect = correctCount == totalCount;

    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
      backgroundColor: Colors.transparent,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 500),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: themeManager.isDarkMode
                ? const [Color(0xFF2C2C2E), Color(0xFF1C1C1E)]
                : const [Color(0xFFFAFAFA), Color(0xFFF0FDFA)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(28),
          border: Border.all(
            color: themeManager.primary.withOpacity(0.3),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: themeManager.primary.withOpacity(0.25),
              blurRadius: 24,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: isPerfect
                      ? const [Color(0xFF22C55E), Color(0xFF16A34A)]
                      : const [Color(0xFFEF4444), Color(0xFFDC2626)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(28),
                  topRight: Radius.circular(28),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    isPerfect
                        ? Icons.emoji_events_rounded
                        : Icons.visibility_rounded,
                    color: Colors.white,
                    size: 32,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    isPerfect ? 'Perfect Score!' : 'Review Your Answers',
                    style: GoogleFonts.montserrat(
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),

            // Score
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  vertical: 16,
                  horizontal: 28,
                ),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: themeManager.isDarkMode
                        ? const [Color(0xFF3C3C3E), Color(0xFF2C2C2E)]
                        : const [Color(0xFFFFFFFF), Color(0xFFF0FDFA)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: themeManager.primary.withOpacity(0.3),
                    width: 1.5,
                  ),
                ),
                child: ShaderMask(
                  shaderCallback: (bounds) => const LinearGradient(
                    colors: [Color(0xFFEF4444), Color(0xFFDC2626)],
                  ).createShader(bounds),
                  child: Text(
                    "$correctCount / $totalCount Correct",
                    style: GoogleFonts.montserrat(
                      fontSize: 28,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),

            // Review List
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: reviewData.asMap().entries.map((entry) {
                    final index = entry.key;
                    final data = entry.value;
                    final imagePath = data['image'] as String;
                    final correctVerb = data['correctVerb'] as String;
                    final options = data['options'] as List<String>;
                    final userIndex = data['userIndex'] as int?;
                    final isCorrect = data['isCorrect'] as bool;

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: isCorrect
                                ? const [Color(0xFF22C55E), Color(0xFF16A34A)]
                                : const [Color(0xFFFF6B6A), Color(0xFFFF4B4A)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color:
                                  (isCorrect
                                          ? const Color(0xFF22C55E)
                                          : const Color(0xFFFF4B4A))
                                      .withOpacity(0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            // Question number
                            Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Center(
                                child: Text(
                                  "${index + 1}",
                                  style: GoogleFonts.montserrat(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w900,
                                    color: isCorrect
                                        ? const Color(0xFF16A34A)
                                        : const Color(0xFFFF4B4A),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),

                            // Image
                            Container(
                              width: 60,
                              height: 60,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: Image.asset(
                                  imagePath,
                                  fit: BoxFit.contain,
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),

                            // User's answer
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Your answer:",
                                    style: GoogleFonts.montserrat(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white.withOpacity(0.8),
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    userIndex != null
                                        ? options[userIndex]
                                        : "N/A",
                                    style: GoogleFonts.montserrat(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w900,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            // Show correct answer if wrong
                            if (!isCorrect) ...[
                              const SizedBox(width: 8),
                              Icon(
                                Icons.arrow_forward_rounded,
                                color: Colors.white.withOpacity(0.7),
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 8,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Text(
                                  correctVerb,
                                  style: GoogleFonts.montserrat(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w900,
                                    color: const Color(0xFF16A34A),
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),

            // Continue Button
            Padding(
              padding: const EdgeInsets.all(20),
              child: SizedBox(
                width: double.infinity,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: themeManager.primaryGradient,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: themeManager.primary.withOpacity(0.4),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: onContinue,
                      borderRadius: BorderRadius.circular(16),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.arrow_forward_rounded,
                              color: Colors.white,
                              size: 24,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              "Continue",
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
            ),
          ],
        ),
      ),
    );
  }
}

class _MixMatchReviewDialog extends StatelessWidget {
  final List<Map<String, dynamic>> reviewData;
  final bool allCorrect;
  final VoidCallback onContinue;

  const _MixMatchReviewDialog({
    required this.reviewData,
    required this.allCorrect,
    required this.onContinue,
  });

  @override
  Widget build(BuildContext context) {
    final themeManager = ThemeManager.of(context, listen: false);
    final correctCount = reviewData.where((d) => d['isCorrect'] == true).length;
    final totalCount = reviewData.length;

    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
      backgroundColor: Colors.transparent,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 500),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: themeManager.isDarkMode
                ? const [Color(0xFF2C2C2E), Color(0xFF1C1C1E)]
                : const [Color(0xFFFAFAFA), Color(0xFFF0FDFA)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(28),
          border: Border.all(
            color: themeManager.primary.withOpacity(0.3),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: themeManager.primary.withOpacity(0.25),
              blurRadius: 24,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFFFFA726), Color(0xFFFF9800)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(28),
                  topRight: Radius.circular(28),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.visibility_rounded,
                    color: Colors.white,
                    size: 28,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    allCorrect ? 'Perfect Match!' : 'Review Your Answers',
                    style: GoogleFonts.montserrat(
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),

            // Score
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  vertical: 16,
                  horizontal: 28,
                ),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: themeManager.isDarkMode
                        ? const [Color(0xFF3C3C3E), Color(0xFF2C2C2E)]
                        : const [Color(0xFFFFFFFF), Color(0xFFF0FDFA)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  "$correctCount / $totalCount Correct",
                  style: GoogleFonts.montserrat(
                    fontSize: 26,
                    fontWeight: FontWeight.w900,
                    color: const Color(0xFFEF4444),
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),

            // Review List
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  children: reviewData.map((data) {
                    final verb = data['verb'] as String;
                    final correctImage = data['correctImage'] as String;
                    final userImage = data['userImage'] as String?;
                    final isCorrect = data['isCorrect'] as bool;

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: isCorrect
                                ? const [Color(0xFF22C55E), Color(0xFF16A34A)]
                                : const [Color(0xFFFF6B6B), Color(0xFFFF5252)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color:
                                  (isCorrect
                                          ? const Color(0xFF16A34A)
                                          : const Color(0xFFFF5252))
                                      .withOpacity(0.4),
                              blurRadius: 8,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            // Verb text
                            Container(
                              width: 65,
                              height: 65,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(14),
                              ),
                              padding: const EdgeInsets.all(4),
                              child: Center(
                                child: Text(
                                  verb,
                                  textAlign: TextAlign.center,
                                  style: GoogleFonts.montserrat(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w900,
                                    color: isCorrect
                                        ? const Color(0xFF16A34A)
                                        : const Color(0xFFFF5252),
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),

                            // Arrow
                            const Icon(
                              Icons.arrow_forward_rounded,
                              color: Colors.white,
                              size: 20,
                            ),
                            const SizedBox(width: 8),

                            // User's matched image
                            Container(
                              width: 80,
                              height: 65,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(16),
                              ),
                              padding: const EdgeInsets.all(4),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: userImage != null
                                    ? Image.asset(
                                        userImage,
                                        fit: BoxFit.contain,
                                      )
                                    : const Center(
                                        child: Icon(
                                          Icons.help_outline_rounded,
                                          color: Colors.grey,
                                        ),
                                      ),
                              ),
                            ),

                            // Always show arrow and correct image for learning
                            const SizedBox(width: 8),
                            const Icon(
                              Icons.arrow_forward_rounded,
                              color: Colors.white,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Container(
                              width: 80,
                              height: 65,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(16),
                              ),
                              padding: const EdgeInsets.all(4),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: Image.asset(
                                  correctImage,
                                  fit: BoxFit.contain,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),

            // Continue Button
            Padding(
              padding: const EdgeInsets.all(20),
              child: SizedBox(
                width: double.infinity,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF8B0000), Color(0xFF6B0000)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF8B0000).withOpacity(0.4),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: onContinue,
                      borderRadius: BorderRadius.circular(16),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.check_circle_rounded,
                              size: 26,
                              color: Colors.white,
                            ),
                            const SizedBox(width: 10),
                            Text(
                              'Continue',
                              style: GoogleFonts.montserrat(
                                fontSize: 20,
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
            ),
          ],
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
    final themeManager = ThemeManager.of(context, listen: false);
    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
      backgroundColor: Colors.transparent,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: themeManager.isDarkMode
                ? [const Color(0xFF2C2C2E), const Color(0xFF1C1C1E)]
                : [const Color(0xFFFAFAFA), const Color(0xFFF0FDFA)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(28),
          border: Border.all(
            color: themeManager.primary.withOpacity(0.3),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: themeManager.primary.withOpacity(0.25),
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
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: isPerfect
                        ? const [Color(0xFFFFD700), Color(0xFFFFA500)]
                        : (themeManager.isDarkMode
                              ? [
                                  const Color(0xFF8B1F1F),
                                  const Color(0xFFD23232),
                                ]
                              : [
                                  const Color(0xFFEF4444),
                                  const Color(0xFFDC2626),
                                ]),
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color:
                          (isPerfect
                                  ? const Color(0xFFFFD700)
                                  : themeManager.primary)
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
              ShaderMask(
                shaderCallback: (bounds) => LinearGradient(
                  colors: isPerfect
                      ? const [Color(0xFFFFD700), Color(0xFFFFA500)]
                      : (themeManager.isDarkMode
                            ? [const Color(0xFF8B1F1F), const Color(0xFFD23232)]
                            : [
                                const Color(0xFFEF4444),
                                const Color(0xFFDC2626),
                              ]),
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
              Text(
                isPerfect
                    ? "You answered every question flawlessly."
                    : "You completed this quiz successfully!",
                textAlign: TextAlign.center,
                style: GoogleFonts.montserrat(
                  fontSize: 16,
                  color: themeManager.isDarkMode
                      ? const Color(0xFF8E8E93)
                      : const Color(0xFF4B5563),
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 26),
              Container(
                padding: const EdgeInsets.symmetric(
                  vertical: 24,
                  horizontal: 28,
                ),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: themeManager.isDarkMode
                        ? [const Color(0xFF3C3C3E), const Color(0xFF2C2C2E)]
                        : [const Color(0xFFFFFFFF), const Color(0xFFF0FDFA)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: themeManager.primary.withOpacity(0.3),
                    width: 1.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: themeManager.primary.withOpacity(0.15),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Center(
                  child: ShaderMask(
                    shaderCallback: (bounds) => LinearGradient(
                      colors: themeManager.isDarkMode
                          ? [const Color(0xFF8B1F1F), const Color(0xFFD23232)]
                          : [const Color(0xFFEF4444), const Color(0xFFDC2626)],
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
              SizedBox(
                width: double.infinity,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: themeManager.primaryGradient,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFEF4444).withOpacity(0.4),
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
                          children: const [
                            Icon(
                              Icons.arrow_back_rounded,
                              size: 24,
                              color: Colors.white,
                            ),
                            SizedBox(width: 8),
                            Text(
                              'Return',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                                fontFamily: 'Montserrat',
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

// ========== Bonus Round Dialog ==========
class _BonusRoundDialog extends StatelessWidget {
  const _BonusRoundDialog();

  @override
  Widget build(BuildContext context) {
    final themeManager = ThemeManager.of(context, listen: false);
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      backgroundColor: themeManager.isDarkMode
          ? const Color(0xFF2C2C2E)
          : Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                gradient: themeManager.primaryGradient,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: themeManager.primary.withOpacity(0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: const Icon(
                Icons.bolt_rounded,
                color: Colors.white,
                size: 40,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Bonus Round:\nMix & Match!',
              textAlign: TextAlign.center,
              style: GoogleFonts.montserrat(
                fontSize: 24,
                fontWeight: FontWeight.w900,
                color: themeManager.textPrimary,
                height: 1.3,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Great job! Now drag letters to their matching signs.',
              textAlign: TextAlign.center,
              style: GoogleFonts.montserrat(
                fontSize: 15,
                color: themeManager.isDarkMode
                    ? const Color(0xFF8E8E93)
                    : const Color(0xFF6B7280),
                height: 1.5,
              ),
            ),
            const SizedBox(height: 28),
            SizedBox(
              width: double.infinity,
              child: Container(
                decoration: BoxDecoration(
                  gradient: themeManager.primaryGradient,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: themeManager.primary.withOpacity(0.4),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () => Navigator.pop(context),
                    borderRadius: BorderRadius.circular(16),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      alignment: Alignment.center,
                      child: Text(
                        'Let\'s Go!',
                        style: GoogleFonts.montserrat(
                          fontSize: 17,
                          fontWeight: FontWeight.w800,
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
      ),
    );
  }
}
