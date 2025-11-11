// lib/colour_q.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'quest_status.dart';
import 'services/sfx_service.dart';
import 'badges/badges_engine.dart';

enum QuizType { multipleChoice, mixMatch, both }

// Cute bottom sheet: Colour mode
Future<void> showColourQuizSelection(BuildContext context) {
  return showModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    builder: (_) => Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(topLeft: Radius.circular(28), topRight: Radius.circular(28)),
      ),
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(2))),
        const SizedBox(height: 20),
        Row(children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: [Color(0xFF69D3E4), Color(0xFF4FC3E4)]),
              borderRadius: BorderRadius.circular(14),
              boxShadow: [BoxShadow(color: const Color(0xFF69D3E4).withOpacity(0.3), blurRadius: 8, offset: const Offset(0, 2))],
            ),
            child: const Icon(Icons.palette_rounded, color: Colors.white, size: 24),
          ),
          const SizedBox(width: 12),
          Expanded(child: Text('Select Quiz Mode', style: GoogleFonts.montserrat(fontSize: 20, fontWeight: FontWeight.w800, color: const Color(0xFF1E1E1E)))),
        ]),
        const SizedBox(height: 20),
        _CompactQuizCard(
          icon: Icons.quiz_rounded,
          title: 'Multiple Choice',
          description: '5 questions',
          gradient: const [Color(0xFF69D3E4), Color(0xFF4FC3E4)],
          onTap: () {
            Navigator.pop(context);
            Navigator.push(context, MaterialPageRoute(builder: (_) => const ColourQuizScreen(quizType: QuizType.multipleChoice)));
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
            Navigator.push(context, MaterialPageRoute(builder: (_) => const ColourQuizScreen(quizType: QuizType.mixMatch)));
          },
        ),
        const SizedBox(height: 12),
        _CompactQuizCard(
          icon: Icons.stars_rounded,
          title: 'Both Modes',
          description: '5 MC + 6 Mix&Match',
          gradient: const [Color(0xFFFFD700), Color(0xFFFFA500)],
          onTap: () {
            Navigator.pop(context);
            Navigator.push(context, MaterialPageRoute(builder: (_) => const ColourQuizScreen(quizType: QuizType.both)));
          },
        ),
      ]),
    ),
  );
}

class _CompactQuizCard extends StatelessWidget {
  final IconData icon; final String title; final String description;
  final List<Color> gradient; final VoidCallback onTap;
  const _CompactQuizCard({required this.icon, required this.title, required this.description, required this.gradient, required this.onTap});
  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap, borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: [Colors.grey.shade50, Colors.grey.shade100]),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: gradient[0].withOpacity(0.3), width: 2),
          ),
          child: Row(children: [
            Container(
              width: 56, height: 56,
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: gradient),
                borderRadius: BorderRadius.circular(14),
                boxShadow: [BoxShadow(color: gradient[0].withOpacity(0.3), blurRadius: 8, offset: const Offset(0, 2))],
              ),
              child: Icon(icon, color: Colors.white, size: 28),
            ),
            const SizedBox(width: 14),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(title, style: GoogleFonts.montserrat(fontSize: 16, fontWeight: FontWeight.w800, color: const Color(0xFF1E1E1E))),
              const SizedBox(height: 2),
              Text(description, style: GoogleFonts.montserrat(fontSize: 12, color: const Color(0xFF6B7280), fontWeight: FontWeight.w600)),
            ])),
            Container(padding: const EdgeInsets.all(6), decoration: BoxDecoration(color: gradient[0].withOpacity(0.15), shape: BoxShape.circle), child: Icon(Icons.arrow_forward_rounded, color: gradient[0], size: 18)),
          ]),
        ),
      ),
    );
  }
}

class ColourQuizScreen extends StatefulWidget {
  final int? startIndex; final QuizType quizType;
  const ColourQuizScreen({super.key, this.startIndex, this.quizType = QuizType.both});
  @override State<ColourQuizScreen> createState() => _ColourQuizScreenState();
}

class _ColourQuizScreenState extends State<ColourQuizScreen> with SingleTickerProviderStateMixin {
  static const int multipleChoiceSize = 5;
  static const int mixMatchSize = 6;

  static const double mmRowGap = 10;
  static const double mmImageHeight = 95;
  static const double mmLetterHeight = 70;

  late List<int> activeIndices; late int currentSlot; bool isOptionSelected = false; int? _pendingIndex;
  final Map<int, bool> _sessionAnswers = {};

  late List<int> mixMatchIndices; bool _isInMixMatchRound = false;
  final Map<String, String> _currentMatches = {};
  List<String> _mmNamesOrder = []; // colour names
  List<String> _mmImagesOrder = []; // images
  Map<String, String> _imageForName = {}; // name -> image
  final ScrollController _mmScroll = ScrollController();

  bool _mmReviewMode = false;
  final Set<String> _mmCorrectRightIds = {};
  final Set<String> _mmWrongRightIds = {};

  late AnimationController _controller; late Animation<Offset> _offsetAnimation; late Animation<double> _fadeAnimation;

  // ===== Replace with your real assets =====
  final List<Map<String, dynamic>> questions = [
    {"image": "assets/images/colour/C1.jpg",  "name": "Blue"},
    {"image": "assets/images/colour/C2.jpg",  "name": "Green"},
    {"image": "assets/images/colour/C3.jpg",  "name": "Black"},
    {"image": "assets/images/colour/C4.jpg",  "name": "Orange"},
    {"image": "assets/images/colour/C5.jpg",  "name": "Grey"},
    {"image": "assets/images/colour/C6.jpg",  "name": "Yellow"},
    {"image": "assets/images/colour/C7.jpg",  "name": "Red"},
    {"image": "assets/images/colour/C8.jpg",  "name": "Pink"},
    {"image": "assets/images/colour/C9.jpg",  "name": "Brown"},
    {"image": "assets/images/colour/C10.jpg", "name": "White"},
    {"image": "assets/images/colour/C11.jpg", "name": "Purple"},
  ];

