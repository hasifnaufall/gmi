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
        break;
      case 2:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const ProfileScreen()),
        );
        break;
    }
  }

  double get _targetProgress =>
      (QuestStatus.claimedPoints / QuestStatus.levelGoalPoints).clamp(0, 1);

  bool get _isChestUnlocked =>
      QuestStatus.claimedPoints >= QuestStatus.levelGoalPoints;

  Future<void> _openChest() async {
    if (!_isChestUnlocked) return;

    bool unlockedWelcome = false;
    int leveled = 0;

    setState(() {
      // ✅ Chest reward: unlock “Welcome” (one-time) + grant 200 XP every chest
      unlockedWelcome = QuestStatus.awardAchievement('Welcome');
      leveled = QuestStatus.addXp(200);
      QuestStatus.chestsOpened += 1;
    });

    // 🎉 XP toast
    _showXpToast(xp: 200, leveledUp: leveled);

    // Optional snack if achievement just unlocked
    if (unlockedWelcome && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Achievement unlocked: Welcome')),
      );
    }

    // Advance chest tier (e.g., 30 -> 50 -> 100 -> ...)
    if (!mounted) return;
    setState(() {
      QuestStatus.advanceChestTier();
    });
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
          // Chest progress + button
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
                  key: ValueKey(
                      '${QuestStatus.claimedPoints}/${QuestStatus.levelGoalPoints}'),
                  duration: const Duration(milliseconds: 700),
                  curve: Curves.easeInOut,
                  tween: Tween<double>(begin: 0, end: _targetProgress),
                  builder: (context, value, _) {
                    final shown =
                    (value * QuestStatus.levelGoalPoints).round();
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
                      backgroundColor:
                      chestEnabled ? Colors.blue : Colors.grey,
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
                      if (!QuestStatus.quest1Claimed &&
                          QuestStatus.completedQuestions >= 3) {
                        QuestStatus.quest1Claimed = true;
                        QuestStatus.userPoints += 100;
                        QuestStatus.claimedPoints += 15;
                        final leveled = QuestStatus.addXp(80);
                        _showXpToast(xp: 80, leveledUp: leveled);
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
                        QuestStatus.claimedPoints += 15;
                        final leveled = QuestStatus.addXp(120);
                        _showXpToast(xp: 120, leveledUp: leveled);
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

  // --------------------------------------------------------------------
  // Local animated XP toast so we don't depend on xp_popups.dart
  // --------------------------------------------------------------------
  void _showXpToast({required int xp, required int leveledUp}) {
    final overlay = Overlay.of(context);
    final entry = OverlayEntry(
      builder: (_) => Positioned(
        top: 64,
        right: 16,
        child: _SlideInToast(
          bgColor: Colors.indigo.shade600,
          icon: Icons.star,
          iconColor: Colors.amber,
          title: "XP +$xp",
          subtitle: leveledUp > 0 ? "Level Up! (+$leveledUp)" : "Nice work!",
        ),
      ),
    );
    overlay.insert(entry);
    Future.delayed(const Duration(seconds: 2), () => entry.remove());
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
                Text('$points',
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 18)),
              ]),
              Row(children: [
                const Icon(Icons.local_fire_department,
                    color: Colors.red, size: 24),
                const SizedBox(width: 6),
                Text('$streak',
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 18)),
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

// ---------------- Slide-in toast widget ----------------
class _SlideInToast extends StatefulWidget {
  final Color bgColor;
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;

  const _SlideInToast({
    required this.bgColor,
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
  });

  @override
  State<_SlideInToast> createState() => _SlideInToastState();
}

class _SlideInToastState extends State<_SlideInToast>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 260),
    )..forward();
    _slide = Tween<Offset>(begin: const Offset(1.1, 0), end: Offset.zero)
        .chain(CurveTween(curve: Curves.easeOut))
        .animate(_ctrl);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: _slide,
      child: Material(
        color: Colors.transparent,
        child: Container(
          width: 280,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: widget.bgColor,
            borderRadius: BorderRadius.circular(12),
            boxShadow: const [
              BoxShadow(color: Colors.black26, blurRadius: 18, offset: Offset(0, 8)),
            ],
          ),
          child: Row(
            children: [
              Icon(widget.icon, color: widget.iconColor, size: 28),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(widget.title,
                        style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w800,
                            fontSize: 16)),
                    const SizedBox(height: 2),
                    Text(widget.subtitle,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                            color: Colors.white70, fontSize: 13)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
