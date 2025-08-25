// quest_status.dart
// In-memory only: no persistence. Perfect for testing.
// Everything resets when the app restarts.

class QuestStatus {
  // ================= Level 1 (Alphabet) =================
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
  static int userPoints = 0;            // in-app currency ("keys")
  static bool quest1Claimed = false;    // "Complete 3 Questions"
  static bool quest2Claimed = false;    // "Complete Level 1"

  static bool canClaimQuest1() => completedQuestions >= 3 && !quest1Claimed;
  static int claimQuest1({int reward = 100, int progress = 15}) {
    if (!canClaimQuest1()) return 0;
    quest1Claimed = true;
    userPoints += reward;
    claimedPoints += progress;
    return reward;
  }

  static bool canClaimQuest2() => level1Completed && !quest2Claimed;
  static int claimQuest2({int reward = 100, int progress = 15}) {
    if (!canClaimQuest2()) return 0;
    quest2Claimed = true;
    userPoints += reward;
    claimedPoints += progress;
    return reward;
  }

  // ================= Chest Progress =================
  static int claimedPoints = 0;
  static int levelGoalPoints = 30;
  static int chestsOpened = 0;
  static void advanceChestTier() {
    if (levelGoalPoints < 50) {
      levelGoalPoints = 50;
    } else {
      levelGoalPoints += 50;
    }
    // claimedPoints = 0; // optional reset after open
  }

  // ================= Achievements =================
  static Set<String> achievements = <String>{};
  static bool awardAchievement(String name) {
    if (achievements.contains(name)) return false;
    achievements.add(name);
    return true;
  }

  // ------- One-time Medal (session only; no persistence) -------
  static bool _medalFirstQuiz = false;
  static Future<bool> hasFirstQuizMedal() async => _medalFirstQuiz;

  static Future<bool> markFirstQuizMedalEarned() async {
    if (_medalFirstQuiz) return false;
    _medalFirstQuiz = true;
    achievements.add("Finish your first quiz");
    return true;
  }

  // ================= XP / Level =================
  static int xp = 0;
  static int level = 1;
  static int xpForLevel(int lvl) => 100 + (lvl - 1) * 50;
  static int get xpToNext => xpForLevel(level);
  static double get xpProgress => xpToNext == 0 ? 0 : xp / xpToNext;

  /// Returns how many levels were gained
  static int addXp(int amount) {
    int levelsUp = 0;
    xp += amount;
    while (xp >= xpToNext) {
      xp -= xpToNext;
      level += 1;
      levelsUp += 1;
    }
    return levelsUp;
  }

  // ================= Content Keys & Level Thresholds =================
  static const String levelAlphabet   = 'alphabet';
  static const String levelNumbers    = 'numbers';
  static const String levelGreetings  = 'greetings';
  static const String levelColour     = 'colour';
  static const String levelCommonVerb = 'commonVerb';

  static const Map<String, int> _unlockAtLevel = {
    levelAlphabet  : 1,   // always accessible (no purchase)
    levelNumbers   : 5,
    levelGreetings : 10,
    levelColour    : 15,
    levelCommonVerb: 25,
  };

  static int requiredLevelFor(String key) => _unlockAtLevel[key] ?? 1;
  static bool meetsLevelRequirement(String key) => level >= requiredLevelFor(key);

  // Helper for UI popups after levelling up
  static List<String> unlockedBetween(int fromLevel, int toLevel) {
    final List<String> hits = [];
    _unlockAtLevel.forEach((key, need) {
      if (need > fromLevel && need <= toLevel) hits.add(key);
    });
    return hits;
  }

  static String titleFor(String key) {
    switch (key) {
      case levelAlphabet:   return "Alphabet";
      case levelNumbers:    return "Numbers";
      case levelGreetings:  return "Greetings";
      case levelColour:     return "Colour";
      case levelCommonVerb: return "Common Verbs";
      default:              return key;
    }
  }

  // ================= Manual unlock (Level + 200 keys) — In-Memory Only =================
  static const int unlockCost = 200;
  static Set<String> _unlockedContent = <String>{}; // session only

  /// Alphabet is always playable; others require manual unlock.
  static bool isContentUnlocked(String key) {
    if (key == levelAlphabet) return true;
    return _unlockedContent.contains(key);
  }

  /// No-op; kept for compatibility with screens that call it.
  static Future<void> ensureUnlocksLoaded() async {
    return; // nothing to load (no persistence)
  }

  /// No-op; kept for compatibility.
  static Future<void> _saveUnlocks() async {
    return; // nothing to save (no persistence)
  }

  /// Attempt to unlock content. Requires BOTH: level >= required AND 200 keys.
  /// Unlock exists only for current session (resets on app restart).
  static Future<UnlockStatus> attemptUnlock(String key) async {
    if (key == levelAlphabet) return UnlockStatus.alreadyUnlocked;
    if (_unlockedContent.contains(key)) return UnlockStatus.alreadyUnlocked;

    if (level < requiredLevelFor(key)) return UnlockStatus.needLevel;
    if (userPoints < unlockCost) return UnlockStatus.needKeys;

    userPoints -= unlockCost;
    _unlockedContent.add(key);
    return UnlockStatus.success;
  }

  // ================= Streak (24h window) =================
  static int streakDays = 0;
  static int longestStreak = 0;
  static DateTime? lastStreakUtc;

  static bool addStreakForLevel({DateTime? now}) {
    final n = (now ?? DateTime.now()).toUtc();
    if (lastStreakUtc == null || n.difference(lastStreakUtc!).inHours >= 24) {
      streakDays += 1;
      if (streakDays > longestStreak) longestStreak = streakDays;
      lastStreakUtc = n;
      return true;
    }
    return false;
  }

  static void resetStreak() {
    streakDays = 0;
    longestStreak = 0;
    lastStreakUtc = null;
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
    _unlockedContent.clear();
    _medalFirstQuiz = false;
    resetStreak();
  }

  /// Compatibility placeholder (no persistence). Same as resetAll.
  static Future<void> resetAllPersistent() async {
    resetAll();
  }
}

enum UnlockStatus { success, alreadyUnlocked, needLevel, needKeys }