  final Map<int, List<String>> _questionOptions = {};
  final Map<int, int> _questionCorrectIndex = {};

  bool _isAnsweredInSession(int qIdx) => _sessionAnswers.containsKey(qIdx);
  bool _allAnsweredInSession() { for (final i in activeIndices) { if (!_sessionAnswers.containsKey(i)) return false; } return true; }
  int? _nextUnansweredSlotAfter(int fromSlot) { for (int s = fromSlot + 1; s < activeIndices.length; s++) { if (!_isAnsweredInSession(activeIndices[s])) return s; } return null; }

  List<String> _generateOptions(int qIdx) {
    if (_questionOptions.containsKey(qIdx)) return _questionOptions[qIdx]!;
    final correct = questions[qIdx]['name'] as String;
    final pool = questions.map((e) => e['name'] as String).toList()..remove(correct)..shuffle();
    final wrong = pool.take(3).toList();
    final options = [...wrong, correct]..shuffle();
    _questionOptions[qIdx] = options;
    _questionCorrectIndex[qIdx] = options.indexOf(correct);
    return options;
  }

  @override
  void initState() {
    super.initState();
    Sfx().init();

    final all = List<int>.generate(questions.length, (i) => i)..shuffle();
    if (widget.quizType == QuizType.multipleChoice) {
      activeIndices = all.take(multipleChoiceSize).toList(); mixMatchIndices = [];
    } else if (widget.quizType == QuizType.mixMatch) {
      activeIndices = []; mixMatchIndices = all.take(mixMatchSize).toList();
    } else {
      activeIndices = all.take(multipleChoiceSize).toList();
      final remaining = all.skip(multipleChoiceSize).toList()..shuffle();
      mixMatchIndices = remaining.take(mixMatchSize).toList();
    }
    for (final idx in activeIndices) { _generateOptions(idx); }

    final totalQuestions = activeIndices.length + (mixMatchIndices.isEmpty ? 0 : 1);
    QuestStatus.ensureLevel1Length(totalQuestions);
    QuestStatus.resetLevel1Answers();

    int startSlot = widget.startIndex ?? 0;
    currentSlot = activeIndices.isNotEmpty ? startSlot.clamp(0, activeIndices.length - 1) : 0;

    _isInMixMatchRound = widget.quizType == QuizType.mixMatch;
    if (_isInMixMatchRound) _prepareMixMatchRound();

    _controller = AnimationController(duration: const Duration(milliseconds: 500), vsync: this);
    _offsetAnimation = Tween<Offset>(begin: const Offset(0.0, 0.3), end: Offset.zero)
        .animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0)
        .animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
    _controller.forward();
  }

  @override
  void dispose() { _controller.dispose(); _mmScroll.dispose(); super.dispose(); }

  void _prepareMixMatchRound() {
    _imageForName.clear();
    for (final idx in mixMatchIndices) {
      final name = questions[idx]['name'] as String;
      final image = questions[idx]['image'] as String;
      _imageForName[name] = image;
    }
    final names = mixMatchIndices.map((i) => questions[i]['name'] as String).toList();
    final images = mixMatchIndices.map((i) => questions[i]['image'] as String).toList();
    _mmNamesOrder = List<String>.from(names)..shuffle();
    _mmImagesOrder = List<String>.from(images)..shuffle();
  }

  Future<void> handleAnswer(int selectedIndex) async {
    if (isOptionSelected) return;
    final qIdx = activeIndices[currentSlot];
    if (_sessionAnswers.containsKey(qIdx)) return;

    setState(() { isOptionSelected = true; _pendingIndex = null; });
    final correctIndex = _questionCorrectIndex[qIdx]!;
    final isCorrect = selectedIndex == correctIndex;

    _sessionAnswers[qIdx] = isCorrect;
    QuestStatus.level1Answers[currentSlot] = isCorrect;

    if (isCorrect) {
      showAnimatedPopup(icon: Icons.star, title: "Correct!", subtitle: "You earned 20 XP", bgColor: const Color(0xFF2C5CB0));
      QuestStatus.addXp(20);
    } else {
      final correctName = _questionOptions[qIdx]![correctIndex];
      showAnimatedPopup(icon: Icons.close, title: "Incorrect", subtitle: "Correct: $correctName", bgColor: const Color(0xFFFF4B4A));
    }

    await Future.delayed(const Duration(milliseconds: 250));

    if (_allAnsweredInSession()) {
      if (!mounted) return;
      if (widget.quizType == QuizType.both && mixMatchIndices.isNotEmpty) {
        await Future.delayed(const Duration(milliseconds: 500));
        await showDialog(context: context, barrierDismissible: false, builder: (_) => const _BonusRoundDialog());
        setState(() { _prepareMixMatchRound(); _isInMixMatchRound = true; currentSlot = 0; _controller.reset(); _controller.forward(); });
      } else {
        await Future.delayed(const Duration(milliseconds: 500));
        _finishSession();
      }
      return;
    }

    final nextSlot = _nextUnansweredSlotAfter(currentSlot);
    setState(() {
      currentSlot = (nextSlot ?? (currentSlot + 1)).clamp(0, activeIndices.length - 1);
      isOptionSelected = false; _pendingIndex = null; _controller.reset(); _controller.forward();
    });
  }

  void _undoMatch(String rightId) { setState(() { _currentMatches.removeWhere((k, v) => v == rightId); }); }

  void _onAllPairsFilled() async {
    final submit = await showDialog<bool>(
      context: context, barrierDismissible: false,
      builder: (_) => const _CleanConfirmDialog(
        icon: Icons.check_circle_rounded, title: 'Submit answers?',
        message: "You've matched all pairs. Submit now or reset all to try again.",
        primaryLabel: 'Submit', secondaryLabel: 'Reset',
      ),
    );
    if (submit == true) { _evaluateMixMatchAndReview(); } else { setState(() => _currentMatches.clear()); }
  }

  void _evaluateMixMatchAndReview() {
    _mmCorrectRightIds.clear(); _mmWrongRightIds.clear();
    bool allCorrect = true;
    for (final idx in mixMatchIndices) {
      final name = questions[idx]['name'] as String;
      final leftId = "left_$name";
      final rightId = "right_$name";
      if (_currentMatches[leftId] == rightId) {
        _mmCorrectRightIds.add(rightId);
      } else { allCorrect = false; _mmWrongRightIds.add(rightId); }
    }
    final mmResultIndex = activeIndices.isEmpty ? 0 : activeIndices.length;
    QuestStatus.level1Answers[mmResultIndex] = allCorrect;

    setState(() => _mmReviewMode = true);

    // 2-second review (required)
    Future.delayed(const Duration(seconds: 2), () {
      if (!mounted) return;
      setState(() => _mmReviewMode = false);
      _completeMixMatch(allCorrect);
    });
  }

  void _completeMixMatch(bool allCorrect) {
    if (allCorrect) { showAnimatedPopup(icon: Icons.star, title: "Perfect Match!", subtitle: "You earned 50 XP", bgColor: const Color(0xFF2C5CB0)); QuestStatus.addXp(50); }
    else { showAnimatedPopup(icon: Icons.close, title: "Some Incorrect", subtitle: "Try again next time!", bgColor: const Color(0xFFFF4B4A)); }
    Future.delayed(const Duration(milliseconds: 500), () => _finishSession());
  }

  Future<void> _finishSession() async {
    if (!mounted) return;

    int sessionScore = 0;

    // Count MC correct answers
    for (final i in activeIndices) {
      if (_sessionAnswers[i] == true) sessionScore++;
    }

    // Mix & Match contributes 1 point if all pairs were correct
    final mmResultIndex = activeIndices.isEmpty ? 0 : activeIndices.length;
    if (QuestStatus.level1Answers.length > mmResultIndex &&
        QuestStatus.level1Answers[mmResultIndex] == true) {
      sessionScore++;
    }

    final totalQuestions = activeIndices.length + (mixMatchIndices.isEmpty ? 0 : 1);
    final perfect = sessionScore == totalQuestions;

    // ========== BADGES (ADDED) ==========
    await BadgeEngine.recordRun(
      category: 'colour',                // <-- this screen/category
      mode: widget.quizType.name,        // 'multipleChoice' | 'mixMatch' | 'both'
      total: totalQuestions,
      score: sessionScore,
      perfect: perfect,
    );
    await BadgeEngine.checkAndToast(context);
    // ======== END BADGES (ADDED) ========

    // Your existing quest logic
    QuestStatus.alphabetRoundsCompleted += 1;
    if (QuestStatus.alphabetRoundsCompleted >= 3 && !QuestStatus.quest5Claimed) {
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


  Future<bool> _confirmExitQuiz() async {
    final first = await showDialog<bool>(
      context: context, barrierDismissible: false,
      builder: (_) => const _CleanConfirmDialog(
        icon: Icons.logout_rounded, title: 'Leave quiz?',
        message: "Your current progress will be lost.",
        primaryLabel: 'Continue', secondaryLabel: 'Cancel',
      ),
    );
    if (first != true) return false;
    final second = await showDialog<bool>(
      context: context, barrierDismissible: false,
      builder: (_) => const _CleanConfirmDialog(
        icon: Icons.warning_amber_rounded, title: 'Are you sure?',
        message: "This action can't be undone and your progress this round will be lost.",
        primaryLabel: 'Leave', secondaryLabel: 'Stay',
      ),
    );
    return second == true;
  }

  void _handleBackPressed() async { final shouldExit = await _confirmExitQuiz(); if (shouldExit && mounted) Navigator.pop(context); }

  void showAnimatedPopup({required IconData icon, required String title, required String subtitle, required Color bgColor}) {
    final overlay = Overlay.of(context);
    final entry = OverlayEntry(builder: (_) => Positioned(top: 60, right: 16, child: _SlideInBadge(icon: icon, title: title, subtitle: subtitle, color: bgColor)));
    overlay.insert(entry);
    Future.delayed(const Duration(seconds: 2), () => entry.remove());
  }

  @override
  Widget build(BuildContext context) { return _isInMixMatchRound ? _buildMixMatchQuiz() : _buildMultipleChoiceQuiz(); }

  Widget _buildMultipleChoiceQuiz() {
    final qIdx = activeIndices[currentSlot];
    final question = questions[qIdx];
    final options = _questionOptions[qIdx]!;

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
                child: Column(children: [
                  _buildHeader("Colour Quiz"),
                  const SizedBox(height: 12),
                  _buildProgressBar(),
                  const SizedBox(height: 16),
                  _buildQuestionCard(question),
                  const SizedBox(height: 32),
                  _buildOptionsGrid(options, qIdx),
                  const SizedBox(height: 12),
                  if (_pendingIndex != null) _buildConfirmBar(options),
                ]),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMixMatchQuiz() {
    if (_mmNamesOrder.isEmpty || _mmImagesOrder.isEmpty) _prepareMixMatchRound();
    final totalPairs = mixMatchIndices.length;

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
                padding: const EdgeInsets.all(16.0),
                child: Column(children: [
                  _buildHeader("Mix & Match"),
                  const SizedBox(height: 8),
                  _buildStableMixMatchProgress(totalPairs),
                  const SizedBox(height: 12),
                  _buildMixMatchInstruction(),
                  const SizedBox(height: 16),
                  Expanded(
                    child: Scrollbar(
                      controller: _mmScroll, thumbVisibility: true,
                      child: SingleChildScrollView(
                        controller: _mmScroll,
                        physics: const AlwaysScrollableScrollPhysics(),
                        child: _buildMatchingAreaStable(namesOrder: _mmNamesOrder, imagesOrder: _mmImagesOrder),
                      ),
                    ),
                  ),
                ]),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(String title) {
    return Row(children: [
      IconButton(
        onPressed: _handleBackPressed,
        icon: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            gradient: const LinearGradient(colors: [Color(0xFFFFFFFF), Color(0xFFF0FDFA)]),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFF69D3E4).withOpacity(0.3)),
            boxShadow: [BoxShadow(color: const Color(0xFF69D3E4).withOpacity(0.15), blurRadius: 8, offset: const Offset(0, 2))],
          ),
          child: const Icon(Icons.arrow_back_ios_new_rounded, color: Color(0xFF69D3E4), size: 20),
        ),
      ),
      const SizedBox(width: 12),
      Expanded(child: Text(title, style: GoogleFonts.montserrat(fontSize: 24, fontWeight: FontWeight.w800, color: const Color(0xFF69D3E4)))),
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          gradient: const LinearGradient(colors: [Color(0xFF69D3E4), Color(0xFF4FC3E4)]),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [BoxShadow(color: const Color(0xFF69D3E4).withOpacity(0.3), blurRadius: 8, offset: const Offset(0, 2))],
        ),
        child: Row(children: [
          const Icon(Icons.bolt_rounded, color: Colors.white, size: 16),
          const SizedBox(width: 4),
          Text("Lvl ${QuestStatus.level}", style: GoogleFonts.montserrat(fontSize: 13, fontWeight: FontWeight.w800, color: Colors.white)),
        ]),
      ),
    ]);
  }

  Widget _buildProgressBar() {
    final total = activeIndices.length; int correct = 0, wrong = 0;
    for (final i in activeIndices) {
      if (_sessionAnswers.containsKey(i)) { if (_sessionAnswers[i] == true) correct++; if (_sessionAnswers[i] == false) wrong++; }
    }
    final remaining = (total - correct - wrong).clamp(0, total);
    Widget segment({required Color color, required int flex, required BorderRadius radius}) {
      if (flex <= 0) return const SizedBox.shrink();
      return Expanded(flex: flex, child: AnimatedContainer(duration: const Duration(milliseconds: 220), decoration: BoxDecoration(color: color, borderRadius: radius), height: 12));
    }
    final hasCorrect = correct > 0, hasWrong = wrong > 0, hasRemaining = remaining > 0;
    final bars = <Widget>[];
    if (hasCorrect) bars.add(segment(color: const Color(0xFF22C55E), flex: correct, radius: hasWrong || hasRemaining ? const BorderRadius.horizontal(left: Radius.circular(10)) : BorderRadius.circular(10)));
    if (hasWrong) { if (bars.isNotEmpty) bars.add(const SizedBox(width: 2)); bars.add(segment(color: const Color(0xFFFF4B4A), flex: wrong, radius: (!hasCorrect && !hasRemaining) ? BorderRadius.circular(10) : BorderRadius.zero)); }
    if (hasRemaining) { if (bars.isNotEmpty) bars.add(const SizedBox(width: 2)); bars.add(segment(color: const Color(0xFFE0F2F1), flex: remaining, radius: (hasCorrect || hasWrong) ? const BorderRadius.horizontal(right: Radius.circular(10)) : BorderRadius.circular(10))); }

    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      Container(
        padding: const EdgeInsets.all(3),
        decoration: BoxDecoration(
          gradient: const LinearGradient(colors: [Colors.white, Color(0xFFF0FDFA)]),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFF69D3E4).withOpacity(0.3)),
          boxShadow: [BoxShadow(color: const Color(0xFF69D3E4).withOpacity(0.1), blurRadius: 8, offset: const Offset(0, 2))],
        ),
        child: Row(children: bars),
      ),
      const SizedBox(height: 8),
      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: const [
        _LegendDot(label: 'Correct', color: Color(0xFF22C55E)),
        _LegendDot(label: 'Wrong', color: Color(0xFFFF4B4A)),
      ]),
    ]);
  }

  Widget _buildMixMatchInstruction() {
    return Container(
      width: double.infinity, padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [Color(0xFFFFFFFF), Color(0xFFF0FDFA)]),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF69D3E4).withOpacity(0.3), width: 2),
        boxShadow: [BoxShadow(color: const Color(0xFF69D3E4).withOpacity(0.15), blurRadius: 12, offset: const Offset(0, 4))],
      ),
      child: Row(children: [
        Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(gradient: const LinearGradient(colors: [Color(0xFF69D3E4), Color(0xFF4FC3E4)]), borderRadius: BorderRadius.circular(12)), child: const Icon(Icons.swap_horiz_rounded, color: Colors.white, size: 20)),
        const SizedBox(width: 10),
        Expanded(child: Text("Drag names to their matching colours", style: GoogleFonts.montserrat(fontSize: 14, fontWeight: FontWeight.w700, color: const Color(0xFF69D3E4)))),
      ]),
    );
  }

  Widget _buildMatchingAreaStable({required List<String> namesOrder, required List<String> imagesOrder}) {
    assert(namesOrder.length == imagesOrder.length);
    return Column(
      children: List.generate(namesOrder.length, (i) {
        final name = namesOrder[i];
        final leftId = "left_$name";
        final isLeftMatched = _currentMatches.containsKey(leftId);

        final imagePath = imagesOrder[i];
        final rightName = _imageForName.entries.firstWhere((e) => e.value == imagePath).key;
        final rightId = "right_$rightName";
        final isRightMatched = _currentMatches.values.contains(rightId);

        final showCorrect = _mmReviewMode && _mmCorrectRightIds.contains(rightId);
        final showWrong = _mmReviewMode && _mmWrongRightIds.contains(rightId);

        return Padding(
          key: ValueKey('ROW_$i'),
          padding: const EdgeInsets.only(bottom: mmRowGap),
          child: SizedBox(
            height: mmImageHeight,
            child: Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
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
                          feedback: Material(elevation: 8, borderRadius: BorderRadius.circular(16), child: _LetterCard(letter: name, isFloating: true)),
                          childWhenDragging: Opacity(opacity: 0.3, child: _LetterCard(letter: name)),
                          child: _LetterCard(letter: name, isMatched: isLeftMatched),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                flex: 4,
                child: Stack(children: [
                  DragTarget<String>(
                    onWillAccept: (data) => !_mmReviewMode && data != null && !isRightMatched,
                    onAccept: (draggedLeftId) {
                      setState(() { _currentMatches[draggedLeftId] = rightId; });
                      if (_currentMatches.length >= mixMatchIndices.length) _onAllPairsFilled();
                    },
                    builder: (context, candidate, rejected) {
                      final isHovering = !_mmReviewMode && candidate.isNotEmpty && !isRightMatched;
                      return SizedBox(
                        height: mmImageHeight,
                        child: _ImageCard(
                          imagePath: imagePath,
                          isMatched: isRightMatched,
                          isHovering: isHovering,
                          reviewCorrect: showCorrect,
                          reviewWrong: showWrong,
                        ),
                      );
                    },
                  ),
                  if (isRightMatched && !_mmReviewMode)
                    Positioned(
                      top: 4, right: 4,
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () => _undoMatch(rightId),
                          borderRadius: BorderRadius.circular(20),
                          child: Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.9), shape: BoxShape.circle,
                              border: Border.all(color: const Color(0xFFFF4B4A), width: 2),
                              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 4, offset: const Offset(0, 2))],
                            ),
                            child: const Icon(Icons.close_rounded, size: 16, color: Color(0xFFFF4B4A)),
                          ),
                        ),
                      ),
                    ),
                ]),
              ),
            ]),
          ),
        );
      }),
    );
  }

  Widget _buildQuestionCard(Map<String, dynamic> question) {
    return Container(
      width: double.infinity, padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [Color(0xFFFFFFFF), Color(0xFFF0FDFA)]),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFF69D3E4).withOpacity(0.3), width: 2),
        boxShadow: [BoxShadow(color: const Color(0xFF69D3E4).withOpacity(0.15), blurRadius: 12, offset: const Offset(0, 4))],
      ),
      child: Column(children: [
        Text("What colour is shown?", textAlign: TextAlign.center, style: GoogleFonts.montserrat(fontSize: 18, fontWeight: FontWeight.w800, color: const Color(0xFF69D3E4))),
        const SizedBox(height: 20),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), border: Border.all(color: const Color(0xFF69D3E4).withOpacity(0.2))),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.asset(
              question['image'], fit: BoxFit.contain, height: 140,
              errorBuilder: (c, e, s) => const SizedBox(height: 140, child: Center(child: Icon(Icons.broken_image_rounded, size: 36, color: Colors.grey))),
            ),
          ),
        ),
      ]),
    );
  }

  Widget _buildOptionsGrid(List<String> options, int qIdx) {
    return Expanded(
      child: GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, childAspectRatio: 1.6, mainAxisSpacing: 16, crossAxisSpacing: 16),
        itemCount: options.length,
        itemBuilder: (context, index) {
          final alreadyAnswered = _sessionAnswers.containsKey(qIdx);
          final correctIndex = _questionCorrectIndex[qIdx]!;
          final isCorrect = index == correctIndex;
          final wasSelected = alreadyAnswered && _sessionAnswers[qIdx] == isCorrect && isCorrect;
          final isPending = !alreadyAnswered && _pendingIndex == index;

          return _OptionCard(
            option: options[index],
            number: index + 1,
            isSelected: wasSelected,
            isPending: isPending,
            onTap: alreadyAnswered ? null : () => setState(() => _pendingIndex = index),
          );
        },
      ),
    );
  }

  Widget _buildConfirmBar(List<String> options) {
    final idx = _pendingIndex!;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [Color(0xFFFFFFFF), Color(0xFFF0FDFA)]),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF69D3E4), width: 2),
        boxShadow: [BoxShadow(color: const Color(0xFF69D3E4).withOpacity(0.2), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Row(children: [
        Container(padding: const EdgeInsets.all(6), decoration: BoxDecoration(gradient: const LinearGradient(colors: [Color(0xFF69D3E4), Color(0xFF4FC3E4)]), borderRadius: BorderRadius.circular(8)), child: const Icon(Icons.touch_app, size: 18, color: Colors.white)),
        const SizedBox(width: 10),
        Expanded(child: Text('Selected: ${options[idx]}', style: GoogleFonts.montserrat(color: const Color(0xFF69D3E4), fontWeight: FontWeight.w700, fontSize: 15), overflow: TextOverflow.ellipsis)),
        const SizedBox(width: 8),
        TextButton(onPressed: () => setState(() => _pendingIndex = null), child: Text('Cancel', style: GoogleFonts.montserrat(color: Colors.grey.shade600))),
        const SizedBox(width: 8),
        ElevatedButton(
          style: ElevatedButton.styleFrom(backgroundColor: Colors.transparent, foregroundColor: Colors.white, elevation: 0, padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)))
              .copyWith(backgroundColor: MaterialStateProperty.all(Colors.transparent)),
          onPressed: () { final i = _pendingIndex; if (i != null) handleAnswer(i); },
          child: Ink(
            decoration: BoxDecoration(gradient: const LinearGradient(colors: [Color(0xFF69D3E4), Color(0xFF4FC3E4)]), borderRadius: BorderRadius.circular(12)),
            child: Container(padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12), child: Text('Confirm', style: GoogleFonts.montserrat(fontWeight: FontWeight.w700))),
          ),
        ),
      ]),
    );
  }

  Widget _buildStableMixMatchProgress(int total) {
    final matched = _currentMatches.length;
    final value = total == 0 ? 0.0 : matched / total;
    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      SizedBox(
        height: 10,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: LinearProgressIndicator(
            value: value, backgroundColor: const Color(0xFFE0F2F1),
            valueColor: const AlwaysStoppedAnimation(Color(0xFF69D3E4)), minHeight: 10,
          ),
        ),
      ),
      const SizedBox(height: 8),
      Text("$matched / $total matched", textAlign: TextAlign.center, style: GoogleFonts.montserrat(fontSize: 13, color: Colors.black54, fontWeight: FontWeight.w600)),
    ]);
  }
}

