import 'package:flutter/material.dart';
import 'profile.dart';
import 'quest.dart';
import 'number_q.dart';
import 'alphabet_q.dart';
import 'quest_status.dart';
import 'alphabet_learn.dart';

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

  // 🔽 Bottom sheet for Learn / Quiz choice
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
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.w800)),
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () { Navigator.pop(context); onLearn(); },
                      icon: const Icon(Icons.school),
                      label: const Text("Learn"),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        backgroundColor: const Color(0xFF22D3EE),
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () { Navigator.pop(context); onQuiz(); },
                      icon: const Icon(Icons.quiz),
                      label: const Text("Quiz"),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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

  @override
  Widget build(BuildContext context) {
    final points = QuestStatus.userPoints;
    final streak = QuestStatus.streakDays;

    if (_loadingUnlocks) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final isNumbersUnlocked = QuestStatus.isContentUnlocked(QuestStatus.levelNumbers);
    final isGreetingsUnlocked = QuestStatus.isContentUnlocked(QuestStatus.levelGreetings);
    final isColourUnlocked = QuestStatus.isContentUnlocked(QuestStatus.levelColour);
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

          buildCategoryTile(
            context,
            "ALPHABET",
            Icons.abc,
            Colors.lightBlue.shade200,
            true,
            onTap: () {
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

          // 🔽 Numbers
          buildCategoryTile(
            context,
            "NUMBER",
            Icons.looks_3,
            isNumbersUnlocked ? Colors.lightBlue.shade200 : Colors.grey.shade300,
            isNumbersUnlocked,
            onTap: () {
              // For now, only Quiz
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const NumberQuizScreen()),
              );
            },
          ),

          // 🔽 Colour
          buildCategoryTile(
            context,
            "COLOUR",
            Icons.palette,
            isColourUnlocked ? Colors.lightBlue.shade200 : Colors.grey.shade300,
            isColourUnlocked,
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Learn/Quiz for Colour coming soon')),
              );
            },
          ),

          // 🔽 Greetings
          buildCategoryTile(
            context,
            "GREETINGS",
            Icons.person,
            isGreetingsUnlocked ? Colors.lightBlue.shade200 : Colors.grey.shade300,
            isGreetingsUnlocked,
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Learn/Quiz for Greetings coming soon')),
              );
            },
          ),

          // 🔽 Common Verbs
          buildCategoryTile(
            context,
            "COMMON VERBS",
            Icons.flash_on,
            isCommonVerbUnlocked ? Colors.lightBlue.shade200 : Colors.grey.shade300,
            isCommonVerbUnlocked,
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Learn/Quiz for Common Verbs coming soon')),
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
