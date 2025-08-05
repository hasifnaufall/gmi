import 'package:flutter/material.dart';
import 'profile.dart';
import 'quest.dart';
import 'alphabet_q.dart';

class QuizCategoryScreen extends StatefulWidget {
  @override
  _QuizCategoryScreenState createState() => _QuizCategoryScreenState();
}

class _QuizCategoryScreenState extends State<QuizCategoryScreen> {
  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    if (index == _selectedIndex) return;

    setState(() {
      _selectedIndex = index;
    });

    switch (index) {
      case 0:
        break; // Stay on current page
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(80),
        child: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          flexibleSpace: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(children: [
                    const Icon(Icons.monetization_on, color: Colors.amber, size: 24),
                    const SizedBox(width: 6),
                    const Text('200',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                  ]),
                  Row(children: [
                    const Icon(Icons.local_fire_department, color: Colors.red, size: 24),
                    const SizedBox(width: 6),
                    const Text('0',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
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
            style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, fontFamily: 'Cursive'),
          ),
          const SizedBox(height: 20),
          // ALPHABET - unlocked and navigates to AlphabetQPage
          buildCategoryTile(
            context,
            "ALPHABET",
            Icons.abc,
            Colors.lightBlue.shade200,
            true,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AlphabetQuizScreen()),
              );
            },
          ),
          // NUMBER
          buildCategoryTile(
            context,
            "NUMBER",
            Icons.looks_3,
            Colors.lightBlue.shade200,
            true,
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Opening NUMBER Quiz...')),
              );
            },
          ),
          // GREETINGS
          buildCategoryTile(
            context,
            "GREETINGS",
            Icons.person,
            Colors.lightBlue.shade200,
            true,
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Opening GREETINGS Quiz...')),
              );
            },
          ),
          // LOCKED categories (no onTap)
          buildCategoryTile(context, "COLOUR", Icons.lock, Colors.grey.shade300, false),
          buildCategoryTile(context, "COMMON VERBS", Icons.lock, Colors.grey.shade300, false),
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
      onTap: unlocked ? onTap : null,
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