// ---------- Small widgets ----------
class _OptionCard extends StatelessWidget {
  final String option; final int number; final bool isSelected; final bool isPending; final VoidCallback? onTap;
  const _OptionCard({required this.option, required this.number, this.isSelected = false, this.isPending = false, this.onTap});
  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      decoration: BoxDecoration(
        gradient: isSelected || isPending ? const LinearGradient(colors: [Color(0xFFFFFFFF), Color(0xFFF0FDFA)]) : const LinearGradient(colors: [Color(0xFFFFFFFF), Color(0xFFFAFAFA)]),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isSelected ? const Color(0xFF69D3E4) : (isPending ? const Color(0xFF4FC3E4) : const Color(0xFFE3E6EE)), width: isSelected || isPending ? 2.5 : 1.5),
        boxShadow: [if (isSelected || isPending) BoxShadow(color: const Color(0xFF69D3E4).withOpacity(0.25), blurRadius: 12, offset: const Offset(0, 4))],
      ),
      child: Material(
        color: Colors.transparent, borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: onTap, borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(children: [
              Container(width: 32, height: 32, decoration: const BoxDecoration(gradient: LinearGradient(colors: [Color(0xFF69D3E4), Color(0xFF4FC3E4)]), shape: BoxShape.circle),
                  child: Center(child: Text(number.toString(), style: GoogleFonts.montserrat(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 15)))),
              const SizedBox(width: 12),
              Expanded(child: Text(option, style: GoogleFonts.montserrat(fontSize: 20, fontWeight: FontWeight.w800, color: isSelected || isPending ? const Color(0xFF69D3E4) : const Color(0xFF2D5263)))),
              if (isSelected) const Icon(Icons.check_circle, color: Color(0xFF69D3E4)),
            ]),
          ),
        ),
      ),
    );
  }
}

