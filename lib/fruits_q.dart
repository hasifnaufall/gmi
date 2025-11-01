import 'package:flutter/material.dart';
import 'quest_status.dart';

class FruitsQuizScreen extends StatefulWidget {
  final int? startIndex;
  const FruitsQuizScreen({super.key, this.startIndex});

  @override
  State<FruitsQuizScreen> createState() => _FruitsQuizScreenState();
}

class _FruitsQuizScreenState extends State<FruitsQuizScreen>
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
    {"image": "assets/images/fruit/apple.jpg", "options": ["Banana", "Apple", "Orange", "Grape"], "correctIndex": 1},
    {"image": "assets/images/fruit/banana.jpg", "options": ["Banana", "Mango", "Pear", "Peach"], "correctIndex": 0},
    {"image": "assets/images/fruit/ciku.jpg", "options": ["Apple", "Ciku", "Watermelon", "Pineapple"], "correctIndex": 1},
    {"image": "assets/images/fruit/coconut.jpg", "options": ["Cherry", "Lemon", "Coconut", "Strawberry"], "correctIndex": 2},
    {"image": "assets/images/fruit/corn.jpg", "options": ["Mango", "Pear", "Corn", "Peach"], "correctIndex": 2},
    {"image": "assets/images/fruit/duku.jpg", "options": ["Orange", "Duku", "Grape", "Pear"], "correctIndex": 1},
    {"image": "assets/images/fruit/durian.jpg", "options": ["Apple", "Strawberry", "Durian", "Plum"], "correctIndex": 2},
    {"image": "assets/images/fruit/grape.jpg", "options": ["Grape", "Kiwi", "Watermelon", "Papaya"], "correctIndex": 0},
    {"image": "assets/images/fruit/langsat.jpg", "options": ["Langsat", "Banana", "Grape", "Orange"], "correctIndex": 0},
    {"image": "assets/images/fruit/lemon.jpg", "options": ["Pear", "Banana", "Peach", "Lemon"], "correctIndex": 3},
    {"image": "assets/images/fruit/mango.jpg", "options": ["Pineapple", "Watermelon", "Mango", "Apple"], "correctIndex": 2},
    {"image": "assets/images/fruit/mangosteen.jpg", "options": ["Lemon", "Mangosteen", "Strawberry", "Grape"], "correctIndex": 1},
    {"image": "assets/images/fruit/orange.jpg", "options": ["Peach", "Orange", "Banana", "Mango"], "correctIndex": 1},
    {"image": "assets/images/fruit/papaya.jpg", "options": ["Papaya", "Grape", "Orange", "Pineapple"], "correctIndex": 0},
    {"image": "assets/images/fruit/peanut.jpg", "options": ["Apple", "Plum", "Strawberry", "Peanut"], "correctIndex": 3},
    {"image": "assets/images/fruit/pear.jpg", "options": ["Kiwi", "Pear", "Papaya", "Watermelon"], "correctIndex": 1},
    {"image": "assets/images/fruit/pineapple.jpg", "options": ["Pineapple", "Orange", "Banana", "Apple"], "correctIndex": 0},
    {"image": "assets/images/fruit/pomelo.jpg", "options": ["Banana", "Peach", "Pear", "Pomelo"], "correctIndex": 3},
    {"image": "assets/images/fruit/rambutan.jpg", "options": ["Rambutan", "Apple", "Orange", "Watermelon"], "correctIndex": 0},
    {"image": "assets/images/fruit/sour-sop.jpg", "options": ["Banana", "Durian", "Soursop", "Watermelon"], "correctIndex": 2},
    {"image": "assets/images/fruit/starfruit.jpg", "options": ["Ciku", "Starfruit", "Pomelo", "Apple"], "correctIndex": 1},
    {"image": "assets/images/fruit/sugar cane.jpg", "options": ["Durian", "Sugar Cane", "Coconut", "Watermelon"], "correctIndex": 1},
    {"image": "assets/images/fruit/watermelon.jpg", "options": ["Corn", "Watermelon", "Mango", "Peanut"], "correctIndex": 1},
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
    final all = List<int>.generate(questions.length, (i) => i)..shuffle();
    activeIndices = all.take(sessionSize).toList();

    int startSlot = widget.startIndex ?? _firstUnansweredSlot();
    startSlot = startSlot.clamp(0, activeIndices.length - 1);
    currentSlot = startSlot;

    _controller = AnimationController(duration: const Duration(milliseconds: 500), vsync: this);
    _offsetAnimation = Tween<Offset>(begin: const Offset(0.0, 0.3), end: Offset.zero)
        .animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0)
        .animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
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
        message: "This action can't be undone and your progress this round will be lost.",
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
      _toast(icon: Icons.star, title: "Correct!", sub: "You earned 20 XP${levels > 0 ? " & leveled up!" : ""}", color: const Color(0xFF2C5CB0));

      if (levels > 0) {
        final newlyUnlocked = QuestStatus.unlockedBetween(oldLvl, QuestStatus.level);
        for (final key in newlyUnlocked) {
          _toast(icon: Icons.lock_open, title: "New Level Unlocked!", sub: QuestStatus.titleFor(key), color: const Color(0xFFFF4B4A));
          await Future.delayed(const Duration(milliseconds: 300));
        }
      }
    } else {
      final correct = (questions[qIdx]['options'] as List)[correctIndex].toString();
      _toast(icon: Icons.close, title: "Incorrect", sub: "Correct: $correct", color: const Color(0xFFFF4B4A));
    }

    await Future.delayed(const Duration(milliseconds: 250));

    if (_allAnsweredInSession()) {
      if (!mounted) return;
      final sessionScore = activeIndices.where((i) => _sessionAnswers[i] == true).length;
      _toast(icon: Icons.emoji_events, title: "Quiz Complete!", sub: "Score: $sessionScore/${activeIndices.length}", color: const Color(0xFF2C5CB0));

      final didIncrease = QuestStatus.addStreakForLevel();
      if (didIncrease && mounted) {
        _toast(icon: Icons.local_fire_department, title: "Streak +1!", sub: "Current streak: ${QuestStatus.streakDays}", color: const Color(0xFFFF4B4A));
        await Future.delayed(const Duration(seconds: 2));
      }

      if (!mounted) return;
      Navigator.pop(context);
    } else {
      final nextSlot = _nextUnansweredSlotAfter(currentSlot);
      setState(() {
        currentSlot = (nextSlot ?? (currentSlot + 1)).clamp(0, activeIndices.length - 1);
        isOptionSelected = false;
        _pendingIndex = null;
        _controller.reset();
        _controller.forward();
      });
    }
  }

  void _toast({required IconData icon, required Color color, required String title, required String sub}) {
    final overlay = Overlay.of(context);
    final entry = OverlayEntry(
      builder: (_) => Positioned(top: 60, right: 16, child: _SlideToast(bgColor: color, icon: icon, title: title, subtitle: sub)),
    );
    overlay.insert(entry);
    Future.delayed(const Duration(seconds: 2), () => entry.remove());
  }

  @override
  Widget build(BuildContext context) {
    final qIdx = activeIndices[currentSlot];
    final question = questions[qIdx];
    final options = (question['options'] as List).map((e) => e.toString()).toList();

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
            decoration: BoxDecoration(color: const Color(0xFFEFF3FF), borderRadius: BorderRadius.circular(12)),
            child: const Icon(Icons.arrow_back_ios_new_rounded, color: Color(0xFF2C5CB0), size: 20),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("Fruits Level", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF2C5CB0), letterSpacing: -0.5)),
              const SizedBox(height: 4),
              Text("Question ${currentSlot + 1} of ${activeIndices.length}", style: const TextStyle(fontSize: 14, color: Colors.black54)),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(color: const Color(0xFF2C5CB0), borderRadius: BorderRadius.circular(18)),
          child: Row(
            children: [
              const Icon(Icons.bolt_rounded, color: Colors.white, size: 16),
              const SizedBox(width: 4),
              Text("Lvl ${QuestStatus.level}", style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Colors.white)),
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

    Widget segment({required Color color, required int flex, required BorderRadius radius}) {
      if (flex <= 0) return const SizedBox.shrink();
      return Expanded(flex: flex, child: AnimatedContainer(duration: const Duration(milliseconds: 220), decoration: BoxDecoration(color: color, borderRadius: radius), height: 10));
    }

    final hasCorrect = correct > 0;
    final hasWrong = wrong > 0;
    final hasRemaining = remaining > 0;

    final bars = <Widget>[];
    if (hasCorrect) bars.add(segment(color: const Color(0xFF44b427), flex: correct, radius: hasWrong || hasRemaining ? const BorderRadius.horizontal(left: Radius.circular(8)) : BorderRadius.circular(8)));
    if (hasWrong) {
      if (bars.isNotEmpty) bars.add(const SizedBox(width: 1));
      bars.add(segment(color: const Color(0xFFFF4B4A), flex: wrong, radius: (!hasCorrect && !hasRemaining) ? BorderRadius.circular(8) : BorderRadius.zero));
    }
    if (hasRemaining) {
      if (bars.isNotEmpty) bars.add(const SizedBox(width: 1));
      bars.add(segment(color: const Color(0xFFE8EEF9), flex: remaining, radius: (hasCorrect || hasWrong) ? const BorderRadius.horizontal(right: Radius.circular(8)) : BorderRadius.circular(8)));
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 2),
          decoration: BoxDecoration(color: const Color(0xFFF2F6FF), borderRadius: BorderRadius.circular(10), border: Border.all(color: const Color(0xFFE3E6EE))),
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
      decoration: BoxDecoration(color: const Color(0xFFF9FBFF), borderRadius: BorderRadius.circular(24), border: Border.all(color: const Color(0xFFE3E6EE))),
      child: Column(
        children: [
          const Text("What fruit is shown?", textAlign: TextAlign.center, style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: Color(0xFF2C5CB0), letterSpacing: -0.3)),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), border: Border.all(color: const Color(0xFFE3E6EE))),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.asset(
                question['image'],
                fit: BoxFit.contain,
                height: 140,
                errorBuilder: (context, error, stack) {
                  return const SizedBox(
                    height: 140,
                    child: Center(child: Column(mainAxisSize: MainAxisSize.min, children: [Icon(Icons.broken_image_rounded, size: 36, color: Colors.grey), SizedBox(height: 8), Text('Image not found', style: TextStyle(color: Colors.grey))])),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOptionsGrid(List<String> options, int qIdx, Map<String, dynamic> question) {
    return Expanded(
      child: GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, childAspectRatio: 1.6, mainAxisSpacing: 16, crossAxisSpacing: 16),
        itemCount: options.length,
        itemBuilder: (context, index) {
          final alreadyAnswered = _sessionAnswers.containsKey(qIdx);
          final isCorrect = index == question['correctIndex'];
          final wasSelected = alreadyAnswered && _sessionAnswers[qIdx] == isCorrect && isCorrect;
          final isPending = !alreadyAnswered && _pendingIndex == index;

          return OptionCard(option: options[index], number: index + 1, isSelected: wasSelected, isPending: isPending, onTap: alreadyAnswered ? null : () => setState(() => _pendingIndex = index));
        },
      ),
    );
  }

  Widget _buildConfirmBar(List<String> options) {
    final idx = _pendingIndex!;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: const Color(0xFFF6F7FB), borderRadius: BorderRadius.circular(16), border: Border.all(color: const Color(0xFFE3E6EE))),
      child: Row(
        children: [
          const Icon(Icons.touch_app, size: 18, color: Color(0xFF2C5CB0)),
          const SizedBox(width: 8),
          Text('Selected: ${options[idx]}', style: const TextStyle(color: Color(0xFF2C5CB0), fontWeight: FontWeight.w600)),
          const Spacer(),
          TextButton(onPressed: () => setState(() => _pendingIndex = null), child: const Text('Cancel')),
          const SizedBox(width: 8),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF2C5CB0), foregroundColor: Colors.white, elevation: 0, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
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

  const OptionCard({super.key, required this.option, required this.number, this.isSelected = false, this.isPending = false, this.onTap});

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: isSelected ? const Color(0xFF2C5CB0) : (isPending ? const Color(0xFF311E76) : const Color(0xFFE3E6EE)), width: isSelected || isPending ? 2 : 1)),
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
                CircleAvatar(radius: 16, backgroundColor: const Color(0xFF2C5CB0), child: Text(number.toString(), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
                const SizedBox(width: 12),
                Expanded(child: Text(option, style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: isSelected ? Colors.black : const Color(0xFF2C5CB0)))),
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

class _SlideToast extends StatefulWidget {
  final Color bgColor;
  final IconData icon;
  final String title;
  final String subtitle;
  const _SlideToast({required this.bgColor, required this.icon, required this.title, required this.subtitle});

  @override
  State<_SlideToast> createState() => _SlideToastState();
}

class _SlideToastState extends State<_SlideToast> with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 260))..forward();
  late final Animation<Offset> _slide = Tween<Offset>(begin: const Offset(1.1, 0), end: Offset.zero).chain(CurveTween(curve: Curves.easeOut)).animate(_ctrl);

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: _slide,
      child: Material(
        elevation: 6,
        borderRadius: BorderRadius.circular(12),
        color: widget.bgColor,
        child: Container(
          width: 280,
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Icon(widget.icon, color: Colors.white, size: 28),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(widget.title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 16)),
                    const SizedBox(height: 2),
                    Text(widget.subtitle, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Colors.white70, fontSize: 13)),
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

  const _CleanConfirmDialog({required this.icon, required this.title, required this.message, required this.primaryLabel, required this.secondaryLabel});

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
            Container(width: 64, height: 64, decoration: const BoxDecoration(color: Color(0xFFF4F7FF), shape: BoxShape.circle), child: Icon(icon, size: 34, color: Color(0xFF2C5CB0))),
            const SizedBox(height: 16),
            Text(title, textAlign: TextAlign.center, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: Color(0xFF1E1E1E), letterSpacing: -0.2)),
            const SizedBox(height: 8),
            Text(message, textAlign: TextAlign.center, style: const TextStyle(fontSize: 14.5, color: Color(0xFF6B7280), height: 1.35)),
            const SizedBox(height: 18),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context, false),
                    style: OutlinedButton.styleFrom(side: const BorderSide(color: Color(0xFFE5E7EB)), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), padding: const EdgeInsets.symmetric(vertical: 12), foregroundColor: const Color(0xFF2C5CB0)),
                    child: Text(secondaryLabel, style: const TextStyle(fontWeight: FontWeight.w700)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context, true),
                    style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFFF4B4A), foregroundColor: Colors.white, elevation: 0, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), padding: const EdgeInsets.symmetric(vertical: 12)),
                    child: Text(primaryLabel, style: const TextStyle(fontWeight: FontWeight.w800)),
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