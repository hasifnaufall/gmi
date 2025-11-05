//leaderboard.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'quiz_category.dart';

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
    // Navigation logic: pushReplacement to avoid stacking
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
        // Already on leaderboard
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
  int? _currentUserRank;

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
      // Fetch all users and sort locally (avoids composite index requirement)
      final snapshot = await _firestore.collection('progress').get();

      print(
        'Leaderboard: Found ${snapshot.docs.length} users in progress collection',
      );

      // Get current user info from Firebase Auth
      final currentUser = _auth.currentUser;
      final currentUserDisplayName = currentUser?.displayName;
      final currentUserEmail = currentUser?.email;

      // Collect all users with their data
      List<Map<String, dynamic>> allUsers = [];

      for (var doc in snapshot.docs) {
        final data = doc.data();
        final userId = doc.id;

        // Get email from progress data, or current user if it's their record
        String? userEmail = data['email'] as String?;
        if (userId == currentUser?.uid && userEmail == null) {
          userEmail = currentUserEmail;
        }

        // Extract username from email (part before @)
        String emailUsername = '';
        if (userEmail != null && userEmail.contains('@')) {
          emailUsername = userEmail.split('@')[0];
        }

        // Priority: progress.displayName > FirebaseAuth.displayName (if current user) > email username > UID short
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

      // Sort by level (descending), then by score (descending)
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

      // Assign ranks and take top 50
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

        if (user['isCurrentUser'] == true) {
          _currentUserRank = rank;
        }

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

      // If compound index doesn't exist, try simpler query
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

            // Get email from progress data, or current user if it's their record
            String? userEmail = data['email'] as String?;
            if (userId == currentUser?.uid && userEmail == null) {
              userEmail = currentUserEmail;
            }

            // Extract username from email (part before @)
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

            if (userId == _currentUserId) {
              _currentUserRank = rank;
            }
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

  Widget _buildTopThreePodium() {
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
          // Second place
          if (second != null) _buildDiamondPodium(second, 2, 0),
          // First place (higher)
          if (first != null) _buildDiamondPodium(first, 1, 40),
          // Third place
          if (third != null) _buildDiamondPodium(third, 3, 0),
        ],
      ),
    );
  }

  Widget _buildDiamondPodium(
    Map<String, dynamic> entry,
    int rank,
    double extraHeight,
  ) {
    Color bgColor;
    Color badgeColor;
    Color avatarBgColor;
    String emoji;

    if (rank == 1) {
      bgColor = Color(0xFF69D3E4); // Bright cyan from palette
      badgeColor = Color(0xFFFFD700); // Gold
      avatarBgColor = Color(0xFFFFF7D1); // Cream
      emoji = '🥇';
    } else if (rank == 2) {
      bgColor = Color(0xFFA4A9FC); // Periwinkle from palette
      badgeColor = Color(0xFFC0C0C0); // Silver
      avatarBgColor = Color(0xFFCFFFF7); // Light mint
      emoji = '🥈';
    } else {
      bgColor = Color(0xFF69D3E4).withOpacity(0.6); // Lighter cyan
      badgeColor = Color(0xFFCD7F32); // Bronze
      avatarBgColor = Color(0xFFFFFFD0); // Light yellow
      emoji = '🥉';
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Avatar with circular background
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
        SizedBox(height: extraHeight > 0 ? 8 : 0),
        // Diamond shape
        Stack(
          alignment: Alignment.center,
          clipBehavior: Clip.none,
          children: [
            // Diamond container
            Transform.rotate(
              angle: 0.785398, // 45 degrees in radians
              child: Container(
                width: 95,
                height: 95,
                decoration: BoxDecoration(
                  color: bgColor,
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            // Name on diamond
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
            // Badge at bottom
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
        SizedBox(height: 22),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFCFFFF7), // Light cyan/mint
      appBar: AppBar(
        backgroundColor: const Color(0xFFCFFFF7),
        elevation: 0,
        leading: Padding(
          padding: const EdgeInsets.only(left: 8),
          child: Container(
            margin: EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              border: Border.all(
                color: Color(0xFF69D3E4).withOpacity(0.3),
                width: 1,
              ),
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(100),
                onTap: () => Navigator.pop(context),
                child: Icon(
                  Icons.arrow_back,
                  color: Color(0xFF69D3E4),
                  size: 20,
                ),
              ),
            ),
          ),
        ),
        title: Text(
          'Leaderboard',
          style: TextStyle(
            color: Color(0xFF69D3E4),
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: Container(
              margin: EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                border: Border.all(
                  color: Color(0xFF69D3E4).withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(100),
                  onTap: _loadLeaderboard,
                  child: Padding(
                    padding: const EdgeInsets.all(10),
                    child: Icon(
                      Icons.share_outlined,
                      color: Color(0xFF69D3E4),
                      size: 20,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF69D3E4)),
              ),
            )
          : _leaderboard.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.leaderboard, size: 80, color: Colors.grey),
                  SizedBox(height: 20),
                  Text(
                    'No rankings yet',
                    style: TextStyle(color: Colors.grey, fontSize: 18),
                  ),
                ],
              ),
            )
          : Column(
              children: [
                // Weekly/All Time Toggle
                Padding(
                  padding: EdgeInsets.fromLTRB(16, 16, 16, 0),
                  child: Container(
                    padding: EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(25),
                      boxShadow: [
                        BoxShadow(
                          color: Color(0xFF69D3E4).withOpacity(0.2),
                          blurRadius: 8,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Container(
                            padding: EdgeInsets.symmetric(vertical: 12),
                            decoration: BoxDecoration(
                              color: Color(0xFF69D3E4),
                              borderRadius: BorderRadius.circular(22),
                            ),
                            child: Text(
                              'Weekly',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          child: Container(
                            padding: EdgeInsets.symmetric(vertical: 12),
                            child: Text(
                              'All Time',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Color(0xFF69D3E4),
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Top 3 Podium
                _buildTopThreePodium(),

                // Current User Rank Card (if not in top 3)
                if (_currentUserRank != null && _currentUserRank! > 3)
                  Container(
                    margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    padding: EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Color(0xFF69D3E4),
                          Color(0xFFA4A9FC),
                        ], // Palette colors
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Color(0xFF69D3E4).withOpacity(0.4),
                          blurRadius: 16,
                          offset: Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Your Rank',
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.9),
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 0.5,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              '#$_currentUserRank',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 40,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        Container(
                          padding: EdgeInsets.all(18),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Colors.white.withOpacity(0.3),
                              width: 2,
                            ),
                          ),
                          child: Icon(
                            Icons.emoji_events_rounded,
                            color: Colors.white,
                            size: 40,
                          ),
                        ),
                      ],
                    ),
                  ),

                // Table Container
                Expanded(
                  child: Container(
                    margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.white,
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
                            color: Color(0xFF69D3E4), // Bright cyan
                            borderRadius: BorderRadius.vertical(
                              top: Radius.circular(20),
                            ),
                          ),
                          child: Row(
                            children: [
                              SizedBox(
                                width: 60,
                                child: Text(
                                  'Rank',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 15,
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
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                              SizedBox(
                                width: 80,
                                child: Text(
                                  'Points',
                                  textAlign: TextAlign.right,
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 15,
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
                              color: Colors.grey.shade200,
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
                                color: isCurrentUser
                                    ? Color(0xFFFFFFD0).withOpacity(
                                        0.5,
                                      ) // Light yellow from palette
                                    : Colors.white,
                                padding: EdgeInsets.symmetric(
                                  horizontal: 20,
                                  vertical: 16,
                                ),
                                child: Row(
                                  children: [
                                    SizedBox(
                                      width: 60,
                                      child: Text(
                                        '${rank.toString().padLeft(2, '0')}',
                                        style: TextStyle(
                                          color: Colors.black87,
                                          fontSize: 16,
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
                                                color: Colors.black87,
                                                fontSize: 16,
                                                fontWeight: isCurrentUser
                                                    ? FontWeight.bold
                                                    : FontWeight.w500,
                                              ),
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                          if (isCurrentUser)
                                            Container(
                                              margin: EdgeInsets.only(left: 8),
                                              padding: EdgeInsets.symmetric(
                                                horizontal: 10,
                                                vertical: 4,
                                              ),
                                              decoration: BoxDecoration(
                                                color: Color(0xFF69D3E4),
                                                borderRadius:
                                                    BorderRadius.circular(10),
                                              ),
                                              child: Text(
                                                'YOU',
                                                style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 10,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                        ],
                                      ),
                                    ),
                                    SizedBox(
                                      width: 80,
                                      child: Text(
                                        '${entry['score']}',
                                        textAlign: TextAlign.right,
                                        style: TextStyle(
                                          color: Colors.black87,
                                          fontSize: 16,
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
      bottomNavigationBar: _buildModernNavBar(),
    );
  }

  Widget _buildModernNavBar() {
    final navItems = [
      {
        'label': 'Home',
        'icon': Icons.home_outlined,
        'activeIcon': Icons.home_rounded,
        'color': const Color(0xFF2563EB),
        'emoji': '🏠',
      },
      {
        'label': 'Quest',
        'icon': Icons.menu_book_outlined,
        'activeIcon': Icons.menu_book_rounded,
        'color': const Color(0xFF22C55E),
        'emoji': '📚',
      },
      {
        'label': 'Ranking',
        'icon': Icons.leaderboard_outlined,
        'activeIcon': Icons.leaderboard,
        'color': const Color(0xFF63539C),
        'emoji': '🏆',
      },
      {
        'label': 'Profile',
        'icon': Icons.person_outline_rounded,
        'activeIcon': Icons.person_rounded,
        'color': const Color(0xFFF59E0B),
        'emoji': '👤',
      },
    ];

    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        child: Container(
          height: 67,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(25),
            color: const Color(0xFF6ac5e6),
            boxShadow: [
              BoxShadow(
                color: Color(0xFF6ac5e6).withOpacity(0.4),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Row(
            children: List.generate(navItems.length, (i) {
              final active = i == _selectedIndex;
              final color = active
                  ? Colors.white
                  : Colors.white.withOpacity(0.7);
              final emoji = navItems[i]['emoji'] as String;

              return Expanded(
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(20),
                    onTap: () => _onNavBarTap(i),
                    child: Container(
                      decoration: active
                          ? BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  Colors.white.withOpacity(0.2),
                                  Colors.white.withOpacity(0.1),
                                ],
                              ),
                              borderRadius: BorderRadius.circular(20),
                            )
                          : null,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(emoji, style: const TextStyle(fontSize: 20)),
                          const SizedBox(height: 4),
                          Text(
                            navItems[i]['label'] as String,
                            style: TextStyle(
                              color: color,
                              fontWeight: active
                                  ? FontWeight.w800
                                  : FontWeight.w600,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}
