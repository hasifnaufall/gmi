// profile.dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart'
    hide Badge; // avoid clash with Material Badge
import 'package:provider/provider.dart';

import 'badges/badges.dart';
import 'badges/badges_engine.dart';
import 'badges/badges_widgets.dart';
import 'badges/badges_screen.dart';

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
  int _selectedAvatarIndex = 0;

  @override
  void initState() {
    super.initState();
    _loadDisplayName();
    _loadAvatarIndex();
  }

  Future<void> _loadDisplayName() async {
    final name = await _progressService.getDisplayName();
    if (!mounted) return;
    setState(() => _displayName = name);
  }

  Future<void> _loadAvatarIndex() async {
    final index = await _progressService.getAvatarIndex();
    if (!mounted) return;
    setState(() => _selectedAvatarIndex = index);
  }

  Future<void> _saveAvatarIndex(int index) async {
    await _progressService.saveAvatarIndex(index);
    setState(() => _selectedAvatarIndex = index);
  }

  List<List<Color>> get _avatarGradients => [
    // 0: Cyan-Purple (default)
    const [Color(0xFF0891B2), Color(0xFF7C7FCC)],
    // 1: Pink-Orange
    const [Color(0xFFEC4899), Color(0xFFF97316)],
    // 2: Green-Blue
    const [Color(0xFF10B981), Color(0xFF06B6D4)],
    // 3: Purple-Pink
    const [Color(0xFF8B5CF6), Color(0xFFEC4899)],
    // 4: Yellow-Red
    const [Color(0xFFFBBF24), Color(0xFFEF4444)],
    // 5: Indigo-Purple
    const [Color(0xFF6366F1), Color(0xFF8B5CF6)],
    // 6: Teal-Green
    const [Color(0xFF14B8A6), Color(0xFF22C55E)],
    // 7: Orange-Pink
    const [Color(0xFFF97316), Color(0xFFEC4899)],
    // 8: Blue-Cyan
    const [Color(0xFF3B82F6), Color(0xFF06B6D4)],
    // 9: Rose-Red
    const [Color(0xFFF43F5E), Color(0xFFDC2626)],
  ];

  Future<void> _showAvatarPicker() async {
    final themeManager = Provider.of<ThemeManager>(context, listen: false);
    await showDialog(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: themeManager.isDarkMode
                  ? [const Color(0xFF2C2C2E), const Color(0xFF1C1C1E)]
                  : [const Color(0xFFFAFAFA), const Color(0xFFF0FDFA)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: themeManager.primary.withOpacity(0.3),
              width: 1.5,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Choose Your Avatar',
                  style: GoogleFonts.montserrat(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: themeManager.isDarkMode
                        ? const Color(0xFFD23232)
                        : const Color(0xFF0891B2),
                  ),
                ),
                const SizedBox(height: 20),
                GridView.builder(
                  shrinkWrap: true,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    mainAxisSpacing: 16,
                    crossAxisSpacing: 16,
                  ),
                  itemCount: _avatarGradients.length,
                  itemBuilder: (_, i) {
                    final isSelected = i == _selectedAvatarIndex;
                    return GestureDetector(
                      onTap: () {
                        _saveAvatarIndex(i);
                        Navigator.pop(ctx);
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: isSelected
                                ? (themeManager.isDarkMode
                                      ? const Color(0xFFD23232)
                                      : const Color(0xFF0891B2))
                                : Colors.transparent,
                            width: 3,
                          ),
                        ),
                        child: Container(
                          margin: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: _avatarGradients[i],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: _avatarGradients[i][0].withOpacity(0.4),
                                blurRadius: 12,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.person,
                            size: 40,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 20),
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: Text(
                    'Cancel',
                    style: GoogleFonts.montserrat(
                      fontWeight: FontWeight.w600,
                      color: themeManager.isDarkMode
                          ? const Color(0xFF8E8E93)
                          : const Color(0xFF6B7280),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
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
                if (mounted) setState(() => _displayName = raw);
                Navigator.of(ctx).pop(true);
              } catch (e) {
                setStateDialog(() => saving = false);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Failed to update name: $e')),
                );
              }
            }

            return AlertDialog(
              backgroundColor: themeManager.isDarkMode
                  ? const Color(0xFF2C2C2E)
                  : const Color(0xFFFFFFFF),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              title: Text(
                'Edit Display Name',
                style: GoogleFonts.montserrat(
                  color: themeManager.isDarkMode
                      ? const Color(0xFFD23232)
                      : const Color(0xFF0891B2),
                  fontWeight: FontWeight.w700,
                  fontSize: 22,
                ),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: themeManager.isDarkMode
                          ? const Color(0xFF3C3C3E)
                          : Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: TextField(
                      controller: controller,
                      style: TextStyle(
                        color: themeManager.isDarkMode
                            ? Colors.white
                            : const Color(0xFF2D5263),
                      ),
                      decoration: InputDecoration(
                        labelText: 'Display name',
                        labelStyle: GoogleFonts.montserrat(
                          color: themeManager.isDarkMode
                              ? const Color(0xFF8E8E93)
                              : const Color(0xFF2D5263),
                        ),
                        prefixIcon: Icon(
                          Icons.person_outline,
                          color: themeManager.isDarkMode
                              ? const Color(0xFFD23232)
                              : const Color(0xFF0891B2),
                        ),
                        errorText: localError,
                        filled: true,
                        fillColor: themeManager.isDarkMode
                            ? const Color(0xFF3C3C3E)
                            : Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(
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
                    foregroundColor: themeManager.isDarkMode
                        ? const Color(0xFFD23232)
                        : const Color(0xFF0891B2),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 12,
                    ),
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
                    backgroundColor: themeManager.isDarkMode
                        ? const Color(0xFFD23232)
                        : const Color(0xFF0891B2),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 12,
                    ),
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
          backgroundColor: themeManager.isDarkMode
              ? const Color(0xFFD23232)
              : const Color(0xFF0891B2),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          margin: const EdgeInsets.all(16),
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
        backgroundColor: themeManager.isDarkMode
            ? const Color(0xFF2C2C2E)
            : const Color(0xFFFFFFFF),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'Log out?',
          style: GoogleFonts.montserrat(
            color: themeManager.isDarkMode
                ? const Color(0xFFD23232)
                : const Color(0xFF0891B2),
            fontWeight: FontWeight.w700,
            fontSize: 22,
          ),
        ),
        content: Text(
          'Are you sure you want to log out of your account?',
          style: GoogleFonts.montserrat(
            color: themeManager.isDarkMode
                ? const Color(0xFFE8E8E8)
                : const Color(0xFF2D5263),
            fontSize: 16,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            style: TextButton.styleFrom(
              foregroundColor: themeManager.isDarkMode
                  ? const Color(0xFFD23232)
                  : const Color(0xFF0891B2),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
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
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
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
                QuestStatus.feedbackSent = true;
                await BadgeEngine.checkAndToast(context);
                if (mounted) Navigator.of(ctx).pop(true);
              } catch (e) {
                setStateDialog(() {
                  sending = false;
                  localError = 'Failed to send feedback: $e';
                });
              }
            }

            return AlertDialog(
              backgroundColor: themeManager.isDarkMode
                  ? const Color(0xFF2C2C2E)
                  : const Color(0xFFFFFFFF),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              title: Row(
                children: [
                  Icon(
                    Icons.feedback_rounded,
                    color: themeManager.isDarkMode
                        ? const Color(0xFFD23232)
                        : const Color(0xFF0891B2),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Send Feedback',
                    style: GoogleFonts.montserrat(
                      color: themeManager.isDarkMode
                          ? const Color(0xFFD23232)
                          : const Color(0xFF0891B2),
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
                      color: themeManager.isDarkMode
                          ? const Color(0xFFE8E8E8)
                          : const Color(0xFF2D5263),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    decoration: BoxDecoration(
                      color: themeManager.isDarkMode
                          ? const Color(0xFF3C3C3E)
                          : Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: TextField(
                      controller: controller,
                      maxLines: 5,
                      maxLength: 500,
                      style: TextStyle(
                        color: themeManager.isDarkMode
                            ? Colors.white
                            : const Color(0xFF2D5263),
                      ),
                      decoration: InputDecoration(
                        hintText: 'Type your message here...',
                        hintStyle: TextStyle(
                          color: themeManager.isDarkMode
                              ? const Color(0xFF636366)
                              : Colors.grey.shade400,
                        ),
                        filled: true,
                        fillColor: themeManager.isDarkMode
                            ? const Color(0xFF3C3C3E)
                            : Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.all(16),
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
                    foregroundColor: themeManager.isDarkMode
                        ? const Color(0xFFD23232)
                        : const Color(0xFF0891B2),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 12,
                    ),
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
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(Icons.send_rounded, size: 20),
                  label: const Text('Send'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: themeManager.isDarkMode
                        ? const Color(0xFFD23232)
                        : const Color(0xFF0891B2),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      vertical: 18,
                      horizontal: 24,
                    ),
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
          content: const Text(
            'Feedback sent! Thank you for your input.',
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
          backgroundColor: const Color(0xFF22C55E),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          margin: const EdgeInsets.all(16),
        ),
      );
    }
  }

  Widget _buildModernNavBar() {
    final themeManager = Provider.of<ThemeManager>(context);
    return Container(
      decoration: BoxDecoration(
        color: themeManager.isDarkMode ? const Color(0xFF2C2C2E) : Colors.white,
        border: Border.all(
          color: themeManager.isDarkMode
              ? const Color(0xFFD23232).withOpacity(0.3)
              : const Color(0xFF0891B2).withOpacity(0.3),
          width: 1.5,
        ),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
        boxShadow: [
          BoxShadow(
            color: themeManager.isDarkMode
                ? const Color(0xFFD23232).withOpacity(0.15)
                : const Color(0xFF0891B2).withOpacity(0.15),
            blurRadius: 20,
            offset: const Offset(0, -5),
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
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: isSelected
                ? (themeManager.isDarkMode
                      ? const Color(0xFFD23232).withOpacity(0.1)
                      : const Color(0xFF0891B2).withOpacity(0.1))
                : Colors.transparent,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(emoji, style: TextStyle(fontSize: isSelected ? 28 : 24)),
              const SizedBox(height: 4),
              Text(
                label,
                style: GoogleFonts.montserrat(
                  fontSize: 11,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                  color: isSelected
                      ? (themeManager.isDarkMode
                            ? const Color(0xFFD23232)
                            : const Color(0xFF0891B2))
                      : (themeManager.isDarkMode
                            ? const Color(0xFF8E8E93)
                            : const Color(0xFF2D5263).withOpacity(0.6)),
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
        color: themeManager.isDarkMode
            ? const Color(0xFF1C1C1E)
            : const Color(0xFFCFFFF7),
      ),
      child: SafeArea(
        child: Scaffold(
          backgroundColor: Colors.transparent,
          body: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top bar
                Row(
                  children: [
                    Text(
                      'Profile',
                      style: GoogleFonts.montserrat(
                        fontSize: 28,
                        fontWeight: FontWeight.w700,
                        color: themeManager.isDarkMode
                            ? const Color(0xFFD23232)
                            : const Color(0xFF0891B2),
                      ),
                    ),
                    const Spacer(),
                    Container(
                      decoration: BoxDecoration(
                        color: themeManager.isDarkMode
                            ? const Color(0xFF2C2C2E)
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
                        ? const LinearGradient(
                            colors: [Color(0xFF2C2C2E), Color(0xFF3C3C3E)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          )
                        : LinearGradient(
                            colors: [
                              const Color(0xFFCFFFF7),
                              const Color(0xFFA4A9FC),
                            ].map((c) => c.withOpacity(0.3)).toList(),
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: themeManager.isDarkMode
                            ? Colors.black.withOpacity(0.3)
                            : const Color(0xFF0891B2).withOpacity(0.15),
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
                          GestureDetector(
                            onTap: _showAvatarPicker,
                            child: Container(
                              width: 100,
                              height: 100,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors:
                                      _avatarGradients[_selectedAvatarIndex],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color:
                                        _avatarGradients[_selectedAvatarIndex][0]
                                            .withOpacity(0.3),
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
                          ),
                          Positioned(
                            top: 0,
                            right: 0,
                            child: GestureDetector(
                              onTap: _showAvatarPicker,
                              child: Container(
                                padding: const EdgeInsets.all(6),
                                decoration: BoxDecoration(
                                  color: themeManager.isDarkMode
                                      ? const Color(0xFFD23232)
                                      : const Color(0xFF0891B2),
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: Colors.white,
                                    width: 2,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.2),
                                      blurRadius: 8,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: const Icon(
                                  Icons.palette_rounded,
                                  size: 16,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                          Positioned(
                            bottom: 0,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: themeManager.isDarkMode
                                    ? const Color(0xFFD23232)
                                    : const Color(0xFF0891B2),
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
                                color: themeManager.isDarkMode
                                    ? const Color(0xFFD23232)
                                    : const Color(0xFF0891B2),
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
                                    ? const Color(0xFFD23232).withOpacity(0.1)
                                    : const Color(0xFF0891B2).withOpacity(0.1),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.edit,
                                size: 18,
                                color: themeManager.isDarkMode
                                    ? const Color(0xFFD23232)
                                    : const Color(0xFF0891B2),
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
                              ? const Color(0xFF8E8E93)
                              : const Color(0xFF2D5263).withOpacity(0.7),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // XP Progress
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: themeManager.isDarkMode
                        ? const LinearGradient(
                            colors: [Color(0xFF2C2C2E), Color(0xFF3C3C3E)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          )
                        : LinearGradient(
                            colors: [
                              const Color(0xFFCFFFF7),
                              const Color(0xFFA4A9FC),
                            ].map((c) => c.withOpacity(0.3)).toList(),
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: themeManager.isDarkMode
                            ? Colors.black.withOpacity(0.3)
                            : const Color(0xFF0891B2).withOpacity(0.15),
                        blurRadius: 15,
                        offset: const Offset(0, 5),
                      ),
                    ],
                    border: Border.all(
                      color: themeManager.isDarkMode
                          ? const Color(0xFF636366).withOpacity(0.3)
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
                              color: themeManager.isDarkMode
                                  ? const Color(0xFFD23232)
                                  : const Color(0xFF0891B2),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: themeManager.isDarkMode
                                  ? const Color(0xFFD23232).withOpacity(0.15)
                                  : const Color(0xFF0891B2).withOpacity(0.15),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              '${(xpToNext - xp).clamp(0, xpToNext)} XP to level up',
                              style: GoogleFonts.montserrat(
                                color: themeManager.isDarkMode
                                    ? const Color(0xFFD23232)
                                    : const Color(0xFF0891B2),
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
                              ? const Color(0xFF636366).withOpacity(0.3)
                              : Colors.white.withOpacity(0.5),
                          color: themeManager.isDarkMode
                              ? const Color(0xFFD23232)
                              : const Color(0xFF0891B2),
                          minHeight: 8,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '${(xpProgress * 100).round()}%',
                        style: GoogleFonts.montserrat(
                          fontSize: 12,
                          color: themeManager.isDarkMode
                              ? const Color(0xFF8E8E93)
                              : const Color(0xFF2D5263).withOpacity(0.7),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 12),

                // Stats
                Row(
                  children: [
                    Expanded(
                      child: _buildStatCard(
                        icon: Icons.emoji_events,
                        iconColor: themeManager.isDarkMode
                            ? const Color(0xFFD23232)
                            : const Color(0xFF0891B2),
                        label: 'Level',
                        value: level.toString(),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildStatCard(
                        icon: Icons.key_rounded,
                        iconColor: const Color(0xFFFFEB99),
                        label: 'Keys',
                        value: points.toString(),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _buildStatCard(
                        icon: Icons.local_fire_department,
                        iconColor: themeManager.isDarkMode
                            ? const Color(0xFF8B1F1F)
                            : const Color(0xFF7C7FCC),
                        label: 'Streak',
                        value: '$streakDays days',
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Expanded(child: SizedBox.shrink()),
                  ],
                ),

                const SizedBox(height: 20),

                // ===== Achievements (horizontal) + Badges (images-only) =====
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: Text(
                    'Your Achievement',
                    style: GoogleFonts.montserrat(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: themeManager.isDarkMode
                          ? const Color(0xFFD23232)
                          : const Color(0xFF0891B2),
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                FutureBuilder<(List<Badge>, List<String>)>(
                  future: BadgeEngine.evaluateAndSave(),
                  builder: (ctx, snap) {
                    if (snap.connectionState == ConnectionState.waiting) {
                      return SizedBox(
                        height: 140,
                        child: Center(
                          child: CircularProgressIndicator(
                            color: themeManager.isDarkMode
                                ? const Color(0xFFD23232)
                                : const Color(0xFF0891B2),
                          ),
                        ),
                      );
                    }
                    if (snap.hasError) {
                      return Padding(
                        padding: const EdgeInsets.all(12),
                        child: Text(
                          'Failed to load badges: ${snap.error}',
                          style: GoogleFonts.montserrat(
                            color: themeManager.isDarkMode
                                ? const Color(0xFF8E8E93)
                                : Colors.grey,
                          ),
                        ),
                      );
                    }
                    if (!snap.hasData) return const SizedBox();

                    final (badges, _) = snap.data!;
                    final unlocked = badges
                        .where((b) => b.state == BadgeState.unlocked)
                        .toList();
                    final inProg = badges
                        .where((b) => b.state == BadgeState.inProgress)
                        .toList();
                    final locked = badges
                        .where((b) => b.state == BadgeState.locked)
                        .toList();

                    final featured = [
                      ...unlocked.take(3),
                      ...inProg.take(2),
                      if (unlocked.length + inProg.length < 5)
                        ...locked.take(5 - (unlocked.length + inProg.length)),
                    ].take(5).toList();

                    if (featured.isEmpty) {
                      return Text(
                        'No achievements yet. Start a quiz to earn your first one!',
                        style: GoogleFonts.montserrat(
                          color: themeManager.isDarkMode
                              ? const Color(0xFF8E8E93)
                              : Colors.grey,
                        ),
                      );
                    }

                    // ---- achievement card (horizontal) ----
                    Widget achievementCard(Badge b) {
                      final isUnlocked = b.state == BadgeState.unlocked;
                      final isProgress = b.state == BadgeState.inProgress;

                      final chipBg = isUnlocked
                          ? (themeManager.isDarkMode
                                ? const Color(0xFFD23232).withOpacity(0.15)
                                : const Color(0xFF0891B2).withOpacity(0.15))
                          : isProgress
                          ? const Color(0xFFEAB308).withOpacity(0.15)
                          : (themeManager.isDarkMode
                                ? const Color(0xFF636366).withOpacity(0.2)
                                : Colors.grey.withOpacity(0.2));

                      final chipFg = isUnlocked
                          ? (themeManager.isDarkMode
                                ? const Color(0xFFD23232)
                                : const Color(0xFF0891B2))
                          : isProgress
                          ? const Color(0xFFEAB308)
                          : (themeManager.isDarkMode
                                ? const Color(0xFF8E8E93)
                                : Colors.grey);

                      final IconData stateIcon = isUnlocked
                          ? Icons.emoji_events
                          : (isProgress
                                ? Icons.hourglass_bottom
                                : Icons.lock_outline);

                      final cardBorder = themeManager.isDarkMode
                          ? const Color(0xFF636366).withOpacity(0.3)
                          : Colors.white.withOpacity(0.5);

                      return GestureDetector(
                        onTap: () {
                          showModalBottomSheet(
                            context: context,
                            backgroundColor: Colors.transparent,
                            isScrollControlled: true,
                            builder: (_) => BadgeDetailSheet(badge: b),
                          );
                        },
                        child: SizedBox(
                          width: 290,
                          child: Container(
                            margin: const EdgeInsets.only(right: 12),
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              gradient: themeManager.isDarkMode
                                  ? const LinearGradient(
                                      colors: [
                                        Color(0xFF2C2C2E),
                                        Color(0xFF3C3C3E),
                                      ],
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                    )
                                  : const LinearGradient(
                                      colors: [Colors.white, Color(0xFFCFFFF7)],
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                    ),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: cardBorder),
                              boxShadow: [
                                BoxShadow(
                                  color: themeManager.isDarkMode
                                      ? Colors.black.withOpacity(0.25)
                                      : const Color(
                                          0xFF0891B2,
                                        ).withOpacity(0.08),
                                  blurRadius: 12,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                CircleAvatar(
                                  radius: 22,
                                  backgroundColor: chipBg,
                                  child: Icon(
                                    stateIcon,
                                    color: chipFg,
                                    size: 22,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        b.title,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: GoogleFonts.montserrat(
                                          fontWeight: FontWeight.w800,
                                          fontSize: 16,
                                          color: themeManager.isDarkMode
                                              ? const Color(0xFFE8E8E8)
                                              : const Color(0xFF2D5263),
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        b.description,
                                        maxLines: 3,
                                        overflow: TextOverflow.ellipsis,
                                        style: GoogleFonts.montserrat(
                                          fontSize: 12,
                                          height: 1.28,
                                          color: themeManager.isDarkMode
                                              ? const Color(0xFF8E8E93)
                                              : const Color(0xFF2D5263),
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 10,
                                          vertical: 4,
                                        ),
                                        decoration: BoxDecoration(
                                          color: chipBg,
                                          borderRadius: BorderRadius.circular(
                                            999,
                                          ),
                                        ),
                                        child: Text(
                                          isUnlocked
                                              ? 'Unlocked'
                                              : (isProgress
                                                    ? 'In progress'
                                                    : 'Locked'),
                                          style: GoogleFonts.montserrat(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w700,
                                            color: chipFg,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    }

                    // ---- badges-only circle using REAL IMAGES ----
                    Widget badgeDot(Badge b, int index) {
                      final isUnlocked = b.state == BadgeState.unlocked;

                      // Map index -> asset path (cycle if more badges than images)
                      const badgeImages = [
                        'assets/images/module1.png',
                        'assets/images/module2.png',
                        'assets/images/module3.png',
                        'assets/images/module4.png',
                        'assets/images/module5.png',
                        'assets/images/module6.png',
                        'assets/images/module7.png',
                        'assets/images/module8.png',
                        'assets/images/module9.png',
                        'assets/images/module10.png',
                        'assets/images/module11.png',
                        'assets/images/module12.png',
                      ];
                      final imgPath = badgeImages[index % badgeImages.length];

                      return GestureDetector(
                        onTap: () {
                          showModalBottomSheet(
                            context: context,
                            backgroundColor: Colors.transparent,
                            isScrollControlled: true,
                            builder: (_) => BadgeDetailSheet(badge: b),
                          );
                        },
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            Container(
                              width: 70,
                              height: 70,
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                              ),
                              child: ClipOval(
                                child: Image.asset(imgPath, fit: BoxFit.cover),
                              ),
                            ),
                            if (!isUnlocked)
                              Container(
                                width: 70,
                                height: 70,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.black.withOpacity(0.5),
                                ),
                                child: const Icon(
                                  Icons.lock,
                                  color: Colors.white,
                                  size: 28,
                                ),
                              ),
                          ],
                        ),
                      );
                    }

                    // Achievements horizontal list
                    final achievementsList = SizedBox(
                      height: 140,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        physics: const BouncingScrollPhysics(),
                        itemCount: featured.length,
                        separatorBuilder: (_, __) => const SizedBox(width: 12),
                        itemBuilder: (_, i) => achievementCard(featured[i]),
                      ),
                    );

                    // Build section
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        achievementsList,
                        const SizedBox(height: 16),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Your Badges',
                                style: GoogleFonts.montserrat(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w700,
                                  color: themeManager.isDarkMode
                                      ? const Color(0xFFD23232)
                                      : const Color(0xFF0891B2),
                                ),
                              ),
                              TextButton(
                                onPressed: () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => BadgesScreen(),
                                  ),
                                ),
                                child: Text(
                                  'View all',
                                  style: GoogleFonts.montserrat(
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 12),
                        SizedBox(
                          height: 78,
                          child: ListView.separated(
                            scrollDirection: Axis.horizontal,
                            itemCount: featured.length,
                            separatorBuilder: (_, __) =>
                                const SizedBox(width: 12),
                            itemBuilder: (_, i) => badgeDot(featured[i], i),
                          ),
                        ),
                      ],
                    );
                  },
                ),

                const SizedBox(height: 16),
                // Dark Mode Toggle
                Consumer<ThemeManager>(
                  builder: (context, themeManager, child) {
                    return Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      decoration: BoxDecoration(
                        color: themeManager.isDarkMode
                            ? const Color(0xFF1A1F26)
                            : Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.08),
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
                          color: const Color(0xFF0891B2),
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
                                ? Colors.grey[400]
                                : Colors.grey[600],
                          ),
                        ),
                        trailing: Transform.scale(
                          scale: 0.9,
                          child: Switch(
                            value: themeManager.isDarkMode,
                            onChanged: (_) => themeManager.toggleTheme(),
                            activeColor: const Color(0xFF0891B2),
                            activeTrackColor: const Color(0xFF69D3E4),
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

                // Feedback
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
                      backgroundColor: themeManager.isDarkMode
                          ? const Color(0xFFD23232)
                          : const Color(0xFF0891B2),
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
                    ? const Color(0xFF3C3C3E)
                    : Colors.grey.shade100);
          final border = isUnlocked
              ? medal.color.withOpacity(0.3)
              : (themeManager.isDarkMode
                    ? const Color(0xFF636366).withOpacity(0.2)
                    : Colors.grey.withOpacity(0.2));
          final fg = isUnlocked
              ? medal.color
              : (themeManager.isDarkMode
                    ? const Color(0xFF636366)
                    : Colors.grey);

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
                                ? (themeManager.isDarkMode
                                      ? Colors.white
                                      : const Color(0xFF0891B2))
                                : (themeManager.isDarkMode
                                      ? const Color(0xFF636366)
                                      : Colors.grey),
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
                                ? (themeManager.isDarkMode
                                      ? const Color(0xFFE8E8E8)
                                      : const Color(0xFF2D5263))
                                : (themeManager.isDarkMode
                                      ? const Color(0xFF636366)
                                      : Colors.grey),
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
                                        ? Colors.white.withOpacity(0.15)
                                        : const Color(
                                            0xFF0891B2,
                                          ).withOpacity(0.15))
                                  : (themeManager.isDarkMode
                                        ? const Color(
                                            0xFF636366,
                                          ).withOpacity(0.2)
                                        : Colors.grey.withOpacity(0.2)),
                              borderRadius: BorderRadius.circular(999),
                            ),
                            child: Text(
                              isUnlocked ? 'Unlocked' : 'Locked',
                              style: GoogleFonts.montserrat(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: isUnlocked
                                    ? (themeManager.isDarkMode
                                          ? Colors.white
                                          : const Color(0xFF0891B2))
                                    : (themeManager.isDarkMode
                                          ? const Color(0xFF636366)
                                          : Colors.grey),
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
            ? const LinearGradient(
                colors: [Color(0xFF2C2C2E), Color(0xFF3C3C3E)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              )
            : const LinearGradient(
                colors: [Colors.white, Color(0xFFCFFFF7)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: themeManager.isDarkMode
                ? Colors.black.withOpacity(0.3)
                : const Color(0xFF0891B2).withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
        border: Border.all(
          color: themeManager.isDarkMode
              ? const Color(0xFF636366).withOpacity(0.3)
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
                      ? Colors.white.withOpacity(0.7)
                      : const Color(0xFF2D5263).withOpacity(0.7),
                ),
              ),
              Text(
                value,
                style: GoogleFonts.montserrat(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: themeManager.isDarkMode
                      ? Colors.white
                      : const Color(0xFF0891B2),
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
        color: const Color(0xFF7C7FCC),
        unlocked: QuestStatus.achievements.contains('Welcome'),
      ),
      _Medal(
        name: 'Quiz Novice',
        title: 'Quiz Novice',
        description: 'Finish your first quiz.',
        icon: Icons.school,
        color: const Color(0xFF0891B2),
        unlocked: QuestStatus.level1Completed,
      ),
      _Medal(
        name: 'Treasure Hunter',
        title: 'Treasure Hunter',
        description: 'Open 3 chests.',
        icon: Icons.card_giftcard,
        color: const Color(0xFFFFEB99),
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
