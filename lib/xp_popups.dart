import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Fancy XP celebration popup (no 3rd-party packages).
/// Usage: await showXpCelebration(context, xp: 80, leveledUp: 1);
Future<Object?> showXpCelebration(
    BuildContext context, {
      required int xp,
      int leveledUp = 0,
    }) {
  HapticFeedback.lightImpact();

  return showGeneralDialog(
    context: context,
    barrierDismissible: true,
    barrierLabel: 'xp',
    barrierColor: Colors.black.withOpacity(0.45),
    transitionDuration: const Duration(milliseconds: 380),
    pageBuilder: (_, __, ___) => const SizedBox.shrink(),
    transitionBuilder: (ctx, anim, _, __) {
      final scale = Tween<double>(begin: 0.85, end: 1.0)
          .chain(CurveTween(curve: Curves.easeOutBack))
          .animate(anim);

      return Stack(
        children: [
          Center(
            child: Transform.scale(
              scale: scale.value,
              child: _XpCard(xp: xp, leveledUp: leveledUp),
            ),
          ),
          Positioned.fill(
            child: IgnorePointer(
              ignoring: true,
              child: _Sparkles(progress: anim.value),
            ),
          ),
        ],
      );
    },
  );
}

/// Celebration for quiz completion — same style as XP popup.
Future<Object?> showQuizCompleteCelebration(
    BuildContext context, {
      required int score,
      required int total,
      String title = 'Quiz Complete!',
      String subtitle = 'Nice work! You’ve finished the level.',
      String buttonText = 'Continue',
    }) {
  HapticFeedback.mediumImpact();

  return showGeneralDialog(
    context: context,
    barrierDismissible: true,
    barrierLabel: 'quiz-complete',
    barrierColor: Colors.black.withOpacity(0.45),
    transitionDuration: const Duration(milliseconds: 380),
    pageBuilder: (_, __, ___) => const SizedBox.shrink(),
    transitionBuilder: (ctx, anim, _, __) {
      final scale = Tween<double>(begin: 0.85, end: 1.0)
          .chain(CurveTween(curve: Curves.easeOutBack))
          .animate(anim);

      return Stack(
        children: [
          Center(
            child: Transform.scale(
              scale: scale.value,
              child: _QuizCompleteCard(
                title: title,
                subtitle: subtitle,
                score: score,
                total: total,
                buttonText: buttonText,
              ),
            ),
          ),
          Positioned.fill(
            child: IgnorePointer(
              ignoring: true,
              child: _Sparkles(progress: anim.value),
            ),
          ),
        ],
      );
    },
  );
}

class _XpCard extends StatelessWidget {
  final int xp;
  final int leveledUp;

  const _XpCard({required this.xp, required this.leveledUp});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Material(
      color: Colors.transparent,
      child: Container(
        width: 300,
        padding: const EdgeInsets.fromLTRB(20, 18, 20, 16),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.95),
          borderRadius: BorderRadius.circular(20),
          boxShadow: const [
            BoxShadow(color: Colors.black26, blurRadius: 20, offset: Offset(0, 8)),
          ],
          border: Border.all(color: Colors.purple.withOpacity(0.25)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              Icon(Icons.auto_awesome, color: Colors.amber.shade700),
              const SizedBox(width: 8),
              Text('Nice!',
                  style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800)),
            ]),
            const SizedBox(height: 10),
            // Gradient XP amount
            ShaderMask(
              shaderCallback: (r) =>
                  const LinearGradient(colors: [Color(0xFF8E2DE2), Color(0xFF4A00E0)])
                      .createShader(r),
              child: Text(
                '+$xp XP',
                style: const TextStyle(
                  fontSize: 40,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                  letterSpacing: 1.2,
                ),
              ),
            ),
            if (leveledUp > 0) ...[
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.amber.shade100,
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(color: Colors.amber.shade300),
                ),
                child: Row(mainAxisSize: MainAxisSize.min, children: const [
                  Icon(Icons.rocket_launch, size: 18, color: Colors.orange),
                  SizedBox(width: 6),
                  Text('Level Up!', style: TextStyle(fontWeight: FontWeight.w700)),
                ]),
              ),
            ],
            const SizedBox(height: 14),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.of(context).maybePop(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurple,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                child: const Text('Awesome'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _QuizCompleteCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final int score;
  final int total;
  final String buttonText;

  const _QuizCompleteCard({
    required this.title,
    required this.subtitle,
    required this.score,
    required this.total,
    required this.buttonText,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Material(
      color: Colors.transparent,
      child: Container(
        width: 320,
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.95),
          borderRadius: BorderRadius.circular(22),
          boxShadow: const [
            BoxShadow(color: Colors.black26, blurRadius: 22, offset: Offset(0, 8)),
          ],
          border: Border.all(color: Colors.purple.withOpacity(0.25)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              Icon(Icons.emoji_events, color: Colors.amber.shade700),
              const SizedBox(width: 8),
              Text(title, style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800)),
            ]),
            const SizedBox(height: 10),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(color: Colors.black54),
            ),
            const SizedBox(height: 14),
            // Big gradient score text: "5 / 5"
            ShaderMask(
              shaderCallback: (r) =>
                  const LinearGradient(colors: [Color(0xFF8E2DE2), Color(0xFF4A00E0)])
                      .createShader(r),
              child: Text(
                '$score / $total',
                style: const TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                  letterSpacing: 1.1,
                ),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.of(context).maybePop(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurple,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                child: Text(buttonText),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Simple sparkle effect using emoji particles.
class _Sparkles extends StatelessWidget {
  final double progress; // 0..1
  const _Sparkles({required this.progress});

  @override
  Widget build(BuildContext context) {
    final rnd = Random(7);
    final size = MediaQuery.sizeOf(context);
    const count = 28;

    List<Widget> dots = [];
    for (int i = 0; i < count; i++) {
      final angle = (i / count) * pi * 2;
      final radius = Curves.easeOut.transform(progress) * 160;
      final dx = cos(angle) * radius;
      final dy = sin(angle) * radius;

      final baseX = size.width / 2;
      final baseY = size.height / 2 + 10;

      final opacity = (1.0 - progress).clamp(0.0, 1.0);
      final emoji = ['✨', '⭐', '💫', '🔮'][rnd.nextInt(4)];

      dots.add(Positioned(
        left: baseX + dx,
        top: baseY + dy,
        child: Opacity(
          opacity: opacity,
          child: Transform.scale(
            scale: 0.8 + progress * 0.6,
            child: Text(emoji, style: const TextStyle(fontSize: 18)),
          ),
        ),
      ));
    }

    return Stack(children: dots);
  }
}
