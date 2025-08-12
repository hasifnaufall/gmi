import 'package:flutter/material.dart';
import 'quiz_category.dart';
import 'profile.dart';
import 'quest_status.dart';
import 'xp_popups.dart'; // NEW: fancy XP popup

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
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => QuizCategoryScreen()));
        break;
      case 1:
        break;
      case 2:
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const ProfileScreen()));
        break;
    }
  }

  double get _targetProgress =>
      (QuestStatus.claimedPoints / QuestStatus.levelGoalPoints).clamp(0, 1);
  bool get _isChestUnlocked => QuestStatus.claimedPoints >= QuestStatus.levelGoalPoints;

  // Removed the old AlertDialog; now just reward + celebration, then advance tier.
  Future<void> _openChest() async {
    if (!_isChestUnlocked) return;

    // Give keys + XP immediately
    int leveled = 0; // ✅ initialize first
    setState(() {
      QuestStatus.userPoints += QuestStatus.chestReward;
      leveled = QuestStatus.addXp(200);
    });

    // Show celebratory popup (no extra dialog)
    await showXpCelebration(context, xp: 200, leveledUp: leveled);

    // Advance the chest tier (e.g., 30 -> 50), keep current progress
    if (mounted) {
      setState(() {
        QuestStatus.advanceChestTier();
      });
    }
  }


  @override
  Widget build(BuildContext context) {
    final bool chestEnabled = _isChestUnlocked;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(80),
        child: _TopBar(points: QuestStatus.userPoints, streak: 0),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Chest progress + animated bar + button
          Container(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                const SizedBox(height: 6),
                const Text(
                  'COMPLETE QUEST TO UNLOCK CHEST!!',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16.0),
                Icon(
                  chestEnabled ? Icons.card_giftcard : Icons.lock_outline,
                  size: 100,
                  color: chestEnabled ? Colors.orange : Colors.brown,
                ),
                const SizedBox(height: 16.0),
                TweenAnimationBuilder<double>(
                  key: ValueKey('${QuestStatus.claimedPoints}/${QuestStatus.levelGoalPoints}'),
                  duration: const Duration(milliseconds: 700),
                  curve: Curves.easeInOut,
                  tween: Tween<double>(begin: 0, end: _targetProgress),
                  builder: (context, value, _) {
                    final shown = (value * QuestStatus.levelGoalPoints).round();
                    return Column(
                      children: [
                        LinearProgressIndicator(
                          value: value,
                          backgroundColor: Colors.grey.shade300,
                          color: Colors.blue,
                          minHeight: 10,
                        ),
                        const SizedBox(height: 8.0),
                        Text('$shown/${QuestStatus.levelGoalPoints}'),
                      ],
                    );
                  },
                ),
                const SizedBox(height: 12.0),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: chestEnabled ? _openChest : null,
                    icon: const Icon(Icons.card_giftcard),
                    label: Text(chestEnabled ? 'Open Chest' : 'Chest Locked'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      backgroundColor: chestEnabled ? Colors.blue : Colors.grey,
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Quests
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
                        QuestStatus.claimedPoints += 15;
                        final levels = QuestStatus.addXp(80);
                        showXpCelebration(context, xp: 80, leveledUp: levels);
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
                        QuestStatus.claimedPoints += 15;
                        final levels = QuestStatus.addXp(120);
                        showXpCelebration(context, xp: 120, leveledUp: levels);
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

class _TopBar extends StatelessWidget {
  final int points;
  final int streak;
  const _TopBar({required this.points, required this.streak});

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
                Text('$points', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
              ]),
              Row(children: [
                const Icon(Icons.local_fire_department, color: Colors.red, size: 24),
                const SizedBox(width: 6),
                Text('$streak', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
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
