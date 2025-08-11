import 'package:flutter/material.dart';
import 'quiz_category.dart';
import 'profile.dart';
import 'quest_status.dart';

class QuestScreen extends StatefulWidget {
  const QuestScreen({super.key});

  @override
  State<QuestScreen> createState() => _QuestScreenState();
}

class _QuestScreenState extends State<QuestScreen> {
  int _selectedIndex = 1;

  void _onItemTapped(int index) {
    if (index == _selectedIndex) return;
    setState(() => _selectedIndex = index);

    switch (index) {
      case 0:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => QuizCategoryScreen()),
        );
        break;
      case 1:
        break; // stay on Quest
      case 2:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const ProfileScreen()),
        );
        break;
    }
  }

  // ✅ Progress is based on COMPLETION (not claim)
  // Each objective contributes 50% (15/30 previously = visual only),
  // but we’ll keep your 30 scale for the label to match your UI text.
  double _chestProgress() {
    final int earned = (QuestStatus.completedQuestions >= 3 ? 15 : 0) +
        (QuestStatus.level1Completed ? 15 : 0);
    return earned / 30.0;
  }

  String _chestProgressLabel() {
    final int earned = (QuestStatus.completedQuestions >= 3 ? 15 : 0) +
        (QuestStatus.level1Completed ? 15 : 0);
    return '$earned/30';
  }

  bool get _isChestUnlocked => _chestProgress() >= 1.0;

  void _openChest() {
    if (! _isChestUnlocked || QuestStatus.chestClaimed) return;

    setState(() {
      QuestStatus.userPoints += QuestStatus.chestReward;
      QuestStatus.chestClaimed = true;
    });

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Chest Opened!'),
        content: Text(
          'Congrats! You earned ${QuestStatus.chestReward} keys.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Awesome'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool chestEnabled = _isChestUnlocked && !QuestStatus.chestClaimed;

    return Scaffold(
      backgroundColor: Colors.white,

      appBar: const PreferredSize(
        preferredSize: Size.fromHeight(80),
        child: _TopBar(),
      ),

      body: Column(
        children: [
          // Chest progress + claim button
          Container(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                const Text(
                  'COMPLETE QUEST TO UNLOCK CHEST!!',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16.0),
                Icon(
                  QuestStatus.chestClaimed
                      ? Icons.lock_open_rounded
                      : (_isChestUnlocked ? Icons.card_giftcard : Icons.lock_outline),
                  // If `Icons.treasure_chest_outlined` isn’t available in your Flutter version,
                  // replace it with Icons.card_giftcard
                  size: 100,
                  color: QuestStatus.chestClaimed
                      ? Colors.amber
                      : (_isChestUnlocked ? Colors.orange : Colors.brown),
                ),
                const SizedBox(height: 16.0),
                LinearProgressIndicator(
                  value: _chestProgress(),
                  backgroundColor: Colors.grey.shade300,
                  color: Colors.blue,
                  minHeight: 10,
                ),
                const SizedBox(height: 8.0),
                Text(_chestProgressLabel()),

                const SizedBox(height: 12.0),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: chestEnabled ? _openChest : null,
                    icon: const Icon(Icons.card_giftcard),
                    label: Text(
                      QuestStatus.chestClaimed
                          ? 'Chest Claimed'
                          : (_isChestUnlocked ? 'Open Chest' : 'Chest Locked'),
                    ),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      backgroundColor:
                      chestEnabled ? Colors.blue : Colors.grey,
                    ),
                  ),
                ),
                if (!QuestStatus.chestClaimed && _isChestUnlocked)
                  const Padding(
                    padding: EdgeInsets.only(top: 6),
                    child: Text(
                      'You can claim your chest now!',
                      style: TextStyle(fontSize: 12, color: Colors.black54),
                    ),
                  ),
              ],
            ),
          ),

          // Quest list
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
                      if (!QuestStatus.quest1Claimed &&
                          QuestStatus.completedQuestions >= 3) {
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
                      if (!QuestStatus.quest2Claimed &&
                          QuestStatus.level1Completed) {
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

      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
          BottomNavigationBarItem(icon: Icon(Icons.menu_book), label: "Task"),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profile"),
        ],
      ),
    );
  }
}

// Top bar (same placement/style as category page)
class _TopBar extends StatelessWidget {
  const _TopBar();

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      flexibleSpace: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(children: [
                const Icon(Icons.key, color: Colors.amber, size: 24),
                const SizedBox(width: 6),
                Text(
                  '${QuestStatus.userPoints}',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                ),
              ]),
              Row(children: const [
                Icon(Icons.local_fire_department, color: Colors.red, size: 24),
                SizedBox(width: 6),
                Text(
                  '0', // streak placeholder
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                ),
              ]),
            ],
          ),
        ),
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
