// quests.dart
import 'package:flutter/material.dart';
// Import other screens for navigation
import 'quiz_category.dart';
import 'profile.dart';

class QuestScreen extends StatelessWidget {  // Must match exactly
  const QuestScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Quests'),
        backgroundColor: Colors.blue,
      ),
      body: Stack(
        children: [
          Column(
            children: [
              Container(
                padding: const EdgeInsets.all(16.0),
                color: Colors.grey[200],
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.monetization_on, color: Colors.yellow),
                        const SizedBox(width: 8.0),
                        const Text('200', style: TextStyle(fontSize: 18)),
                      ],
                    ),
                    Row(
                      children: [
                        Icon(Icons.local_fire_department, color: Colors.red),
                        const SizedBox(width: 8.0),
                        const Text('0', style: TextStyle(fontSize: 18)),
                      ],
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    const Text(
                      'COMPLETE QUEST TO UNLOCK CHEST!!',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 16.0),
                    Icon(Icons.lock_outline, size: 100, color: Colors.brown),
                    const SizedBox(height: 16.0),
                    LinearProgressIndicator(
                      value: 15 / 30,
                      backgroundColor: Colors.grey,
                      color: Colors.blue,
                      minHeight: 10,
                    ),
                    const SizedBox(height: 8.0),
                    const Text('15/30'),
                  ],
                ),
              ),
              Expanded(
                child: ListView(
                  children: const [
                    QuestItem(title: 'Quest 1', subtitle: 'Log In', points: 15),
                    QuestItem(title: 'Quest 2', subtitle: 'Learn a lesson', points: 15),
                    QuestItem(title: 'Quest 3', subtitle: 'Learn a lesson', points: 15),
                  ],
                ),
              ),
            ],
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              color: Colors.grey[200],
              padding: const EdgeInsets.all(8.0),
              child: BottomNavigationBar(
                // Use a consistent navigation style across all pages: Home, Task, Profile
                currentIndex: 1, // Quest page corresponds to the Task tab
                onTap: (index) {
                  if (index == 0) {
                    // Navigate to the home (category) page
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (_) => QuizCategoryScreen()),
                    );
                  } else if (index == 1) {
                    // Stay on the quest page (Task)
                  } else if (index == 2) {
                    // Navigate to the profile page
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (_) => const ProfileScreen()),
                    );
                  }
                },
                items: const [
                  BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
                  BottomNavigationBarItem(icon: Icon(Icons.menu_book), label: 'Task'),
                  BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class QuestItem extends StatelessWidget {
  final String title;
  final String subtitle;
  final int points;

  const QuestItem({
    super.key,
    required this.title,
    required this.subtitle,
    required this.points,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      color: Colors.yellow[100],
      child: ListTile(
        title: Text(title),
        subtitle: Text(subtitle),
        trailing: FittedBox(
          // Wrap the row in a FittedBox to prevent overflow on smaller screens
          fit: BoxFit.scaleDown,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('$points'),
              Icon(Icons.key, color: Colors.yellow),
              const SizedBox(width: 8.0),
              ElevatedButton(
                onPressed: () {},
                child: const Text('CLAIM'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
