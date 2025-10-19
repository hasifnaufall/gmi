import 'package:flutter/material.dart';
import 'dart:ui' as ui;
import 'package:firebase_auth/firebase_auth.dart';
import 'quiz_category.dart';
import 'quest.dart';
import 'login.dart';
import 'quest_status.dart'; // keys + xp + chestsOpened + achievements
import 'xp_popups.dart'; // 🎉 showAchievementPopup
import 'user_progress_service.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  int _selectedTab = 0;

  final UserProgressService _progressService = UserProgressService();
  String _progressStatus = '';
  Map<String, dynamic>? _progressData;

  Future<void> _saveProgress() async {
    try {
      await QuestStatus.autoSaveProgress(); // Use the comprehensive save method
      setState(() {
        _progressStatus = 'Progress Saved!';
      });
    } catch (e) {
      setState(() {
        _progressStatus = 'Save failed: $e';
      });
    }
  }

  Future<void> _loadProgress() async {
    try {
      final userId = _progressService.getCurrentUserId();
      if (userId != null) {
        await QuestStatus.loadProgressForUser(userId);
        final data = await _progressService.getProgress();
        setState(() {
          _progressData = data;
          _progressStatus = data != null
              ? 'Progress Loaded!'
              : 'No progress found.';
        });
      } else {
        setState(() {
          _progressStatus = 'No user logged in';
        });
      }
    } catch (e) {
      setState(() {
        _progressStatus = 'Load failed: $e';
      });
    }
  }

  Future<void> _confirmLogout() async {
    final shouldLogout = await showDialog<bool>(
      context: context,
      barrierDismissible: true,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Log out?'),
        content: const Text(
          'Are you sure you want to log out of your account?',
        ),
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
      // Only clear the current user ID - DO NOT reset progress data
      // The progress should remain in Firestore for when user logs back in
      QuestStatus.clearCurrentUser(); // Clear the current user ID

      await FirebaseAuth.instance.signOut();
      if (!mounted) return;
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
        (route) => false,
      );
    }
  }

  Widget _progressButtonsAndStatus() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: _saveProgress,
              child: const Text('Save Progress'),
            ),
            const SizedBox(width: 12),
            ElevatedButton(
              onPressed: _loadProgress,
              child: const Text('Load Progress'),
            ),
          ],
        ),
        if (_progressStatus.isNotEmpty) ...[
          const SizedBox(height: 8),
          Text(_progressStatus, style: const TextStyle(color: Colors.teal)),
        ],
        if (_progressData != null) ...[
          const SizedBox(height: 8),
          Text('Level: ${_progressData!['level']}'),
          Text('Score: ${_progressData!['score']}'),
          Text(
            'Achievements: ${(_progressData!['achievements'] as List).join(', ')}',
          ),
        ],
      ],
    );
  }

  // Modern glassy bottom navigation bar with animated active pill
  Widget _buildModernNavBar() {
    final navItems = [
      {
        'label': 'Home',
        'icon': Icons.home_outlined,
        'activeIcon': Icons.home_rounded,
        'color': const Color(0xFF2563EB),
      },
      {
        'label': 'Task',
        'icon': Icons.menu_book_outlined,
        'activeIcon': Icons.menu_book_rounded,
        'color': const Color(0xFF22C55E),
      },
      {
        'label': 'Profile',
        'icon': Icons.person_outline_rounded,
        'activeIcon': Icons.person_rounded,
        'color': const Color(0xFFF59E0B),
      },
    ];

    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        child: Container(
          height: 72,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: BackdropFilter(
              filter: ui.ImageFilter.blur(sigmaX: 12, sigmaY: 12),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.55),
                  border: Border.all(color: Colors.white.withOpacity(0.7)),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final itemWidth = constraints.maxWidth / navItems.length;
                    final accent = navItems[2]['color'] as Color;
                    return Stack(
                      children: [
                        // Active pill background
                        AnimatedPositioned(
                          duration: const Duration(milliseconds: 260),
                          curve: Curves.easeOutCubic,
                          left: 2 * itemWidth,
                          top: 8,
                          bottom: 8,
                          child: Container(
                            width: itemWidth,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  accent.withOpacity(0.18),
                                  accent.withOpacity(0.08),
                                ],
                              ),
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                        ),
                        // Nav items row
                        Row(
                          children: List.generate(navItems.length, (i) {
                            final active = i == 2;
                            final icon =
                                (active
                                        ? navItems[i]['activeIcon']
                                        : navItems[i]['icon'])
                                    as IconData;
                            final color = active
                                ? navItems[i]['color'] as Color
                                : Colors.black54;
                            return Expanded(
                              child: Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  borderRadius: BorderRadius.circular(16),
                                  onTap: () {
                                    if (i == 0) {
                                      Navigator.pushReplacement(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) => QuizCategoryScreen(),
                                        ),
                                      );
                                    } else if (i == 1) {
                                      Navigator.pushReplacement(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) => const QuestScreen(),
                                        ),
                                      );
                                    }
                                  },
                                  child: SizedBox(
                                    height: 72,
                                    child: Center(
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(icon, size: 24, color: color),
                                          AnimatedSwitcher(
                                            duration: const Duration(
                                              milliseconds: 180,
                                            ),
                                            switchInCurve: Curves.easeOut,
                                            switchOutCurve: Curves.easeIn,
                                            child: active
                                                ? Padding(
                                                    key: ValueKey('lbl$i'),
                                                    padding:
                                                        const EdgeInsets.only(
                                                          left: 8,
                                                        ),
                                                    child: Text(
                                                      navItems[i]['label']
                                                          as String,
                                                      style: TextStyle(
                                                        color: color,
                                                        fontWeight:
                                                            FontWeight.w600,
                                                      ),
                                                    ),
                                                  )
                                                : const SizedBox(
                                                    key: ValueKey('empty'),
                                                  ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            );
                          }),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final double width = MediaQuery.of(context).size.width;
    final double padding = width * 0.05;
    final user = FirebaseAuth.instance.currentUser;
    final username = user?.email?.split('@').first ?? 'User';
    final int opened = QuestStatus.chestsOpened;
    final String chestLabel = "CHESTS OPENED: $opened";
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
              ..._buildAchievementContent(),
          ],
        ),
      ),
      bottomNavigationBar: _buildModernNavBar(),
    );
    // ...existing code...
  }

  List<_Medal> _allMedals() {
    return [
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

    final int streak = QuestStatus.streakDays;
    final String streakLabel = "$streak DAY${streak == 1 ? '' : 'S'}\nSTREAK";

    final medals = _allMedals();
    final unlockedCount = medals.where((m) => m.unlocked).length;

    return [
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
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _TinyStat(
            icon: Icons.local_fire_department,
            label: streakLabel,
            color: Colors.orange,
          ),
          _TinyStat(
            icon: Icons.lock_open,
            label: chestLabel,
            color: Colors.brown,
          ),
          _TinyStat(
            icon: Icons.emoji_events,
            label: "$unlockedCount MEDAL${unlockedCount == 1 ? '' : 'S'}",
            color: Colors.pink,
          ),
        ],
      ),
      const SizedBox(height: 20),
      _progressButtonsAndStatus(), // <--- Progress buttons/status here!
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
                const Text(
                  "Google:",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(
                  user?.email ?? "No email linked",
                  style: TextStyle(color: Colors.grey[700]),
                ),
              ],
            ),
          ],
        ),
      ),
      const SizedBox(height: 40),
    ];
  }

  List<Widget> _buildAchievementContent() {
    final medals = _allMedals();

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
      // Debug section for testing
      Card(
        margin: EdgeInsets.symmetric(vertical: 8),
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Debug Info:',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        QuestStatus.showCurrentProgress();
                      },
                      child: Text('Show Progress'),
                    ),
                  ),
                  SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () async {
                        await QuestStatus.forceSave();
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Progress saved manually!')),
                        );
                      },
                      child: Text('Force Save'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    ];
  }
}

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
          radius: 30,
          child: Icon(icon, color: color, size: 28),
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
    final bg = isUnlocked
        ? medal.color.withOpacity(0.14)
        : Colors.grey.shade200;
    final border = isUnlocked
        ? medal.color.withOpacity(0.45)
        : Colors.grey.withOpacity(0.35);
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
                  Text(
                    medal.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontWeight: FontWeight.w800,
                      color: isUnlocked ? Colors.black : Colors.black54,
                    ),
                  ),
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
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: isUnlocked
                            ? Colors.green.withOpacity(0.15)
                            : Colors.grey.withOpacity(0.2),
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
