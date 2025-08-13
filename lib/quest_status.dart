class QuestStatus {
  // ================= Level 1 (Alphabet) =================
  /// Per-question results: null = unanswered, true = correct, false = wrong
  static List<bool?> level1Answers = List<bool?>.filled(5, null);

  static int get completedQuestions => level1Answers.where((e) => e != null).length;
  static bool get level1Completed => level1Answers.every((e) => e != null);
  static int get level1Score => level1Answers.where((e) => e == true).length;

  static void ensureLevel1Length(int length) {
    if (level1Answers.length != length) {
      final old = level1Answers;
      level1Answers = List<bool?>.filled(length, null);
      for (int i = 0; i < length && i < old.length; i++) {
        level1Answers[i] = old[i];
      }
    }
  }

  // ================= Keys / Quests =================
  static int userPoints = 0;            // keys (quests may still award these)
  static bool quest1Claimed = false;    // "Complete 3 Questions"
  static bool quest2Claimed = false;    // "Complete Level 1"

  // ================= Chest Progress (CLAIMS-based) =================
  /// Progress points from claims (Quest1 +15, Quest2 +15, ...)
  static int claimedPoints = 0;

  /// Current chest tier target (starts at 30; after chest -> 50; then +50 each time)
  static int levelGoalPoints = 30;

  /// Count of opened chests
  static int chestsOpened = 0;

  /// Advance chest tier size (30 -> 50 -> 100 -> 150 ...)
  static void advanceChestTier() {
    if (levelGoalPoints < 50) {
      levelGoalPoints = 50; // 30 -> 50
    } else {
      levelGoalPoints += 50; // 50 -> 100 -> 150 ...
    }
    // If you want to reset progress after each chest, uncomment:
    // claimedPoints = 0;
  }

  // ================= Achievements =================
  /// Store unlocked achievement names
  static Set<String> achievements = <String>{};

  /// Returns true if it's newly unlocked
  static bool awardAchievement(String name) {
    if (achievements.contains(name)) return false;
    achievements.add(name);
    return true;
  }

  // ================= XP / Level =================
  static int xp = 0;      // XP toward next level (rollover kept here)
  static int level = 1;

  /// XP required per level (simple linear curve)
  static int xpForLevel(int lvl) => 100 + (lvl - 1) * 50;
  static int get xpToNext => xpForLevel(level);
  static double get xpProgress => xpToNext == 0 ? 0 : xp / xpToNext;

  /// Add XP, handle rollovers, and return how many levels were gained
  static int addXp(int amount) {
    int levelsUp = 0;
    xp += amount;
    while (xp >= xpToNext) {
      xp -= xpToNext; // rollover to next level
      level += 1;
      levelsUp += 1;
    }
    return levelsUp;
  }

  // ================= Resets =================
  static void resetLevel1Answers() {
    for (int i = 0; i < level1Answers.length; i++) {
      level1Answers[i] = null;
    }
  }

  static void resetChestProgress() {
    claimedPoints = 0;
    levelGoalPoints = 30;
    chestsOpened = 0;
  }

  static void resetXp() {
    xp = 0;
    level = 1;
  }

  static void resetAll() {
    resetLevel1Answers();
    quest1Claimed = false;
    quest2Claimed = false;
    userPoints = 0;
    achievements.clear();
    resetChestProgress();
    resetXp();
  }
}