class _LegendDot extends StatelessWidget {
  final String label; final Color color; const _LegendDot({required this.label, required this.color});
  @override Widget build(BuildContext context) {
    return Row(children: [
      Container(width: 12, height: 12, decoration: BoxDecoration(color: color, shape: BoxShape.circle, boxShadow: [BoxShadow(color: color.withOpacity(0.3), blurRadius: 4, offset: const Offset(0, 1))])),
      const SizedBox(width: 6),
      Text(label, style: GoogleFonts.montserrat(fontSize: 12, color: Colors.black54, fontWeight: FontWeight.w700)),
    ]);
  }
}

class _LetterCard extends StatelessWidget {
  final String letter; final bool isMatched; final bool isDragging; final bool isFloating;
  const _LetterCard({required this.letter, this.isMatched = false, this.isDragging = false, this.isFloating = false});
  @override
  Widget build(BuildContext context) {
    return Container(
      width: isFloating ? 120 : double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: isMatched ? [const Color(0xFF22C55E), const Color(0xFF16A34A)] : [const Color(0xFFFFFFFF), const Color(0xFFF0FDFA)]),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isMatched ? const Color(0xFF22C55E) : const Color(0xFF69D3E4).withOpacity(0.3), width: 2),
        boxShadow: [BoxShadow(color: (isMatched ? const Color(0xFF22C55E) : const Color(0xFF69D3E4)).withOpacity(0.2), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Center(child: Text(letter, textAlign: TextAlign.center, style: GoogleFonts.montserrat(fontSize: 22, fontWeight: FontWeight.w900, color: isMatched ? Colors.white : const Color(0xFF69D3E4)))),
    );
  }
}

