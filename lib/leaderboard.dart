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
    setState(() {
      _isLoading = true;
    });

    try {
      // Fetch top 50 users by level, then by score
      final snapshot = await _firestore
          .collection('progress')
          .orderBy('level', descending: true)
          .orderBy('score', descending: true)
          .limit(50)
          .get();

      print(
        'Leaderboard: Found [32m${snapshot.docs.length}[0m users in progress collection',
      );

      List<Map<String, dynamic>> leaderboardData = [];
      int rank = 1;

      // Get current user displayName from Firebase Auth (for fallback)
      final currentUser = _auth.currentUser;
      final currentUserDisplayName = currentUser?.displayName;

      for (var doc in snapshot.docs) {
        final data = doc.data();
        final userId = doc.id;

        // Priority: progress.displayName > FirebaseAuth.displayName (if current user) > UID short
        String displayName = '';
        if (data['displayName'] != null &&
            data['displayName'].toString().isNotEmpty) {
          displayName = data['displayName'];
        } else if (userId == currentUser?.uid &&
            currentUserDisplayName != null &&
            currentUserDisplayName.isNotEmpty) {
          displayName = currentUserDisplayName;
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

      print('Leaderboard: Loaded ${leaderboardData.length} entries');

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

          for (var doc in snapshot.docs) {
            final data = doc.data();
            final userId = doc.id;
            String displayName = '';
            if (data['displayName'] != null &&
                data['displayName'].toString().isNotEmpty) {
              displayName = data['displayName'];
            } else if (userId == currentUser?.uid &&
                currentUserDisplayName != null &&
                currentUserDisplayName.isNotEmpty) {
              displayName = currentUserDisplayName;
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

          setState(() {
            _leaderboard = leaderboardData;
            _isLoading = false;
          });
          return;
        } catch (fallbackError) {
          print('Fallback query also failed: $fallbackError');
        }
      }

      setState(() {
        _isLoading = false;
      });
    }
  }

  Color _getRankColor(int rank) {
    if (rank == 1) return const Color(0xFFFFD700); // Gold
    if (rank == 2) return const Color(0xFFC0C0C0); // Silver
    if (rank == 3) return const Color(0xFFCD7F32); // Bronze
    return Colors.white;
  }

  Widget _buildRankBadge(int rank, bool isCurrentUser) {
    String emoji = '';
    if (rank == 1) emoji = '👑';
    if (rank == 2) emoji = '🥈';
    if (rank == 3) emoji = '🥉';

    return Container(
      width: 50,
      height: 50,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: isCurrentUser
            ? LinearGradient(
                colors: [Color(0xFFFF3B30), Color(0xFFFF6B6B)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              )
            : LinearGradient(
                colors: [Color(0xFF2D2D2D), Color(0xFF1A1A1A)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
        border: Border.all(color: _getRankColor(rank), width: 2),
        boxShadow: [
          BoxShadow(
            color: isCurrentUser
                ? Color(0xFFFF3B30).withOpacity(0.3)
                : Colors.black26,
            blurRadius: 8,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Center(
        child: emoji.isNotEmpty
            ? Text(emoji, style: TextStyle(fontSize: 24))
            : Text(
                '$rank',
                style: TextStyle(
                  color: _getRankColor(rank),
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Global Leaderboard',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        centerTitle: true,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Colors.white.withOpacity(0.2),
                  width: 1,
                ),
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(12),
                  onTap: _loadLeaderboard,
                  child: Padding(
                    padding: const EdgeInsets.all(10),
                    child: Icon(
                      Icons.refresh_rounded,
                      color: Colors.white,
                      size: 22,
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
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFFF3B30)),
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
                if (_currentUserRank != null)
                  Container(
                    margin: EdgeInsets.all(16),
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Color(0xFFFF3B30), Color(0xFFFF6B6B)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Color(0xFFFF3B30).withOpacity(0.3),
                          blurRadius: 12,
                          offset: Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Your Rank',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          '#$_currentUserRank',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                Expanded(
                  child: ListView.builder(
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    itemCount: _leaderboard.length,
                    itemBuilder: (context, index) {
                      final entry = _leaderboard[index];
                      final isCurrentUser = entry['isCurrentUser'] as bool;
                      final rank = entry['rank'] as int;

                      return Container(
                        margin: EdgeInsets.only(bottom: 12),
                        decoration: BoxDecoration(
                          gradient: isCurrentUser
                              ? LinearGradient(
                                  colors: [
                                    Color(0xFFFF3B30).withOpacity(0.2),
                                    Color(0xFFFF6B6B).withOpacity(0.1),
                                  ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                )
                              : LinearGradient(
                                  colors: [
                                    Color(0xFF1E1E1E),
                                    Color(0xFF2A2A2A),
                                  ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: isCurrentUser
                                ? Color(0xFFFF3B30)
                                : Colors.white.withOpacity(0.1),
                            width: isCurrentUser ? 2 : 1,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: isCurrentUser
                                  ? Color(0xFFFF3B30).withOpacity(0.2)
                                  : Colors.black26,
                              blurRadius: 8,
                              offset: Offset(0, 4),
                            ),
                          ],
                        ),
                        child: ListTile(
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                          leading: _buildRankBadge(rank, isCurrentUser),
                          title: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  entry['displayName'],
                                  style: TextStyle(
                                    color: Colors.white,
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
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Color(0xFFFF3B30),
                                    borderRadius: BorderRadius.circular(8),
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
                          subtitle: Row(
                            children: [
                              Icon(
                                Icons.star,
                                size: 16,
                                color: Color(0xFFFFD700),
                              ),
                              SizedBox(width: 4),
                              Text(
                                'Level ${entry['level']}',
                                style: TextStyle(
                                  color: Colors.grey,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                          trailing: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                '${entry['score']} XP',
                                style: TextStyle(
                                  color: Color(0xFFFF3B30),
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
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
      },
      {
        'label': 'Quest',
        'icon': Icons.menu_book_outlined,
        'activeIcon': Icons.menu_book_rounded,
        'color': const Color(0xFF22C55E),
      },
      {
        'label': 'Ranking',
        'icon': Icons.leaderboard_outlined,
        'activeIcon': Icons.leaderboard,
        'color': const Color(0xFF63539C),
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
          height: 64,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.85),
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: List.generate(navItems.length, (index) {
              final item = navItems[index];
              final bool isSelected = _selectedIndex == index;
              return Expanded(
                child: GestureDetector(
                  onTap: () => _onNavBarTap(index),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    curve: Curves.ease,
                    margin: const EdgeInsets.symmetric(
                      vertical: 8,
                      horizontal: 4,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? (item['color'] as Color).withOpacity(0.15)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    padding: const EdgeInsets.symmetric(
                      vertical: 6,
                      horizontal: 0,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          isSelected
                              ? item['activeIcon'] as IconData
                              : item['icon'] as IconData,
                          color: isSelected
                              ? item['color'] as Color
                              : Colors.grey[500],
                          size: 24,
                        ),
                        if (isSelected)
                          Padding(
                            padding: const EdgeInsets.only(left: 4),
                            child: Text(
                              item['label'] as String,
                              style: TextStyle(
                                color: item['color'] as Color,
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                      ],
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
