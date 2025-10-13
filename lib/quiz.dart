import 'package:flutter/material.dart';
import 'quiz_category.dart';  // make sure this import is present
import 'quest_status.dart';

class QuizScreen extends StatelessWidget {
  const QuizScreen({super.key});

  void _saveProgressAfterQuiz(BuildContext context) async {
    try {
      await QuestStatus.autoSaveProgress();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Progress auto-saved!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to save progress: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back_ios),
                    onPressed: () {
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
            // ... other widgets ...
            ElevatedButton(
              onPressed: () {
                // Call this when quiz is completed!
                _saveProgressAfterQuiz(context);
              },
              child: Text('Finish Quiz & Auto-Save Progress'),
            ),
            // ... rest of the page ...
          ],
        ),
      ),
      // ... bottom nav bar ...
    );
  }
}