class _ImageCard extends StatelessWidget {
  final String imagePath; final bool isMatched; final bool isHovering; final bool reviewCorrect; final bool reviewWrong;
  const _ImageCard({required this.imagePath, this.isMatched = false, this.isHovering = false, this.reviewCorrect = false, this.reviewWrong = false});
  @override
  Widget build(BuildContext context) {
    List<Color> colors;
    if (reviewCorrect) colors = const [Color(0xFF22C55E), Color(0xFF16A34A)];
    else if (reviewWrong) colors = const [Color(0xFFFF6B6A), Color(0xFFFF4B4A)];
    else if (isHovering) colors = const [Color(0xFF4FC3E4), Color(0xFF69D3E4)];
    else if (isMatched) colors = const [Color(0xFF22C55E), Color(0xFF16A34A)];
    else colors = const [Color(0xFFFFFFFF), Color(0xFFF0FDFA)];

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: colors),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF1B3C73), width: 1.0),
        boxShadow: [BoxShadow(color: (reviewWrong ? const Color(0xFFFF4B4A) : reviewCorrect ? const Color(0xFF22C55E) : const Color(0xFF69D3E4)).withOpacity(isHovering ? 0.3 : 0.15), blurRadius: isHovering ? 12 : 8, offset: const Offset(0, 2))],
      ),
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Stack(children: [
          Positioned.fill(child: ClipRRect(borderRadius: BorderRadius.circular(12), child: Image.asset(imagePath, fit: BoxFit.contain, errorBuilder: (c, e, s) => const Center(child: Icon(Icons.broken_image_rounded, size: 32, color: Colors.grey))))),
          if (reviewCorrect || reviewWrong)
            Positioned(right: 8, top: 8, child: Container(padding: const EdgeInsets.all(4), decoration: BoxDecoration(color: Colors.white.withOpacity(0.85), shape: BoxShape.circle), child: Icon(reviewCorrect ? Icons.check_rounded : Icons.close_rounded, size: 18, color: reviewCorrect ? const Color(0xFF16A34A) : const Color(0xFFD90416)))),
        ]),
      ),
    );
  }
}

