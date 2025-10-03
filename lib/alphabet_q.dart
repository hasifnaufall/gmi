import 'package:flutter/material.dart';
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

  final Map<int, bool> _sessionAnswers = {};

  late AnimationController _controller;
  late Animation<Offset> _offsetAnimation;

  final List<Map<String, dynamic>> questions = [
    {"image": "assets/images/alphabet/Q1.jpg",  "options": ["P", "A", "E", "S"], "correctIndex": 1},
    {"image": "assets/images/alphabet/Q2.jpg",  "options": ["W", "U", "F", "B"], "correctIndex": 3},
    {"image": "assets/images/alphabet/Q3.jpg",  "options": ["C", "Z", "R", "H"], "correctIndex": 0},
    {"image": "assets/images/alphabet/Q4.jpg",  "options": ["U", "Y", "D", "L"], "correctIndex": 2},
    {"image": "assets/images/alphabet/Q5.jpg",  "options": ["J", "E", "I", "O"], "correctIndex": 1},
    {"image": "assets/images/alphabet/Q6.jpg",  "options": ["M", "F", "E", "S"], "correctIndex": 1},
    {"image": "assets/images/alphabet/Q7.jpg",  "options": ["X", "N", "G", "D"], "correctIndex": 2},
    {"image": "assets/images/alphabet/Q8.jpg",  "options": ["H", "O", "R", "Q"], "correctIndex": 0},
    {"image": "assets/images/alphabet/Q9.jpg",  "options": ["U", "Y", "N", "I"], "correctIndex": 3},
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

  final List<Color> kahootColors = [
    Colors.redAccent,
    Colors.blueAccent,
    Colors.orangeAccent,
    Colors.greenAccent,
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

    // ✅✅ Mark Quest 3 (Start Alphabet QUIZ specifically) as soon as quiz opens
    if (!QuestStatus.alphabetQuizStarted) {
      QuestStatus.markAlphabetQuizStarted();
      if (QuestStatus.canClaimQuest3()) {
        QuestStatus.claimQuest3();
        // Show notification after build
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Quest 3 completed! Started Alphabet Quiz! +80 keys'),
                duration: Duration(seconds: 2),
                behavior: SnackBarBehavior.floating,
              ),
            );
          }
        });
      }
    }
    // ✅✅ END Quest 3 trigger

    final all = List<int>.generate(questions.length, (i) => i)..shuffle();
    activeIndices = all.take(sessionSize).toList();

    QuestStatus.ensureLevel1Length(activeIndices.length);
    QuestStatus.resetLevel1Answers();

    int startSlot = widget.startIndex ?? _firstUnansweredSlot();
    startSlot = startSlot.clamp(0, activeIndices.length - 1);
    currentSlot = startSlot;

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
    if (_sessionAnswers.containsKey(qIdx)) return;

    setState(() => isOptionSelected = true);

    final correctIndex = questions[qIdx]['correctIndex'] as int;
    final isCorrect = selectedIndex == correctIndex;

    _sessionAnswers[qIdx] = isCorrect;
    QuestStatus.level1Answers[currentSlot] = isCorrect;

    if (isCorrect) {
      final oldLvl = QuestStatus.level;
      final levels = QuestStatus.addXp(20);

      showAnimatedPopup(
        icon: Icons.star,
        iconColor: Colors.yellow.shade700,
        title: "Correct!",
        subtitle: "You earned 20 XP${levels > 0 ? " & leveled up!" : ""}",
        bgColor: Colors.green.shade600,
      );

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

      // ✅✅ Check Quest 4 (3 in a row)
      if (QuestStatus.level1BestStreak >= 3 && !QuestStatus.quest4Claimed) {
        if (QuestStatus.canClaimQuest4()) {
          QuestStatus.claimQuest4();
          showAnimatedPopup(
            icon: Icons.whatshot,
            iconColor: Colors.orange,
            title: "Quest 4 Complete!",
            subtitle: "3 correct in a row! +120 keys",
            bgColor: Colors.deepOrange.shade600,
          );
          await Future.delayed(const Duration(milliseconds: 800));
        }
      }
      // ✅✅ END Quest 4
    } else {
      final correctLetter = (questions[qIdx]['options'] as List<String>)[correctIndex];
      showAnimatedPopup(
        icon: Icons.close,
        iconColor: Colors.redAccent,
        title: "Incorrect",
        subtitle: "Correct: $correctLetter",
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

      // ✅✅ Update quest counters
      QuestStatus.alphabetRoundsCompleted += 1;

      // Check Quest 5 (3 rounds)
      if (QuestStatus.alphabetRoundsCompleted >= 3 && !QuestStatus.quest5Claimed) {
        if (QuestStatus.canClaimQuest5()) {
          QuestStatus.claimQuest5();
          await Future.delayed(const Duration(milliseconds: 500));
          showAnimatedPopup(
            icon: Icons.military_tech,
            iconColor: Colors.amber,
            title: "Quest 5 Complete!",
            subtitle: "3 rounds finished! +200 keys",
            bgColor: Colors.indigo.shade600,
          );
          await Future.delayed(const Duration(seconds: 2));
        }
      }

      // Check Quest 6 (perfect round)
      if (sessionScore == activeIndices.length && !QuestStatus.quest6Claimed) {
        if (QuestStatus.canClaimQuest6()) {
          QuestStatus.claimQuest6();
          await Future.delayed(const Duration(milliseconds: 500));
          showAnimatedPopup(
            icon: Icons.stars,
            iconColor: Colors.yellow,
            title: "Quest 6 Complete!",
            subtitle: "Perfect round! +250 keys",
            bgColor: Colors.green.shade700,
          );
          await Future.delayed(const Duration(seconds: 2));
        }
      }
      // ✅✅ END quest counters

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
    final options = question['options'] as List<String>;

    return Scaffold(
      appBar: AppBar(title: const Text("Alphabet Level"), backgroundColor: Colors.blue.shade700),
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
                Image.asset(question['image'], fit: BoxFit.contain, height: 180),
                const SizedBox(height: 20),
                Expanded(
                  child: GridView.count(
                    crossAxisCount: 2,
                    childAspectRatio: 1.3,
                    children: List.generate(options.length, (i) {
                      return kahootButton(options[i], kahootColors[i], i);
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
}

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