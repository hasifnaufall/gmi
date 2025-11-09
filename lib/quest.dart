// quest.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import 'leaderboard.dart';
import 'quiz_category.dart';
import 'profile.dart';
import 'quest_status.dart';
import 'user_progress_service.dart';
import 'theme_manager.dart';

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
    if (QuestStatus.quest25Claimed) count++;
    if (QuestStatus.quest26Claimed) count++;
    if (QuestStatus.quest27Claimed) count++;
    if (QuestStatus.quest28Claimed) count++;
    return count;
  }

  Widget _buildStatCard({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: EdgeInsets.all(14),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Theme.of(context).brightness == Brightness.dark
                ? Color(0xFF1C1C1E)
                : Colors.white,
            Theme.of(context).brightness == Brightness.dark
                ? Color(0xFF2C2C2E)
                : Colors.white.withOpacity(0.9),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.3), width: 2),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.1),
            blurRadius: 8,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 22),
          ),
          SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: GoogleFonts.montserrat(
                  color: Theme.of(context).brightness == Brightness.dark
                      ? Color(0xFFF8F8F8)
                      : Color(0xFF2D5263),
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                value,
                style: GoogleFonts.montserrat(
                  color: Theme.of(context).brightness == Brightness.dark
                      ? Color(0xFFFFE5E5)
                      : color,
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
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
    return Consumer<ThemeManager>(
      builder: (context, themeManager, child) {
        if (_isLoading) {
          return Scaffold(
            body: Container(
              decoration: BoxDecoration(color: themeManager.backgroundColor),
              child: Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(
                    themeManager.primary,
                  ),
                ),
              ),
            ),
          );
        }

        return _buildQuestScreen(context, themeManager);
      },
    );
  }

  Widget _buildQuestScreen(BuildContext context, ThemeManager themeManager) {
    final bool chestEnabled = _isChestUnlocked;

    // Lightweight refresh (no auto-claim inside)
    // QuestStatus.ensureUnlocksLoaded(); // Commented out - was being called on every build

    return Container(
      decoration: BoxDecoration(color: themeManager.backgroundColor),
      child: SafeArea(
        child: Scaffold(
          backgroundColor: Colors.transparent,
          body: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Modern Header with Stats
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Quest Board Title
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Quest Board',
                          style: GoogleFonts.montserrat(
                            fontSize: 28,
                            fontWeight: FontWeight.w700,
                            color: themeManager.isDarkMode
                                ? Color(0xFFFFE5E5)
                                : themeManager.primary,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Complete missions & earn rewards',
                          style: GoogleFonts.montserrat(
                            fontSize: 13,
                            color: themeManager.isDarkMode
                                ? Color(0xFFF8F8F8)
                                : Color(0xFF2D5263),
                          ),
                        ),
                      ],
                    ),
                    // Keys counter
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: themeManager.isDarkMode
                              ? [Color(0xFF636366), Color(0xFF8E8E93)]
                              : [Color(0xFFF5E6C8), Color(0xFFF0DDB8)],
                        ),
                        borderRadius: BorderRadius.circular(25),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.vpn_key,
                            color: themeManager.isDarkMode
                                ? Color(0xFFE8E8E8)
                                : Color(0xFF8B6914),
                            size: 20,
                          ),
                          SizedBox(width: 8),
                          Text(
                            '${QuestStatus.userPoints}',
                            style: TextStyle(
                              color: themeManager.isDarkMode
                                  ? Color(0xFFE8E8E8)
                                  : Color(0xFF8B6914),
                              fontWeight: FontWeight.w700,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 24),

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
                        value: '${_getCompletedQuestCount()}/28',
                        color: themeManager.isDarkMode
                            ? Color(0xFFD23232)
                            : Color(0xFF2D5263),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                // Chest Card - Redesigned with matching theme
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: themeManager.isDarkMode
                          ? [Color(0xFF2C2C2E), Color(0xFF1C1C1E)]
                          : [Color(0xFFF5E6C8), Color(0xFFF0DDB8)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: themeManager.isDarkMode
                            ? Color(0xFFD23232).withOpacity(0.10)
                            : Color(0xFF8E8E93).withOpacity(0.10),
                        blurRadius: 15,
                        offset: Offset(0, 5),
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
                                  ? const Color(0xFFFFEB99) // Darker yellow
                                  : Color(0xFF6B5D42).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Icon(
                              chestEnabled
                                  ? Icons.card_giftcard
                                  : Icons.lock_outline,
                              size: 32,
                              color: chestEnabled
                                  ? const Color(0xFF8B6914) // Darker brown
                                  : Color(0xFF6B5D42),
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
                                  style: GoogleFonts.montserrat(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w700,
                                    color: themeManager.isDarkMode
                                        ? Color(0xFFFFE5E5)
                                        : Color(0xFF2D5263),
                                  ),
                                ),
                                SizedBox(height: 4),
                                Text(
                                  chestEnabled
                                      ? 'Claim your rewards now'
                                      : 'Complete quests to unlock',
                                  style: GoogleFonts.montserrat(
                                    fontSize: 13,
                                    color: themeManager.isDarkMode
                                        ? Color(0xFFF8F8F8)
                                        : Color(0xFF2D5263),
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
                        height: 10,
                        decoration: BoxDecoration(
                          color: themeManager.isDarkMode
                              ? Color(0xFF2C2C2E)
                              : Colors.white.withOpacity(0.5),
                          borderRadius: BorderRadius.circular(5),
                        ),
                        child: LayoutBuilder(
                          builder: (context, constraints) {
                            return AnimatedContainer(
                              duration: Duration(milliseconds: 500),
                              width: constraints.maxWidth * _targetProgress,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: chestEnabled
                                      ? [Color(0xFFD23232), Color(0xFF8E8E93)]
                                      : [Color(0xFF636366), Color(0xFF1C1C1E)],
                                ),
                                borderRadius: BorderRadius.circular(5),
                              ),
                            );
                          },
                        ),
                      ),
                      SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: chestEnabled ? _openChest : null,
                          style: ElevatedButton.styleFrom(
                            padding: EdgeInsets.symmetric(vertical: 16),
                            backgroundColor: chestEnabled
                                ? Color(0xFFD23232)
                                : Color(0xFF636366).withOpacity(0.3),
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          child: Text(
                            chestEnabled ? '✨ Open Chest' : '🔒 Locked',
                            style: GoogleFonts.montserrat(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 24),

                // Quests Header
                Text(
                  'Available Quests',
                  style: GoogleFonts.montserrat(
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    color: themeManager.isDarkMode
                        ? Color(0xFFFFE5E5)
                        : Color(0xFF2D5263),
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  '${_getCompletedQuestCount()} of 28 completed',
                  style: GoogleFonts.montserrat(
                    fontSize: 14,
                    color: themeManager.isDarkMode
                        ? Color(0xFFF8F8F8)
                        : Color(0xFF2D5263).withOpacity(0.7),
                  ),
                ),

                const SizedBox(height: 14),

                // Quests List
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Color(0xFF0891B2).withOpacity(0.1),
                        blurRadius: 15,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: Column(
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
                              ) &&
                              QuestStatus.isContentUnlocked(
                                QuestStatus.levelVerbs,
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

                        // ================= Q25 – Q28 : Verbs (Unlock at Level 30) =================
                        _FunQuestItem(
                          title: 'Quest 25',
                          subtitle: 'Start "Verbs" level',
                          points: 100,
                          isClaimed: QuestStatus.quest25Claimed,
                          isCompleted: QuestStatus.isContentUnlocked(
                            QuestStatus.levelVerbs,
                          ),
                          onClaim: () {
                            setState(() {
                              if (QuestStatus.canClaimQuest25()) {
                                QuestStatus.claimQuest25();
                              }
                            });
                          },
                          icon: '🏃',
                        ),
                        _FunQuestItem(
                          title: 'Quest 26',
                          subtitle: 'Learn ALL Verbs in Learning Mode',
                          points: 120,
                          isClaimed: QuestStatus.quest26Claimed,
                          isCompleted: QuestStatus.learnedVerbsAll,
                          onClaim: () {
                            setState(() {
                              if (QuestStatus.canClaimQuest26()) {
                                QuestStatus.claimQuest26();
                              }
                            });
                          },
                          icon: '💪',
                        ),
                        _FunQuestItem(
                          title: 'Quest 27',
                          subtitle: 'Finish 2 Verbs rounds',
                          points: 150,
                          isClaimed: QuestStatus.quest27Claimed,
                          isCompleted: QuestStatus.verbsRoundsCompleted >= 2,
                          onClaim: () {
                            setState(() {
                              if (QuestStatus.canClaimQuest27()) {
                                QuestStatus.claimQuest27();
                              }
                            });
                          },
                          icon: '🎬',
                        ),
                        _FunQuestItem(
                          title: 'Quest 28',
                          subtitle: 'Complete ONE Verbs round without mistakes',
                          points: 200,
                          isClaimed: QuestStatus.quest28Claimed,
                          isCompleted: QuestStatus.verbsPerfectRounds >= 1,
                          onClaim: () {
                            setState(() {
                              if (QuestStatus.canClaimQuest28()) {
                                QuestStatus.claimQuest28();
                              }
                            });
                          },
                          icon: '🌟',
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          bottomNavigationBar: _buildFunNavBar(themeManager),
        ),
      ),
    );
  }

  // Navigation bar matching quiz_category and leaderboard theme
  Widget _buildFunNavBar(ThemeManager themeManager) {
    return Container(
      decoration: BoxDecoration(
        color: themeManager.isDarkMode ? Color(0xFF000000) : Colors.white,
        border: Border.all(
          color: themeManager.primary.withOpacity(0.3),
          width: 1.5,
        ),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
        boxShadow: [
          BoxShadow(
            color: themeManager.primary.withOpacity(0.15),
            blurRadius: 20,
            offset: Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(
                emoji: '🏠',
                label: 'Home',
                isSelected: _selectedIndex == 0,
                onTap: () => _onItemTapped(0),
                themeManager: themeManager,
              ),
              _buildNavItem(
                emoji: '📚',
                label: 'Quest',
                isSelected: _selectedIndex == 1,
                onTap: () => _onItemTapped(1),
                themeManager: themeManager,
              ),
              _buildNavItem(
                emoji: '🏆',
                label: 'Ranking',
                isSelected: _selectedIndex == 2,
                onTap: () => _onItemTapped(2),
                themeManager: themeManager,
              ),
              _buildNavItem(
                emoji: '👤',
                label: 'Profile',
                isSelected: _selectedIndex == 3,
                onTap: () => _onItemTapped(3),
                themeManager: themeManager,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required String emoji,
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
    required ThemeManager themeManager,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: isSelected
                ? (themeManager.isDarkMode
                      ? Color(0xFFD23232).withOpacity(0.15)
                      : Color(0xFF0891B2).withOpacity(0.1))
                : Colors.transparent,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(emoji, style: TextStyle(fontSize: isSelected ? 28 : 24)),
              SizedBox(height: 4),
              Text(
                label,
                style: GoogleFonts.montserrat(
                  fontSize: 11,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                  color: isSelected
                      ? (themeManager.isDarkMode
                            ? Color(0xFFD23232)
                            : Color(0xFF0891B2))
                      : (themeManager.isDarkMode
                            ? Color(0xFF8E8E93)
                            : Color(0xFF2D5263).withOpacity(0.6)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Animated XP toast matching theme
  void _showXpToast({required int xp, required int leveledUp}) {
    final overlay = Overlay.of(context);
    final entry = OverlayEntry(
      builder: (_) => Positioned(
        top: 80,
        right: 16,
        child: _FunSlideInToast(
          bgColor: const Color(0xFF0891B2), // Darker cyan matching theme
          icon: Icons.auto_awesome,
          iconColor: Color(0xFFFFEB99), // Darker yellow
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
      backgroundColor = const Color(0xFFD1FAE5); // Light green
      borderColor = const Color(0xFF10B981); // Green
      statusEmoji = '✅';
    } else if (canClaim) {
      backgroundColor = const Color(0xFFFFEB99); // Darker yellow matching theme
      borderColor = const Color(0xFF8B6914); // Darker brown matching theme
      statusEmoji = '🎁';
    } else {
      backgroundColor = Colors.grey.shade100;
      borderColor = Color(0xFF6B5D42); // Darker brown for locked
      statusEmoji = '🔒';
    }

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6.0, horizontal: 12.0),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor, width: 2),
        boxShadow: [
          BoxShadow(
            color: borderColor.withOpacity(0.15),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        leading: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            border: Border.all(color: borderColor, width: 2),
          ),
          child: Center(
            child: Text(icon, style: const TextStyle(fontSize: 18)),
          ),
        ),
        title: Row(
          children: [
            Text(
              title,
              style: GoogleFonts.montserrat(
                fontSize: 14,
                fontWeight: FontWeight.w800,
                color: Color(0xFF2D5263),
              ),
            ),
            const SizedBox(width: 4),
            Text(statusEmoji, style: TextStyle(fontSize: 12)),
          ],
        ),
        subtitle: Text(
          subtitle,
          style: GoogleFonts.montserrat(
            fontSize: 12,
            color: Color(0xFF2D5263).withOpacity(0.8),
          ),
        ),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
          decoration: BoxDecoration(
            color: canClaim
                ? Color(0xFF0891B2) // Darker cyan for claimable
                : isClaimed
                ? Color(0xFF10B981) // Green for claimed
                : Color(0xFF6B5D42).withOpacity(0.5), // Brown for locked
            borderRadius: BorderRadius.circular(10),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '$points',
                    style: GoogleFonts.montserrat(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(width: 2),
                  const Icon(Icons.vpn_key, color: Color(0xFFFFEB99), size: 12),
                ],
              ),
              const SizedBox(height: 3),
              SizedBox(
                height: 22,
                child: ElevatedButton(
                  onPressed: canClaim ? onClaim : null,
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(60, 22),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 0,
                    ),
                    backgroundColor: isClaimed
                        ? const Color(0xFF7C7FCC) // Purple/periwinkle for DONE
                        : canClaim
                        ? const Color(0xFFFFEB99) // Yellow for CLAIM
                        : Colors.grey.shade400, // Grey for locked
                    foregroundColor: isClaimed
                        ? Colors.white
                        : canClaim
                        ? Color(0xFF2D5263)
                        : Colors.white,
                    elevation: 0,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                  child: Text(
                    isClaimed ? 'DONE' : 'CLAIM',
                    style: GoogleFonts.montserrat(
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                    ),
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
                        style: GoogleFonts.montserrat(
                          color: Colors.white,
                          fontWeight: FontWeight.w900,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        widget.subtitle,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.montserrat(
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