class _SlideInBadge extends StatefulWidget {
  final IconData icon; final String title; final String subtitle; final Color color;
  const _SlideInBadge({required this.icon, required this.title, required this.subtitle, required this.color});
  @override State<_SlideInBadge> createState() => _SlideInBadgeState();
}
class _SlideInBadgeState extends State<_SlideInBadge> with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(vsync: this, duration: const Duration(milliseconds: 280))..forward();
  late final Animation<Offset> _a = Tween<Offset>(begin: const Offset(1.1, 0), end: Offset.zero).animate(CurvedAnimation(parent: _c, curve: Curves.easeOut));
  @override void dispose() { _c.dispose(); super.dispose(); }
  @override Widget build(BuildContext context) {
    return SlideTransition(
      position: _a,
      child: Material(
        elevation: 8, borderRadius: BorderRadius.circular(16), color: Colors.transparent,
        child: Container(
          width: 300, padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: widget.color == const Color(0xFF2C5CB0) ? const [Color(0xFF69D3E4), Color(0xFF4FC3E4)] : [widget.color, widget.color.withOpacity(0.8)]),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [BoxShadow(color: widget.color == const Color(0xFF2C5CB0) ? const Color(0xFF69D3E4).withOpacity(0.4) : widget.color.withOpacity(0.4), blurRadius: 12, offset: const Offset(0, 4))],
          ),
          child: Row(children: [
            Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), shape: BoxShape.circle), child: Icon(widget.icon, color: Colors.white, size: 24)),
            const SizedBox(width: 12),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(widget.title, style: GoogleFonts.montserrat(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 16)),
              Text(widget.subtitle, style: GoogleFonts.montserrat(color: Colors.white.withOpacity(0.9), fontSize: 13)),
            ])),
          ]),
        ),
      ),
    );
  }
}

