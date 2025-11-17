//leaderboard.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'quiz_category.dart';
import 'theme_manager.dart';

class LeaderboardPage extends StatefulWidget {
  const LeaderboardPage({super.key});

  @override
  State<LeaderboardPage> createState() => _LeaderboardPageState();
}

class _LeaderboardPageState extends State<LeaderboardPage> {
  int _selectedIndex = 2; // Leaderboard index

  void _onNavBarTap(int index) {
    if (index == _selectedIndex) return;
    setState(() {
      _selectedIndex = index;
    });
    switch (index) {
      case 0:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => QuizCategoryScreen()),
        );
        break;
      case 1:
        Navigator.pushReplacementNamed(context, '/quest');
        break;
      case 2:
        break;
      case 3:
        Navigator.pushReplacementNamed(context, '/profile');
        break;
    }
  }

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  List<Map<String, dynamic>> _leaderboard = [];
  bool _isLoading = true;
  String? _currentUserId;

  @override
  void initState() {
    super.initState();
    _currentUserId = _auth.currentUser?.uid;
    _loadLeaderboard();
  }

  Future<void> _loadLeaderboard() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
    });

    try {
      final snapshot = await _firestore
          .collection('progress')
          .get()
          .timeout(const Duration(seconds: 5));

      print(
        'Leaderboard: Found ${snapshot.docs.length} users in progress collection',
      );

      final currentUser = _auth.currentUser;
      final currentUserDisplayName = currentUser?.displayName;
      final currentUserEmail = currentUser?.email;

      List<Map<String, dynamic>> allUsers = [];

      for (var doc in snapshot.docs) {
        final data = doc.data();
        final userId = doc.id;

        String? userEmail = data['email'] as String?;
        if (userId == currentUser?.uid && userEmail == null) {
          userEmail = currentUserEmail;
        }

        String emailUsername = '';
        if (userEmail != null && userEmail.contains('@')) {
          emailUsername = userEmail.split('@')[0];
        }

        String displayName = '';
        if (data['displayName'] != null &&
            data['displayName'].toString().isNotEmpty) {
          displayName = data['displayName'];
        } else if (userId == currentUser?.uid &&
            currentUserDisplayName != null &&
            currentUserDisplayName.isNotEmpty) {
          displayName = currentUserDisplayName;
        } else if (emailUsername.isNotEmpty) {
          displayName = emailUsername;
        } else {
          displayName = 'Player ${userId.substring(0, 6)}';
        }

        allUsers.add({
          'userId': userId,
          'displayName': displayName,
          'level': data['level'] ?? 0,
          'score': data['score'] ?? 0,
          'isCurrentUser': userId == _currentUserId,
        });
      }

      allUsers.sort((a, b) {
        int levelCompare = (b['level'] as int).compareTo(a['level'] as int);
        if (levelCompare != 0) return levelCompare;
        return (b['score'] as int).compareTo(a['score'] as int);
      });

      print('Leaderboard: Top 5 after sorting:');
      for (var i = 0; i < allUsers.length && i < 5; i++) {
        print(
          '  ${i + 1}. ${allUsers[i]['displayName']} - Level ${allUsers[i]['level']}, Score ${allUsers[i]['score']}',
        );
      }

      List<Map<String, dynamic>> leaderboardData = [];
      int rank = 1;

      for (var user in allUsers.take(50)) {
        leaderboardData.add({
          'rank': rank,
          'userId': user['userId'],
          'displayName': user['displayName'],
          'level': user['level'],
          'score': user['score'],
          'isCurrentUser': user['isCurrentUser'],
        });

        rank++;
      }

      print('Leaderboard: Loaded ${leaderboardData.length} entries');

      if (!mounted) return;
      setState(() {
        _leaderboard = leaderboardData;
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading leaderboard: $e');

      if (e.toString().contains('index') ||
          e.toString().contains('FAILED_PRECONDITION')) {
        print('Trying fallback query without compound orderBy');
        try {
          final snapshot = await _firestore
              .collection('progress')
              .orderBy('level', descending: true)
              .limit(50)
              .get();

          List<Map<String, dynamic>> leaderboardData = [];
          int rank = 1;

          final currentUser = _auth.currentUser;
          final currentUserDisplayName = currentUser?.displayName;
          final currentUserEmail = currentUser?.email;

          for (var doc in snapshot.docs) {
            final data = doc.data();
            final userId = doc.id;

            String? userEmail = data['email'] as String?;
            if (userId == currentUser?.uid && userEmail == null) {
              userEmail = currentUserEmail;
            }

            String emailUsername = '';
            if (userEmail != null && userEmail.contains('@')) {
              emailUsername = userEmail.split('@')[0];
            }

            String displayName = '';
            if (data['displayName'] != null &&
                data['displayName'].toString().isNotEmpty) {
              displayName = data['displayName'];
            } else if (userId == currentUser?.uid &&
                currentUserDisplayName != null &&
                currentUserDisplayName.isNotEmpty) {
              displayName = currentUserDisplayName;
            } else if (emailUsername.isNotEmpty) {
              displayName = emailUsername;
            } else {
              displayName = 'Player ${userId.substring(0, 6)}';
            }

            leaderboardData.add({
              'rank': rank,
              'userId': userId,
              'displayName': displayName,
              'level': data['level'] ?? 0,
              'score': data['score'] ?? 0,
              'isCurrentUser': userId == _currentUserId,
            });

            rank++;
          }

          if (!mounted) return;
          setState(() {
            _leaderboard = leaderboardData;
            _isLoading = false;
          });
          return;
        } catch (fallbackError) {
          print('Fallback query also failed: $fallbackError');
        }
      }

      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });
    }
  }

  Widget _buildTopThreePodium(ThemeManager themeManager) {
    if (_leaderboard.length < 3) return SizedBox.shrink();

    final top3 = _leaderboard.take(3).toList();
    final first = top3.isNotEmpty ? top3[0] : null;
    final second = top3.length > 1 ? top3[1] : null;
    final third = top3.length > 2 ? top3[2] : null;

    return Container(
      margin: EdgeInsets.fromLTRB(16, 16, 16, 24),
      padding: EdgeInsets.symmetric(vertical: 30, horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (second != null) _buildDiamondPodium(second, 2, 0, themeManager),
          if (first != null) _buildDiamondPodium(first, 1, 0, themeManager),
          if (third != null) _buildDiamondPodium(third, 3, 0, themeManager),
        ],
      ),
    );
  }

  Widget _buildDiamondPodium(
    Map<String, dynamic> entry,
    int rank,
    double extraHeight,
    ThemeManager themeManager,
  ) {
    Color bgColor;
    Color badgeColor;
    Color avatarBgColor;
    String emoji;

    if (rank == 1) {
      bgColor = themeManager.isDarkMode ? Color(0xFFD23232) : Color(0xFF0891B2);
      badgeColor = Color(0xFFFFD700);
      avatarBgColor = themeManager.isDarkMode
          ? Color(0xFF3A3A3C)
          : Color(0xFFFFF7D1);
      emoji = '🥇';
    } else if (rank == 2) {
      bgColor = themeManager.isDarkMode ? Color(0xFF8B1F1F) : Color(0xFF7C7FCC);
      badgeColor = Color(0xFFC0C0C0);
      avatarBgColor = themeManager.isDarkMode
          ? Color(0xFF2C2C2E)
          : Color(0xFFCFFFF7);
      emoji = '🥈';
    } else {
      bgColor = themeManager.isDarkMode
          ? Color(0xFF636366)
          : Color(0xFF0891B2).withOpacity(0.6);
      badgeColor = Color(0xFFCD7F32);
      avatarBgColor = themeManager.isDarkMode
          ? Color(0xFF1C1C1E)
          : Color(0xFFFFEB99);
      emoji = '🥉';
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 70,
          height: 70,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: avatarBgColor,
            border: Border.all(color: Colors.white, width: 3),
          ),
          child: Center(child: Text(emoji, style: TextStyle(fontSize: 32))),
        ),
        SizedBox(height: 8),
        Stack(
          alignment: Alignment.center,
          clipBehavior: Clip.none,
          children: [
            Transform.rotate(
              angle: 0.785398,
              child: Container(
                width: 95,
                height: 95,
                decoration: BoxDecoration(
                  color: bgColor,
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            Container(
              width: 90,
              alignment: Alignment.center,
              child: Text(
                entry['displayName'],
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Positioned(
              bottom: -18,
              child: Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: badgeColor,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                ),
                child: Center(
                  child: Text(
                    '$rank',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 26 + extraHeight),
        // Level and XP below the diamond
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: themeManager.isDarkMode
                    ? Color(0xFF3C3C3E)
                    : Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: bgColor.withOpacity(0.5), width: 1.5),
              ),
              child: Text(
                'Lv ${entry['level']}',
                style: TextStyle(
                  color: themeManager.isDarkMode ? Color(0xFFE8E8E8) : bgColor,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            SizedBox(width: 6),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: themeManager.isDarkMode
                    ? Color(0xFF3C3C3E)
                    : Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: bgColor.withOpacity(0.5), width: 1.5),
              ),
              child: Text(
                '${entry['score']} XP',
                style: TextStyle(
                  color: themeManager.isDarkMode ? Color(0xFFE8E8E8) : bgColor,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeManager>(
      builder: (context, themeManager, child) {
        return Scaffold(
          backgroundColor: themeManager.backgroundColor,
          appBar: AppBar(
            backgroundColor: themeManager.backgroundColor,
            elevation: 0,
            automaticallyImplyLeading: false,
            title: Text(
              'Leaderboard',
              style: GoogleFonts.montserrat(
                fontSize: 28,
                fontWeight: FontWeight.w700,
                color: themeManager.isDarkMode
                    ? const Color(0xFFD23232)
                    : const Color(0xFF0891B2),
              ),
            ),
            centerTitle: true,
          ),
          body: _isLoading
              ? Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(
                      themeManager.primary,
                    ),
                  ),
                )
              : _leaderboard.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.leaderboard,
                        size: 80,
                        color: themeManager.isDarkMode
                            ? Color(0xFF636366)
                            : Colors.grey,
                      ),
                      SizedBox(height: 20),
                      Text(
                        'No rankings yet',
                        style: TextStyle(
                          color: themeManager.isDarkMode
                              ? Color(0xFF8E8E93)
                              : Colors.grey,
                          fontSize: 18,
                        ),
                      ),
                    ],
                  ),
                )
              : Column(
                  children: [
                    // How Leaderboard Works Info
                    Container(
                      margin: EdgeInsets.fromLTRB(16, 8, 16, 16),
                      padding: EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: themeManager.isDarkMode
                              ? [Color(0xFF2C2C2E), Color(0xFF3A3A3C)]
                              : [Color(0xFFE0F2FE), Color(0xFFF0F9FF)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: themeManager.primary.withOpacity(0.3),
                          width: 1.5,
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: themeManager.primary.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              Icons.info_outline_rounded,
                              color: themeManager.primary,
                              size: 24,
                            ),
                          ),
                          SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'How Rankings Work',
                                  style: GoogleFonts.montserrat(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                    color: themeManager.isDarkMode
                                        ? Color(0xFFE8E8E8)
                                        : Color(0xFF1E293B),
                                  ),
                                ),
                                SizedBox(height: 4),
                                Text(
                                  'Rankings are based on your Level first, then XP points. Complete quizzes to climb higher!',
                                  style: GoogleFonts.montserrat(
                                    fontSize: 12,
                                    height: 1.4,
                                    color: themeManager.isDarkMode
                                        ? Color(0xFF8E8E93)
                                        : Color(0xFF475569),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    _buildTopThreePodium(themeManager),

                    // Table Container
                    Expanded(
                      child: Container(
                        margin: EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: themeManager.isDarkMode
                              ? Color(0xFF2C2C2E)
                              : Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.08),
                              blurRadius: 15,
                              offset: Offset(0, 5),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            // Table Header
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 16,
                              ),
                              decoration: BoxDecoration(
                                color: themeManager.primary,
                                borderRadius: BorderRadius.vertical(
                                  top: Radius.circular(20),
                                ),
                              ),
                              child: Row(
                                children: [
                                  SizedBox(
                                    width: 50,
                                    child: Text(
                                      'Rank',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    flex: 2,
                                    child: Text(
                                      'Name',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                  SizedBox(
                                    width: 50,
                                    child: Text(
                                      'Level',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                  SizedBox(
                                    width: 60,
                                    child: Text(
                                      'Points',
                                      textAlign: TextAlign.right,
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            // Table Content
                            Expanded(
                              child: ListView.separated(
                                padding: EdgeInsets.zero,
                                itemCount: _leaderboard
                                    .where((e) => e['rank'] > 3)
                                    .length,
                                separatorBuilder: (context, index) => Divider(
                                  height: 1,
                                  thickness: 1,
                                  color: themeManager.isDarkMode
                                      ? Color(0xFF3C3C3E)
                                      : Colors.grey.shade200,
                                ),
                                itemBuilder: (context, index) {
                                  final allEntries = _leaderboard
                                      .where((e) => e['rank'] > 3)
                                      .toList();
                                  final entry = allEntries[index];
                                  final isCurrentUser =
                                      entry['isCurrentUser'] as bool;
                                  final rank = entry['rank'] as int;

                                  return Container(
                                    decoration: BoxDecoration(
                                      gradient: isCurrentUser
                                          ? (themeManager.isDarkMode
                                              ? LinearGradient(
                                                  colors: [
                                                    Color(0xFFD23232).withOpacity(0.3),
                                                    Color(0xFF8B1F1F).withOpacity(0.3),
                                                  ],
                                                  begin: Alignment.centerLeft,
                                                  end: Alignment.centerRight,
                                                )
                                              : LinearGradient(
                                                  colors: [
                                                    Color(0xFF0891B2).withOpacity(0.2),
                                                    Color(0xFF7C7FCC).withOpacity(0.2),
                                                  ],
                                                  begin: Alignment.centerLeft,
                                                  end: Alignment.centerRight,
                                                ))
                                          : null,
                                      color: !isCurrentUser
                                          ? (themeManager.isDarkMode
                                              ? Color(0xFF2C2C2E)
                                              : Colors.white)
                                          : null,
                                      border: isCurrentUser
                                          ? Border.all(
                                              color: themeManager.primary.withOpacity(0.6),
                                              width: 2,
                                            )
                                          : null,
                                    ),
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 20,
                                      vertical: 16,
                                    ),
                                    child: Row(
                                      children: [
                                        SizedBox(
                                          width: 50,
                                          child: Text(
                                            '${rank.toString().padLeft(2, '0')}',
                                            style: TextStyle(
                                              color: themeManager.isDarkMode
                                                  ? Color(0xFFE8E8E8)
                                                  : Colors.black87,
                                              fontSize: 15,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ),
                                        Expanded(
                                          flex: 2,
                                          child: Row(
                                            children: [
                                              Expanded(
                                                child: Text(
                                                  entry['displayName'],
                                                  style: TextStyle(
                                                    color:
                                                        themeManager.isDarkMode
                                                        ? Color(0xFFE8E8E8)
                                                        : Colors.black87,
                                                    fontSize: 15,
                                                    fontWeight: isCurrentUser
                                                        ? FontWeight.bold
                                                        : FontWeight.w500,
                                                  ),
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                ),
                                              ),
                                              if (isCurrentUser)
                                                Container(
                                                  margin: EdgeInsets.only(
                                                    left: 8,
                                                  ),
                                                  padding: EdgeInsets.symmetric(
                                                    horizontal: 8,
                                                    vertical: 3,
                                                  ),
                                                  decoration: BoxDecoration(
                                                    color: themeManager.primary,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          8,
                                                        ),
                                                  ),
                                                  child: Text(
                                                    'YOU',
                                                    style: TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 9,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                                ),
                                            ],
                                          ),
                                        ),
                                        SizedBox(
                                          width: 50,
                                          child: Container(
                                            padding: EdgeInsets.symmetric(
                                              horizontal: 8,
                                              vertical: 4,
                                            ),
                                            decoration: BoxDecoration(
                                              gradient: LinearGradient(
                                                colors: themeManager.isDarkMode
                                                    ? [
                                                        Color(0xFF8B1F1F),
                                                        Color(0xFFD23232),
                                                      ]
                                                    : [
                                                        Color(0xFF0891B2),
                                                        Color(0xFF06B6D4),
                                                      ],
                                              ),
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                            ),
                                            child: Text(
                                              '${entry['level']}',
                                              textAlign: TextAlign.center,
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 14,
                                                fontWeight: FontWeight.w700,
                                              ),
                                            ),
                                          ),
                                        ),
                                        SizedBox(
                                          width: 60,
                                          child: Text(
                                            '${entry['score']}',
                                            textAlign: TextAlign.right,
                                            style: TextStyle(
                                              color: themeManager.isDarkMode
                                                  ? Color(0xFFE8E8E8)
                                                  : Colors.black87,
                                              fontSize: 15,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
          bottomNavigationBar: _buildModernNavBar(themeManager),
        );
      },
    );
  }

  Widget _buildModernNavBar(ThemeManager themeManager) {
    return Container(
      decoration: BoxDecoration(
        color: themeManager.isDarkMode ? Color(0xFF2C2C2E) : Colors.white,
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
                onTap: () => _onNavBarTap(0),
                themeManager: themeManager,
              ),
              _buildNavItem(
                emoji: '📚',
                label: 'Quest',
                isSelected: _selectedIndex == 1,
                onTap: () => _onNavBarTap(1),
                themeManager: themeManager,
              ),
              _buildNavItem(
                emoji: '🏆',
                label: 'Ranking',
                isSelected: _selectedIndex == 2,
                onTap: () => _onNavBarTap(2),
                themeManager: themeManager,
              ),
              _buildNavItem(
                emoji: '👤',
                label: 'Profile',
                isSelected: _selectedIndex == 3,
                onTap: () => _onNavBarTap(3),
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
                ? themeManager.primary.withOpacity(0.1)
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
                      ? themeManager.primary
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
}
