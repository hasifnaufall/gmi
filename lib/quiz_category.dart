import 'package:flutter/material.dart';
import 'profile.dart';
import 'quest.dart';
import 'alphabet_q.dart';
import 'quest_status.dart';

class QuizCategoryScreen extends StatefulWidget {
  @override
  _QuizCategoryScreenState createState() => _QuizCategoryScreenState();
}

class _QuizCategoryScreenState extends State<QuizCategoryScreen> {
  int _selectedIndex = 0;
  bool isNumberUnlocked = false; // 🔓 example

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

  void _showUnlockDialog(String levelName, VoidCallback onConfirm) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text("Unlock $levelName?"),
        content: const Text("Spend 200 keys to unlock this level?"),
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

  @override
  Widget build(BuildContext context) {
    final points = QuestStatus.userPoints;
    final streak = QuestStatus.streakDays; // 🔥 use live streak

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
              padding:
              const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(children: [
                    const Icon(Icons.key, color: Colors.amber, size: 24),
                    const SizedBox(width: 6),
                    Text(
                      '$points',
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 18),
                    ),
                  ]),
                  Row(children: [
                    const Icon(Icons.local_fire_department,
                        color: Colors.red, size: 24),
                    const SizedBox(width: 6),
                    // 🔥 show live streak here
                    Text(
                      '$streak',
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 18),
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

          // ✅ ALPHABET - Always unlocked
          buildCategoryTile(
            context,
            "ALPHABET",
            Icons.abc,
            Colors.lightBlue.shade200,
            true,
            onTap: () async {
              // Important: wait for the quiz screen to close, then rebuild
              await Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AlphabetQuizScreen()),
              );
              if (!mounted) return;
              setState(() {}); // refresh keys/streak after returning
            },
          ),

          // 🔒 NUMBER - Unlockable by 200 keys
          buildCategoryTile(
            context,
            "NUMBER",
            Icons.looks_3,
            isNumberUnlocked ? Colors.lightBlue.shade200 : Colors.grey.shade300,
            isNumberUnlocked,
            onTap: () {
              if (isNumberUnlocked) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Opening NUMBER Quiz...')),
                );
              } else {
                if (QuestStatus.userPoints >= 200) {
                  _showUnlockDialog("NUMBER", () {
                    setState(() {
                      isNumberUnlocked = true;
                      QuestStatus.userPoints -= 200;
                    });
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('NUMBER level unlocked!')),
                    );
                  });
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text('Not enough keys to unlock NUMBER.')),
                  );
                }
              }
            },
          ),

          // 🔒 LOCKED CATEGORIES
          buildCategoryTile(
              context, "GREETINGS", Icons.person, Colors.grey.shade300, false),
          buildCategoryTile(
              context, "COLOUR", Icons.lock, Colors.grey.shade300, false),
          buildCategoryTile(context, "COMMON VERBS", Icons.lock,
              Colors.grey.shade300, false),
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
      onTap: onTap, // keep unlock logic in the handler
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
            Icon(icon, size: 30, color: unlocked ? Colors.black : Colors.black45),
          ],
        ),
      ),
    );
  }
}
