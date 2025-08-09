import 'package:flutter/material.dart';
import 'quiz_category.dart';
import 'profile.dart';
import 'quest_status.dart'; // ✅ import for quest tracking
import 'alphabet_q.dart';  // ✅ import your alphabet quiz screen to pass startIndex

class QuestScreen extends StatefulWidget {
  const QuestScreen({super.key});

  @override
  State<QuestScreen> createState() => _QuestScreenState();
}

class _QuestScreenState extends State<QuestScreen> {
  // 🔢 Configure Level 1 (Alphabet) length here
  static const int level1TotalQuestions = 5;

  double _chestProgress() {
    // each claim = 15, total target = 30 (based on your UI text)
    final int earned = (QuestStatus.quest1Claimed ? 15 : 0) + (QuestStatus.quest2Claimed ? 15 : 0);
    return earned / 30.0;
  }

  String _chestProgressLabel() {
    final int earned = (QuestStatus.quest1Claimed ? 15 : 0) + (QuestStatus.quest2Claimed ? 15 : 0);
    return '$earned/30';
  }

  bool get _hasStartedLevel1 =>
      QuestStatus.completedQuestions > 0 && QuestStatus.completedQuestions < level1TotalQuestions;

  int get _nextUnansweredIndex {
    // Clamp to valid range [0, total-1]
    final c = QuestStatus.completedQuestions;
    if (c <= 0) return 0;
    if (c >= level1TotalQuestions) return level1TotalQuestions - 1;
    return c; // next unanswered equals number completed
  }

  void _continueLevel1() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => AlphabetQuizScreen(
          startIndex: _nextUnansweredIndex, // 👈 resume here
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Column(
            children: [
              // 🔐 Top bar: keys + streak (consistent placement)
              Container(
                padding: const EdgeInsets.all(16.0),
                color: Colors.grey[200],
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.key, color: Colors.amber),
                        const SizedBox(width: 8.0),
                        Text(
                          '${QuestStatus.userPoints}',
                          style: const TextStyle(fontSize: 18),
                        ),
                      ],
                    ),
                    Row(
                      children: const [
                        Icon(Icons.local_fire_department, color: Colors.red),
                        SizedBox(width: 8.0),
                        Text('0', style: TextStyle(fontSize: 18)),
                      ],
                    ),
                  ],
                ),
              ),

              // 🧰 Chest progress + "Continue Level 1" CTA
              Container(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    const Text(
                      'COMPLETE QUEST TO UNLOCK CHEST!!',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 16.0),
                    const Icon(Icons.lock_outline, size: 100, color: Colors.brown),
                    const SizedBox(height: 16.0),

                    // ✅ Fixed progress calculation (parentheses + division)
                    LinearProgressIndicator(
                      value: _chestProgress(),
                      backgroundColor: Colors.grey,
                      color: Colors.blue,
                      minHeight: 10,
                    ),
                    const SizedBox(height: 8.0),
                    Text(_chestProgressLabel()),

                    // ▶️ Continue button appears only if started but not completed
                    if (_hasStartedLevel1 && !QuestStatus.level1Completed) ...[
                      const SizedBox(height: 16.0),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: _continueLevel1,
                          icon: const Icon(Icons.play_arrow),
                          label: Text('Continue Level 1 (Question ${_nextUnansweredIndex + 1}/$level1TotalQuestions)'),
                          style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 14)),
                        ),
                      ),
                    ],
                  ],
                ),
              ),

              // 📜 Quest list
              Expanded(
                child: ListView(
                  children: [
                    QuestItem(
                      title: 'Quest 1',
                      subtitle: 'Complete 3 Questions',
                      points: 100,
                      isClaimed: QuestStatus.quest1Claimed,
                      isCompleted: QuestStatus.completedQuestions >= 3,
                      onClaim: () {
                        setState(() {
                          if (!QuestStatus.quest1Claimed && QuestStatus.completedQuestions >= 3) {
                            QuestStatus.quest1Claimed = true;
                            QuestStatus.userPoints += 100;
                          }
                        });
                      },
                    ),
                    QuestItem(
                      title: 'Quest 2',
                      subtitle: 'Complete Level 1',
                      points: 100,
                      isClaimed: QuestStatus.quest2Claimed,
                      isCompleted: QuestStatus.level1Completed,
                      onClaim: () {
                        setState(() {
                          if (!QuestStatus.quest2Claimed && QuestStatus.level1Completed) {
                            QuestStatus.quest2Claimed = true;
                            QuestStatus.userPoints += 100;
                          }
                        });
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),

          // ⬇️ Bottom navigation (Home, Quest, Profile)
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              color: Colors.grey[200],
              padding: const EdgeInsets.all(8.0),
              child: BottomNavigationBar(
                currentIndex: 1,
                onTap: (index) {
                  if (index == 0) {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (_) => QuizCategoryScreen()),
                    );
                  } else if (index == 2) {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (_) => const ProfileScreen()),
                    );
                  }
                },
                items: const [
                  BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
                  BottomNavigationBarItem(icon: Icon(Icons.menu_book), label: 'Quest'),
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
  final bool isCompleted;
  final bool isClaimed;
  final VoidCallback onClaim;

  const QuestItem({
    super.key,
    required this.title,
    required this.subtitle,
    required this.points,
    required this.isCompleted,
    required this.isClaimed,
    required this.onClaim,
  });

  @override
  Widget build(BuildContext context) {
    final canClaim = isCompleted && !isClaimed;

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      color: isClaimed ? Colors.green[100] : Colors.yellow[100],
      child: ListTile(
        title: Text(title),
        subtitle: Text(subtitle),
        trailing: FittedBox(
          fit: BoxFit.scaleDown,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('$points'),
              const Icon(Icons.key, color: Colors.yellow),
              const SizedBox(width: 8.0),
              ElevatedButton(
                onPressed: canClaim ? onClaim : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: canClaim ? Colors.blue : Colors.grey,
                ),
                child: Text(isClaimed ? 'CLAIMED' : 'CLAIM'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
