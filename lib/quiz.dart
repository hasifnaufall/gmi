import 'package:flutter/material.dart';
// Removed unused imports

class QuizScreen extends StatefulWidget {
  const QuizScreen({super.key});

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  int? _selectedIndex;
  int? _correctIndex = 1;
  int? _wrongIndex;
  bool _answered = false;

  final List<String> _answers = [
    'Volleyball',
    'Football',
    'Basketball',
    'Badminton',
  ];

  void _onAnswerTap(int index) {
    if (_answered) return;
    setState(() {
      _selectedIndex = index;
      _answered = true;
      if (index == _correctIndex) {
        _wrongIndex = null;
      } else {
        _wrongIndex = index;
      }
    });
  }

  void _onNext() {
    // TODO: Implement next question logic
    setState(() {
      _answered = false;
      _selectedIndex = null;
      _wrongIndex = null;
      // _currentQuestion++;
      // _timer = 30;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFF4D4B),
      body: SafeArea(
        child: Stack(
          children: [
            // Decorative background shapes
            Positioned(
              top: -40,
              left: -40,
              child: Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: Color(0xFF285EAE).withOpacity(0.18),
                  shape: BoxShape.circle,
                ),
              ),
            ),
            Positioned(
              bottom: -30,
              right: -30,
              child: Container(
                width: 90,
                height: 90,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.13),
                  shape: BoxShape.circle,
                ),
              ),
            ),
            Column(
              children: [
                SizedBox(height: 24),
                // Speech bubble question
                Container(
                  margin: EdgeInsets.symmetric(horizontal: 24),
                  padding: EdgeInsets.symmetric(horizontal: 18, vertical: 22),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.white, Color(0xFFECF3FF)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.08),
                        blurRadius: 16,
                        offset: Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'When did Christopher Columbus discover America?',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF285EAE),
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(width: 8),
                      Icon(
                        Icons.question_mark_rounded,
                        color: Color(0xFF285EAE),
                        size: 28,
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 32),
                // Answer buttons
                ...List.generate(_answers.length, (i) {
                  String label = String.fromCharCode(65 + i); // A, B, C, D
                  bool isSelected = _selectedIndex == i;
                  bool isCorrect = _answered && i == _correctIndex;
                  bool isWrong = _answered && i == _wrongIndex;
                  Color buttonColor = Colors.white;
                  Color borderColor = Colors.white;
                  Color textColor = Color(0xFF285EAE);
                  if (isSelected) {
                    buttonColor = Color(0xFF285EAE).withOpacity(0.12);
                    borderColor = Color(0xFF285EAE);
                  }
                  if (isCorrect) {
                    buttonColor = Color(0xFF285EAE).withOpacity(0.18);
                    borderColor = Color(0xFF285EAE);
                    textColor = Color(0xFF285EAE);
                  }
                  if (isWrong) {
                    buttonColor = Color(0xFFFF4D4B).withOpacity(0.18);
                    borderColor = Color(0xFFFF4D4B);
                    textColor = Color(0xFFFF4D4B);
                  }
                  return Container(
                    margin: EdgeInsets.symmetric(horizontal: 32, vertical: 8),
                    child: Material(
                      color: buttonColor,
                      borderRadius: BorderRadius.circular(12),
                      elevation: 2,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(12),
                        onTap: _answered ? null : () => _onAnswerTap(i),
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 18,
                            vertical: 16,
                          ),
                          decoration: BoxDecoration(
                            border: Border.all(color: borderColor, width: 2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              Text(
                                '$label :',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  color: textColor,
                                ),
                              ),
                              SizedBox(width: 16),
                              Expanded(
                                child: Text(
                                  _answers[i],
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: textColor,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                              if (isCorrect)
                                Icon(
                                  Icons.check_circle,
                                  color: Color(0xFF285EAE),
                                  size: 22,
                                ),
                              if (isWrong)
                                Icon(
                                  Icons.cancel,
                                  color: Color(0xFFFF4D4B),
                                  size: 22,
                                ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                }),
                Spacer(),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 32, vertical: 18),
                  child: SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFF285EAE),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        elevation: 0,
                      ),
                      onPressed: _answered ? _onNext : null,
                      child: Text(
                        'Next',
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
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
    );
  }
}
