// quest_status.dart
// In-memory only (no persistence). Perfect for testing.
// Everything resets when the app restarts.

class QuestStatus {
  // ================= Content Keys & Level Thresholds =================
  static const String levelAlphabet = 'alphabet';
  static const String levelNumbers = 'numbers';
  static const String levelGreetings = 'greetings';
  static const String levelColour = 'colour';
  static const String levelCommonVerb = 'commonVerb';

  static const Map<String, int> _unlockAtLevel = {
    levelAlphabet: 1,
    levelNumbers: 5,
    levelColour: 10,
    levelGreetings: 15,
    levelCommonVerb: 25,
  };

  static int requiredLevelFor(String key) => _unlockAtLevel[key] ?? 1;
  static bool meetsLevelRequirement(String key) => level >= requiredLevelFor(key);

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
  static int userPoints = 0;

  // Quest flags
  static bool quest1Claimed = false; // Start Alphabet
  static bool quest2Claimed = false; // 3 correct answers in a row (Alphabet)
  static bool quest3Claimed = false; // Finish 3 rounds of Alphabet
  static bool quest4Claimed = false; // Complete Alphabet without mistakes
  static bool quest5Claimed = false; // Unlock Numbers
  static bool quest6Claimed = false; // Numbers perfect round
  static bool quest7Claimed = false; // Finish 3 rounds of Numbers

  // Medal/extra trackers
  static bool firstQuizMedalEarned = false;
  static int alphabetRoundsCompleted = 0;
  static int colourRoundsCompleted = 0;
  static int numbersRoundsCompleted = 0;
  static int numbersPerfectRounds = 0;

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

  // ================= Unlock Logic =================
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

  // ================= Quests =================
  // --- Quest 1 ---
  static bool canClaimQuest1() => completedQuestions >= 1 && !quest1Claimed;
  static int claimQuest1({int reward = 100, int progress = 15}) {
    if (!canClaimQuest1()) return 0;
    quest1Claimed = true;
    userPoints += reward;
    claimedPoints += progress;
    addXp(50);
    return reward;
  }

  // --- Quest 2 ---
  static bool canClaimQuest2() => completedQuestions >= 3 && !quest2Claimed;
  static int claimQuest2({int reward = 120, int progress = 15}) {
    if (!canClaimQuest2()) return 0;
    quest2Claimed = true;
    userPoints += reward;
    claimedPoints += progress;
    addXp(100);
    return reward;
  }

  // --- Quest 3 ---
  static bool canClaimQuest3() => alphabetRoundsCompleted >= 3 && !quest3Claimed;
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
      level1Completed &&
          level1Score == level1Answers.length &&
          !quest4Claimed;
  static int claimQuest4({int reward = 300, int progress = 30}) {
    if (!canClaimQuest4()) return 0;
    quest4Claimed = true;
    userPoints += reward;
    claimedPoints += progress;
    addXp(180);
    return reward;
  }

  // --- Quest 5 ---
  static bool canClaimQuest5() => isContentUnlocked(levelNumbers) && !quest5Claimed;
  static int claimQuest5({int reward = 150, int progress = 20}) {
    if (!canClaimQuest5()) return 0;
    quest5Claimed = true;
    userPoints += reward;
    claimedPoints += progress;
    addXp(120);
    return reward;
  }

  // --- Quest 6 ---
  static bool canClaimQuest6() => numbersPerfectRounds >= 1 && !quest6Claimed;
  static int claimQuest6({int reward = 200, int progress = 20}) {
    if (!canClaimQuest6()) return 0;
    quest6Claimed = true;
    userPoints += reward;
    claimedPoints += progress;
    addXp(160);
    return reward;
  }

  // --- Quest 7 ---
  static bool canClaimQuest7() => numbersRoundsCompleted >= 3 && !quest7Claimed;
  static int claimQuest7({int reward = 200, int progress = 20}) {
    if (!canClaimQuest7()) return 0;
    quest7Claimed = true;
    userPoints += reward;
    claimedPoints += progress;
    addXp(150);
    return reward;
  }

  // ================= Utility / Titles / Newly Unlocked =================
  static Future<void> ensureUnlocksLoaded() async {
    await Future.delayed(const Duration(milliseconds: 1));
  }

  static List<String> unlockedBetween(int oldLevel, int newLevel) {
    final newlyUnlocked = <String>[];
    for (final contentKey in _unlockAtLevel.keys) {
      final requiredLevel = _unlockAtLevel[contentKey]!;
      if (requiredLevel > oldLevel && requiredLevel <= newLevel) {
        newlyUnlocked.add(contentKey);
      }
    }
    return newlyUnlocked;
  }

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

  /// Set the first-quiz medal once; returns true if it was newly earned.
  static Future<bool> markFirstQuizMedalEarned() async {
    if (firstQuizMedalEarned) return false;
    firstQuizMedalEarned = true;
    addXp(25);
    return true;
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
    quest5Claimed = false;
    quest6Claimed = false;
    quest7Claimed = false;

    userPoints = 0;
    achievements.clear();
    claimedPoints = 0;
    levelGoalPoints = 30;
    chestsOpened = 0;

    xp = 0;
    level = 1;

    _unlockedContent.clear();
    resetStreak();

    firstQuizMedalEarned = false;
    alphabetRoundsCompleted = 0;
    colourRoundsCompleted = 0;
    numbersRoundsCompleted = 0;
    numbersPerfectRounds = 0;
  }
}

enum UnlockStatus { success, alreadyUnlocked, needLevel, needKeys }
