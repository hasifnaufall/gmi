import 'package:flutter/material.dart';

class AlphabetQuizScreen extends StatefulWidget {
  const AlphabetQuizScreen({super.key});

  @override
  State<AlphabetQuizScreen> createState() => _AlphabetQuizScreenState();
}

class _AlphabetQuizScreenState extends State<AlphabetQuizScreen>
    with SingleTickerProviderStateMixin {
  int currentQuestion = 0;
  int selectedOption = -1;
  int score = 0;
  late AnimationController _controller;
  late Animation<Offset> _offsetAnimation;

  final List<Color> kahootColors = [
    Colors.red,
    Colors.blue,
    Colors.orange,
    Colors.green,
  ];

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
      "correctIndex": 0,
    },
    {
      "image": "assets/images/Q4.jpg",
      "options": ["A", "C", "B", "Z"],
      "correctIndex": 2,
    },
  ];

  @override
  void initState() {
    super.initState();
    _controller =
        AnimationController(duration: const Duration(milliseconds: 300), vsync: this);
    _offsetAnimation = Tween<Offset>(
      begin: const Offset(1.0, 0.0),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

    _controller.forward();
  }

  void submitAnswer() {
    final correctIndex = questions[currentQuestion]['correctIndex'];
    final isCorrect = selectedOption == correctIndex;

    // Increase score if correct
    if (isCorrect) score++;

    // Show feedback GIF
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        title: Text(isCorrect ? "Correct!" : "Wrong!"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(
              isCorrect
                  ? 'assets/gifs/correct.gif'
                  : 'assets/gifs/wrong.gif',
              height: 150,
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context); // close GIF dialog
                // move to next question or show final score
                if (currentQuestion < questions.length - 1) {
                  setState(() {
                    currentQuestion++;
                    selectedOption = -1;
                    _controller.reset();
                    _controller.forward();
                  });
                } else {
                  showDialog(
                    context: context,
                    barrierDismissible: false,
                    builder: (_) => AlertDialog(
                      title: const Text("Quiz Complete"),
                      content: Text("You’ve completed the Alphabet Level!\n\nScore: $score / ${questions.length}"),
                      actions: [
                        TextButton(
                          onPressed: () {
                            Navigator.pop(context);
                            Navigator.pop(context);
                          },
                          child: const Text("OK"),
                        ),
                      ],
                    ),
                  );
                }
              },
              child: const Text("Next"),
            ),
          ],
        ),
      ),
    );
  }


  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
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
      body: SingleChildScrollView(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            minHeight: MediaQuery.of(context).size.height -
                AppBar().preferredSize.height -
                MediaQuery.of(context).padding.top,
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: SlideTransition(
              position: _offsetAnimation,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    "Question ${currentQuestion + 1} of ${questions.length}",
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 20),
                  Image.asset(
                    question['image'],
                    height: 200,
                    fit: BoxFit.contain,
                  ),
                  const SizedBox(height: 30),
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: options.length,
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      childAspectRatio: 2,
                    ),
                    itemBuilder: (context, index) {
                      final isSelected = selectedOption == index;
                      final bgColor = isSelected
                          ? kahootColors[index].withOpacity(0.7)
                          : kahootColors[index];

                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            selectedOption = index;
                          });
                        },
                        child: Container(
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: bgColor,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: const [
                              BoxShadow(
                                color: Colors.black12,
                                blurRadius: 4,
                                offset: Offset(2, 2),
                              ),
                            ],
                          ),
                          child: Text(
                            options[index],
                            style: const TextStyle(
                              fontSize: 24,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 30),
                  ElevatedButton(
                    onPressed: selectedOption != -1 ? submitAnswer : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue.shade700,
                      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                    ),
                    child: const Text("SUBMIT", style: TextStyle(fontSize: 16)),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
