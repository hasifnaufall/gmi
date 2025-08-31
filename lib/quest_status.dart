// quest_status.dart
// In-memory only: no persistence. Perfect for testing.
// Everything resets when the app restarts.

class QuestStatus {
  // ================= Level 1 (Alphabet) =================
  static List<bool?> level1Answers = List<bool?>.filled(5, null);
  static int get completedQuestions =>
      level1Answers.where((e) => e != null).length;
  static bool get level1Completed => level1Answers.every((e) => e != null);
  static int get level1Score =>
      level1Answers.where((e) => e == true).length;

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
  static int userPoints = 0;

  // Quest flags
  static bool quest1Claimed = false; // Start Alphabet
  static bool quest2Claimed = false; // Complete 3 Qs in Alphabet
  static bool quest3Claimed = false; // Finish 3 rounds of Alphabet
  static bool quest4Claimed = false; // Unlock Numbers

  // Extra tracker
  static int alphabetRoundsCompleted = 0;

  // ================= Medal Tracking =================
  static bool firstQuizMedalEarned = false;

  // --- Quest 1 ---
  static bool canClaimQuest1() =>
      completedQuestions >= 1 && !quest1Claimed;
  static int claimQuest1({int reward = 100, int progress = 15}) {
    if (!canClaimQuest1()) return 0;
    quest1Claimed = true;
    userPoints += reward;
    claimedPoints += progress;
    addXp(50);
    return reward;
  }

  // --- Quest 2 ---
  static bool canClaimQuest2() =>
      completedQuestions >= 3 && !quest2Claimed;
  static int claimQuest2({int reward = 100, int progress = 15}) {
    if (!canClaimQuest2()) return 0;
    quest2Claimed = true;
    userPoints += reward;
    claimedPoints += progress;
    addXp(80);
    return reward;
  }

  // --- Quest 3 ---
  static bool canClaimQuest3() =>
      alphabetRoundsCompleted >= 3 && !quest3Claimed;
  static int claimQuest3({int reward = 200, int progress = 20}) {
    if (!canClaimQuest3()) return 0;
    quest3Claimed = true;
    userPoints += reward;
    claimedPoints += progress;
    addXp(150);
    return reward;
  }

  // --- Quest 4 ---
  static bool canClaimQuest4() =>
      isContentUnlocked(levelNumbers) && !quest4Claimed;
  static int claimQuest4({int reward = 300, int progress = 30}) {
    if (!canClaimQuest4()) return 0;
    quest4Claimed = true;
    userPoints += reward;
    claimedPoints += progress;
    addXp(200);
    return reward;
  }

  // ================= Missing Methods (Added) =================

  /// Initialize unlocks - can be used to preload any data
  static Future<void> ensureUnlocksLoaded() async {
    // Initialize any unlock data if needed
    // For now, this is just a placeholder that ensures initialization
    await Future.delayed(Duration(milliseconds: 1)); // Simulate async operation
  }

  /// Get list of content keys unlocked between two levels
  static List<String> unlockedBetween(int oldLevel, int newLevel) {
    List<String> newlyUnlocked = [];

    for (String contentKey in _unlockAtLevel.keys) {
      int requiredLevel = _unlockAtLevel[contentKey]!;
      if (requiredLevel > oldLevel && requiredLevel <= newLevel) {
        newlyUnlocked.add(contentKey);
      }
    }

    return newlyUnlocked;
  }

  /// Get display title for a content key
  static String titleFor(String key) {
    switch (key) {
      case levelAlphabet:
        return 'Alphabet Quest';
      case levelNumbers:
        return 'Numbers Quest';
      case levelGreetings:
        return 'Greetings Quest';
      case levelColour:
        return 'Colors Quest';
      case levelCommonVerb:
        return 'Common Verbs Quest';
      default:
        return key.replaceAll(RegExp(r'([a-z])([A-Z])'), r'$1 $2');
    }
  }

  /// Mark that the first quiz medal was earned (returns true if this was the first time)
  static Future<bool> markFirstQuizMedalEarned() async {
    if (firstQuizMedalEarned) {
      return false; // Already earned before
    }

    firstQuizMedalEarned = true;
    // You could award bonus XP or points here for the first medal
    addXp(25);
    return true; // This was the first time earning a medal
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
  }

  // ================= Achievements =================
  static Set<String> achievements = <String>{};
  static bool awardAchievement(String name) {
    if (achievements.contains(name)) return false;
    achievements.add(name);
    return true;
  }

  // ================= XP / Level =================
  static int xp = 0;
  static int level = 1;
  static int xpForLevel(int lvl) => 100 + (lvl - 1) * 50;
  static int get xpToNext => xpForLevel(level);
  static double get xpProgress =>
      xpToNext == 0 ? 0 : xp / xpToNext;

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
  static const String levelAlphabet = 'alphabet';
  static const String levelNumbers = 'numbers';
  static const String levelGreetings = 'greetings';
  static const String levelColour = 'colour';
  static const String levelCommonVerb = 'commonVerb';

  static const Map<String, int> _unlockAtLevel = {
    levelAlphabet: 1,
    levelNumbers: 5,
    levelGreetings: 10,
    levelColour: 15,
    levelCommonVerb: 25,
  };

  static int requiredLevelFor(String key) =>
      _unlockAtLevel[key] ?? 1;
  static bool meetsLevelRequirement(String key) =>
      level >= requiredLevelFor(key);

  static bool isContentUnlocked(String key) {
    if (key == levelAlphabet) return true;
    return _unlockedContent.contains(key);
  }

  static const int unlockCost = 200;
  static Set<String> _unlockedContent = <String>{};

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

  static void resetAll() {
    resetLevel1Answers();
    quest1Claimed = false;
    quest2Claimed = false;
    quest3Claimed = false;
    quest4Claimed = false;
    userPoints = 0;
    achievements.clear();
    claimedPoints = 0;
    levelGoalPoints = 30;
    chestsOpened = 0;
    xp = 0;
    level = 1;
    _unlockedContent.clear();
    resetStreak();
    firstQuizMedalEarned = false; // Reset medal tracking
    alphabetRoundsCompleted = 0;
  }
}

enum UnlockStatus { success, alreadyUnlocked, needLevel, needKeys }