class _CleanConfirmDialog extends StatelessWidget {
  final IconData icon; final String title; final String message; final String primaryLabel; final String secondaryLabel;
  const _CleanConfirmDialog({required this.icon, required this.title, required this.message, required this.primaryLabel, required this.secondaryLabel});
  @override Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      backgroundColor: Colors.transparent,
      child: Container(
        decoration: BoxDecoration(
          gradient: const LinearGradient(colors: [Color(0xFFFAFAFA), Color(0xFFF0FDFA)]),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: const Color(0xFF69D3E4).withOpacity(0.3), width: 1.5),
          boxShadow: [BoxShadow(color: const Color(0xFF69D3E4).withOpacity(0.2), blurRadius: 20, offset: const Offset(0, 8))],
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 28, 20, 20),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Container(
              width: 110, height: 110,
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: icon == Icons.warning_amber_rounded ? const [Color(0xFFFF4B4A), Color(0xFFFF6B6A)] : const [Color(0xFF69D3E4), Color(0xFF4FC3E4)]),
                shape: BoxShape.circle,
                boxShadow: [BoxShadow(color: (icon == Icons.warning_amber_rounded ? const Color(0xFFFF4B4A) : const Color(0xFF69D3E4)).withOpacity(0.3), blurRadius: 12, offset: const Offset(0, 4))],
              ),
              child: Icon(icon, size: 56, color: Colors.white),
            ),
            const SizedBox(height: 20),
            Text(title, textAlign: TextAlign.center, style: GoogleFonts.montserrat(fontSize: 22, fontWeight: FontWeight.w800, color: const Color(0xFF1E1E1E))),
            const SizedBox(height: 10),
            Text(message, textAlign: TextAlign.center, style: GoogleFonts.montserrat(fontSize: 15, color: const Color(0xFF6B7280), height: 1.4)),
            const SizedBox(height: 22),
            Row(children: [
              Expanded(child: Container(
                decoration: BoxDecoration(gradient: const LinearGradient(colors: [Color(0xFFFAFAFA), Color(0xFFFFFFFF)]), borderRadius: BorderRadius.circular(14), border: Border.all(color: const Color(0xFF69D3E4).withOpacity(0.5), width: 2)),
                child: Material(color: Colors.transparent, child: InkWell(
                  onTap: () => Navigator.pop(context, false), borderRadius: BorderRadius.circular(14),
                  child: Container(padding: const EdgeInsets.symmetric(vertical: 14), alignment: Alignment.center, child: Text('Reset', style: GoogleFonts.montserrat(fontWeight: FontWeight.w700, fontSize: 15, color: const Color(0xFF69D3E4)))),
                )),
              )),
              const SizedBox(width: 12),
              Expanded(child: Container(
                decoration: BoxDecoration(gradient: const LinearGradient(colors: [Color(0xFF69D3E4), Color(0xFF4FC3E4)]), borderRadius: BorderRadius.circular(14), boxShadow: [BoxShadow(color: const Color(0xFF69D3E4).withOpacity(0.3), blurRadius: 8, offset: const Offset(0, 3))]),
                child: Material(color: Colors.transparent, child: InkWell(
                  onTap: () => Navigator.pop(context, true), borderRadius: BorderRadius.circular(14),
                  child: Container(padding: const EdgeInsets.symmetric(vertical: 14), alignment: Alignment.center, child: Text('Submit', style: GoogleFonts.montserrat(fontWeight: FontWeight.w800, fontSize: 15, color: Colors.white))),
                )),
              )),
            ]),
          ]),
        ),
      ),
    );
  }
}

