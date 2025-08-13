import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'quiz_category.dart';
import 'quest.dart';
import 'login.dart';
import 'quest_status.dart'; // keys + xp + chestsOpened + achievements
import 'xp_popups.dart';    // 🎉 showAchievementPopup

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  int _selectedTab = 0;

  Future<void> _confirmLogout() async {
    final shouldLogout = await showDialog<bool>(
      context: context,
      barrierDismissible: true,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Log out?'),
        content: const Text('Are you sure you want to log out of your account?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton.icon(
            onPressed: () => Navigator.pop(context, true),
            icon: const Icon(Icons.logout),
            label: const Text('Log out'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );

    if (shouldLogout == true) {
      await FirebaseAuth.instance.signOut();
      if (!mounted) return;
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
            (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final double width = MediaQuery.of(context).size.width;
    final double padding = width * 0.05;
    final user = FirebaseAuth.instance.currentUser;
    final username = user?.email?.split('@').first ?? 'User';

    final int opened = QuestStatus.chestsOpened;
    final String chestLabel =
    opened == 1 ? "1 CHEST\nOPENED" : "$opened CHESTS\nOPENED";

    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 70,
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Padding(
          padding: EdgeInsets.symmetric(horizontal: padding),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.key, color: Colors.amber, size: 28),
                  const SizedBox(width: 4),
                  Text(
                    '${QuestStatus.userPoints}',
                    style: const TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                    ),
                  ),
                ],
              ),
              const Text(
                "APPEARANCE",
                style: TextStyle(color: Colors.black, fontSize: 14),
              ),
            ],
          ),
        ),
        // ✅ Logout icon on the right
        actions: [
          IconButton(
            tooltip: 'Logout',
            icon: const Icon(Icons.logout, color: Colors.black87),
            onPressed: _confirmLogout,
          ),
        ],
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
            Text(
              "Hello, $username!",
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                GestureDetector(
                  onTap: () => setState(() => _selectedTab = 0),
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
                  onTap: () => setState(() => _selectedTab = 1),
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
            if (_selectedTab == 0)
              ..._buildProfileContent(context, user, chestLabel)
            else
              ..._buildAchievementContent(), // ⬅️ horizontal list lives here
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
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.menu_book), label: 'Task'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }

  List<Widget> _buildProfileContent(
      BuildContext context,
      User? user,
      String chestLabel,
      ) {
    final level = QuestStatus.level;
    final xp = QuestStatus.xp;
    final xpToNext = QuestStatus.xpToNext;
    final progress = QuestStatus.xpProgress.clamp(0.0, 1.0);

    return [
      // -------- Level / XP Card --------
      Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Row(
              children: [
                Text(
                  "LEVEL $level",
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
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
                FractionallySizedBox(
                  widthFactor: progress,
                  child: Container(
                    height: 16,
                    decoration: BoxDecoration(
                      color: Colors.deepPurple,
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Align(
              alignment: Alignment.centerRight,
              child: Text(
                "$xp / $xpToNext XP",
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
      const SizedBox(height: 20),

      // -------- Small stats row --------
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          const _TinyStat(
            icon: Icons.local_fire_department,
            label: "3 DAYS\nSTREAK",
            color: Colors.orange,
          ),
          _TinyStat(
            icon: Icons.lock_open,
            label: chestLabel,
            color: Colors.brown,
          ),
          _TinyStat(
            icon: Icons.emoji_events,
            label:
            "${QuestStatus.achievements.length} MEDAL${QuestStatus.achievements.length == 1 ? '' : 'S'}",
            color: Colors.pink,
          ),
        ],
      ),
      const SizedBox(height: 20),
      const Align(
        alignment: Alignment.centerLeft,
        child: Text("SETTINGS", style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      const SizedBox(height: 12),

      // -------- Account row --------
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
                Text(
                  user?.email ?? "No email linked",
                  style: TextStyle(color: Colors.grey[700]),
                ),
              ],
            )
          ],
        ),
      ),
      const SizedBox(height: 40),
    ];
  }

  // ========= ACHIEVEMENTS TAB =========
  List<Widget> _buildAchievementContent() {
    final medals = <_Medal>[
      _Medal(
        name: 'Welcome',
        title: 'Welcome',
        description: 'Unlocked a chest for the first time.',
        icon: Icons.emoji_emotions,
        color: Colors.amber,
        unlocked: QuestStatus.achievements.contains('Welcome'),
      ),
      _Medal(
        name: 'Quiz Novice',
        title: 'Quiz Novice',
        description: 'Finish your first quiz.',
        icon: Icons.school,
        color: Colors.blue,
        unlocked: QuestStatus.level1Completed,
      ),
      _Medal(
        name: 'Treasure Hunter',
        title: 'Treasure Hunter',
        description: 'Open 3 chests.',
        icon: Icons.card_giftcard,
        color: Colors.deepOrange,
        unlocked: QuestStatus.chestsOpened >= 3,
      ),
    ];

    return [
      const SizedBox(height: 8),
      Align(
        alignment: Alignment.centerLeft,
        child: Text(
          "Your medals",
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: Colors.grey[800],
          ),
        ),
      ),
      const SizedBox(height: 10),
      SizedBox(
        height: 160,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          itemCount: medals.length,
          separatorBuilder: (_, __) => const SizedBox(width: 12),
          itemBuilder: (_, i) {
            final m = medals[i];
            return _MedalChip(
              medal: m,
              onTap: () async {
                await showAchievementPopup(
                  context,
                  title: m.title,
                  description: m.description,
                  unlocked: m.unlocked,
                );
              },
            );
          },
        ),
      ),
      const SizedBox(height: 24),
    ];
  }
}

// ======= UI helpers =======

class _TinyStat extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  const _TinyStat({
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
        ),
      ],
    );
  }
}

class _Medal {
  final String name;
  final String title;
  final String description;
  final IconData icon;
  final Color color;
  final bool unlocked;

  const _Medal({
    required this.name,
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
    required this.unlocked,
  });
}

class _MedalChip extends StatelessWidget {
  final _Medal medal;
  final VoidCallback onTap;
  const _MedalChip({required this.medal, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final isUnlocked = medal.unlocked;
    final bg = isUnlocked ? medal.color.withOpacity(0.14) : Colors.grey.shade200;
    final border = isUnlocked ? medal.color.withOpacity(0.45) : Colors.grey.withOpacity(0.35);
    final fg = isUnlocked ? medal.color : Colors.grey;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 260,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: border),
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 26,
              backgroundColor: fg.withOpacity(0.15),
              child: Icon(medal.icon, color: fg, size: 28),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(medal.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                        color: isUnlocked ? Colors.black : Colors.black54,
                      )),
                  const SizedBox(height: 4),
                  Text(
                    medal.description,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 12,
                      height: 1.2,
                      color: isUnlocked ? Colors.black87 : Colors.black45,
                    ),
                  ),
                  const Spacer(),
                  Align(
                    alignment: Alignment.bottomLeft,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: isUnlocked ? Colors.green.withOpacity(0.15) : Colors.grey.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        isUnlocked ? 'Unlocked' : 'Locked',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: isUnlocked ? Colors.green : Colors.grey,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
