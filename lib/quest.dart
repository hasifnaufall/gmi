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
        break; // stay here
      case 2:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const ProfileScreen()),
        );
        break;
    }
  }

  double get _targetProgress =>
      (QuestStatus.claimedPoints / QuestStatus.levelGoalPoints).clamp(0, 1).toDouble();

  bool get _isChestUnlocked =>
      QuestStatus.claimedPoints >= QuestStatus.levelGoalPoints;

  Future<void> _openChest() async {
    if (!_isChestUnlocked) return;

    int leveled = 0;

    setState(() {
      // Chest reward: grant 200 XP every chest; optional one-time achievement
      QuestStatus.awardAchievement('Welcome');
      leveled = QuestStatus.addXp(200);
      QuestStatus.chestsOpened += 1;
    });

    // XP toast
    _showXpToast(xp: 200, leveledUp: leveled);

    // Advance chest tier (e.g., 30 -> 50 -> 100 -> ...)
    if (!mounted) return;
    setState(() {
      QuestStatus.advanceChestTier();
    });
  }

  /// Max consecutive TRUEs in the current Alphabet 5-question session.
  int _alphabetBestStreak() {
    int best = 0, cur = 0;
    for (final v in QuestStatus.level1Answers) {
      if (v == true) {
        cur += 1;
        if (cur > best) best = cur;
      } else {
        cur = 0;
      }
    }
    return best;
  }

  @override
  Widget build(BuildContext context) {
    final bool chestEnabled = _isChestUnlocked;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(56), // compact height
        child: _TopBar(
          points: QuestStatus.userPoints,
          streak: QuestStatus.streakDays,
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Compact Chest section
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 6),
            child: Container(
              padding: const EdgeInsets.all(12.0),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Column(
                children: [
                  const Text(
                    'COMPLETE QUEST TO UNLOCK CHEST!!',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Icon(
                    chestEnabled ? Icons.card_giftcard : Icons.lock_outline,
                    size: 64,
                    color: chestEnabled ? Colors.orange : Colors.brown,
                  ),
                  const SizedBox(height: 8),
                  TweenAnimationBuilder<double>(
                    key: ValueKey(
                      '${QuestStatus.claimedPoints}/${QuestStatus.levelGoalPoints}',
                    ),
                    duration: const Duration(milliseconds: 600),
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
                            minHeight: 8,
                          ),
                          const SizedBox(height: 6),
                          Text(
                            '$shown/${QuestStatus.levelGoalPoints}',
                            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                          ),
                        ],
                      );
                    },
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: chestEnabled ? _openChest : null,
                      icon: const Icon(Icons.card_giftcard, size: 18),
                      label: Text(chestEnabled ? 'Open Chest' : 'Chest Locked'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        backgroundColor: chestEnabled ? Colors.blue : Colors.grey,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Quests
          Expanded(
            child: ListView(
              padding: const EdgeInsets.only(top: 4, bottom: 8),
              children: [
                // Quest 1 – Start Alphabet (answer >= 1 question)
                QuestItem(
                  title: 'Quest 1',
                  subtitle: 'Start "Alphabet" level',
                  points: 100,
                  isClaimed: QuestStatus.quest1Claimed,
                  isCompleted: QuestStatus.completedQuestions >= 1,
                  onClaim: () {
                    setState(() {
                      if (QuestStatus.canClaimQuest1()) {
                        QuestStatus.claimQuest1();
                        QuestStatus.addStreakForLevel();
                        _showXpToast(xp: 50, leveledUp: 0);
                      }
                    });
                  },
                ),

                // Quest 2 – Get 3 correct answers in a row (Alphabet)
                QuestItem(
                  title: 'Quest 2',
                  subtitle: 'Get 3 correct answers in a row (Alphabet)',
                  points: 120,
                  isClaimed: QuestStatus.quest2Claimed,
                  isCompleted: _alphabetBestStreak() >= 3,
                  onClaim: () {
                    setState(() {
                      if (QuestStatus.canClaimQuest2()) {
                        // you can change reward/progress in claimQuest2() if desired
                        QuestStatus.claimQuest2();
                        _showXpToast(xp: 100, leveledUp: 0);
                      }
                    });
                  },
                ),

                // Quest 3 – Finish 3 rounds of Alphabet
                QuestItem(
                  title: 'Quest 3',
                  subtitle: 'Finish 3 rounds of Alphabet level',
                  points: 200,
                  isClaimed: QuestStatus.quest3Claimed,
                  isCompleted: QuestStatus.alphabetRoundsCompleted >= 3,
                  onClaim: () {
                    setState(() {
                      if (QuestStatus.canClaimQuest3()) {
                        QuestStatus.claimQuest3();
                        _showXpToast(xp: 150, leveledUp: 0);
                      }
                    });
                  },
                ),

                // Quest 4 – Complete ONE Alphabet level without mistakes
                QuestItem(
                  title: 'Quest 4',
                  subtitle: 'Complete ONE Alphabet round without mistakes',
                  points: 250,
                  isClaimed: QuestStatus.quest4Claimed,
                  isCompleted: QuestStatus.level1Completed &&
                      QuestStatus.level1Score == QuestStatus.level1Answers.length,
                  onClaim: () {
                    setState(() {
                      if (QuestStatus.canClaimQuest4()) {
                        QuestStatus.claimQuest4();
                        _showXpToast(xp: 180, leveledUp: 0);
                      }
                    });
                  },
                ),

                // Quest 5 – Unlock Numbers
                QuestItem(
                  title: 'Quest 5',
                  subtitle: 'Unlock the "Number" level',
                  points: 100,
                  isClaimed: QuestStatus.quest5Claimed,
                  isCompleted: QuestStatus.isContentUnlocked(QuestStatus.levelNumbers),
                  onClaim: () {
                    setState(() {
                      if (QuestStatus.canClaimQuest5()) {
                        QuestStatus.claimQuest5();
                        _showXpToast(xp: 120, leveledUp: 0);
                      }
                    });
                  },
                ),

                // Quest 6 – Numbers: complete all questions correctly (perfect round)
                QuestItem(
                  title: 'Quest 6',
                  subtitle: 'Complete all questions correctly in Numbers',
                  points: 200,
                  isClaimed: QuestStatus.quest6Claimed,
                  isCompleted: (QuestStatus.numbersPerfectRounds >= 1),
                  onClaim: () {
                    setState(() {
                      if (QuestStatus.canClaimQuest6()) {
                        QuestStatus.claimQuest6();
                        _showXpToast(xp: 160, leveledUp: 0);
                      }
                    });
                  },
                ),

                // Quest 7 – Numbers: finish 3 rounds
                QuestItem(
                  title: 'Quest 7',
                  subtitle: 'Finish 3 rounds of Numbers level',
                  points: 200,
                  isClaimed: QuestStatus.quest7Claimed,
                  isCompleted: (QuestStatus.numbersRoundsCompleted >= 3),
                  onClaim: () {
                    setState(() {
                      if (QuestStatus.canClaimQuest7()) {
                        QuestStatus.claimQuest7();
                        _showXpToast(xp: 150, leveledUp: 0);
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
  // Local animated XP toast
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
    // Same constants as quiz_category.dart
    const double iconSize = 22;
    const TextStyle valueStyle =
    TextStyle(fontWeight: FontWeight.w700, fontSize: 16);

    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      toolbarHeight: 52, // same height as quiz_category
      flexibleSpace: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 6),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Row(children: [
                const Icon(Icons.key, color: Colors.amber, size: iconSize),
                const SizedBox(width: 6),
                Text('$points', style: valueStyle),
              ]),
              Row(children: [
                const Icon(Icons.local_fire_department,
                    color: Colors.red, size: iconSize),
                const SizedBox(width: 6),
                Text('$streak', style: valueStyle),
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
      margin: const EdgeInsets.symmetric(vertical: 6.0, horizontal: 12.0),
      color: isClaimed ? Colors.green[100] : Colors.yellow[100],
      child: ListTile(
        dense: true,
        title: Text(title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
        subtitle: Text(subtitle, style: const TextStyle(fontSize: 13)),
        trailing: FittedBox(
          fit: BoxFit.scaleDown,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('$points', style: const TextStyle(fontSize: 13)),
              const Icon(Icons.key, color: Colors.yellow, size: 18),
              const SizedBox(width: 6.0),
              ElevatedButton(
                onPressed: canClaim ? onClaim : null,
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(84, 34),
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  backgroundColor: canClaim ? Colors.blue : Colors.grey,
                ),
                child: Text(isClaimed ? 'CLAIMED' : 'CLAIM',
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
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
      duration: const Duration(milliseconds: 240),
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
          width: 260,
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: widget.bgColor,
            borderRadius: BorderRadius.circular(12),
            boxShadow: const [
              BoxShadow(color: Colors.black26, blurRadius: 16, offset: Offset(0, 8)),
            ],
          ),
          child: Row(
            children: [
              Icon(widget.icon, color: widget.iconColor, size: 24),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(widget.title,
                        style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w800,
                            fontSize: 14)),
                    const SizedBox(height: 2),
                    Text(widget.subtitle,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                            color: Colors.white70, fontSize: 12)),
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
