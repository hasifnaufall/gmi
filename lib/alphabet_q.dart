import 'package:flutter/material.dart';
import 'quest_status.dart';
import 'xp_popups.dart'; // for XP + completion celebration

class AlphabetQuizScreen extends StatefulWidget {
  /// If null, auto-resume at the first unanswered question.
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

    // Record result for resume/score logic
    QuestStatus.level1Answers[currentQuestion] = isCorrect;

    // Optional: XP popup on correct
    if (isCorrect) {
      final levels = QuestStatus.addXp(20);
      await showXpCelebration(context, xp: 20, leveledUp: levels);
    }

    // Small pause for tactile feedback
    await Future.delayed(const Duration(milliseconds: 400));

    if (_allAnswered()) {
      if (!mounted) return;

      // Stylish completion popup (sparkles + gradient score)
      await showQuizCompleteCelebration(
        context,
        score: QuestStatus.level1Score,
        total: questions.length,
        subtitle: "You’ve completed the Alphabet Level!",
        buttonText: "OK",
      );

      if (!mounted) return;
      Navigator.pop(context); // back to previous screen
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

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

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
            boxShadow: const [
              BoxShadow(color: Colors.black26, blurRadius: 4, offset: Offset(2, 4)),
            ],
          ),
          child: Center(
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
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
