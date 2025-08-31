import 'package:flutter/material.dart';
import 'profile.dart';
import 'quest.dart';
import 'number_q.dart';
import 'alphabet_q.dart';
import 'quest_status.dart';

class QuizCategoryScreen extends StatefulWidget {
  @override
  _QuizCategoryScreenState createState() => _QuizCategoryScreenState();
}

class _QuizCategoryScreenState extends State<QuizCategoryScreen> {
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

  void _showUnlockDialog({
    required String title,
    required VoidCallback onConfirm,
  }) {
    final cost = QuestStatus.unlockCost;
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text("Unlock $title?"),
        content: Text("Spend $cost keys to unlock this level permanently."),
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
    required VoidCallback onOpen,
  }) async {
    // Alphabet always open
    if (key == QuestStatus.levelAlphabet || QuestStatus.isContentUnlocked(key)) {
      onOpen();
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

    // Confirm unlock
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
            onOpen();
            break;
          case UnlockStatus.alreadyUnlocked:
            onOpen();
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

    final isNumbersUnlocked    = QuestStatus.isContentUnlocked(QuestStatus.levelNumbers);
    final isGreetingsUnlocked  = QuestStatus.isContentUnlocked(QuestStatus.levelGreetings);
    final isColourUnlocked     = QuestStatus.isContentUnlocked(QuestStatus.levelColour);
    final isCommonVerbUnlocked = QuestStatus.isContentUnlocked(QuestStatus.levelCommonVerb);

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
                    Text(
                      '$points',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                    ),
                  ]),
                  Row(children: [
                    const Icon(Icons.local_fire_department, color: Colors.red, size: 24),
                    const SizedBox(width: 6),
                    Text(
                      '$streak',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                    ),
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

          // Alphabet
          buildCategoryTile(
            context,
            "ALPHABET",
            Icons.abc,
            Colors.lightBlue.shade200,
            true,
            onTap: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AlphabetQuizScreen()),
              );
              if (!mounted) return;
              setState(() {});
            },
          ),

          // Numbers (Level 5 + 200 keys)
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
                  await Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const NumberQuizScreen()),
                  );
                  if (!mounted) return;
                  setState(() {}); // refresh after returning
                },
              );
            },
          ),

          // Greetings (Level 10 + 200 keys)
          buildCategoryTile(
            context,
            "GREETINGS",
            Icons.person,
            isGreetingsUnlocked ? Colors.lightBlue.shade200 : Colors.grey.shade300,
            isGreetingsUnlocked,
            onTap: () {
              _handleOpenOrUnlock(
                key: QuestStatus.levelGreetings,
                title: "Greetings",
                onOpen: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Opening Greetings... (WIP)')),
                  );
                },
              );
            },
          ),

          // Colour (Level 15 + 200 keys)
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
                onOpen: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Opening Colour... (WIP)')),
                  );
                },
              );
            },
          ),

          // Common Verbs (Level 25 + 200 keys)
          buildCategoryTile(
            context,
            "COMMON VERBS",
            Icons.flash_on,
            isCommonVerbUnlocked ? Colors.lightBlue.shade200 : Colors.grey.shade300,
            isCommonVerbUnlocked,
            onTap: () {
              _handleOpenOrUnlock(
                key: QuestStatus.levelCommonVerb,
                title: "Common Verbs",
                onOpen: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Opening Common Verbs... (WIP)')),
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
