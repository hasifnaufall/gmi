import 'package:flutter/services.dart';
import 'package:flutter/material.dart';

// Call this when the user taps a medal in the Achievements tab
Future<Object?> showAchievementPopup(
  BuildContext context, {
  required String title,
  required String description,
  required bool unlocked,
}) {
  HapticFeedback.selectionClick();

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

  const _AchievementCard({
    required this.title,
    required this.description,
    required this.unlocked,
  });

  @override
  Widget build(BuildContext context) {
    final icon = unlocked ? Icons.emoji_events : Icons.lock_outline;
    final color = unlocked ? Colors.amber : Colors.grey;

    return Material(
      color: Colors.transparent,
      child: Container(
        width: 320,
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.96),
          borderRadius: BorderRadius.circular(22),
          boxShadow: const [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 22,
              offset: Offset(0, 8),
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
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              description,
              style: const TextStyle(fontSize: 14, color: Colors.black54),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 14),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.of(context).maybePop(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: unlocked ? Colors.amber : Colors.grey,
                  foregroundColor: Colors.black,
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
