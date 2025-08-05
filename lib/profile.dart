import 'package:flutter/material.dart';
import 'quiz_category.dart';
import 'quest.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  int _selectedTab = 0; // 0 = Profile tab, 1 = Achievement tab

  @override
  Widget build(BuildContext context) {
    final double width = MediaQuery.of(context).size.width;
    final double padding = width * 0.05;

    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 70,
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => QuizCategoryScreen()),
            );
          },
        ),
        title: Padding(
          padding: EdgeInsets.symmetric(horizontal: padding),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: const [
                  Icon(Icons.monetization_on, color: Colors.amber, size: 28),
                  SizedBox(width: 4),
                  Text(
                    '200',
                    style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 20),
                  ),
                ],
              ),
              const Text("APPEARANCE", style: TextStyle(color: Colors.black, fontSize: 14)),
            ],
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: padding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 20),
            CircleAvatar(
              radius: 50,
              backgroundColor: Colors.orange[200],
              child: const Icon(Icons.person, size: 60, color: Colors.white),
            ),
            const SizedBox(height: 12),
            const Text("Hello, Sam!", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),

            // Tab row: PROFILE vs ACHIEVEMENT
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                GestureDetector(
                  onTap: () {
                    setState(() => _selectedTab = 0);
                  },
                  child: Text(
                    "PROFILE",
                    style: TextStyle(
                      color: _selectedTab == 0 ? Colors.blue : Colors.grey[600],
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 20),
                GestureDetector(
                  onTap: () {
                    setState(() => _selectedTab = 1);
                  },
                  child: Text(
                    "ACHIEVEMENT",
                    style: TextStyle(
                      color: _selectedTab == 1 ? Colors.blue : Colors.grey[600],
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // Conditionally render profile or achievement content
            if (_selectedTab == 0) ..._buildProfileContent(context) else ..._buildAchievementContent(),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 2,
        selectedItemColor: Colors.teal,
        unselectedItemColor: Colors.grey,
        onTap: (index) {
          if (index == 0) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => QuizCategoryScreen()),
            );
          } else if (index == 1) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const QuestScreen()),
            );
          }
          // index == 2 stays on Profile
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.menu_book), label: 'Task'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }

  // Build the profile details section
  List<Widget> _buildProfileContent(BuildContext context) {
    return [
      // Level and progress bar
      Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            const Row(
              children: [
                Text("LEVEL 5", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              ],
            ),
            const SizedBox(height: 12),
            Stack(
              children: [
                Container(
                  height: 16,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                Container(
                  height: 16,
                  width: MediaQuery.of(context).size.width * 0.6,
                  decoration: BoxDecoration(
                    color: Colors.deepPurple,
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            const Align(
              alignment: Alignment.centerRight,
              child: Text("70/500 XP", style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
      const SizedBox(height: 20),

      // Achievement icons (streak, chest, medals)
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: const [
          AchievementIcon(
              icon: Icons.local_fire_department, label: "3 DAYS\nSTREAK", color: Colors.orange),
          AchievementIcon(icon: Icons.lock_open, label: "3 CHEST\nOPENED", color: Colors.brown),
          AchievementIcon(icon: Icons.emoji_events, label: "2 MEDALS", color: Colors.pink),
        ],
      ),
      const SizedBox(height: 20),

      // Settings section
      const Align(
        alignment: Alignment.centerLeft,
        child: Text("SETTINGS", style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      const SizedBox(height: 12),
      Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: Colors.grey[200],
        ),
        child: Row(
          children: [
            const Icon(Icons.account_circle, size: 30, color: Colors.red),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("Google:", style: TextStyle(fontWeight: FontWeight.bold)),
                Text("m********g@gmail.com", style: TextStyle(color: Colors.grey[700])),
              ],
            )
          ],
        ),
      ),
      const SizedBox(height: 40),
    ];
  }

  // Build the achievement cards section
  List<Widget> _buildAchievementContent() {
    return [
      buildMedalCard("MEDAL 1", "Description of medal 1"),
      buildMedalCard("MEDAL 2", "Description of medal 2"),
      buildMedalCard("MEDAL 3", "Description of medal 3"),
      const SizedBox(height: 40),
    ];
  }

  // Helper to build medal cards
  Widget buildMedalCard(String title, String description) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          const Icon(Icons.emoji_events, color: Colors.pink, size: 40),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              Text(description),
            ],
          ),
        ],
      ),
    );
  }
}

class AchievementIcon extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const AchievementIcon({
    super.key,
    required this.icon,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CircleAvatar(
          backgroundColor: color.withOpacity(0.2),
          child: Icon(icon, color: color, size: 28),
          radius: 30,
        ),
        const SizedBox(height: 6),
        Text(
          label,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 12),
        )
      ],
    );
  }
}
