//profile.dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import 'leaderboard.dart';
import 'login.dart';
import 'quest.dart';
import 'quest_status.dart';
import 'quiz_category.dart';
import 'user_progress_service.dart';
import 'xp_popups.dart';
import 'theme_manager.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _progressService = UserProgressService();
  String? _displayName;

  @override
  void initState() {
    super.initState();
    _loadDisplayName();
  }

  Future<void> _loadDisplayName() async {
    final name = await _progressService.getDisplayName();
    if (!mounted) return;
    setState(() => _displayName = name);
  }

  Future<void> _promptEditDisplayName() async {
    final themeManager = Provider.of<ThemeManager>(context, listen: false);
    final controller = TextEditingController(text: _displayName);
    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) {
        String? localError;
        bool saving = false;
        return StatefulBuilder(
          builder: (ctx, setStateDialog) {
            Future<void> doSave() async {
              final raw = controller.text.trim();
              if (raw.isEmpty) {
                setStateDialog(() => localError = 'Name cannot be empty');
                return;
              }
              if (raw.length < 2) {
                setStateDialog(
                  () => localError = 'Name must be at least 2 characters',
                );
                return;
              }
              setStateDialog(() => saving = true);
              try {
                await _progressService.saveDisplayName(raw);
                final user = FirebaseAuth.instance.currentUser;
                if (user != null) {
                  await user.updateDisplayName(raw);
                }
                if (mounted) {
                  setState(() => _displayName = raw);
                }
                Navigator.of(ctx).pop(true);
              } catch (e) {
                setStateDialog(() => saving = false);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Failed to update name: $e')),
                );
              }
            }

            return AlertDialog(
              backgroundColor: themeManager.isDarkMode ? Color(0xFF2C2C2E) : Color(0xFFFFFFFF),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              title: Text(
                'Edit Display Name',
                style: GoogleFonts.montserrat(
                  color: themeManager.isDarkMode ? Color(0xFFD23232) : Color(0xFF0891B2),
                  fontWeight: FontWeight.w700,
                  fontSize: 22,
                ),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: themeManager.isDarkMode ? Color(0xFF3C3C3E) : Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 8,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: TextField(
                      controller: controller,
                      style: TextStyle(color: themeManager.isDarkMode ? Colors.white : Color(0xFF2D5263)),
                      decoration: InputDecoration(
                        labelText: 'Display name',
                        labelStyle: GoogleFonts.montserrat(
                          color: themeManager.isDarkMode ? Color(0xFF8E8E93) : Color(0xFF2D5263),
                        ),
                        prefixIcon: Icon(
                          Icons.person_outline,
                          color: themeManager.isDarkMode ? Color(0xFFD23232) : Color(0xFF0891B2),
                        ),
                        errorText: localError,
                        filled: true,
                        fillColor: themeManager.isDarkMode ? Color(0xFF3C3C3E) : Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: EdgeInsets.symmetric(
                          vertical: 16,
                          horizontal: 16,
                        ),
                      ),
                      enabled: !saving,
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: saving ? null : () => Navigator.of(ctx).pop(false),
                  style: TextButton.styleFrom(
                    foregroundColor: themeManager.isDarkMode ? Color(0xFFD23232) : Color(0xFF0891B2),
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  ),
                  child: Text(
                    'Cancel',
                    style: GoogleFonts.montserrat(
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                    ),
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: saving ? null : doSave,
                  icon: saving
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(Icons.save_rounded, size: 18),
                  label: const Text('Save'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: themeManager.isDarkMode ? Color(0xFFD23232) : Color(0xFF0891B2),
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                ),
              ],
            );
          },
        );
      },
    );

    if (result == true && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Display name updated',
            style: GoogleFonts.montserrat(fontWeight: FontWeight.w600),
          ),
          backgroundColor: themeManager.isDarkMode ? Color(0xFFD23232) : Color(0xFF0891B2),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          margin: EdgeInsets.all(16),
        ),
      );
    }
  }

  Future<void> _confirmLogout() async {
    final themeManager = Provider.of<ThemeManager>(context, listen: false);
    final shouldLogout = await showDialog<bool>(
      context: context,
      barrierDismissible: true,
      builder: (_) => AlertDialog(
        backgroundColor: themeManager.isDarkMode ? Color(0xFF2C2C2E) : Color(0xFFFFFFFF),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'Log out?',
          style: GoogleFonts.montserrat(
            color: themeManager.isDarkMode ? Color(0xFFD23232) : Color(0xFF0891B2),
            fontWeight: FontWeight.w700,
            fontSize: 22,
          ),
        ),
        content: Text(
          'Are you sure you want to log out of your account?',
          style: GoogleFonts.montserrat(
            color: themeManager.isDarkMode ? Color(0xFFE8E8E8) : Color(0xFF2D5263),
            fontSize: 16,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            style: TextButton.styleFrom(
              foregroundColor: themeManager.isDarkMode ? Color(0xFFD23232) : Color(0xFF0891B2),
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            ),
            child: Text(
              'Cancel',
              style: GoogleFonts.montserrat(
                fontWeight: FontWeight.w600,
                fontSize: 15,
              ),
            ),
          ),
          ElevatedButton.icon(
            onPressed: () => Navigator.pop(context, true),
            icon: const Icon(Icons.logout_rounded, size: 18),
            label: const Text('Log out'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFF4B4A),
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 0,
            ),
          ),
        ],
      ),
    );

    if (shouldLogout == true) {
      QuestStatus.clearCurrentUser();
      await FirebaseAuth.instance.signOut();
      if (!mounted) return;
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
        (route) => false,
      );
    }
  }

  Future<void> _showFeedbackDialog() async {
    final themeManager = Provider.of<ThemeManager>(context, listen: false);
    final controller = TextEditingController();
    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) {
        String? localError;
        bool sending = false;
        return StatefulBuilder(
          builder: (ctx, setStateDialog) {
            Future<void> doSend() async {
              final message = controller.text.trim();
              if (message.isEmpty) {
                setStateDialog(() => localError = 'Please enter your feedback');
                return;
              }
              if (message.length < 10) {
                setStateDialog(
                  () => localError = 'Feedback must be at least 10 characters',
                );
                return;
              }

              setStateDialog(() => sending = true);
              try {
                await _progressService.submitFeedback(message);
                if (mounted) {
                  Navigator.of(ctx).pop(true);
                }
              } catch (e) {
                setStateDialog(() {
                  sending = false;
                  localError = 'Failed to send feedback: $e';
                });
              }
            }

            return AlertDialog(
              backgroundColor: themeManager.isDarkMode ? Color(0xFF2C2C2E) : Color(0xFFFFFFFF),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              title: Row(
                children: [
                  Icon(Icons.feedback_rounded, color: themeManager.isDarkMode ? Color(0xFFD23232) : Color(0xFF0891B2)),
                  const SizedBox(width: 8),
                  Text(
                    'Send Feedback',
                    style: GoogleFonts.montserrat(
                      color: themeManager.isDarkMode ? Color(0xFFD23232) : Color(0xFF0891B2),
                      fontWeight: FontWeight.w700,
                      fontSize: 22,
                    ),
                  ),
                ],
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Share your thoughts, suggestions, or report issues.',
                    style: GoogleFonts.montserrat(
                      fontSize: 14,
                      color: themeManager.isDarkMode ? Color(0xFFE8E8E8) : Color(0xFF2D5263),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    decoration: BoxDecoration(
                      color: themeManager.isDarkMode ? Color(0xFF3C3C3E) : Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 8,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: TextField(
                      controller: controller,
                      maxLines: 5,
                      maxLength: 500,
                      style: TextStyle(color: themeManager.isDarkMode ? Colors.white : Color(0xFF2D5263)),
                      decoration: InputDecoration(
                        hintText: 'Type your message here...',
                        hintStyle: TextStyle(color: themeManager.isDarkMode ? Color(0xFF636366) : Colors.grey.shade400),
                        filled: true,
                        fillColor: themeManager.isDarkMode ? Color(0xFF3C3C3E) : Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: EdgeInsets.all(16),
                        errorText: localError,
                        errorMaxLines: 2,
                      ),
                      enabled: !sending,
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: sending
                      ? null
                      : () => Navigator.of(ctx).pop(false),
                  style: TextButton.styleFrom(
                    foregroundColor: themeManager.isDarkMode ? Color(0xFFD23232) : Color(0xFF0891B2),
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  ),
                  child: Text(
                    'Cancel',
                    style: GoogleFonts.montserrat(
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                    ),
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: sending ? null : doSend,
                  icon: sending
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(Icons.send_rounded, size: 18),
                  label: const Text('Send'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: themeManager.isDarkMode ? Color(0xFFD23232) : Color(0xFF0891B2),
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                ),
              ],
            );
          },
        );
      },
    );

    if (result == true && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Feedback sent! Thank you for your input.',
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
          backgroundColor: Color(0xFF22C55E),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          margin: EdgeInsets.all(16),
        ),
      );
    }
  }

  Widget _buildModernNavBar() {
    final themeManager = Provider.of<ThemeManager>(context);
    return Container(
      decoration: BoxDecoration(
        color: themeManager.isDarkMode ? Color(0xFF2C2C2E) : Colors.white,
        border: Border.all(
          color: themeManager.isDarkMode 
              ? Color(0xFFD23232).withOpacity(0.3)
              : Color(0xFF0891B2).withOpacity(0.3),
          width: 1.5,
        ),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
        boxShadow: [
          BoxShadow(
            color: themeManager.isDarkMode 
                ? Color(0xFFD23232).withOpacity(0.15)
                : Color(0xFF0891B2).withOpacity(0.15),
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
                isSelected: false,
                onTap: () => _onItemTapped(0),
              ),
              _buildNavItem(
                emoji: '📚',
                label: 'Quest',
                isSelected: false,
                onTap: () => _onItemTapped(1),
              ),
              _buildNavItem(
                emoji: '🏆',
                label: 'Ranking',
                isSelected: false,
                onTap: () => _onItemTapped(2),
              ),
              _buildNavItem(
                emoji: '👤',
                label: 'Profile',
                isSelected: true,
                onTap: () => _onItemTapped(3),
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
  }) {
    final themeManager = Provider.of<ThemeManager>(context);
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: isSelected
                ? (themeManager.isDarkMode 
                    ? Color(0xFFD23232).withOpacity(0.1)
                    : Color(0xFF0891B2).withOpacity(0.1))
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
                      ? (themeManager.isDarkMode ? Color(0xFFD23232) : Color(0xFF0891B2))
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

  void _onItemTapped(int index) {
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
    } else if (index == 2) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const LeaderboardPage()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeManager = Provider.of<ThemeManager>(context);
    final user = FirebaseAuth.instance.currentUser;
    final username = _displayName ?? user?.email?.split('@').first ?? 'User';
    final email = user?.email ?? '';

    final level = QuestStatus.level;
    final xp = QuestStatus.xp;
    final xpToNext = QuestStatus.xpToNext;
    final xpProgress = QuestStatus.xpProgress.clamp(0.0, 1.0);
    final points = QuestStatus.userPoints;
    final streakDays = QuestStatus.streakDays;

    return Container(
      decoration: BoxDecoration(
        color: themeManager.isDarkMode ? Color(0xFF1C1C1E) : Color(0xFFCFFFF7),
      ),
      child: SafeArea(
        child: Scaffold(
          backgroundColor: Colors.transparent,
          body: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top bar with back button and title
                Row(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: themeManager.isDarkMode 
                            ? Color(0xFF2C2C2E) 
                            : Colors.white.withOpacity(0.8),
                        shape: BoxShape.circle,
                      ),
                      child: IconButton(
                        icon: Icon(
                          Icons.arrow_back,
                          color: themeManager.isDarkMode ? Color(0xFFD23232) : Color(0xFF0891B2),
                        ),
                        onPressed: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (_) => QuizCategoryScreen(),
                            ),
                          );
                        },
                      ),
                    ),
                    SizedBox(width: 16),
                    Text(
                      'Profile',
                      style: GoogleFonts.montserrat(
                        fontSize: 28,
                        fontWeight: FontWeight.w700,
                        color: themeManager.isDarkMode ? Color(0xFFD23232) : Color(0xFF0891B2),
                      ),
                    ),
                    Spacer(),
                    Container(
                      decoration: BoxDecoration(
                        color: themeManager.isDarkMode 
                            ? Color(0xFF2C2C2E) 
                            : Colors.white.withOpacity(0.8),
                        shape: BoxShape.circle,
                      ),
                      child: IconButton(
                        icon: const Icon(
                          Icons.logout,
                          color: Color(0xFFFF4B4A),
                        ),
                        onPressed: _confirmLogout,
                        tooltip: 'Log out',
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 24),
                // Avatar Card
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    gradient: themeManager.isDarkMode
                        ? LinearGradient(
                            colors: [
                              Color(0xFF2C2C2E),
                              Color(0xFF3C3C3E),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          )
                        : LinearGradient(
                            colors: [
                              Color(0xFFCFFFF7),
                              Color(0xFFA4A9FC).withOpacity(0.3),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: themeManager.isDarkMode 
                            ? Colors.black.withOpacity(0.3)
                            : Color(0xFF0891B2).withOpacity(0.15),
                        blurRadius: 15,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Stack(
                        alignment: Alignment.center,
                        children: [
                          // Avatar with gradient background
                          Container(
                            width: 100,
                            height: 100,
                            decoration: BoxDecoration(
                              gradient: themeManager.isDarkMode
                                  ? LinearGradient(
                                      colors: [Color(0xFFD23232), Color(0xFF8B1F1F)],
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                    )
                                  : LinearGradient(
                                      colors: [Color(0xFF0891B2), Color(0xFF7C7FCC)],
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                    ),
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: themeManager.isDarkMode
                                      ? Color(0xFFD23232).withOpacity(0.3)
                                      : Color(0xFF0891B2).withOpacity(0.3),
                                  blurRadius: 20,
                                  offset: const Offset(0, 8),
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.person,
                              size: 50,
                              color: Colors.white,
                            ),
                          ),
                          // Level badge
                          Positioned(
                            bottom: 0,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: themeManager.isDarkMode ? Color(0xFFD23232) : Color(0xFF0891B2),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: Colors.white,
                                  width: 2,
                                ),
                              ),
                              child: Text(
                                'Lvl $level',
                                style: GoogleFonts.montserrat(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Flexible(
                            child: Text(
                              username,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.montserrat(
                                fontSize: 22,
                                fontWeight: FontWeight.w700,
                                color: themeManager.isDarkMode ? Color(0xFFD23232) : Color(0xFF0891B2),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          InkWell(
                            onTap: _promptEditDisplayName,
                            borderRadius: BorderRadius.circular(16),
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                color: themeManager.isDarkMode 
                                    ? Color(0xFFD23232).withOpacity(0.1)
                                    : Color(0xFF0891B2).withOpacity(0.1),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.edit,
                                size: 18,
                                color: themeManager.isDarkMode ? Color(0xFFD23232) : Color(0xFF0891B2),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        email,
                        style: GoogleFonts.montserrat(
                          fontSize: 14,
                          color: themeManager.isDarkMode 
                              ? Color(0xFF8E8E93) 
                              : Color(0xFF2D5263).withOpacity(0.7),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // XP Progress Card
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: themeManager.isDarkMode
                        ? LinearGradient(
                            colors: [
                              Color(0xFF2C2C2E),
                              Color(0xFF3C3C3E),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          )
                        : LinearGradient(
                            colors: [
                              Color(0xFFCFFFF7),
                              Color(0xFFA4A9FC).withOpacity(0.3),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: themeManager.isDarkMode 
                            ? Colors.black.withOpacity(0.3)
                            : Color(0xFF0891B2).withOpacity(0.15),
                        blurRadius: 15,
                        offset: const Offset(0, 5),
                      ),
                    ],
                    border: Border.all(
                      color: themeManager.isDarkMode 
                          ? Color(0xFF636366).withOpacity(0.3)
                          : Colors.white.withOpacity(0.3),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'XP $xp/$xpToNext',
                            style: GoogleFonts.montserrat(
                              fontWeight: FontWeight.w700,
                              fontSize: 16,
                              color: themeManager.isDarkMode ? Color(0xFFD23232) : Color(0xFF0891B2),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: themeManager.isDarkMode 
                                  ? Color(0xFFD23232).withOpacity(0.15)
                                  : Color(0xFF0891B2).withOpacity(0.15),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              '${(xpToNext - xp).clamp(0, xpToNext)} XP to level up',
                              style: GoogleFonts.montserrat(
                                color: themeManager.isDarkMode ? Color(0xFFD23232) : Color(0xFF0891B2),
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: LinearProgressIndicator(
                          value: xpProgress,
                          backgroundColor: themeManager.isDarkMode 
                              ? Color(0xFF636366).withOpacity(0.3)
                              : Colors.white.withOpacity(0.5),
                          color: themeManager.isDarkMode ? Color(0xFFD23232) : Color(0xFF0891B2),
                          minHeight: 8,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '${(xpProgress * 100).round()}%',
                            style: GoogleFonts.montserrat(
                              fontSize: 12,
                              color: themeManager.isDarkMode 
                                  ? Color(0xFF8E8E93) 
                                  : Color(0xFF2D5263).withOpacity(0.7),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 12),

                // Stat cards: Level, Keys
                Row(
                  children: [
                    Expanded(
                      child: _buildStatCard(
                        icon: Icons.emoji_events,
                        iconColor: themeManager.isDarkMode ? Color(0xFFD23232) : Color(0xFF0891B2),
                        label: 'Level',
                        value: level.toString(),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildStatCard(
                        icon: Icons.key_rounded,
                        iconColor: Color(0xFFFFEB99),
                        label: 'Keys',
                        value: points.toString(),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                // Streak card
                Row(
                  children: [
                    Expanded(
                      child: _buildStatCard(
                        icon: Icons.local_fire_department,
                        iconColor: themeManager.isDarkMode ? Color(0xFF8B1F1F) : Color(0xFF7C7FCC),
                        label: 'Streak',
                        value: '$streakDays days',
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Expanded(child: SizedBox.shrink()),
                  ],
                ),

                const SizedBox(height: 20),

                // Achievements Section
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: Text(
                    'Your Medals',
                    style: GoogleFonts.montserrat(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: themeManager.isDarkMode ? Color(0xFFD23232) : Color(0xFF0891B2),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                _buildAchievementsRow(),

                const SizedBox(height: 24),

                // Dark Mode Toggle
                Consumer<ThemeManager>(
                  builder: (context, themeManager, child) {
                    return Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      decoration: BoxDecoration(
                        color: themeManager.isDarkMode
                            ? Color(0xFF2C2C2E)
                            : Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: themeManager.isDarkMode 
                                ? Colors.black.withOpacity(0.3)
                                : Colors.black.withOpacity(0.08),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: ListTile(
                        leading: Icon(
                          themeManager.isDarkMode
                              ? Icons.dark_mode
                              : Icons.light_mode,
                          color: themeManager.isDarkMode ? Color(0xFFD23232) : Color(0xFF0891B2),
                          size: 28,
                        ),
                        title: Text(
                          'Dark Mode',
                          style: GoogleFonts.montserrat(
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                            color: themeManager.isDarkMode
                                ? Colors.white
                                : const Color(0xFF2D5263),
                          ),
                        ),
                        subtitle: Text(
                          themeManager.isDarkMode ? 'Enabled' : 'Disabled',
                          style: GoogleFonts.montserrat(
                            fontSize: 13,
                            color: themeManager.isDarkMode
                                ? Color(0xFF8E8E93)
                                : Colors.grey[600],
                          ),
                        ),
                        trailing: Transform.scale(
                          scale: 0.9,
                          child: Switch(
                            value: themeManager.isDarkMode,
                            onChanged: (_) => themeManager.toggleTheme(),
                            activeColor: Color(0xFFD23232),
                            activeTrackColor: Color(0xFFD23232).withOpacity(0.5),
                          ),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 4,
                        ),
                      ),
                    );
                  },
                ),

                const SizedBox(height: 16),

                // Feedback Button
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: ElevatedButton.icon(
                    onPressed: _showFeedbackDialog,
                    icon: const Icon(Icons.feedback_outlined),
                    label: Text(
                      'Send Feedback',
                      style: GoogleFonts.montserrat(),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: themeManager.isDarkMode ? Color(0xFFD23232) : Color(0xFF0891B2),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 2,
                    ),
                  ),
                ),

                const SizedBox(height: 28),
              ],
            ),
          ),
          bottomNavigationBar: _buildModernNavBar(),
        ),
      ),
    );
  }

  Widget _buildAchievementsRow() {
    final themeManager = Provider.of<ThemeManager>(context);
    final medals = _allMedals();

    return SizedBox(
      height: 160,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: medals.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (_, i) {
          final medal = medals[i];
          final isUnlocked = medal.unlocked;
          final bg = isUnlocked
              ? (themeManager.isDarkMode 
                  ? medal.color.withOpacity(0.2)
                  : medal.color.withOpacity(0.12))
              : (themeManager.isDarkMode 
                  ? Color(0xFF3C3C3E)
                  : Colors.grey.shade100);
          final border = isUnlocked
              ? medal.color.withOpacity(0.3)
              : (themeManager.isDarkMode 
                  ? Color(0xFF636366).withOpacity(0.2)
                  : Colors.grey.withOpacity(0.2));
          final fg = isUnlocked 
              ? medal.color 
              : (themeManager.isDarkMode ? Color(0xFF636366) : Colors.grey);

          return GestureDetector(
            onTap: () async {
              await showAchievementPopup(
                context,
                title: medal.title,
                description: medal.description,
                unlocked: medal.unlocked,
              );
            },
            child: Container(
              width: 260,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: bg,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: border, width: 1.5),
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
                          style: GoogleFonts.montserrat(
                            fontWeight: FontWeight.w800,
                            color: isUnlocked 
                                ? (themeManager.isDarkMode ? Color(0xFFD23232) : Color(0xFF0891B2))
                                : (themeManager.isDarkMode ? Color(0xFF636366) : Colors.grey),
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          medal.description,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.montserrat(
                            fontSize: 12,
                            height: 1.2,
                            color: isUnlocked 
                                ? (themeManager.isDarkMode ? Color(0xFFE8E8E8) : Color(0xFF2D5263))
                                : (themeManager.isDarkMode ? Color(0xFF636366) : Colors.grey),
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
                                  ? (themeManager.isDarkMode 
                                      ? Color(0xFFD23232).withOpacity(0.15)
                                      : Color(0xFF0891B2).withOpacity(0.15))
                                  : (themeManager.isDarkMode 
                                      ? Color(0xFF636366).withOpacity(0.2)
                                      : Colors.grey.withOpacity(0.2)),
                              borderRadius: BorderRadius.circular(999),
                            ),
                            child: Text(
                              isUnlocked ? 'Unlocked' : 'Locked',
                              style: GoogleFonts.montserrat(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: isUnlocked
                                    ? (themeManager.isDarkMode ? Color(0xFFD23232) : Color(0xFF0891B2))
                                    : (themeManager.isDarkMode ? Color(0xFF636366) : Colors.grey),
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
        },
      ),
    );
  }

  // Build stat card (Level/Keys/Streak) matching home style
  Widget _buildStatCard({
    required IconData icon,
    required Color iconColor,
    required String label,
    required String value,
  }) {
    final themeManager = Provider.of<ThemeManager>(context);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: themeManager.isDarkMode
            ? LinearGradient(
                colors: [Color(0xFF2C2C2E), Color(0xFF3C3C3E)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              )
            : LinearGradient(
                colors: [Colors.white, Color(0xFFCFFFF7).withOpacity(0.3)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: themeManager.isDarkMode 
                ? Colors.black.withOpacity(0.3)
                : Color(0xFF0891B2).withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
        border: Border.all(
          color: themeManager.isDarkMode 
              ? Color(0xFF636366).withOpacity(0.3)
              : Colors.white.withOpacity(0.5),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: iconColor, size: 24),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: GoogleFonts.montserrat(
                  fontSize: 12,
                  color: themeManager.isDarkMode 
                      ? Color(0xFF8E8E93) 
                      : Color(0xFF2D5263).withOpacity(0.7),
                ),
              ),
              Text(
                value,
                style: GoogleFonts.montserrat(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: themeManager.isDarkMode ? Color(0xFFD23232) : Color(0xFF0891B2),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  List<_Medal> _allMedals() {
    return [
      _Medal(
        name: 'Welcome',
        title: 'Welcome',
        description: 'Unlocked a chest for the first time.',
        icon: Icons.emoji_emotions,
        color: Color(0xFF7C7FCC),
        unlocked: QuestStatus.achievements.contains('Welcome'),
      ),
      _Medal(
        name: 'Quiz Novice',
        title: 'Quiz Novice',
        description: 'Finish your first quiz.',
        icon: Icons.school,
        color: Color(0xFF0891B2),
        unlocked: QuestStatus.level1Completed,
      ),
      _Medal(
        name: 'Treasure Hunter',
        title: 'Treasure Hunter',
        description: 'Open 3 chests.',
        icon: Icons.card_giftcard,
        color: Color(0xFFFFEB99),
        unlocked: QuestStatus.chestsOpened >= 3,
      ),
    ];
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