// quest.dart
import 'package:flutter/material.dart';

import 'leaderboard.dart';
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
        await QuestStatus.loadProgressForUser(
          userId,
        ).timeout(const Duration(seconds: 5));
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
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const LeaderboardPage()),
        );
        break;
      case 3:
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

    // Rebuild to reflect latest values
    setState(() {});
  }

  int _getCompletedQuestCount() {
    int count = 0;
    if (QuestStatus.quest1Claimed) count++;
    if (QuestStatus.quest2Claimed) count++;
    if (QuestStatus.quest3Claimed) count++;
    if (QuestStatus.quest4Claimed) count++;
    if (QuestStatus.quest5Claimed) count++;
    if (QuestStatus.quest6Claimed) count++;
    if (QuestStatus.quest7Claimed) count++;
    if (QuestStatus.quest8Claimed) count++;
    if (QuestStatus.quest9Claimed) count++;
    if (QuestStatus.quest10Claimed) count++;
    if (QuestStatus.quest11Claimed) count++;
    if (QuestStatus.quest12Claimed) count++;
    if (QuestStatus.quest13Claimed) count++;
    if (QuestStatus.quest14Claimed) count++;
    if (QuestStatus.quest15Claimed) count++;
    if (QuestStatus.quest16Claimed) count++;
    if (QuestStatus.quest17Claimed) count++;
    if (QuestStatus.quest18Claimed) count++;
    if (QuestStatus.quest19Claimed) count++;
    if (QuestStatus.quest20Claimed) count++;
    if (QuestStatus.quest21Claimed) count++;
    if (QuestStatus.quest22Claimed) count++;
    if (QuestStatus.quest23Claimed) count++;
    if (QuestStatus.quest24Claimed) count++;
    return count;
  }

  Widget _buildStatCard({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.6),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3), width: 1),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(color: Colors.black54, fontSize: 11),
              ),
              Text(
                value,
                style: TextStyle(
                  color: Colors.black87,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        body: Container(
          color: const Color(0xFFFAFFDC),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset('assets/loading_character.png', height: 100),
                const SizedBox(height: 20),
                CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF2C5CB0)),
                ),
                const SizedBox(height: 10),
                const Text(
                  'Loading Quests...',
                  style: TextStyle(
                    color: Colors.black87,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final bool chestEnabled = _isChestUnlocked;

    // Lightweight refresh (no auto-claim inside)
    QuestStatus.ensureUnlocksLoaded();

    return Scaffold(
      backgroundColor: const Color(0xFFFAFFDC),
      resizeToAvoidBottomInset: false,
      body: Container(
        color: const Color(0xFFFAFFDC),
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Modern Header with Stats
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Quest Board',
                              style: TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                                letterSpacing: 0.5,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              'Complete missions & earn rewards',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.black54,
                              ),
                            ),
                          ],
                        ),
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [Color(0xFFFF6B6B), Color(0xFFFF8E53)],
                            ),
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: Color(0xFFFF6B6B).withOpacity(0.3),
                                blurRadius: 8,
                                offset: Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.stars, color: Colors.white, size: 20),
                              SizedBox(width: 6),
                              Text(
                                '${QuestStatus.userPoints}',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 16),
                    // Stats Row
                    Row(
                      children: [
                        Expanded(
                          child: _buildStatCard(
                            icon: Icons.local_fire_department,
                            label: 'Streak',
                            value: '${QuestStatus.streakDays}d',
                            color: Color(0xFFFF6B6B),
                          ),
                        ),
                        SizedBox(width: 12),
                        Expanded(
                          child: _buildStatCard(
                            icon: Icons.check_circle,
                            label: 'Completed',
                            value: '${_getCompletedQuestCount()}/24',
                            color: Color(0xFF4ECDC4),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Chest Card - Redesigned
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 8,
                ),
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: chestEnabled
                          ? const Color(0xFFFFB800)
                          : Colors.black.withOpacity(0.08),
                      width: chestEnabled ? 2 : 1,
                    ),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 12,
                        offset: Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 60,
                            height: 60,
                            decoration: BoxDecoration(
                              color: chestEnabled
                                  ? const Color(0xFFFFF3C4)
                                  : Colors.black.withOpacity(0.05),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Icon(
                              chestEnabled
                                  ? Icons.card_giftcard
                                  : Icons.lock_outline,
                              size: 32,
                              color: chestEnabled
                                  ? const Color(0xFF8B4513)
                                  : Colors.black45,
                            ),
                          ),
                          SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  chestEnabled
                                      ? 'Reward Ready!'
                                      : 'Quest Chest',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: chestEnabled
                                        ? const Color(0xFF8B4513)
                                        : Colors.black87,
                                  ),
                                ),
                                SizedBox(height: 4),
                                Text(
                                  chestEnabled
                                      ? 'Claim your rewards now'
                                      : 'Complete quests to unlock',
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: chestEnabled
                                        ? const Color(
                                            0xFF8B4513,
                                          ).withOpacity(0.8)
                                        : Colors.black54,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 16),
                      // Progress Bar
                      Container(
                        height: 8,
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.08),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: LayoutBuilder(
                          builder: (context, constraints) {
                            return AnimatedContainer(
                              duration: Duration(milliseconds: 500),
                              width: constraints.maxWidth * _targetProgress,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: chestEnabled
                                      // Unlocked: warm gold
                                      ? [Color(0xFFFFC107), Color(0xFFFFA000)]
                                      // Locked: vibrant purple for visibility
                                      : [Color(0xFF7C3AED), Color(0xFF9333EA)],
                                ),
                                borderRadius: BorderRadius.circular(4),
                              ),
                            );
                          },
                        ),
                      ),
                      SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: chestEnabled ? _openChest : null,
                          style: ElevatedButton.styleFrom(
                            padding: EdgeInsets.symmetric(vertical: 14),
                            backgroundColor: chestEnabled
                                ? const Color(0xFFFFC107)
                                : Colors.black.withOpacity(0.06),
                            foregroundColor: chestEnabled
                                ? Colors.black
                                : Colors.black45,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Text(
                            chestEnabled ? 'Open Chest' : 'Locked',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              SizedBox(height: 24),

              // Quests Header
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
                child: Row(
                  children: [
                    Icon(Icons.list_alt, color: Colors.black54, size: 22),
                    SizedBox(width: 10),
                    Text(
                      'Available Quests',
                      style: TextStyle(
                        color: Colors.black87,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '${_getCompletedQuestCount()}/24',
                        style: const TextStyle(
                          color: Colors.black87,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Quests List
              Expanded(
                child: Container(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 15,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: ListView(
                      padding: const EdgeInsets.only(top: 8, bottom: 8),
                      children: [
                        // ======================= Q1 – Q4 : Alphabet (Free) =======================
                        _FunQuestItem(
                          title: 'Quest 1',
                          subtitle: 'Start "Alphabet" level',
                          points: 100,
                          isClaimed: QuestStatus.quest1Claimed,
                          isCompleted: QuestStatus.completedQuestions >= 1,
                          onClaim: () {
                            setState(() {
                              if (QuestStatus.canClaimQuest1()) {
                                QuestStatus.claimQuest1();
                              }
                            });
                          },
                          icon: '🔤',
                        ),
                        _FunQuestItem(
                          title: 'Quest 2',
                          subtitle: 'Learn ALL Alphabet in Learning Mode',
                          points: 120,
                          isClaimed: QuestStatus.quest2Claimed,
                          isCompleted: QuestStatus.learnedAlphabetAll,
                          onClaim: () {
                            setState(() {
                              if (QuestStatus.canClaimQuest2()) {
                                QuestStatus.claimQuest2();
                              }
                            });
                          },
                          icon: '📚',
                        ),
                        _FunQuestItem(
                          title: 'Quest 3',
                          subtitle: 'Start "Alphabet" quiz',
                          points: 80,
                          isClaimed: QuestStatus.quest3Claimed,
                          isCompleted: QuestStatus.alphabetQuizStarted,
                          onClaim: () {
                            setState(() {
                              if (QuestStatus.canClaimQuest3()) {
                                QuestStatus.claimQuest3();
                              }
                            });
                          },
                          icon: '🎯',
                        ),
                        _FunQuestItem(
                          title: 'Quest 4',
                          subtitle: 'Get 3 correct answers in a row (Alphabet)',
                          points: 120,
                          isClaimed: QuestStatus.quest4Claimed,
                          isCompleted: QuestStatus.level1BestStreak >= 3,
                          onClaim: () {
                            setState(() {
                              if (QuestStatus.canClaimQuest4()) {
                                QuestStatus.claimQuest4();
                              }
                            });
                          },
                          icon: '🔥',
                        ),

                        // ================ Q5 – Q8 : Numbers (Unlock at Level 5) ==================
                        _FunQuestItem(
                          title: 'Quest 5',
                          subtitle: 'Start "Numbers" level',
                          points: 100,
                          isClaimed: QuestStatus.quest5Claimed,
                          isCompleted: QuestStatus.isContentUnlocked(
                            QuestStatus.levelNumbers,
                          ),
                          onClaim: () {
                            setState(() {
                              if (QuestStatus.canClaimQuest5()) {
                                QuestStatus.claimQuest5();
                              }
                            });
                          },
                          icon: '🔢',
                        ),
                        _FunQuestItem(
                          title: 'Quest 6',
                          subtitle: 'Learn ALL Numbers in Learning Mode',
                          points: 120,
                          isClaimed: QuestStatus.quest6Claimed,
                          isCompleted: QuestStatus.learnedNumbersAll,
                          onClaim: () {
                            setState(() {
                              if (QuestStatus.canClaimQuest6()) {
                                QuestStatus.claimQuest6();
                              }
                            });
                          },
                          icon: '🧮',
                        ),
                        _FunQuestItem(
                          title: 'Quest 7',
                          subtitle:
                              'Complete ONE Numbers round without mistakes',
                          points: 200,
                          isClaimed: QuestStatus.quest7Claimed,
                          isCompleted: QuestStatus.numbersPerfectRounds >= 1,
                          onClaim: () {
                            setState(() {
                              if (QuestStatus.canClaimQuest7()) {
                                QuestStatus.claimQuest7();
                              }
                            });
                          },
                          icon: '⭐',
                        ),
                        _FunQuestItem(
                          title: 'Quest 8',
                          subtitle: 'Finish 3 rounds of Numbers level',
                          points: 200,
                          isClaimed: QuestStatus.quest8Claimed,
                          isCompleted: QuestStatus.numbersRoundsCompleted >= 3,
                          onClaim: () {
                            setState(() {
                              if (QuestStatus.canClaimQuest8()) {
                                QuestStatus.claimQuest8();
                              }
                            });
                          },
                          icon: '🏆',
                        ),

                        // ================= Q9 – Q12 : Colour (Unlock at Level 10) =================
                        _FunQuestItem(
                          title: 'Quest 9',
                          subtitle: 'Start "Colour" level',
                          points: 100,
                          isClaimed: QuestStatus.quest9Claimed,
                          isCompleted: QuestStatus.isContentUnlocked(
                            QuestStatus.levelColour,
                          ),
                          onClaim: () {
                            setState(() {
                              if (QuestStatus.canClaimQuest9()) {
                                QuestStatus.claimQuest9();
                              }
                            });
                          },
                          icon: '🎨',
                        ),
                        _FunQuestItem(
                          title: 'Quest 10',
                          subtitle: 'Learn ALL Colours in Learning Mode',
                          points: 120,
                          isClaimed: QuestStatus.quest10Claimed,
                          isCompleted: QuestStatus.learnedColoursAll,
                          onClaim: () {
                            setState(() {
                              if (QuestStatus.canClaimQuest10()) {
                                QuestStatus.claimQuest10();
                              }
                            });
                          },
                          icon: '🌈',
                        ),
                        _FunQuestItem(
                          title: 'Quest 11',
                          subtitle: 'Get 5 correct answers in a row (Colour)',
                          points: 150,
                          isClaimed: QuestStatus.quest11Claimed,
                          isCompleted: QuestStatus.colourBestStreak >= 5,
                          onClaim: () {
                            setState(() {
                              if (QuestStatus.canClaimQuest11()) {
                                QuestStatus.claimQuest11();
                              }
                            });
                          },
                          icon: '⚡',
                        ),
                        _FunQuestItem(
                          title: 'Quest 12',
                          subtitle: 'Finish 2 Colour rounds',
                          points: 200,
                          isClaimed: QuestStatus.quest12Claimed,
                          isCompleted: QuestStatus.colourRoundsCompleted >= 2,
                          onClaim: () {
                            setState(() {
                              if (QuestStatus.canClaimQuest12()) {
                                QuestStatus.claimQuest12();
                              }
                            });
                          },
                          icon: '✅',
                        ),

                        // ================= Q13 – Q16 : Fruits (Unlock at Level 15) ================
                        _FunQuestItem(
                          title: 'Quest 13',
                          subtitle: 'Start "Fruits" level',
                          points: 100,
                          isClaimed: QuestStatus.quest13Claimed,
                          isCompleted: QuestStatus.isContentUnlocked(
                            QuestStatus.levelGreetings,
                          ),
                          onClaim: () {
                            setState(() {
                              if (QuestStatus.canClaimQuest13()) {
                                QuestStatus.claimQuest13();
                              }
                            });
                          },
                          icon: '🍎',
                        ),
                        _FunQuestItem(
                          title: 'Quest 14',
                          subtitle: 'Learn ALL Fruits in Learning Mode',
                          points: 120,
                          isClaimed: QuestStatus.quest14Claimed,
                          isCompleted: QuestStatus.learnedFruitsAll,
                          onClaim: () {
                            setState(() {
                              if (QuestStatus.canClaimQuest14()) {
                                QuestStatus.claimQuest14();
                              }
                            });
                          },
                          icon: '🍌',
                        ),
                        _FunQuestItem(
                          title: 'Quest 15',
                          subtitle: 'Get 4 correct answers in a row (Fruits)',
                          points: 150,
                          isClaimed: QuestStatus.quest15Claimed,
                          isCompleted: QuestStatus.fruitsBestStreak >= 4,
                          onClaim: () {
                            setState(() {
                              if (QuestStatus.canClaimQuest15()) {
                                QuestStatus.claimQuest15();
                              }
                            });
                          },
                          icon: '🎯',
                        ),
                        _FunQuestItem(
                          title: 'Quest 16',
                          subtitle: 'Finish 2 Fruits rounds',
                          points: 200,
                          isClaimed: QuestStatus.quest16Claimed,
                          isCompleted: QuestStatus.fruitsRoundsCompleted >= 2,
                          onClaim: () {
                            setState(() {
                              if (QuestStatus.canClaimQuest16()) {
                                QuestStatus.claimQuest16();
                              }
                            });
                          },
                          icon: '🏁',
                        ),

                        // ================= Q17 – Q20 : Animals (Unlock at Level 25) ===============
                        _FunQuestItem(
                          title: 'Quest 17',
                          subtitle: 'Start "Animals" level',
                          points: 100,
                          isClaimed: QuestStatus.quest17Claimed,
                          isCompleted: QuestStatus.isContentUnlocked(
                            QuestStatus.levelCommonVerb,
                          ),
                          onClaim: () {
                            setState(() {
                              if (QuestStatus.canClaimQuest17()) {
                                QuestStatus.claimQuest17();
                              }
                            });
                          },
                          icon: '🐯',
                        ),
                        _FunQuestItem(
                          title: 'Quest 18',
                          subtitle: 'Learn ALL Animals in Learning Mode',
                          points: 120,
                          isClaimed: QuestStatus.quest18Claimed,
                          isCompleted: QuestStatus.learnedAnimalsAll,
                          onClaim: () {
                            setState(() {
                              if (QuestStatus.canClaimQuest18()) {
                                QuestStatus.claimQuest18();
                              }
                            });
                          },
                          icon: '🐘',
                        ),
                        _FunQuestItem(
                          title: 'Quest 19',
                          subtitle: 'Finish 3 Animals rounds',
                          points: 150,
                          isClaimed: QuestStatus.quest19Claimed,
                          isCompleted: QuestStatus.animalsRoundsCompleted >= 3,
                          onClaim: () {
                            setState(() {
                              if (QuestStatus.canClaimQuest19()) {
                                QuestStatus.claimQuest19();
                              }
                            });
                          },
                          icon: '🎪',
                        ),
                        _FunQuestItem(
                          title: 'Quest 20',
                          subtitle:
                              'Complete ONE Animals round without mistakes',
                          points: 200,
                          isClaimed: QuestStatus.quest20Claimed,
                          isCompleted: QuestStatus.animalsPerfectRounds >= 1,
                          onClaim: () {
                            setState(() {
                              if (QuestStatus.canClaimQuest20()) {
                                QuestStatus.claimQuest20();
                              }
                            });
                          },
                          icon: '👑',
                        ),

                        // ================= Q21 – Q24 : Simple Global Milestones ====================
                        _FunQuestItem(
                          title: 'Quest 21',
                          subtitle: 'Open 3 chests',
                          points: 150,
                          isClaimed: QuestStatus.quest21Claimed,
                          isCompleted: QuestStatus.chestsOpened >= 3,
                          onClaim: () {
                            setState(() {
                              if (QuestStatus.canClaimQuest21()) {
                                QuestStatus.claimQuest21();
                              }
                            });
                          },
                          icon: '🎁',
                        ),
                        _FunQuestItem(
                          title: 'Quest 22',
                          subtitle: 'Reach Level 10',
                          points: 150,
                          isClaimed: QuestStatus.quest22Claimed,
                          isCompleted: QuestStatus.level >= 10,
                          onClaim: () {
                            setState(() {
                              if (QuestStatus.canClaimQuest22()) {
                                QuestStatus.claimQuest22();
                              }
                            });
                          },
                          icon: '📈',
                        ),
                        _FunQuestItem(
                          title: 'Quest 23',
                          subtitle: 'Unlock all categories',
                          points: 200,
                          isClaimed: QuestStatus.quest23Claimed,
                          isCompleted:
                              QuestStatus.isContentUnlocked(
                                QuestStatus.levelNumbers,
                              ) &&
                              QuestStatus.isContentUnlocked(
                                QuestStatus.levelColour,
                              ) &&
                              QuestStatus.isContentUnlocked(
                                QuestStatus.levelGreetings,
                              ) &&
                              QuestStatus.isContentUnlocked(
                                QuestStatus.levelCommonVerb,
                              ),
                          onClaim: () {
                            setState(() {
                              if (QuestStatus.canClaimQuest23()) {
                                QuestStatus.claimQuest23();
                              }
                            });
                          },
                          icon: '🔓',
                        ),
                        _FunQuestItem(
                          title: 'Quest 24',
                          subtitle: 'Reach Level 25',
                          points: 300,
                          isClaimed: QuestStatus.quest24Claimed,
                          isCompleted: QuestStatus.level >= 25,
                          onClaim: () {
                            setState(() {
                              if (QuestStatus.canClaimQuest24()) {
                                QuestStatus.claimQuest24();
                              }
                            });
                          },
                          icon: '🏅',
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: _buildFunNavBar(),
    );
  }

  // Fun bottom navigation bar with playful design
  Widget _buildFunNavBar() {
    final navItems = [
      {
        'label': 'Home',
        'icon': Icons.home_outlined,
        'activeIcon': Icons.home_rounded,
        'color': const Color(0xFF2563EB),
        'emoji': '🏠',
      },
      {
        'label': 'Quest',
        'icon': Icons.menu_book_outlined,
        'activeIcon': Icons.menu_book_rounded,
        'color': const Color(0xFF22C55E),
        'emoji': '📚',
      },
      {
        'label': 'Ranking',
        'icon': Icons.leaderboard_outlined,
        'activeIcon': Icons.leaderboard,
        'color': const Color(0xFF63539C),
        'emoji': '🏆',
      },
      {
        'label': 'Profile',
        'icon': Icons.person_outline_rounded,
        'activeIcon': Icons.person_rounded,
        'color': const Color(0xFFF59E0B),
        'emoji': '�',
      },
    ];

    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        child: Container(
          height: 67,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(25),
            color: const Color(0xFF6ac5e6),
            boxShadow: [
              BoxShadow(
                color: Color(0xFF6ac5e6).withOpacity(0.4),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Row(
            children: List.generate(navItems.length, (i) {
              final active = i == _selectedIndex;
              final color = active
                  ? Colors.white
                  : Colors.white.withOpacity(0.7);
              final emoji = navItems[i]['emoji'] as String;

              return Expanded(
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(20),
                    onTap: () => _onItemTapped(i),
                    child: Container(
                      decoration: active
                          ? BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  Colors.white.withOpacity(0.2),
                                  Colors.white.withOpacity(0.1),
                                ],
                              ),
                              borderRadius: BorderRadius.circular(20),
                            )
                          : null,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(emoji, style: const TextStyle(fontSize: 20)),
                          const SizedBox(height: 4),
                          Text(
                            navItems[i]['label'] as String,
                            style: TextStyle(
                              color: color,
                              fontWeight: active
                                  ? FontWeight.w800
                                  : FontWeight.w600,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }

  // Fun animated XP toast
  void _showXpToast({required int xp, required int leveledUp}) {
    final overlay = Overlay.of(context);
    final entry = OverlayEntry(
      builder: (_) => Positioned(
        top: 80,
        right: 16,
        child: _FunSlideInToast(
          bgColor: const Color(0xFFFF6B6B),
          icon: Icons.auto_awesome,
          iconColor: Colors.yellow,
          title: "XP +$xp!",
          subtitle: leveledUp > 0
              ? "🎉 Level Up! (+$leveledUp)"
              : "🌟 Great job!",
        ),
      ),
    );
    overlay.insert(entry);
    Future.delayed(const Duration(seconds: 3), () => entry.remove());
  }
}

class _FunQuestItem extends StatelessWidget {
  final String title;
  final String subtitle;
  final int points;
  final bool isCompleted;
  final bool isClaimed;
  final VoidCallback onClaim;
  final String icon;

  const _FunQuestItem({
    required this.title,
    required this.subtitle,
    required this.points,
    required this.isCompleted,
    required this.isClaimed,
    required this.onClaim,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final canClaim = isCompleted && !isClaimed;
    Color backgroundColor;
    Color borderColor;
    String statusEmoji = '⏳';

    if (isClaimed) {
      backgroundColor = const Color(0xFFC8F7DC);
      borderColor = const Color(0xFF22C55E);
      statusEmoji = '✅';
    } else if (canClaim) {
      backgroundColor = const Color(0xFFFFF2C8);
      borderColor = const Color(0xFFFFD700);
      statusEmoji = '🎁';
    } else {
      backgroundColor = Colors.grey.shade100;
      borderColor = Colors.grey.shade400;
      statusEmoji = '🔒';
    }

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 12.0),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: borderColor, width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        // Use a bit more vertical padding to give trailing widgets room
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            border: Border.all(color: borderColor),
          ),
          child: Center(
            child: Text(icon, style: const TextStyle(fontSize: 16)),
          ),
        ),
        title: Row(
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800),
            ),
            const SizedBox(width: 6),
            Text(statusEmoji),
          ],
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
        ),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(
            color: canClaim ? const Color(0xFFFF6B6B) : Colors.grey,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '$points',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(width: 2),
                  const Icon(Icons.key, color: Colors.yellow, size: 12),
                ],
              ),
              const SizedBox(height: 2),
              ElevatedButton(
                onPressed: canClaim ? onClaim : null,
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(56, 22),
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  backgroundColor: canClaim
                      ? const Color(0xFF4CAF50)
                      : Colors.grey.shade400,
                  foregroundColor: Colors.white,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: Text(
                  isClaimed ? 'DONE' : 'CLAIM',
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Fun slide-in toast widget
class _FunSlideInToast extends StatefulWidget {
  final Color bgColor;
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;

  const _FunSlideInToast({
    required this.bgColor,
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
  });

  @override
  State<_FunSlideInToast> createState() => _FunSlideInToastState();
}

class _FunSlideInToastState extends State<_FunSlideInToast>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<Offset> _slide;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    )..forward();
    _slide = Tween<Offset>(
      begin: const Offset(1.5, 0),
      end: Offset.zero,
    ).chain(CurveTween(curve: Curves.elasticOut)).animate(_ctrl);

    _scale = Tween<double>(
      begin: 0.5,
      end: 1.0,
    ).chain(CurveTween(curve: Curves.elasticOut)).animate(_ctrl);
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
      child: ScaleTransition(
        scale: _scale,
        child: Material(
          color: Colors.transparent,
          child: Container(
            width: 280,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [widget.bgColor, widget.bgColor.withOpacity(0.8)],
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: widget.bgColor.withOpacity(0.5),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(widget.icon, color: widget.iconColor, size: 28),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w900,
                          fontSize: 16,
                          fontFamily: 'Comic',
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        widget.subtitle,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
