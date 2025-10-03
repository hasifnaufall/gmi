import 'package:flutter/material.dart';

import 'profile.dart';
import 'quest.dart';
import 'quest_status.dart';

// Learn + Quiz screens
import 'alphabet_learn.dart';
import 'alphabet_q.dart';

import 'number_learn.dart';
import 'number_q.dart';

import 'colour_learn.dart';
import 'colour_q.dart';

import 'fruits_learn.dart';
import 'fruits_q.dart';

import 'animals_learn.dart';
import 'animals_q.dart';

class QuizCategoryScreen extends StatefulWidget {
  const QuizCategoryScreen({super.key});

  @override
  _QuizCategoryScreenState createState() => _QuizCategoryScreenState();
}

class _QuizCategoryScreenState extends State<QuizCategoryScreen> {
  static const bool kUnlocksDisabled = false;

  int _selectedIndex = 0;
  bool _loadingUnlocks = true;

  @override
  void initState() {
    super.initState();
    _loadUnlocks();
  }

  Future<void> _loadUnlocks() async {
    await QuestStatus.ensureUnlocksLoaded();
    if (!mounted) return;
    setState(() => _loadingUnlocks = false);
  }

  void _onItemTapped(int index) {
    if (index == _selectedIndex) return;
    setState(() => _selectedIndex = index);

    switch (index) {
      case 0:
        break;
      case 1:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const QuestScreen()),
        );
        break;
      case 2:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const ProfileScreen()),
        );
        break;
    }
  }

  // ✅✅ NEW: Mark Quest 1 progress when Alphabet is clicked (no auto-claim)
  void _triggerQuest1() {
    if (QuestStatus.completedQuestions == 0 && !QuestStatus.quest1Claimed) {
      if (QuestStatus.level1Answers.isEmpty || QuestStatus.level1Answers.every((e) => e == null)) {
        QuestStatus.ensureLevel1Length(1);
        QuestStatus.level1Answers[0] = true;
      }
      // Quest 1 is now claimable, but user must claim it manually from Quest screen
    }
  }

  void _openLevelChoice({
    required String title,
    required VoidCallback onLearn,
    required VoidCallback onQuiz,
  }) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                height: 4,
                width: 40,
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: Colors.black26,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Text(title,
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pop(context);
                        onLearn();
                      },
                      icon: const Icon(Icons.school),
                      label: const Text("Learn"),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        backgroundColor: const Color(0xFF22D3EE),
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pop(context);
                        onQuiz();
                      },
                      icon: const Icon(Icons.quiz),
                      label: const Text("Quiz"),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        backgroundColor: const Color(0xFF60A5FA),
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showUnlockDialog({
    required String title,
    required VoidCallback onConfirm,
  }) {
    final cost = QuestStatus.unlockCost;
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text("Unlock $title?"),
        content: Text("Spend $cost keys to unlock this level."),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              onConfirm();
            },
            child: const Text("Unlock"),
          ),
        ],
      ),
    );
  }

  Future<void> _handleOpenOrUnlock({
    required String key,
    required String title,
    required Future<void> Function() onOpen,
  }) async {
    if (kUnlocksDisabled) {
      await onOpen();
      return;
    }

    if (key == QuestStatus.levelAlphabet || QuestStatus.isContentUnlocked(key)) {
      await onOpen();
      return;
    }

    final requiredLevel = QuestStatus.requiredLevelFor(key);

    if (QuestStatus.level < requiredLevel) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Reach Level $requiredLevel to unlock $title')),
      );
      return;
    }

    if (QuestStatus.userPoints < QuestStatus.unlockCost) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('You need ${QuestStatus.unlockCost} keys to unlock $title')),
      );
      return;
    }

    _showUnlockDialog(
      title: title,
      onConfirm: () async {
        final result = await QuestStatus.attemptUnlock(key);
        if (!mounted) return;

        switch (result) {
          case UnlockStatus.success:
            setState(() {});
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('$title unlocked!')),
            );
            await onOpen();
            break;
          case UnlockStatus.alreadyUnlocked:
            await onOpen();
            break;
          case UnlockStatus.needLevel:
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Reach Level $requiredLevel to unlock $title')),
            );
            break;
          case UnlockStatus.needKeys:
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('You need ${QuestStatus.unlockCost} keys to unlock $title')),
            );
            break;
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final points = QuestStatus.userPoints;
    final streak = QuestStatus.streakDays;

    if (_loadingUnlocks) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final isNumbersUnlocked =
        kUnlocksDisabled || QuestStatus.isContentUnlocked(QuestStatus.levelNumbers);
    final isColourUnlocked =
        kUnlocksDisabled || QuestStatus.isContentUnlocked(QuestStatus.levelColour);
    final isFruitsUnlocked =
        kUnlocksDisabled || QuestStatus.isContentUnlocked(QuestStatus.levelGreetings);
    final isAnimalsUnlocked =
        kUnlocksDisabled || QuestStatus.isContentUnlocked(QuestStatus.levelCommonVerb);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(80),
        child: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          automaticallyImplyLeading: false,
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
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                  ]),
                  Row(children: [
                    const Icon(Icons.local_fire_department, color: Colors.red, size: 24),
                    const SizedBox(width: 6),
                    Text('$streak',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                  ]),
                ],
              ),
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          const Text(
            "WaveAct",
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              fontFamily: 'Cursive',
            ),
          ),
          const SizedBox(height: 20),

          // ✅✅ Alphabet (Quest 1 triggers here)
          buildCategoryTile(
            context,
            "ALPHABET",
            Icons.abc,
            Colors.lightBlue.shade200,
            true,
            onTap: () {
              // Trigger Quest 1 immediately when Alphabet is clicked
              _triggerQuest1();

              _openLevelChoice(
                title: "Alphabet",
                onLearn: () async {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const AlphabetLearnScreen()),
                  );
                },
                onQuiz: () async {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const AlphabetQuizScreen()),
                  );
                  if (!mounted) return;
                  setState(() {});
                },
              );
            },
          ),

          // Numbers
          buildCategoryTile(
            context,
            "NUMBER",
            Icons.looks_3,
            isNumbersUnlocked ? Colors.lightBlue.shade200 : Colors.grey.shade300,
            isNumbersUnlocked,
            onTap: () {
              _handleOpenOrUnlock(
                key: QuestStatus.levelNumbers,
                title: "Numbers",
                onOpen: () async {
                  _openLevelChoice(
                    title: "Numbers",
                    onLearn: () async {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const NumberLearnScreen()),
                      );
                    },
                    onQuiz: () async {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const NumberQuizScreen()),
                      );
                      if (!mounted) return;
                      setState(() {});
                    },
                  );
                },
              );
            },
          ),

          // Colour
          buildCategoryTile(
            context,
            "COLOUR",
            Icons.palette,
            isColourUnlocked ? Colors.lightBlue.shade200 : Colors.grey.shade300,
            isColourUnlocked,
            onTap: () {
              _handleOpenOrUnlock(
                key: QuestStatus.levelColour,
                title: "Colour",
                onOpen: () async {
                  _openLevelChoice(
                    title: "Colour",
                    onLearn: () async {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const ColourLearnScreen()),
                      );
                    },
                    onQuiz: () async {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const ColourQuizScreen()),
                      );
                      if (!mounted) return;
                      setState(() {});
                    },
                  );
                },
              );
            },
          ),

          // Fruits
          buildCategoryTile(
            context,
            "FRUITS",
            Icons.local_grocery_store,
            isFruitsUnlocked ? Colors.lightBlue.shade200 : Colors.grey.shade300,
            isFruitsUnlocked,
            onTap: () {
              _handleOpenOrUnlock(
                key: QuestStatus.levelGreetings,
                title: "Fruits",
                onOpen: () async {
                  _openLevelChoice(
                    title: "Fruits",
                    onLearn: () async {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const FruitsLearnScreen()),
                      );
                    },
                    onQuiz: () async {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const FruitsQuizScreen()),
                      );
                      if (!mounted) return;
                      setState(() {});
                    },
                  );
                },
              );
            },
          ),

          // Animals
          buildCategoryTile(
            context,
            "ANIMALS",
            Icons.pets,
            isAnimalsUnlocked ? Colors.lightBlue.shade200 : Colors.grey.shade300,
            isAnimalsUnlocked,
            onTap: () {
              _handleOpenOrUnlock(
                key: QuestStatus.levelCommonVerb,
                title: "Animals",
                onOpen: () async {
                  _openLevelChoice(
                    title: "Animals",
                    onLearn: () async {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const AnimalsLearnScreen()),
                      );
                    },
                    onQuiz: () async {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const AnimalQuizScreen()),
                      );
                      if (!mounted) return;
                      setState(() {});
                    },
                  );
                },
              );
            },
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

  Widget buildCategoryTile(
      BuildContext context,
      String title,
      IconData icon,
      Color color,
      bool unlocked, {
        VoidCallback? onTap,
      }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Text(
              title,
              style: TextStyle(
                color: unlocked ? Colors.black : Colors.black45,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Spacer(),
            Icon(
              icon,
              size: 30,
              color: unlocked ? Colors.black : Colors.black45,
            ),
          ],
        ),
      ),
    );
  }
}