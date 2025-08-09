import 'package:flutter/material.dart';
import 'quest_status.dart'; // ✅ keeps track of completedQuestions & level1Completed

class AlphabetQuizScreen extends StatefulWidget {
  /// If null, we auto-resume from QuestStatus.completedQuestions
  final int? startIndex;

  const AlphabetQuizScreen({super.key, this.startIndex});

  @override
  State<AlphabetQuizScreen> createState() => _AlphabetQuizScreenState();
}

class _AlphabetQuizScreenState extends State<AlphabetQuizScreen>
    with SingleTickerProviderStateMixin {
  late int currentQuestion;
  int score = 0;
  bool isOptionSelected = false;

  late AnimationController _controller;
  late Animation<Offset> _offsetAnimation;

  final List<Map<String, dynamic>> questions = [
    {
      "image": "assets/images/Q1.jpg",
      "options": ["M", "P", "E", "S"],
      "correctIndex": 2,
    },
    {
      "image": "assets/images/Q2.jpg",
      "options": ["X", "N", "F", "D"],
      "correctIndex": 0,
    },
    {
      "image": "assets/images/Q3.jpg",
      "options": ["K", "O", "R", "H"],
      "correctIndex": 3,
    },
    {
      "image": "assets/images/Q4.jpg",
      "options": ["U", "Y", "N", "L"],
      "correctIndex": 0,
    },
    {
      "image": "assets/images/Q5.jpg",
      "options": ["J", "L", "I", "O"],
      "correctIndex": 2,
    },
  ];

  final List<Color> kahootColors = [
    Colors.redAccent,
    Colors.blueAccent,
    Colors.orangeAccent,
    Colors.greenAccent,
  ];

  @override
  void initState() {
    super.initState();

    // ✅ Decide where to start:
    // 1) Use explicit startIndex if provided
    // 2) Otherwise, auto-resume from QuestStatus.completedQuestions
    int start = widget.startIndex ?? QuestStatus.completedQuestions;

    // clamp to [0, lastQuestion]
    start = start.clamp(0, questions.length - 1);
    currentQuestion = start;

    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _offsetAnimation = Tween<Offset>(
      begin: const Offset(1.0, 0.0),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
    _controller.forward();

    // Small hint so you know it resumed
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (currentQuestion > 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Resumed at Question ${currentQuestion + 1}'),
            duration: const Duration(seconds: 1),
          ),
        );
      }
    });
  }

  void handleAnswer(int selectedIndex) async {
    if (isOptionSelected) return;

    setState(() {
      isOptionSelected = true;
    });

    final isCorrect =
        selectedIndex == questions[currentQuestion]['correctIndex'];
    if (isCorrect) score++;

    // ✅ Update quest progress (max = number of questions)
    QuestStatus.completedQuestions += 1;
    if (QuestStatus.completedQuestions > questions.length) {
      QuestStatus.completedQuestions = questions.length;
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.transparent,
      builder: (_) => Center(
        child: Image.asset(
          isCorrect ? 'assets/gifs/correct.gif' : 'assets/gifs/wrong.gif',
          height: 180,
        ),
      ),
    );

    await Future.delayed(const Duration(seconds: 2));
    if (mounted) Navigator.of(context).pop();

    if (currentQuestion < questions.length - 1) {
      setState(() {
        currentQuestion++;
        isOptionSelected = false;
        _controller.reset();
        _controller.forward();
      });
    } else {
      // ✅ Mark level as completed
      QuestStatus.level1Completed = true;

      if (!mounted) return;
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => AlertDialog(
          title: const Text("Quiz Complete"),
          content: Text(
            "You’ve completed the Alphabet Level!\n\nScore: $score / ${questions.length}",
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // close dialog
                Navigator.pop(context); // go back to previous screen
              },
              child: const Text("OK"),
            ),
          ],
        ),
      );
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Widget kahootButton(String label, Color color, int index) {
    return GestureDetector(
      onTap: () => handleAnswer(index),
      child: Container(
        padding: const EdgeInsets.all(16),
        margin: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(18),
          boxShadow: const [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 4,
              offset: Offset(2, 4),
            )
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
    );
  }

  @override
  Widget build(BuildContext context) {
    final question = questions[currentQuestion];
    final options = question['options'] as List<String>;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Alphabet Level"),
        backgroundColor: Colors.blue.shade700,
      ),
      body: Container(
        color: Colors.blue.shade100,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: SlideTransition(
            position: _offsetAnimation,
            child: Column(
              children: [
                Text(
                  "Question ${currentQuestion + 1} of ${questions.length}",
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 20),
                Image.asset(
                  question['image'],
                  fit: BoxFit.contain,
                  height: 180,
                ),
                const SizedBox(height: 20),
                Expanded(
                  child: GridView.count(
                    crossAxisCount: 2,
                    childAspectRatio: 1.3,
                    children: List.generate(options.length, (index) {
                      return kahootButton(
                        options[index],
                        kahootColors[index],
                        index,
                      );
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
