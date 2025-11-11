// lib/badges/badges_engine.dart
import 'package:flutter/material.dart' hide Badge;
import '../quest_status.dart';
import 'badges.dart';

class BadgeEngine {
  /// Call this when a quiz run finishes.
  /// [category] e.g. 'alphabet' | 'numbers' | 'colours' | 'animals' | ...
  /// [perfect]  whether the run had all answers correct.
  /// [mode] quiz type name: 'multipleChoice' | 'mixMatch' | 'both'
  /// [total] total number of questions (optional, not used currently)
  static Future<void> recordRun({
    required String category,
    required bool perfect,
    String? mode,
    int? total, // Accept total parameter (even if not used)
    int? score, // <-- ADDED to match call sites (optional)
  }) async {
    // Update general counters
    QuestStatus.quizzesCompleted += 1;
    if (perfect) {
      QuestStatus.perfectQuizzes += 1;
    }

    // Optional: compute or use score if you want
    // final computedScore = score ?? (perfect ? 100 : 0);
    // You could persist or display this if needed.

    // Use mode parameter to set completed flags
    if (mode == 'multipleChoice' || mode == 'both') {
      QuestStatus.completedMC = true;
    }
    if (mode == 'mixMatch' || mode == 'both') {
      QuestStatus.completedMM = true;
    }

    // Mark categories
    switch (category.toLowerCase()) {
      case 'alphabet':
        QuestStatus.playedAlphabet = true;
        break;
      case 'numbers':
      case 'number':
        QuestStatus.playedNumbers = true;
        break;
      case 'colours':
      case 'colors':
      case 'colour':
      case 'color':
        QuestStatus.playedColours = true;
        break;
      default:
      // no-op
        break;
    }

    // Example: simple XP & keys
    QuestStatus.addXp(perfect ? 25 : 15);
    QuestStatus.userPoints += perfect ? 5 : 2;

    // Check if quiz is completed but achievement not yet added
    if (QuestStatus.level1Completed && !QuestStatus.achievements.contains('Welcome')) {
      QuestStatus.achievements.add('Welcome');
    }
  }

  /// Compute badge states and return (badges, newlyUnlockedBadgeIds).
  static Future<(List<Badge>, List<String>)> evaluateAndSave() async {
    final all = <Badge>[
      Badge(
        id: 'welcome',
        title: 'Welcome',
        description: 'Unlocked a chest for the first time.',
        icon: Icons.emoji_emotions,
        rarity: BadgeRarity.common,
        target: 1,
        progress: QuestStatus.achievements.contains('Welcome') ? 1 : 0,
      ),
      Badge(
        id: 'first_quiz',
        title: 'Quiz Novice',
        description: 'Finish your first quiz.',
        icon: Icons.school,
        rarity: BadgeRarity.common,
        target: 1,
        progress: QuestStatus.quizzesCompleted > 0 ? 1 : 0,
      ),
      Badge(
        id: 'three_chests',
        title: 'Treasure Hunter',
        description: 'Open 3 chests.',
        icon: Icons.card_giftcard,
        rarity: BadgeRarity.rare,
        target: 3,
        progress: QuestStatus.chestsOpened,
      ),
      Badge(
        id: 'perfect_5',
        title: 'Sharp Shooter',
        description: 'Get 5 perfect quizzes.',
        icon: Icons.workspace_premium,
        rarity: BadgeRarity.epic,
        target: 5,
        progress: QuestStatus.perfectQuizzes,
      ),
      Badge(
        id: 'both_modes',
        title: 'Versatile',
        description: 'Complete both MCQ and Mix & Match at least once.',
        icon: Icons.extension,
        rarity: BadgeRarity.rare,
        target: 2,
        progress: (QuestStatus.completedMC ? 1 : 0) + (QuestStatus.completedMM ? 1 : 0),
      ),
      Badge(
        id: 'social_feedback',
        title: 'Voice Heard',
        description: 'Send your first feedback.',
        icon: Icons.feedback_rounded,
        rarity: BadgeRarity.common,
        target: 1,
        progress: QuestStatus.feedbackSent ? 1 : 0,
      ),
    ];

    // In-memory "newly unlocked" detection (no persistence yet).
    final newly = <String>[];
    for (final b in all) {
      if (b.progress >= b.target) {
        newly.add(b.id);
      }
    }

    return (all, newly);
  }

  /// Optional toast helper (noop here, keep your own UI toasts if any).
  static Future<void> checkAndToast(BuildContext context) async {
    await evaluateAndSave();
  }
}
