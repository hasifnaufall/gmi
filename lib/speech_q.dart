// lib/speech_q.dart
// Matching alphabet_q.dart style with cyan/mint theme

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'badges/badges_engine.dart';

import 'quest_status.dart';
import 'services/sfx_service.dart';
import 'theme_manager.dart';

enum QuizType { multipleChoice, mixMatch, both }

// NEW: Cute Bottom Sheet Quiz Type Selection
Future<void> showSpeechQuizSelection(BuildContext context) {
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
                        ? [const Color(0xFFD23232), const Color(0xFF8B1F1F)]
                        : [const Color(0xFF69D3E4), const Color(0xFF4FC3E4)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color:
                          (themeManager.isDarkMode
                                  ? const Color(0xFFD23232)
                                  : const Color(0xFF69D3E4))
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
            gradient: themeManager.isDarkMode
                ? const [Color(0xFFD23232), Color(0xFF8B1F1F)]
                : const [Color(0xFF69D3E4), Color(0xFF4FC3E4)],
            themeManager: themeManager,
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) =>
                      const SpeechQuizScreen(quizType: QuizType.multipleChoice),
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
            themeManager: themeManager,
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) =>
                      const SpeechQuizScreen(quizType: QuizType.mixMatch),
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
            themeManager: themeManager,
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) =>
                      const SpeechQuizScreen(quizType: QuizType.both),
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
  final ThemeManager themeManager;

  const _CompactQuizCard({
    required this.icon,
    required this.title,
    required this.description,
    required this.gradient,
    required this.onTap,
    required this.themeManager,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = themeManager.isDarkMode;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: isDark
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
                        color: isDark
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
                        color: const Color(0xFF6B7280),
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

class SpeechQuizScreen extends StatefulWidget {
  final QuizType quizType;

  const SpeechQuizScreen({super.key, this.quizType = QuizType.both});

  @override
  State<SpeechQuizScreen> createState() => _SpeechQuizScreenState();
}

class _SpeechQuizScreenState extends State<SpeechQuizScreen>
    with SingleTickerProviderStateMixin {
  // Session sizes
  static const int multipleChoiceSize = 10;
  static const int mixMatchSize = 6;

  // Mix & Match visual sizing
  static const double mmRowGap = 10;
  static const double mmImageHeight = 95; // hand sign box
  static const double mmPhraseHeight = 70; // phrase box

  // Multiple choice state
  late List<int> activeIndices;
  late int currentSlot;
  bool isOptionSelected = false;
  int? _pendingIndex;
  final Map<int, bool> _sessionAnswers = {};

  // Mix & Match state
  late List<int> mixMatchIndices;
  bool _isInMixMatchRound = false;
  final Map<String, String> _currentMatches = {}; // leftId -> rightId
  List<String> _mmPhrasesOrder = [];
  List<String> _mmImagesOrder = [];
  Map<String, String> _imageForPhrase = {}; // phrase -> imagePath
  final ScrollController _mmScroll = ScrollController();

  // MCQ Review mode
  bool _mcqReviewMode = false;
  final Map<int, int> _userSelectedIndex = {}; // qIdx -> selectedIndex

  // Mix & Match Review mode
  int _mmCorrectCount = 0;
  bool _mmReviewMode = false;
  final Set<String> _mmCorrectRightIds = {}; // e.g. right_Hello
  final Set<String> _mmWrongRightIds = {};

  // Animations
  late AnimationController _controller;
  late Animation<Offset> _offsetAnimation;
  late Animation<double> _fadeAnimation;

  // Questions - speech phrases
  final List<Map<String, dynamic>> questions = [
    {'phrase': 'How are you', 'image': 'assets/images/speech/hay.jpg'},
    {'phrase': 'Peace Be Upon You', 'image': 'assets/images/speech/pbay.jpg'},
    {'phrase': 'Hello', 'image': 'assets/images/speech/hello.jpg'},
    {'phrase': 'Excuse', 'image': 'assets/images/speech/excuse.jpg'},
    {'phrase': 'Sorry', 'image': 'assets/images/speech/sorry.jpg'},
    {'phrase': 'Salam', 'image': 'assets/images/speech/salam.jpg'},
    {'phrase': 'Regards', 'image': 'assets/images/speech/regards.jpg'},
    {'phrase': 'You are Welcome', 'image': 'assets/images/speech/yaw.jpg'},
    {'phrase': 'Well', 'image': 'assets/images/speech/well.jpg'},
    {'phrase': 'Welcome', 'image': 'assets/images/speech/welcome.jpg'},
    {'phrase': 'Happy Birthday', 'image': 'assets/images/speech/birthday.jpg'},
    {'phrase': 'Goodbye', 'image': 'assets/images/speech/goodbye.jpg'},
    {'phrase': 'Good Night', 'image': 'assets/images/speech/goodnight.jpg'},
    {'phrase': 'Good Morning', 'image': 'assets/images/speech/goodmorning.jpg'},
    {'phrase': 'Good Evening', 'image': 'assets/images/speech/goodevening.jpg'},
    {'phrase': 'Good Afternoon', 'image': 'assets/images/speech/afternoon.jpg'},
    {'phrase': 'Congratulations', 'image': 'assets/images/speech/congrats.jpg'},
    {'phrase': 'Thank you', 'image': 'assets/images/speech/thankyou.jpg'},
    {'phrase': 'PLease', 'image': 'assets/images/speech/please.jpg'},
    {'phrase': 'And unto you peace', 'image': 'assets/images/speech/auyp.jpg'},
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

  // Generate randomized options for a question
  List<String> _generateOptions(int qIdx) {
    if (_questionOptions.containsKey(qIdx)) {
      return _questionOptions[qIdx]!;
    }

    final correctPhrase = questions[qIdx]['phrase'] as String;
    final allPhrases = questions.map((q) => q['phrase'] as String).toList();
    allPhrases.remove(correctPhrase);
    allPhrases.shuffle();

    final wrongOptions = allPhrases.take(3).toList();
    final options = [...wrongOptions, correctPhrase]..shuffle();

    _questionOptions[qIdx] = options;
    _questionCorrectIndex[qIdx] = options.indexOf(correctPhrase);

    return options;
  }

  @override
  void initState() {
    super.initState();
    Sfx().init();

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

    currentSlot = 0;

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
    _imageForPhrase.clear();
    for (final idx in mixMatchIndices) {
      final phrase = questions[idx]['phrase'] as String;
      final image = questions[idx]['image'] as String;
      _imageForPhrase[phrase] = image;
    }
    final phrases = mixMatchIndices
        .map((i) => questions[i]['phrase'] as String)
        .toList();
    final images = mixMatchIndices
        .map((i) => questions[i]['image'] as String)
        .toList();
    _mmPhrasesOrder = List<String>.from(phrases)..shuffle();
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

    if (isCorrect) {
      QuestStatus.addXp(20);
    }

    // Enter review mode
    await Future.delayed(const Duration(milliseconds: 300));
    if (!mounted) return;

    setState(() => _mcqReviewMode = true);

    await Future.delayed(const Duration(milliseconds: 1000));
    if (!mounted) return;

    setState(() => _mcqReviewMode = false);

    // Show review dialog if all MCQ answered
    if (_allAnsweredInSession()) {
      if (!mounted) return;
      await _showMCQReviewDialog();

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

  // NEW: Undo a specific match in Mix & Match
  void _undoMatch(String rightId) {
    setState(() {
      _currentMatches.removeWhere((key, value) => value == rightId);
    });
  }

  void _onAllPairsFilled() async {
    _evaluateMixMatchAndReview();
  } // Evaluate + enter review mode, then show dialog

  void _evaluateMixMatchAndReview() {
    _mmCorrectRightIds.clear();
    _mmWrongRightIds.clear();
    _mmCorrectCount = 0;

    for (final idx in mixMatchIndices) {
      final phrase = questions[idx]['phrase'] as String;
      final leftId = "left_$phrase";
      final rightId = "right_$phrase";
      if (_currentMatches[leftId] == rightId) {
        _mmCorrectRightIds.add(rightId);
        _mmCorrectCount++;
      } else {
        _mmWrongRightIds.add(rightId);
      }
    }

    // Enter review mode (disable dragging; show colors)
    setState(() => _mmReviewMode = true);

    // After 1s → exit review, show dialog + finish
    Future.delayed(const Duration(milliseconds: 1000), () async {
      if (!mounted) return;
      setState(() => _mmReviewMode = false);
      await _showMixMatchReviewDialog();
      _completeMixMatch();
    });
  }

  Future<void> _showMCQReviewDialog() async {
    final reviewData = <Map<String, dynamic>>[];
    for (int i = 0; i < activeIndices.length; i++) {
      final qIdx = activeIndices[i];
      final isCorrect = _sessionAnswers[qIdx] == true;
      final correctIndex = _questionCorrectIndex[qIdx]!;
      final userIndex = _userSelectedIndex[qIdx]!;
      reviewData.add({
        'questionNumber': i + 1,
        'imagePath': questions[qIdx]['image'] as String,
        'correctAnswer': _questionOptions[qIdx]![correctIndex],
        'userAnswer': _questionOptions[qIdx]![userIndex],
        'isCorrect': isCorrect,
      });
    }

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => _MCQReviewDialog(reviewData: reviewData),
    );
  }

  Future<void> _showMixMatchReviewDialog() async {
    final reviewData = <Map<String, dynamic>>[];
    for (final idx in mixMatchIndices) {
      final phrase = questions[idx]['phrase'] as String;
      final leftId = "left_$phrase";
      final rightId = "right_$phrase";
      final isCorrect = _currentMatches[leftId] == rightId;
      reviewData.add({
        'imagePath': _imageForPhrase[phrase]!,
        'correctAnswer': phrase,
        'isCorrect': isCorrect,
      });
    }

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => _MixMatchReviewDialog(
        reviewData: reviewData,
        correctCount: _mmCorrectCount,
        totalCount: mixMatchIndices.length,
      ),
    );
  }

  // Separate finisher (used after review)
  void _completeMixMatch() {
    // Proportional XP: 10 per correct pair
    final xpEarned = _mmCorrectCount * 10;
    if (xpEarned > 0) {
      QuestStatus.addXp(xpEarned);
    }
    Future.delayed(const Duration(milliseconds: 500), () => _finishSession());
  }

  // Session Completion
  Future<void> _finishSession() async {
    if (!mounted) return;

    int sessionScore = 0;

    // Count correct answers
    for (final i in activeIndices) {
      if (_sessionAnswers[i] == true) sessionScore++;
    }

    // Count Mix&Match correct pairs individually
    sessionScore += _mmCorrectCount;

    final totalQuestions =
        activeIndices.length +
        (mixMatchIndices.isEmpty ? 0 : mixMatchIndices.length);

    // BADGES: update counters
    QuestStatus.quizzesCompleted++;

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
    QuestStatus.playedSpeech = true;

    // Evaluate & show any newly unlocked badge popup
    await BadgeEngine.checkAndToast(context);

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
            backgroundColor: themeManager.isDarkMode
                ? const Color(0xFF1C1C1E)
                : const Color(0xFFCFFFF7),
            body: SafeArea(
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: SlideTransition(
                  position: _offsetAnimation,
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      children: [
                        _buildHeader("Speech Quiz", themeManager),
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
    if (_mmPhrasesOrder.isEmpty || _mmImagesOrder.isEmpty) {
      _prepareMixMatchRound();
    }

    final totalPairs = mixMatchIndices.length;

    return Consumer<ThemeManager>(
      builder: (context, themeManager, child) {
        return WillPopScope(
          onWillPop: () async => await _confirmExitQuiz(),
          child: Scaffold(
            backgroundColor: themeManager.isDarkMode
                ? const Color(0xFF1C1C1E)
                : const Color(0xFFCFFFF7),
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
                                phrasesOrder: _mmPhrasesOrder,
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
    final isDark = themeManager.isDarkMode;
    return Row(
      children: [
        IconButton(
          onPressed: _handleBackPressed,
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: isDark
                    ? [const Color(0xFF3C3C3E), const Color(0xFF2C2C2E)]
                    : [const Color(0xFFFFFFFF), const Color(0xFFF0FDFA)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isDark
                    ? const Color(0xFFD23232).withOpacity(0.3)
                    : const Color(0xFF69D3E4).withOpacity(0.3),
              ),
              boxShadow: [
                BoxShadow(
                  color: isDark
                      ? const Color(0xFFD23232).withOpacity(0.15)
                      : const Color(0xFF69D3E4).withOpacity(0.15),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Icon(
              Icons.arrow_back_ios_new_rounded,
              color: isDark ? const Color(0xFFD23232) : const Color(0xFF69D3E4),
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
              color: isDark ? const Color(0xFFD23232) : const Color(0xFF69D3E4),
              letterSpacing: -0.5,
            ),
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: isDark
                  ? [const Color(0xFFD23232), const Color(0xFF8B1F1F)]
                  : [const Color(0xFF69D3E4), const Color(0xFF4FC3E4)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: isDark
                    ? const Color(0xFFD23232).withOpacity(0.3)
                    : const Color(0xFF69D3E4).withOpacity(0.3),
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

  // Progress
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
            gradient: const LinearGradient(
              colors: [Colors.white, Color(0xFFF0FDFA)],
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
          children: const [
            _LegendDot(label: 'Correct', color: Color(0xFF22C55E)),
            _LegendDot(label: 'Wrong', color: Color(0xFFFF4B4A)),
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
              valueColor: AlwaysStoppedAnimation(
                themeManager.isDarkMode
                    ? const Color(0xFFD23232)
                    : const Color(0xFF69D3E4),
              ),
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
            color: themeManager.isDarkMode
                ? const Color(0xFF8E8E93)
                : Colors.black54,
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
              ? [const Color(0xFF3C3C3E), const Color(0xFF2C2C2E)]
              : [const Color(0xFFFFFFFF), const Color(0xFFF0FDFA)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: themeManager.isDarkMode
              ? const Color(0xFFD23232).withOpacity(0.3)
              : const Color(0xFF69D3E4).withOpacity(0.3),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: themeManager.isDarkMode
                ? const Color(0xFFD23232).withOpacity(0.15)
                : const Color(0xFF69D3E4).withOpacity(0.15),
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
              gradient: LinearGradient(
                colors: themeManager.isDarkMode
                    ? [const Color(0xFFD23232), const Color(0xFF8B1F1F)]
                    : [const Color(0xFF69D3E4), const Color(0xFF4FC3E4)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
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
              "Drag phrases to their matching signs",
              style: GoogleFonts.montserrat(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: themeManager.isDarkMode
                    ? const Color(0xFFD23232)
                    : const Color(0xFF69D3E4),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Matching area (organized rows; right is bigger) - NOW WITH UNDO BUTTON
  Widget _buildMatchingAreaStable({
    required List<String> phrasesOrder,
    required List<String> imagesOrder,
    required ThemeManager themeManager,
  }) {
    assert(
      phrasesOrder.length == imagesOrder.length,
      "phrasesOrder and imagesOrder must be same length",
    );

    return Column(
      children: List.generate(phrasesOrder.length, (i) {
        final phrase = phrasesOrder[i];
        final leftId = "left_$phrase";
        final isLeftMatched = _currentMatches.containsKey(leftId);

        final imagePath = imagesOrder[i];
        final rightPhrase = _imageForPhrase.entries
            .firstWhere((e) => e.value == imagePath)
            .key;
        final rightId = "right_$rightPhrase";
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
                // Left: draggable phrase (disabled in review)
                Expanded(
                  flex: 2,
                  child: Center(
                    child: Opacity(
                      opacity: (isLeftMatched || _mmReviewMode) ? 0.5 : 1.0,
                      child: IgnorePointer(
                        ignoring: isLeftMatched || _mmReviewMode,
                        child: Draggable<String>(
                          data: leftId,
                          feedback: Material(
                            elevation: 8,
                            borderRadius: BorderRadius.circular(16),
                            child: _PhraseCard(
                              phrase: phrase,
                              isFloating: true,
                              themeManager: themeManager,
                            ),
                          ),
                          childWhenDragging: Opacity(
                            opacity: 0.3,
                            child: _PhraseCard(
                              phrase: phrase,
                              themeManager: themeManager,
                            ),
                          ),
                          child: _PhraseCard(
                            phrase: phrase,
                            isMatched: isLeftMatched,
                            themeManager: themeManager,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(width: 10),

                // Right: drag target (disabled in review) with UNDO button
                Expanded(
                  flex: 3,
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

                          // Extract matched phrase from leftId
                          String? matchedPhrase;
                          if (isRightMatched) {
                            final leftId = _currentMatches.entries
                                .firstWhere((e) => e.value == rightId)
                                .key;
                            matchedPhrase = leftId.replaceFirst('left_', '');
                          }

                          return SizedBox(
                            height: mmImageHeight,
                            child: _ImageCard(
                              imagePath: imagePath,
                              isMatched: isRightMatched,
                              isHovering: isHovering,
                              reviewCorrect: showCorrect,
                              reviewWrong: showWrong,
                              matchedPhrase: matchedPhrase,
                              themeManager: themeManager,
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

  // Question Card
  Widget _buildQuestionCard(
    Map<String, dynamic> question,
    ThemeManager themeManager,
  ) {
    final isDark = themeManager.isDarkMode;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDark
              ? [const Color(0xFF3C3C3E), const Color(0xFF2C2C2E)]
              : [const Color(0xFFFFFFFF), const Color(0xFFF0FDFA)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isDark
              ? const Color(0xFFD23232).withOpacity(0.3)
              : const Color(0xFF69D3E4).withOpacity(0.3),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? const Color(0xFFD23232).withOpacity(0.15)
                : const Color(0xFF69D3E4).withOpacity(0.15),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            "What phrase is being signed?",
            textAlign: TextAlign.center,
            style: GoogleFonts.montserrat(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: isDark ? const Color(0xFFD23232) : const Color(0xFF69D3E4),
              letterSpacing: -0.3,
            ),
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1C1C1E) : Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isDark
                    ? const Color(0xFFD23232).withOpacity(0.2)
                    : const Color(0xFF69D3E4).withOpacity(0.2),
              ),
              boxShadow: [
                BoxShadow(
                  color: isDark
                      ? const Color(0xFFD23232).withOpacity(0.1)
                      : const Color(0xFF69D3E4).withOpacity(0.1),
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

  // Options Grid
  Widget _buildOptionsGrid(
    List<String> options,
    int qIdx,
    ThemeManager themeManager,
  ) {
    return Expanded(
      child: ListView.builder(
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

          // Review mode highlighting
          final showCorrect = _mcqReviewMode && isCorrect;
          final showWrong =
              _mcqReviewMode && _userSelectedIndex[qIdx] == index && !isCorrect;

          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: OptionCard(
              option: options[index],
              number: index + 1,
              isSelected: wasSelected,
              isPending: isPending,
              reviewCorrect: showCorrect,
              reviewWrong: showWrong,
              themeManager: themeManager,
              onTap: alreadyAnswered || _mcqReviewMode
                  ? null
                  : () => setState(() => _pendingIndex = index),
            ),
          );
        },
      ),
    );
  }

  // Confirm Bar
  Widget _buildConfirmBar(List<String> options, ThemeManager themeManager) {
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
          // Gradient confirm button
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 0),
              backgroundColor: Colors.transparent,
              shadowColor: Colors.transparent,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
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
                  style: GoogleFonts.montserrat(
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
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
  final bool reviewCorrect;
  final bool reviewWrong;
  final ThemeManager themeManager;
  final VoidCallback? onTap;

  const OptionCard({
    super.key,
    required this.option,
    required this.number,
    required this.themeManager,
    this.isSelected = false,
    this.isPending = false,
    this.reviewCorrect = false,
    this.reviewWrong = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    Color borderColor;
    List<Color> gradientColors;

    if (reviewCorrect) {
      borderColor = const Color(0xFF22C55E);
      gradientColors = const [Color(0xFF22C55E), Color(0xFF16A34A)];
    } else if (reviewWrong) {
      borderColor = const Color(0xFFFF4B4A);
      gradientColors = const [Color(0xFFFF6B6A), Color(0xFFFF4B4A)];
    } else if (isSelected || isPending) {
      borderColor = isSelected
          ? const Color(0xFF69D3E4)
          : const Color(0xFF4FC3E4);
      gradientColors = const [Color(0xFFFFFFFF), Color(0xFFF0FDFA)];
    } else {
      borderColor = const Color(0xFFE3E6EE);
      gradientColors = const [Color(0xFFFFFFFF), Color(0xFFFAFAFA)];
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
          width: (reviewCorrect || reviewWrong || isSelected || isPending)
              ? 2.5
              : 1.5,
        ),
        boxShadow: [
          if (isSelected || isPending || reviewCorrect || reviewWrong)
            BoxShadow(
              color: borderColor.withOpacity(0.25),
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
                    gradient: (reviewCorrect || reviewWrong)
                        ? null
                        : const LinearGradient(
                            colors: [Color(0xFF69D3E4), Color(0xFF4FC3E4)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                    color: (reviewCorrect || reviewWrong) ? Colors.white : null,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: (reviewCorrect || reviewWrong)
                            ? borderColor.withOpacity(0.3)
                            : const Color(0xFF69D3E4).withOpacity(0.3),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      number.toString(),
                      style: GoogleFonts.montserrat(
                        color: (reviewCorrect || reviewWrong)
                            ? borderColor
                            : Colors.white,
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
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: (reviewCorrect || reviewWrong)
                          ? Colors.white
                          : (isSelected || isPending
                                ? const Color(0xFF69D3E4)
                                : const Color(0xFF2D5263)),
                      height: 1.3,
                    ),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (isSelected)
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
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

// ========== Mix & Match Widgets ==========

class _PhraseCard extends StatelessWidget {
  final String phrase;
  final bool isMatched;
  final bool isFloating;
  final ThemeManager themeManager;

  const _PhraseCard({
    required this.phrase,
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
              : [const Color(0xFFFFFFFF), const Color(0xFFF0FDFA)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isMatched
              ? const Color(0xFFFBBF24)
              : const Color(0xFF69D3E4).withOpacity(0.3),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color:
                (isMatched ? const Color(0xFFFBBF24) : const Color(0xFF69D3E4))
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
            phrase,
            textAlign: TextAlign.center,
            style: GoogleFonts.montserrat(
              fontSize: 13,
              fontWeight: FontWeight.w800,
              color: isMatched ? Colors.white : const Color(0xFF69D3E4),
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
  final String? matchedPhrase;
  final ThemeManager themeManager;

  const _ImageCard({
    required this.imagePath,
    required this.themeManager,
    this.isMatched = false,
    this.isHovering = false,
    this.reviewCorrect = false,
    this.reviewWrong = false,
    this.matchedPhrase,
  });

  @override
  Widget build(BuildContext context) {
    List<Color> colors;
    if (reviewCorrect) {
      colors = const [Color(0xFF22C55E), Color(0xFF16A34A)];
    } else if (reviewWrong) {
      colors = const [Color(0xFFFF6B6A), Color(0xFFFF4B4A)];
    } else if (isHovering) {
      colors = const [Color(0xFF4FC3E4), Color(0xFF69D3E4)];
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
                        : const Color(0xFF69D3E4))
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
            if (isMatched && matchedPhrase != null)
              Positioned(
                left: 8,
                top: 8,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  constraints: const BoxConstraints(
                    maxWidth: 100,
                    minHeight: 45,
                  ),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFFFBBF24), Color(0xFFF59E0B)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.white, width: 3),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFFBBF24).withOpacity(0.5),
                        blurRadius: 12,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Text(
                    matchedPhrase!,
                    style: GoogleFonts.montserrat(
                      fontSize: 12,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                      height: 1.2,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
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
                  ? const [Color(0xFF69D3E4), Color(0xFF4FC3E4)]
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
              Container(
                width: 110,
                height: 110,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: icon == Icons.warning_amber_rounded
                        ? const [Color(0xFFFF4B4A), Color(0xFFFF6B6A)]
                        : const [Color(0xFF69D3E4), Color(0xFF4FC3E4)],
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
                          colors: [Color(0xFF69D3E4), Color(0xFF4FC3E4)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF69D3E4).withOpacity(0.3),
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

// MCQ Review Dialog
class _MCQReviewDialog extends StatelessWidget {
  final List<Map<String, dynamic>> reviewData;

  const _MCQReviewDialog({required this.reviewData});

  @override
  Widget build(BuildContext context) {
    final themeManager = ThemeManager.of(context, listen: false);
    final correctCount = reviewData.where((d) => d['isCorrect'] == true).length;

    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
      backgroundColor: Colors.transparent,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 500, maxHeight: 600),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: themeManager.isDarkMode
                ? const [Color(0xFF2C2C2E), Color(0xFF1C1C1E)]
                : const [Color(0xFFFFFFFF), Color(0xFFF0FDFA)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(28),
          border: Border.all(
            color: themeManager.primary.withOpacity(0.3),
            width: 2,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: themeManager.primaryGradient.colors,
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(26),
                  topRight: Radius.circular(26),
                ),
              ),
              child: Row(
                children: [
                  const Icon(Icons.quiz, color: Colors.white, size: 28),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Review Your Answers',
                      style: GoogleFonts.montserrat(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '$correctCount/${reviewData.length}',
                      style: GoogleFonts.montserrat(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Review List
            Flexible(
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                shrinkWrap: true,
                itemCount: reviewData.length,
                itemBuilder: (context, index) {
                  final data = reviewData[index];
                  final isCorrect = data['isCorrect'] as bool;
                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: themeManager.isDarkMode
                          ? const Color(0xFF3C3C3E)
                          : Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isCorrect
                            ? const Color(0xFF22C55E)
                            : const Color(0xFFFF4B4A),
                        width: 2,
                      ),
                    ),
                    child: Row(
                      children: [
                        // Question image
                        Container(
                          width: 60,
                          height: 60,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: themeManager.primary.withOpacity(0.2),
                            ),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: Image.asset(
                              data['imagePath'],
                              fit: BoxFit.contain,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        // Answer info
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Q${data['questionNumber']}',
                                style: GoogleFonts.montserrat(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: themeManager.isDarkMode
                                      ? const Color(0xFF8E8E93)
                                      : Colors.grey.shade600,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                data['correctAnswer'],
                                style: GoogleFonts.montserrat(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w800,
                                  color: themeManager.textPrimary,
                                ),
                              ),
                              if (!isCorrect) ...[
                                const SizedBox(height: 4),
                                Text(
                                  'You: ${data['userAnswer']}',
                                  style: GoogleFonts.montserrat(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: const Color(0xFFFF4B4A),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                        // Status icon
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: isCorrect
                                ? const Color(0xFF22C55E)
                                : const Color(0xFFFF4B4A),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            isCorrect
                                ? Icons.check_rounded
                                : Icons.close_rounded,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            // Continue button
            Padding(
              padding: const EdgeInsets.all(20),
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: themeManager.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 0,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Continue',
                      style: GoogleFonts.montserrat(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Icon(Icons.arrow_forward_rounded, size: 20),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Mix & Match Review Dialog
class _MixMatchReviewDialog extends StatelessWidget {
  final List<Map<String, dynamic>> reviewData;
  final int correctCount;
  final int totalCount;

  const _MixMatchReviewDialog({
    required this.reviewData,
    required this.correctCount,
    required this.totalCount,
  });

  @override
  Widget build(BuildContext context) {
    final themeManager = ThemeManager.of(context, listen: false);

    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
      backgroundColor: Colors.transparent,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 500, maxHeight: 600),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: themeManager.isDarkMode
                ? const [Color(0xFF2C2C2E), Color(0xFF1C1C1E)]
                : const [Color(0xFFFFFFFF), Color(0xFFF0FDFA)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(28),
          border: Border.all(
            color: themeManager.primary.withOpacity(0.3),
            width: 2,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: themeManager.primaryGradient.colors,
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(26),
                  topRight: Radius.circular(26),
                ),
              ),
              child: Row(
                children: [
                  const Icon(Icons.swap_horiz, color: Colors.white, size: 28),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Match Results',
                      style: GoogleFonts.montserrat(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '$correctCount/$totalCount',
                      style: GoogleFonts.montserrat(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Review Grid
            Flexible(
              child: GridView.builder(
                padding: const EdgeInsets.all(16),
                shrinkWrap: true,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 1.0,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                ),
                itemCount: reviewData.length,
                itemBuilder: (context, index) {
                  final data = reviewData[index];
                  final isCorrect = data['isCorrect'] as bool;
                  return Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: themeManager.isDarkMode
                          ? const Color(0xFF3C3C3E)
                          : Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isCorrect
                            ? const Color(0xFF22C55E)
                            : const Color(0xFFFF4B4A),
                        width: 2,
                      ),
                    ),
                    child: Column(
                      children: [
                        // Image
                        Expanded(
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Image.asset(
                                data['imagePath'],
                                fit: BoxFit.contain,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        // Answer
                        Text(
                          data['correctAnswer'],
                          style: GoogleFonts.montserrat(
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                            color: isCorrect
                                ? const Color(0xFF22C55E)
                                : const Color(0xFFFF4B4A),
                          ),
                          textAlign: TextAlign.center,
                        ),
                        // Status icon
                        Icon(
                          isCorrect ? Icons.check_circle : Icons.cancel,
                          color: isCorrect
                              ? const Color(0xFF22C55E)
                              : const Color(0xFFFF4B4A),
                          size: 20,
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            // Continue button
            Padding(
              padding: const EdgeInsets.all(20),
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: themeManager.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 0,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Continue',
                      style: GoogleFonts.montserrat(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Icon(Icons.arrow_forward_rounded, size: 20),
                  ],
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
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: isPerfect
                        ? const [Color(0xFFFFD700), Color(0xFFFFA500)]
                        : const [Color(0xFF69D3E4), Color(0xFF4FC3E4)],
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
                    errorBuilder: (_, __, ___) => const Icon(
                      Icons.emoji_events,
                      size: 60,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              ShaderMask(
                shaderCallback: (bounds) => LinearGradient(
                  colors: isPerfect
                      ? const [Color(0xFFFFD700), Color(0xFFFFA500)]
                      : const [Color(0xFF69D3E4), Color(0xFF4FC3E4)],
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
                  color: const Color(0xFF4B5563),
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
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      backgroundColor: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
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
                color: const Color(0xFF1E1E1E),
                height: 1.3,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Great job! Now drag phrases to their matching signs.',
              textAlign: TextAlign.center,
              style: GoogleFonts.montserrat(
                fontSize: 15,
                color: const Color(0xFF6B7280),
                height: 1.5,
              ),
            ),
            const SizedBox(height: 28),
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
