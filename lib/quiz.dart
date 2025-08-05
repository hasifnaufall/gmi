// quiz.dart
import 'package:flutter/material.dart';
import 'quiz_category.dart';  // make sure this import is present
import 'quest.dart';
import 'profile.dart';

class QuizScreen extends StatelessWidget {
  const QuizScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // ... other widgets ...
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back_ios),
                    onPressed: () {
                      // Navigate straight back to Home (category) page
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (_) => QuizCategoryScreen()),
                      );
                    },
                  ),
                  const Spacer(),
                ],
              ),
            ),
            // ... rest of the page ...
          ],
        ),
      ),
      // ... bottom nav bar ...
    );
  }
}
