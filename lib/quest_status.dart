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

  /// Longest current streak of consecutive correct answers
  static int get level1BestStreak {
    int best = 0, curr = 0;
    for (final v in level1Answers) {
      if (v == true) {
        curr++;
        if (curr > best) best = curr;
      } else {
        curr = 0;
      }
    }
    return best;
  }

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

  // NEW: learning/quiz state flags for quests
  static bool learnedAlphabetAll = false;   // Quest 2
  static bool alphabetQuizStarted = false;  // Quest 3
  static bool learnedNumbersAll = false;    // Quest 8

  // Helper setters to be called from your Learning/Quiz screens:
  static void markAlphabetLearnAll() => learnedAlphabetAll = true;
  static void markAlphabetQuizStarted() => alphabetQuizStarted = true;
  static void markNumbersLearnAll() => learnedNumbersAll = true;

  // Quest flags (claimed)
  static bool quest1Claimed = false;  // Start "Alphabet" level
  static bool quest2Claimed = false;  // Learn ALL Alphabet (Learning Mode)
  static bool quest3Claimed = false;  // Start "Alphabet" quiz
  static bool quest4Claimed = false;  // Get 3 correct in a row (Alphabet)
  static bool quest5Claimed = false;  // Finish 3 rounds of Alphabet
  static bool quest6Claimed = false;  // Alphabet perfect round
  static bool quest7Claimed = false;  // Unlock Numbers
  static bool quest8Claimed = false;  // Learn ALL Numbers (Learning Mode)
  static bool quest9Claimed = false;  // Numbers perfect round
  static bool quest10Claimed = false; // Finish 3 rounds of Numbers

  // Medal/extra trackers
  static bool firstQuizMedalEarned = false;
  static int alphabetRoundsCompleted = 0;
  static int colourRoundsCompleted = 0;
  static int numbersRoundsCompleted = 0;
  static int numbersPerfectRounds = 0;

  // ================= Chest Progress =================
  static int claimedPoints = 0;        // progress within current chest tier
  static int levelGoalPoints = 30;     // current chest tier goal
  static int chestsOpened = 0;

  static double get chestProgress =>
      levelGoalPoints == 0 ? 0 : (claimedPoints / levelGoalPoints).clamp(0.0, 1.0);

  static void advanceChestTier() {
    if (levelGoalPoints < 50) {
      levelGoalPoints = 50;
    } else {
      levelGoalPoints += 50;
    }
  }

  static void _applyChestProgress(int progress) {
    if (progress <= 0) return;
    claimedPoints += progress;
    while (claimedPoints >= levelGoalPoints && levelGoalPoints > 0) {
      claimedPoints -= levelGoalPoints;
      chestsOpened += 1;
      advanceChestTier();
    }
    if (claimedPoints < 0) claimedPoints = 0;
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

  static int addXp(int amount) {
    int levelsUp = 0;
    if (amount <= 0) return 0;
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

  static bool isContentPurchasableNow(String key) {
    if (key == levelAlphabet) return true;
    return meetsLevelRequirement(key);
  }

  static const int unlockCost = 200;
  static final Set<String> _unlockedContent = <String>{};

  static Future<UnlockStatus> attemptUnlock(String key) async {
    if (key == levelAlphabet) return UnlockStatus.alreadyUnlocked;
    if (_unlockedContent.contains(key)) return UnlockStatus.alreadyUnlocked;

    if (level < requiredLevelFor(key)) return UnlockStatus.needLevel;
    if (userPoints < unlockCost) return UnlockStatus.needKeys;

    userPoints -= unlockCost;
    _unlockedContent.add(key);
    return UnlockStatus.success;
  }

  // ================= Quests (10 total) =================
  // Q1: Start "Alphabet" level (enter/answer ≥ 1)
  static bool canClaimQuest1() => completedQuestions >= 1 && !quest1Claimed;
  static int claimQuest1({int reward = 100, int progress = 15}) {
    if (!canClaimQuest1()) return 0;
    quest1Claimed = true;
    userPoints += reward;
    _applyChestProgress(progress);
    addXp(50);
    return reward;
  }

  // Q2: Learn ALL Alphabet (Learning Mode)
  static bool canClaimQuest2() => learnedAlphabetAll && !quest2Claimed;
  static int claimQuest2({int reward = 120, int progress = 15}) {
    if (!canClaimQuest2()) return 0;
    quest2Claimed = true;
    userPoints += reward;
    _applyChestProgress(progress);
    addXp(80);
    return reward;
  }

  // Q3: Start "Alphabet" quiz
  static bool canClaimQuest3() => alphabetQuizStarted && !quest3Claimed;
  static int claimQuest3({int reward = 80, int progress = 10}) {
    if (!canClaimQuest3()) return 0;
    quest3Claimed = true;
    userPoints += reward;
    _applyChestProgress(progress);
    addXp(60);
    return reward;
  }

  // Q4: Get 3 correct answers in a row (Alphabet)
  static bool canClaimQuest4() => level1BestStreak >= 3 && !quest4Claimed;
  static int claimQuest4({int reward = 120, int progress = 15}) {
    if (!canClaimQuest4()) return 0;
    quest4Claimed = true;
    userPoints += reward;
    _applyChestProgress(progress);
    addXp(100);
    return reward;
  }

  // Q5: Finish 3 rounds of Alphabet
  static bool canClaimQuest5() => alphabetRoundsCompleted >= 3 && !quest5Claimed;
  static int claimQuest5({int reward = 200, int progress = 20}) {
    if (!canClaimQuest5()) return 0;
    quest5Claimed = true;
    userPoints += reward;
    _applyChestProgress(progress);
    addXp(150);
    return reward;
  }

  // Q6: Complete ONE Alphabet round without mistakes
  static bool canClaimQuest6() =>
      level1Completed && level1Score == level1Answers.length && !quest6Claimed;
  static int claimQuest6({int reward = 250, int progress = 30}) {
    if (!canClaimQuest6()) return 0;
    quest6Claimed = true;
    userPoints += reward;
    _applyChestProgress(progress);
    addXp(180);
    return reward;
  }

  // Q7: Unlock the "Number" level
  static bool canClaimQuest7() => isContentUnlocked(levelNumbers) && !quest7Claimed;
  static int claimQuest7({int reward = 150, int progress = 20}) {
    if (!canClaimQuest7()) return 0;
    quest7Claimed = true;
    userPoints += reward;
    _applyChestProgress(progress);
    addXp(120);
    return reward;
  }

  // Q8: Learn ALL Numbers (Learning Mode)
  static bool canClaimQuest8() => learnedNumbersAll && !quest8Claimed;
  static int claimQuest8({int reward = 120, int progress = 15}) {
    if (!canClaimQuest8()) return 0;
    quest8Claimed = true;
    userPoints += reward;
    _applyChestProgress(progress);
    addXp(100);
    return reward;
  }

  // Q9: Numbers perfect round
  static bool canClaimQuest9() => numbersPerfectRounds >= 1 && !quest9Claimed;
  static int claimQuest9({int reward = 200, int progress = 20}) {
    if (!canClaimQuest9()) return 0;
    quest9Claimed = true;
    userPoints += reward;
    _applyChestProgress(progress);
    addXp(160);
    return reward;
  }

  // Q10: Finish 3 rounds of Numbers
  static bool canClaimQuest10() => numbersRoundsCompleted >= 3 && !quest10Claimed;
  static int claimQuest10({int reward = 200, int progress = 20}) {
    if (!canClaimQuest10()) return 0;
    quest10Claimed = true;
    userPoints += reward;
    _applyChestProgress(progress);
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
  static Future<bool> markFirstQuizMedalEarned() async {
    if (firstQuizMedalEarned) return false;
    firstQuizMedalEarned = true;
    addXp(25); // small XP boost for first ever quiz
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

    // reset quest claims
    quest1Claimed = quest2Claimed = quest3Claimed = false;
    quest4Claimed = quest5Claimed = quest6Claimed = false;
    quest7Claimed = quest8Claimed = quest9Claimed = quest10Claimed = false;

    // reset learning/quiz flags
    learnedAlphabetAll = false;
    alphabetQuizStarted = false;
    learnedNumbersAll = false;

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