class _GreatWorkDialog extends StatelessWidget {
  final int score; final int total; final VoidCallback onReturn;
  const _GreatWorkDialog({required this.score, required this.total, required this.onReturn});
  bool get isPerfect => score == total;
  @override Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
      backgroundColor: Colors.transparent,
      child: Container(
        decoration: BoxDecoration(
          gradient: const LinearGradient(colors: [Color(0xFFFAFAFA), Color(0xFFF0FDFA)]),
          borderRadius: BorderRadius.circular(28),
          border: Border.all(color: const Color(0xFF69D3E4).withOpacity(0.3), width: 1.5),
          boxShadow: [BoxShadow(color: const Color(0xFF69D3E4).withOpacity(0.25), blurRadius: 24, offset: const Offset(0, 10))],
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 36, 24, 28),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Container(
              width: 120, height: 120,
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: isPerfect ? const [Color(0xFFFFD700), Color(0xFFFFA500)] : const [Color(0xFF69D3E4), Color(0xFF4FC3E4)]),
                shape: BoxShape.circle,
                boxShadow: [BoxShadow(color: (isPerfect ? const Color(0xFFFFD700) : const Color(0xFF69D3E4)).withOpacity(0.4), blurRadius: 16, offset: const Offset(0, 6))],
              ),
              child: ClipOval(child: Image.asset('assets/gifs/trophy_quiz.gif', fit: BoxFit.cover)),
            ),
            const SizedBox(height: 24),
            ShaderMask(shaderCallback: (b) => LinearGradient(colors: isPerfect ? const [Color(0xFFFFD700), Color(0xFFFFA500)] : const [Color(0xFF69D3E4), Color(0xFF4FC3E4)]).createShader(b),
                child: Text(isPerfect ? "Perfection!" : "Great Work!", textAlign: TextAlign.center, style: GoogleFonts.montserrat(fontSize: 34, fontWeight: FontWeight.w900, color: Colors.white))),
            const SizedBox(height: 12),
            Text(isPerfect ? "You answered every question flawlessly." : "You completed this quiz successfully!", textAlign: TextAlign.center, style: GoogleFonts.montserrat(fontSize: 16, color: const Color(0xFF4B5563))),
            const SizedBox(height: 26),
            Container(
              padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 28),
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: [Color(0xFFFFFFFF), Color(0xFFF0FDFA)]),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: const Color(0xFF69D3E4).withOpacity(0.3), width: 1.5),
                boxShadow: [BoxShadow(color: const Color(0xFF69D3E4).withOpacity(0.15), blurRadius: 12, offset: const Offset(0, 4))],
              ),
              child: Center(child: ShaderMask(shaderCallback: (b) => const LinearGradient(colors: [Color(0xFF69D3E4), Color(0xFF4FC3E4)]).createShader(b), child: Text("$score / $total", style: GoogleFonts.montserrat(fontSize: 40, fontWeight: FontWeight.w900, color: Colors.white)))),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: Container(
                decoration: BoxDecoration(gradient: const LinearGradient(colors: [Color(0xFF69D3E4), Color(0xFF4FC3E4)]), borderRadius: BorderRadius.circular(16), boxShadow: [BoxShadow(color: const Color(0xFF69D3E4).withOpacity(0.4), blurRadius: 12, offset: const Offset(0, 4))]),
                child: Material(color: Colors.transparent, child: InkWell(
                  onTap: onReturn, borderRadius: BorderRadius.circular(16),
                  child: Container(padding: const EdgeInsets.symmetric(vertical: 16), child: Row(mainAxisAlignment: MainAxisAlignment.center, children: const [
                    Icon(Icons.arrow_back_rounded, size: 24, color: Colors.white), SizedBox(width: 8),
                    Text('Return', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: Colors.white, fontFamily: 'Montserrat')),
                  ])),
                )),
              ),
            ),
          ]),
        ),
      ),
    );
  }
}

class _BonusRoundDialog extends StatelessWidget {
  const _BonusRoundDialog();
  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)), backgroundColor: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Container(
            width: 80, height: 80,
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: [Color(0xFF69D3E4), Color(0xFF4FC3E4)]), shape: BoxShape.circle,
              boxShadow: [BoxShadow(color: const Color(0xFF69D3E4).withOpacity(0.3), blurRadius: 12, offset: const Offset(0, 4))],
            ),
            child: const Icon(Icons.bolt_rounded, color: Colors.white, size: 40),
          ),
          const SizedBox(height: 24),
          Text('Bonus Round:\nMix & Match!', textAlign: TextAlign.center, style: GoogleFonts.montserrat(fontSize: 24, fontWeight: FontWeight.w900, color: const Color(0xFF1E1E1E))),
          const SizedBox(height: 12),
          Text('Great job! Now drag names to their matching colours.', textAlign: TextAlign.center, style: GoogleFonts.montserrat(fontSize: 15, color: const Color(0xFF6B7280))),
          const SizedBox(height: 28),
          SizedBox(
            width: double.infinity,
            child: Container(
              decoration: BoxDecoration(gradient: const LinearGradient(colors: [Color(0xFF69D3E4), Color(0xFF4FC3E4)]), borderRadius: BorderRadius.circular(16), boxShadow: [BoxShadow(color: const Color(0xFF69D3E4).withOpacity(0.4), blurRadius: 12, offset: const Offset(0, 4))]),
              child: Material(color: Colors.transparent, child: InkWell(
                onTap: () => Navigator.pop(context), borderRadius: BorderRadius.circular(16),
                child: Container(padding: const EdgeInsets.symmetric(vertical: 16), alignment: Alignment.center, child: Text('Let\'s Go!', style: GoogleFonts.montserrat(fontSize: 17, fontWeight: FontWeight.w800, color: Colors.white))),
              )),
            ),
          ),
        ]),
      ),
    );
  }
}