import 'package:flutter/material.dart';
import 'quiz_category.dart';
import 'profile.dart';
import 'quest_status.dart';
import 'user_progress_service.dart';

class QuestScreen extends StatefulWidget {
  const QuestScreen({super.key});

  @override
  State<QuestScreen> createState() => _QuestScreenState();
}

class _QuestScreenState extends State<QuestScreen> {
  int _selectedIndex = 1;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _ensureUserProgressLoaded();
  }

  Future<void> _ensureUserProgressLoaded() async {
    try {
      final userId = UserProgressService().getCurrentUserId();
      if (userId != null && QuestStatus.currentUserId != userId) {
        // User has changed or progress not loaded for current user
        await QuestStatus.loadProgressForUser(userId)
            .timeout(const Duration(seconds: 5));
      }
    } catch (e) {
      print('Error ensuring user progress in QuestScreen: $e');
    }
    if (mounted) {
      setState(() => _isLoading = false);
    }
  }

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

  double get _targetProgress => QuestStatus.chestProgress;
  bool get _isChestUnlocked =>
      QuestStatus.claimedPoints >= QuestStatus.levelGoalPoints;

  Future<void> _openChest() async {
    if (!_isChestUnlocked) return;

    int leveled = 0;

    setState(() {
      QuestStatus.awardAchievement('Welcome');
      leveled = QuestStatus.addXp(200); // Chest grants +200 XP

      int overflow = QuestStatus.claimedPoints - QuestStatus.levelGoalPoints;
      QuestStatus.chestsOpened += 1;
      QuestStatus.advanceChestTier(); // Next chest bar += 20

      while (overflow >= QuestStatus.levelGoalPoints) {
        overflow -= QuestStatus.levelGoalPoints;
        QuestStatus.chestsOpened += 1;
        QuestStatus.advanceChestTier();
      }
      QuestStatus.claimedPoints = overflow.clamp(0, 1 << 30);
    });

    _showXpToast(xp: 200, leveledUp: leveled);

    // Sweep auto-claim in case any chest-related quests complete
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final bool chestEnabled = _isChestUnlocked;

    // Optional: light sweep to reflect latest auto-claims when opening screen
    QuestStatus.ensureUnlocksLoaded();

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
          // Chest section
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
                      final shown =
                      (value * QuestStatus.levelGoalPoints).round();
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
                            style: const TextStyle(
                                fontSize: 12, fontWeight: FontWeight.w600),
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
                        backgroundColor:
                        chestEnabled ? Colors.blue : Colors.grey,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                        textStyle: const TextStyle(
                            fontSize: 14, fontWeight: FontWeight.w700),
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
                // ======================= Q1 – Q4 : Alphabet (Free) =======================
                QuestItem(
                  title: 'Quest 1',
                  subtitle: 'Start "Alphabet" level',
                  points: 100,
                  isClaimed: QuestStatus.quest1Claimed,
                  isCompleted: QuestStatus.completedQuestions >= 1,
                  onClaim: () {
                    setState(() {
                      if (QuestStatus.canClaimQuest1()) QuestStatus.claimQuest1();
                    });
                  },
                ),

                QuestItem(
                  title: 'Quest 2',
                  subtitle: 'Learn ALL Alphabet in Learning Mode',
                  points: 120,
                  isClaimed: QuestStatus.quest2Claimed,
                  isCompleted: QuestStatus.learnedAlphabetAll,
                  onClaim: () {
                    setState(() {
                      if (QuestStatus.canClaimQuest2()) QuestStatus.claimQuest2();
                    });
                  },
                ),

                QuestItem(
                  title: 'Quest 3',
                  subtitle: 'Start "Alphabet" quiz',
                  points: 80,
                  isClaimed: QuestStatus.quest3Claimed,
                  isCompleted: QuestStatus.alphabetQuizStarted,
                  onClaim: () {
                    setState(() {
                      if (QuestStatus.canClaimQuest3()) QuestStatus.claimQuest3();
                    });
                  },
                ),

                QuestItem(
                  title: 'Quest 4',
                  subtitle: 'Get 3 correct answers in a row (Alphabet)',
                  points: 120,
                  isClaimed: QuestStatus.quest4Claimed,
                  isCompleted: QuestStatus.level1BestStreak >= 3,
                  onClaim: () {
                    setState(() {
                      if (QuestStatus.canClaimQuest4()) QuestStatus.claimQuest4();
                    });
                  },
                ),

                // ================ Q5 – Q8 : Numbers (Unlock at Level 5) ==================
                QuestItem(
                  title: 'Quest 5',
                  subtitle: 'Start "Numbers" level',
                  points: 100,
                  isClaimed: QuestStatus.quest5Claimed,
                  isCompleted: QuestStatus.isContentUnlocked(QuestStatus.levelNumbers),
                  onClaim: () {
                    setState(() {
                      if (QuestStatus.canClaimQuest5()) QuestStatus.claimQuest5();
                    });
                  },
                ),

                QuestItem(
                  title: 'Quest 6',
                  subtitle: 'Learn ALL Numbers in Learning Mode',
                  points: 120,
                  isClaimed: QuestStatus.quest6Claimed,
                  isCompleted: QuestStatus.learnedNumbersAll,
                  onClaim: () {
                    setState(() {
                      if (QuestStatus.canClaimQuest6()) QuestStatus.claimQuest6();
                    });
                  },
                ),

                QuestItem(
                  title: 'Quest 7',
                  subtitle: 'Complete ONE Numbers round without mistakes',
                  points: 200,
                  isClaimed: QuestStatus.quest7Claimed,
                  isCompleted: QuestStatus.numbersPerfectRounds >= 1,
                  onClaim: () {
                    setState(() {
                      if (QuestStatus.canClaimQuest7()) QuestStatus.claimQuest7();
                    });
                  },
                ),

                QuestItem(
                  title: 'Quest 8',
                  subtitle: 'Finish 3 rounds of Numbers level',
                  points: 200,
                  isClaimed: QuestStatus.quest8Claimed,
                  isCompleted: QuestStatus.numbersRoundsCompleted >= 3,
                  onClaim: () {
                    setState(() {
                      if (QuestStatus.canClaimQuest8()) QuestStatus.claimQuest8();
                    });
                  },
                ),

                // ================= Q9 – Q12 : Colour (Unlock at Level 10) =================
                QuestItem(
                  title: 'Quest 9',
                  subtitle: 'Start "Colour" level',
                  points: 100,
                  isClaimed: QuestStatus.quest9Claimed,
                  isCompleted: QuestStatus.isContentUnlocked(QuestStatus.levelColour),
                  onClaim: () {
                    setState(() {
                      if (QuestStatus.canClaimQuest9()) QuestStatus.claimQuest9();
                    });
                  },
                ),

                QuestItem(
                  title: 'Quest 10',
                  subtitle: 'Learn ALL Colours in Learning Mode',
                  points: 120,
                  isClaimed: QuestStatus.quest10Claimed,
                  isCompleted: QuestStatus.learnedColoursAll,
                  onClaim: () {
                    setState(() {
                      if (QuestStatus.canClaimQuest10()) QuestStatus.claimQuest10();
                    });
                  },
                ),

                QuestItem(
                  title: 'Quest 11',
                  subtitle: 'Get 5 correct answers in a row (Colour)',
                  points: 150,
                  isClaimed: QuestStatus.quest11Claimed,
                  isCompleted: QuestStatus.colourBestStreak >= 5,
                  onClaim: () {
                    setState(() {
                      if (QuestStatus.canClaimQuest11()) QuestStatus.claimQuest11();
                    });
                  },
                ),

                QuestItem(
                  title: 'Quest 12',
                  subtitle: 'Finish 2 Colour rounds',
                  points: 200,
                  isClaimed: QuestStatus.quest12Claimed,
                  isCompleted: QuestStatus.colourRoundsCompleted >= 2,
                  onClaim: () {
                    setState(() {
                      if (QuestStatus.canClaimQuest12()) QuestStatus.claimQuest12();
                    });
                  },
                ),

                // ================= Q13 – Q16 : Fruits (Unlock at Level 15) ================
                QuestItem(
                  title: 'Quest 13',
                  subtitle: 'Start "Fruits" level',
                  points: 100,
                  isClaimed: QuestStatus.quest13Claimed,
                  isCompleted: QuestStatus.isContentUnlocked(QuestStatus.levelGreetings),
                  onClaim: () {
                    setState(() {
                      if (QuestStatus.canClaimQuest13()) QuestStatus.claimQuest13();
                    });
                  },
                ),

                QuestItem(
                  title: 'Quest 14',
                  subtitle: 'Learn ALL Fruits in Learning Mode',
                  points: 120,
                  isClaimed: QuestStatus.quest14Claimed,
                  isCompleted: QuestStatus.learnedFruitsAll,
                  onClaim: () {
                    setState(() {
                      if (QuestStatus.canClaimQuest14()) QuestStatus.claimQuest14();
                    });
                  },
                ),

                QuestItem(
                  title: 'Quest 15',
                  subtitle: 'Get 4 correct answers in a row (Fruits)',
                  points: 150,
                  isClaimed: QuestStatus.quest15Claimed,
                  isCompleted: QuestStatus.fruitsBestStreak >= 4,
                  onClaim: () {
                    setState(() {
                      if (QuestStatus.canClaimQuest15()) QuestStatus.claimQuest15();
                    });
                  },
                ),

                QuestItem(
                  title: 'Quest 16',
                  subtitle: 'Finish 2 Fruits rounds',
                  points: 200,
                  isClaimed: QuestStatus.quest16Claimed,
                  isCompleted: QuestStatus.fruitsRoundsCompleted >= 2,
                  onClaim: () {
                    setState(() {
                      if (QuestStatus.canClaimQuest16()) QuestStatus.claimQuest16();
                    });
                  },
                ),

                // ================= Q17 – Q20 : Animals (Unlock at Level 25) ===============
                QuestItem(
                  title: 'Quest 17',
                  subtitle: 'Start "Animals" level',
                  points: 100,
                  isClaimed: QuestStatus.quest17Claimed,
                  isCompleted: QuestStatus.isContentUnlocked(QuestStatus.levelCommonVerb),
                  onClaim: () {
                    setState(() {
                      if (QuestStatus.canClaimQuest17()) QuestStatus.claimQuest17();
                    });
                  },
                ),

                QuestItem(
                  title: 'Quest 18',
                  subtitle: 'Learn ALL Animals in Learning Mode',
                  points: 120,
                  isClaimed: QuestStatus.quest18Claimed,
                  isCompleted: QuestStatus.learnedAnimalsAll,
                  onClaim: () {
                    setState(() {
                      if (QuestStatus.canClaimQuest18()) QuestStatus.claimQuest18();
                    });
                  },
                ),

                QuestItem(
                  title: 'Quest 19',
                  subtitle: 'Finish 3 Animals rounds',
                  points: 150,
                  isClaimed: QuestStatus.quest19Claimed,
                  isCompleted: QuestStatus.animalsRoundsCompleted >= 3,
                  onClaim: () {
                    setState(() {
                      if (QuestStatus.canClaimQuest19()) QuestStatus.claimQuest19();
                    });
                  },
                ),

                QuestItem(
                  title: 'Quest 20',
                  subtitle: 'Complete ONE Animals round without mistakes',
                  points: 200,
                  isClaimed: QuestStatus.quest20Claimed,
                  isCompleted: QuestStatus.animalsPerfectRounds >= 1,
                  onClaim: () {
                    setState(() {
                      if (QuestStatus.canClaimQuest20()) QuestStatus.claimQuest20();
                    });
                  },
                ),

                // ================= Q21 – Q24 : Simple Global Milestones ====================
                QuestItem(
                  title: 'Quest 21',
                  subtitle: 'Open 3 chests',
                  points: 150,
                  isClaimed: QuestStatus.quest21Claimed,
                  isCompleted: QuestStatus.chestsOpened >= 3,
                  onClaim: () {
                    setState(() {
                      if (QuestStatus.canClaimQuest21()) QuestStatus.claimQuest21();
                    });
                  },
                ),

                QuestItem(
                  title: 'Quest 22',
                  subtitle: 'Reach Level 10',
                  points: 150,
                  isClaimed: QuestStatus.quest22Claimed,
                  isCompleted: QuestStatus.level >= 10,
                  onClaim: () {
                    setState(() {
                      if (QuestStatus.canClaimQuest22()) QuestStatus.claimQuest22();
                    });
                  },
                ),

                QuestItem(
                  title: 'Quest 23',
                  subtitle: 'Unlock all categories',
                  points: 200,
                  isClaimed: QuestStatus.quest23Claimed,
                  isCompleted: QuestStatus.isContentUnlocked(QuestStatus.levelNumbers) &&
                      QuestStatus.isContentUnlocked(QuestStatus.levelColour)  &&
                      QuestStatus.isContentUnlocked(QuestStatus.levelGreetings) &&
                      QuestStatus.isContentUnlocked(QuestStatus.levelCommonVerb),
                  onClaim: () {
                    setState(() {
                      if (QuestStatus.canClaimQuest23()) QuestStatus.claimQuest23();
                    });
                  },
                ),

                QuestItem(
                  title: 'Quest 24',
                  subtitle: 'Reach Level 25',
                  points: 300,
                  isClaimed: QuestStatus.quest24Claimed,
                  isCompleted: QuestStatus.level >= 25,
                  onClaim: () {
                    setState(() {
                      if (QuestStatus.canClaimQuest24()) QuestStatus.claimQuest24();
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
          BottomNavigationBarItem(icon: Icon(Icons.menu_book), label: "Quest"),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "User"),
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
    const double iconSize = 22;
    const TextStyle valueStyle =
    TextStyle(fontWeight: FontWeight.w700, fontSize: 16);

    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      toolbarHeight: 52,
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
        title: Text(title,
            style:
            const TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
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
                  padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  backgroundColor: canClaim ? Colors.blue : Colors.grey,
                ),
                child: Text(isClaimed ? 'CLAIMED' : 'CLAIM',
                    style: const TextStyle(
                        fontSize: 12, fontWeight: FontWeight.w700)),
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
              BoxShadow(
                  color: Colors.black26, blurRadius: 16, offset: Offset(0, 8)),
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
