import 'package:flutter/material.dart';
import 'quest_status.dart';

class NumberQuizScreen extends StatefulWidget {
  /// startIndex = slot inside the 5-question session (0..4)
  final int? startIndex;

  const NumberQuizScreen({super.key, this.startIndex});

  @override
  State<NumberQuizScreen> createState() => _NumberQuizScreenState();
}

class _NumberQuizScreenState extends State<NumberQuizScreen>
    with SingleTickerProviderStateMixin {
  static const int sessionSize = 5; // 5 random questions per run

  // Session
  late List<int> activeIndices; // the 5 chosen indices from full pool
  late int currentSlot;         // 0..activeIndices.length-1
  bool isOptionSelected = false;

  // Per-playthrough answers (key=index in FULL pool)
  final Map<int, bool> _sessionAnswers = {};

  late AnimationController _controller;
  late Animation<Offset> _offsetAnimation;

  // ---------- MANUAL IMAGE QUESTIONS (edit here) ----------
  // Use any images and options you want. correctIndex is 0..3
  final List<Map<String, dynamic>> questions = [
    {"image": "assets/images/number/N1.jpg",  "options": ["11", "7", "1", "10"], "correctIndex": 2},
    {"image": "assets/images/number/N2.jpg",  "options": ["2", "5", "8", "3"], "correctIndex": 0},
    {"image": "assets/images/number/N3.jpg",  "options": ["9", "3", "6", "12"], "correctIndex": 1},
    {"image": "assets/images/number/N4.jpg",  "options": ["11", "14", "20", "4"], "correctIndex": 3},
    {"image": "assets/images/number/N5.jpg",  "options": ["6", "10", "5", "15"], "correctIndex": 2},
    {"image": "assets/images/number/N6.jpg",  "options": ["3", "18", "6", "19"], "correctIndex": 2},
    {"image": "assets/images/number/N7.jpg",  "options": ["14", "12", "10", "7"], "correctIndex": 3},
    {"image": "assets/images/number/N8.jpg",  "options": ["7", "12", "8", "20"], "correctIndex": 2},
    {"image": "assets/images/number/N9.jpg",  "options": ["9", "19", "18", "8"], "correctIndex": 0},
    {"image": "assets/images/number/N10.jpg", "options": ["6", "10", "15", "20"], "correctIndex": 1},
    {"image": "assets/images/number/N11.jpg", "options": ["10", "16", "1", "11"], "correctIndex": 3},
    {"image": "assets/images/number/N12.jpg", "options": ["14", "2", "12", "20"], "correctIndex": 2},
    {"image": "assets/images/number/N13.jpg", "options": ["18", "3", "13", "16"], "correctIndex": 2},
    {"image": "assets/images/number/N14.jpg", "options": ["4", "12", "7", "14"], "correctIndex": 3},
    {"image": "assets/images/number/N15.jpg", "options": ["5", "10", "15", "20"], "correctIndex": 2},
    {"image": "assets/images/number/N16.jpg", "options": ["16", "4", "7", "19"], "correctIndex": 0},
    {"image": "assets/images/number/N17.jpg", "options": ["11", "1", "17", "9"], "correctIndex": 2},
    {"image": "assets/images/number/N18.jpg", "options": ["8", "13", "6", "18"], "correctIndex": 3},
    {"image": "assets/images/number/N19.jpg", "options": ["16", "20", "19", "7"], "correctIndex": 2},
    {"image": "assets/images/number/N20.jpg", "options": ["15", "10", "20", "14"], "correctIndex": 2},
  ];

  // ---------- Session helpers ----------
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

    // 1) Pick a fresh random set of 5
    final all = List<int>.generate(questions.length, (i) => i)..shuffle();
    final take = all.length < sessionSize ? all.length : sessionSize;
    activeIndices = all.take(take).toList();

    // 2) Where to start in the 5
    int startSlot = widget.startIndex ?? _firstUnansweredSlot();
    startSlot = startSlot.clamp(0, activeIndices.length - 1);
    currentSlot = startSlot;

    // 3) Animations
    _controller = AnimationController(duration: const Duration(milliseconds: 300), vsync: this);
    _offsetAnimation = Tween<Offset>(begin: const Offset(1.0, 0.0), end: Offset.zero)
        .animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
    _controller.forward();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (currentSlot > 0 && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Resumed where you left off'), duration: Duration(seconds: 1)),
        );
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
    if (_sessionAnswers.containsKey(qIdx)) return; // answered in THIS session

    setState(() => isOptionSelected = true);

    final correctIndex = questions[qIdx]['correctIndex'] as int;
    final isCorrect = selectedIndex == correctIndex;

    // Save for this run
    _sessionAnswers[qIdx] = isCorrect;

    if (isCorrect) {
      final oldLvl = QuestStatus.level;
      final levels = QuestStatus.addXp(20); // award XP like alphabet

      // XP / Level-up feedback
      showAnimatedPopup(
        icon: Icons.star,
        iconColor: Colors.yellow.shade700,
        title: "Correct!",
        subtitle: "You earned 20 XP${levels > 0 ? " & leveled up!" : ""}",
        bgColor: Colors.green.shade600,
      );

      // Announce any new unlocks crossed by this level-up
      if (levels > 0) {
        final newlyUnlocked = QuestStatus.unlockedBetween(oldLvl, QuestStatus.level);
        for (final key in newlyUnlocked) {
          showAnimatedPopup(
            icon: Icons.lock_open,
            iconColor: Colors.lightGreenAccent,
            title: "New Level Unlocked!",
            subtitle: QuestStatus.titleFor(key),
            bgColor: Colors.teal.shade700,
          );
          await Future.delayed(const Duration(milliseconds: 300));
        }
      }
    } else {
      final correctValue = (questions[qIdx]['options'] as List<dynamic>)[correctIndex].toString();
      showAnimatedPopup(
        icon: Icons.close,
        iconColor: Colors.redAccent,
        title: "Incorrect",
        subtitle: "Correct: $correctValue",
        bgColor: Colors.red.shade600,
      );
    }

    await Future.delayed(const Duration(milliseconds: 250));

    if (_allAnsweredInSession()) {
      if (!mounted) return;

      final sessionScore = activeIndices.where((i) => _sessionAnswers[i] == true).length;

      showAnimatedPopup(
        icon: Icons.emoji_events,
        iconColor: Colors.amber,
        title: "Quiz Complete!",
        subtitle: "Score: $sessionScore/${activeIndices.length}",
        bgColor: Colors.blue.shade600,
      );

      // Optional: reuse generic first-quiz medal
      final justEarned = await QuestStatus.markFirstQuizMedalEarned();
      if (justEarned && mounted) {
        showAnimatedPopup(
          icon: Icons.military_tech,
          iconColor: Colors.amber,
          title: "Medal unlocked!",
          subtitle: "Finish your first quiz",
          bgColor: Colors.indigo.shade600,
        );
        await Future.delayed(const Duration(seconds: 2));
      }

      // Streak bump (once per 24h)
      final didIncrease = QuestStatus.addStreakForLevel();
      if (didIncrease && mounted) {
        showAnimatedPopup(
          icon: Icons.local_fire_department,
          iconColor: Colors.orange,
          title: "Streak +1!",
          subtitle: "Current streak: ${QuestStatus.streakDays} day${QuestStatus.streakDays == 1 ? '' : 's'}",
          bgColor: Colors.deepOrange.shade600,
        );
        await Future.delayed(const Duration(seconds: 2));
      }

      if (!mounted) return;
      Navigator.pop(context);
    } else {
      final nextSlot = _nextUnansweredSlotAfter(currentSlot);
      setState(() {
        currentSlot = (nextSlot ?? (currentSlot + 1)).clamp(0, activeIndices.length - 1);
        isOptionSelected = false;
        _controller.reset();
        _controller.forward();
      });
    }
  }

  // ---------- Custom Animated Popup ----------
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
        child: _NumberSlideInPopup(
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

  // ---------- Kahoot Button ----------
  Widget kahootButton(String label, Color color, int index) {
    final qIdx = activeIndices[currentSlot];
    final alreadyAnswered = _sessionAnswers.containsKey(qIdx);

    return GestureDetector(
      onTap: alreadyAnswered ? null : () => handleAnswer(index),
      child: Opacity(
        opacity: alreadyAnswered ? 0.6 : 1.0,
        child: Container(
          padding: const EdgeInsets.all(16),
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(18),
            boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 4, offset: Offset(2, 4))],
          ),
          child: Center(
            child: Text(
              label,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final qIdx = activeIndices[currentSlot];
    final question = questions[qIdx];
    final options = (question['options'] as List).map((e) => e.toString()).toList();

    return Scaffold(
      appBar: AppBar(title: const Text("Number Level"), backgroundColor: Colors.blue.shade700),
      body: Container(
        color: Colors.blue.shade100,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: SlideTransition(
            position: _offsetAnimation,
            child: Column(
              children: [
                Text(
                  "Question ${currentSlot + 1} of ${activeIndices.length}",
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 20),

                // Image prompt (same position as alphabet)
                Image.asset(question['image'], fit: BoxFit.contain, height: 180),

                const SizedBox(height: 20),
                Expanded(
                  child: GridView.count(
                    crossAxisCount: 2,
                    childAspectRatio: 1.3,
                    children: List.generate(options.length, (i) {
                      return kahootButton(options[i], _kahootColors[i], i);
                    }),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // local color list to avoid accidental external edits
  List<Color> get _kahootColors => const [
    Colors.redAccent,
    Colors.blueAccent,
    Colors.orangeAccent,
    Colors.greenAccent,
  ];
}

// ---------- Private Popup Widget (renamed to avoid clash) ----------
class _NumberSlideInPopup extends StatefulWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final Color bgColor;

  const _NumberSlideInPopup({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.bgColor,
  });

  @override
  State<_NumberSlideInPopup> createState() => _NumberSlideInPopupState();
}

class _NumberSlideInPopupState extends State<_NumberSlideInPopup>
    with SingleTickerProviderStateMixin {
  late AnimationController controller;
  late Animation<Offset> offsetAnimation;

  @override
  void initState() {
    super.initState();
    controller = AnimationController(duration: const Duration(milliseconds: 300), vsync: this);
    offsetAnimation = Tween<Offset>(begin: const Offset(1.2, 0), end: Offset.zero)
        .animate(CurvedAnimation(parent: controller, curve: Curves.easeOut));
    controller.forward();
  }

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
                    Text(widget.title,
                        style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                    Text(widget.subtitle,
                        style: const TextStyle(color: Colors.white70, fontSize: 14)),
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
