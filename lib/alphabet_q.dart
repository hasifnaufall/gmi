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
  late int currentQuestion;
  bool isOptionSelected = false;

  late AnimationController _controller;
  late Animation<Offset> _offsetAnimation;

  final List<Map<String, dynamic>> questions = [
    {"image": "assets/images/Q1.jpg", "options": ["M", "P", "E", "S"], "correctIndex": 2},
    {"image": "assets/images/Q2.jpg", "options": ["X", "N", "F", "D"], "correctIndex": 0},
    {"image": "assets/images/Q3.jpg", "options": ["K", "O", "R", "H"], "correctIndex": 3},
    {"image": "assets/images/Q4.jpg", "options": ["U", "Y", "N", "L"], "correctIndex": 0},
    {"image": "assets/images/Q5.jpg", "options": ["J", "L", "I", "O"], "correctIndex": 2},
  ];

  final List<Color> kahootColors = [
    Colors.redAccent,
    Colors.blueAccent,
    Colors.orangeAccent,
    Colors.greenAccent,
  ];

  int _firstUnansweredIndex() {
    for (int i = 0; i < questions.length; i++) {
      if (QuestStatus.level1Answers[i] == null) return i;
    }
    return questions.length - 1;
  }

  bool _allAnswered() => QuestStatus.level1Answers.every((e) => e != null);

  int? _nextUnansweredAfter(int from) {
    for (int i = from + 1; i < questions.length; i++) {
      if (QuestStatus.level1Answers[i] == null) return i;
    }
    return null;
  }

  @override
  void initState() {
    super.initState();
    QuestStatus.ensureLevel1Length(questions.length);

    int start = widget.startIndex ?? _firstUnansweredIndex();
    start = start.clamp(0, questions.length - 1);
    currentQuestion = start;

    _controller = AnimationController(duration: const Duration(milliseconds: 300), vsync: this);
    _offsetAnimation = Tween<Offset>(begin: const Offset(1.0, 0.0), end: Offset.zero)
        .animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
    _controller.forward();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (currentQuestion > 0 && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Resumed where you left off'), duration: Duration(seconds: 1)),
        );
      }
    });
  }

  Future<void> handleAnswer(int selectedIndex) async {
    if (isOptionSelected) return;
    if (QuestStatus.level1Answers[currentQuestion] != null) return;

    setState(() => isOptionSelected = true);

    final correctIndex = questions[currentQuestion]['correctIndex'] as int;
    final isCorrect = selectedIndex == correctIndex;
    QuestStatus.level1Answers[currentQuestion] = isCorrect;

    if (isCorrect) {
      final levels = QuestStatus.addXp(20);
      showAnimatedPopup(
        icon: Icons.star,
        iconColor: Colors.yellow.shade700,
        title: "Correct!",
        subtitle: "You earned 20 XP${levels > 0 ? " & leveled up!" : ""}",
        bgColor: Colors.green.shade600,
      );
    } else {
      final correctLetter = (questions[currentQuestion]['options'] as List<String>)[correctIndex];
      showAnimatedPopup(
        icon: Icons.close,
        iconColor: Colors.redAccent,
        title: "Incorrect",
        subtitle: "Correct: $correctLetter",
        bgColor: Colors.red.shade600,
      );
    }

    await Future.delayed(const Duration(milliseconds: 250));

    if (_allAnswered()) {
      if (!mounted) return;
      showAnimatedPopup(
        icon: Icons.emoji_events,
        iconColor: Colors.amber,
        title: "Quiz Complete!",
        subtitle: "Score: ${QuestStatus.level1Score}/${questions.length}",
        bgColor: Colors.blue.shade600,
      );
      await Future.delayed(const Duration(seconds: 2));
      if (!mounted) return;
      Navigator.pop(context);
    } else {
      final next = _nextUnansweredAfter(currentQuestion);
      setState(() {
        currentQuestion = (next ?? (currentQuestion + 1)).clamp(0, questions.length - 1);
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

  // ---------- Kahoot Button ----------
  Widget kahootButton(String label, Color color, int index) {
    final alreadyAnswered = QuestStatus.level1Answers[currentQuestion] != null;
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
    final question = questions[currentQuestion];
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
                Text("Question ${currentQuestion + 1} of ${questions.length}",
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
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

// ---------- Popup Widget ----------
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
