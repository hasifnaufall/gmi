import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'theme_manager.dart';

// Call this when the user taps a medal in the Achievements tab
Future<Object?> showAchievementPopup(
  BuildContext context, {
  required String title,
  required String description,
  required bool unlocked,
}) {
  HapticFeedback.selectionClick();
  final themeManager = Provider.of<ThemeManager>(context, listen: false);

  return showGeneralDialog(
    context: context,
    barrierDismissible: true,
    barrierLabel: 'achievement',
    barrierColor: Colors.black.withOpacity(0.45),
    transitionDuration: const Duration(milliseconds: 320),
    pageBuilder: (_, __, ___) => const SizedBox.shrink(),
    transitionBuilder: (ctx, anim, _, __) {
      final scale = Tween<double>(
        begin: 0.9,
        end: 1.0,
      ).chain(CurveTween(curve: Curves.easeOutBack)).animate(anim);

      return Stack(
        children: [
          Center(
            child: Transform.scale(
              scale: scale.value,
              child: _AchievementCard(
                title: title,
                description: description,
                unlocked: unlocked,
                themeManager: themeManager,
              ),
            ),
          ),
          // Optional: if you already have a sparkle widget, you can reuse it here.
          // Positioned.fill(child: IgnorePointer(ignoring: true, child: _Sparkles(progress: anim.value))),
        ],
      );
    },
  );
}

class _AchievementCard extends StatelessWidget {
  final String title;
  final String description;
  final bool unlocked;
  final ThemeManager themeManager;

  const _AchievementCard({
    required this.title,
    required this.description,
    required this.unlocked,
    required this.themeManager,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = themeManager.isDarkMode;
    final icon = unlocked ? Icons.emoji_events : Icons.lock_outline;
    final color = unlocked
        ? (isDark ? const Color(0xFFD23232) : Colors.amber)
        : (isDark ? const Color(0xFF636366) : Colors.grey);

    return Material(
      color: Colors.transparent,
      child: Container(
        width: 320,
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
        decoration: BoxDecoration(
          color: isDark
              ? const Color(0xFF2C2C2E).withOpacity(0.96)
              : Colors.white.withOpacity(0.96),
          borderRadius: BorderRadius.circular(22),
          boxShadow: [
            BoxShadow(
              color: isDark ? Colors.black.withOpacity(0.5) : Colors.black26,
              blurRadius: 22,
              offset: const Offset(0, 8),
            ),
          ],
          border: Border.all(color: color.withOpacity(0.25)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircleAvatar(
              radius: 30,
              backgroundColor: color.withOpacity(0.18),
              child: Icon(icon, color: color, size: 30),
            ),
            const SizedBox(height: 10),
            Text(
              title,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: isDark ? const Color(0xFFE8E8E8) : Colors.black,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              description,
              style: TextStyle(
                fontSize: 14,
                color: isDark ? const Color(0xFF8E8E93) : Colors.black54,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 14),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.of(context).maybePop(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: color,
                  foregroundColor: isDark && unlocked
                      ? Colors.white
                      : Colors.black,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                child: Text(unlocked ? 'Nice!' : 'Keep going'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
