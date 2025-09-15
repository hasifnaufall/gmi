import 'package:flutter/material.dart';
import 'quest_status.dart';

class ColourQuizScreen extends StatefulWidget {
  const ColourQuizScreen({super.key});

  @override
  State<ColourQuizScreen> createState() => _ColourQuizScreenState();
}

class _ColourQuizScreenState extends State<ColourQuizScreen>
    with SingleTickerProviderStateMixin {
  static const int sessionSize = 5;

  late List<int> activeIndices;
  late int currentSlot;
  bool isOptionSelected = false;

  final Map<int, bool> _sessionAnswers = {};

  late AnimationController _controller;
  late Animation<Offset> _offsetAnimation;

  // Full pool of colour questions (⬅️ you can expand with your own images/options)
  final List<Map<String, dynamic>> questions = [
    {
      "image": "assets/images/red.jpg",
      "options": ["Red", "Blue", "Green", "Yellow"],
      "correctIndex": 0,
    },
    {
      "image": "assets/images/blue.jpg",
      "options": ["Red", "Blue", "Green", "Yellow"],
      "correctIndex": 1,
    },
    {
      "image": "assets/images/green.jpg",
      "options": ["Black", "Purple", "Green", "Pink"],
      "correctIndex": 2,
    },
    {
      "image": "assets/images/yellow.jpg",
      "options": ["Yellow", "Orange", "White", "Brown"],
      "correctIndex": 0,
    },
    {
      "image": "assets/images/black.jpg",
      "options": ["Black", "Grey", "White", "Blue"],
      "correctIndex": 0,
    },
    {
      "image": "assets/images/pink.jpg",
      "options": ["Pink", "Purple", "Orange", "Red"],
      "correctIndex": 0,
    },
  ];

  final List<Color> optionColors = [
    Colors.redAccent,
    Colors.blueAccent,
    Colors.orangeAccent,
    Colors.greenAccent,
  ];

  bool _allAnsweredInSession() {
    for (final i in activeIndices) {
      if (!_sessionAnswers.containsKey(i)) return false;
    }
    return true;
  }

  @override
  void initState() {
    super.initState();

    final all = List<int>.generate(questions.length, (i) => i)..shuffle();
    activeIndices = all.take(sessionSize).toList();

    currentSlot = 0;

    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _offsetAnimation = Tween<Offset>(
      begin: const Offset(1.0, 0.0),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
    _controller.forward();
  }

  Future<void> handleAnswer(int selectedIndex) async {
    if (isOptionSelected) return;

    final qIdx = activeIndices[currentSlot];
    if (_sessionAnswers.containsKey(qIdx)) return;

    setState(() => isOptionSelected = true);

    final correctIndex = questions[qIdx]['correctIndex'] as int;
    final isCorrect = selectedIndex == correctIndex;

    _sessionAnswers[qIdx] = isCorrect;

    if (isCorrect) {
      QuestStatus.addXp(20);
      showPopup("Correct!", "You earned 20 XP", Colors.green);
    } else {
      final correctAnswer =
      (questions[qIdx]['options'] as List<String>)[correctIndex];
      showPopup("Incorrect", "Correct: $correctAnswer", Colors.red);
    }

    await Future.delayed(const Duration(milliseconds: 250));

    if (_allAnsweredInSession()) {
      showPopup("Quiz Complete!", "Good job!", Colors.blue);

      QuestStatus.colourRoundsCompleted += 1;
      QuestStatus.addStreakForLevel();


      if (!mounted) return;
      Navigator.pop(context);
    } else {
      setState(() {
        currentSlot = (currentSlot + 1).clamp(0, activeIndices.length - 1);
        isOptionSelected = false;
        _controller.reset();
        _controller.forward();
      });
    }
  }

  void showPopup(String title, String subtitle, Color color) {
    final overlay = Overlay.of(context);
    final entry = OverlayEntry(
      builder: (_) => Positioned(
        top: 70,
        right: 16,
        child: Material(
          color: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.all(12),
            width: 240,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold)),
                Text(subtitle,
                    style: const TextStyle(color: Colors.white70, fontSize: 14)),
              ],
            ),
          ),
        ),
      ),
    );
    overlay.insert(entry);
    Future.delayed(const Duration(seconds: 2), () => entry.remove());
  }

  @override
  Widget build(BuildContext context) {
    final qIdx = activeIndices[currentSlot];
    final question = questions[qIdx];
    final options = question['options'] as List<String>;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Colour Level"),
        backgroundColor: Colors.deepPurple,
      ),
      body: Container(
        color: Colors.purple.shade50,
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
                Image.asset(question['image'], fit: BoxFit.contain, height: 160),
                const SizedBox(height: 20),
                Expanded(
                  child: GridView.count(
                    crossAxisCount: 2,
                    childAspectRatio: 1.3,
                    children: List.generate(options.length, (i) {
                      return GestureDetector(
                        onTap: () => handleAnswer(i),
                        child: Container(
                          margin: const EdgeInsets.all(8),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: optionColors[i],
                            borderRadius: BorderRadius.circular(18),
                          ),
                          child: Center(
                            child: Text(
                              options[i],
                              style: const TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white),
                            ),
                          ),
                        ),
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
