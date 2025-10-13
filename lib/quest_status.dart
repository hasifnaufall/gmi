import 'user_progress_service.dart';

// In-memory only (no persistence). Everything resets when the app restarts.

class QuestStatus {
  // Save coalescing to avoid excessive Firestore writes
  static bool _saving = false;
  static bool _saveQueued = false;
  // ================= Content Keys & Level Thresholds =================
  static const String levelAlphabet   = 'alphabet';
  static const String levelNumbers    = 'numbers';
  static const String levelGreetings  = 'greetings';   // Fruits (UI)
  static const String levelColour     = 'colour';
  static const String levelCommonVerb = 'commonVerb';  // Animals (UI)

  // Unlock requirements (Alphabet free, Numbers 5, Colour 10, Fruits 15, Animals 25)
  static const Map<String, int> _unlockAtLevel = {
    levelAlphabet:   1,
    levelNumbers:    5,
    levelColour:     10,
    levelGreetings:  15,
    levelCommonVerb: 25,
  };

  static int requiredLevelFor(String key) => _unlockAtLevel[key] ?? 1;
  static bool meetsLevelRequirement(String key) => level >= requiredLevelFor(key);

  // ================= Per-correct XP rule =================
  static const int xpPerCorrect = 25;

  // ================= Level 1 (Alphabet) =================
  static List<bool?> level1Answers = List<bool?>.filled(5, null);
  static int get completedQuestions => level1Answers.where((e) => e != null).length;
  static bool get level1Completed   => level1Answers.every((e) => e != null);
  static int  get level1Score       => level1Answers.where((e) => e == true).length;

  /// Longest current streak of consecutive correct answers (Alphabet)
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

  // ================= Keys / Quests (global state) =================
  static int userPoints = 0; // "keys"

  // ---- Learning/quiz state flags & counters (across categories)
  // Alphabet
  static bool learnedAlphabetAll      = false; // Q2
  static bool alphabetQuizStarted     = false; // Q3
  static int  alphabetRoundsCompleted = 0;     // used by alphabet_q.dart / milestone

  // Numbers
  static bool learnedNumbersAll       = false; // Q6
  static int  numbersRoundsCompleted  = 0;     // Q8
  static int  numbersPerfectRounds    = 0;     // Q7

  // Colour
  static bool learnedColoursAll       = false; // Q10
  static int  colourRoundsCompleted   = 0;     // Q12
  static int  colourBestStreak        = 0;     // Q11

  // Fruits
  static bool learnedFruitsAll        = false; // Q14
  static int  fruitsRoundsCompleted   = 0;     // Q16
  static int  fruitsBestStreak        = 0;     // Q15

  // Animals
  static bool learnedAnimalsAll       = false; // Q18
  static int  animalsRoundsCompleted  = 0;     // Q19
  static int  animalsPerfectRounds    = 0;     // Q20

  // Misc tracker
  static bool firstQuizMedalEarned    = false; // used by markFirstQuizMedalEarned()

  // ---- Helper setters to be called from Learning/Quiz screens:
  // Alphabet helpers
    static void markAlphabetLearnAll() { learnedAlphabetAll = true; _autoClaimAll(); Future.microtask(() => autoSaveProgress()); }
    static void markAlphabetQuizStarted() { alphabetQuizStarted = true; markFirstQuizMedalEarned(); _autoClaimAll(); Future.microtask(() => autoSaveProgress()); }
    static void incAlphabetRoundsCompleted() { alphabetRoundsCompleted++; _autoClaimAll(); Future.microtask(() => autoSaveProgress()); }

  // Numbers helpers
    static void markNumbersLearnAll() { learnedNumbersAll = true; _autoClaimAll(); Future.microtask(() => autoSaveProgress()); }
    static void incNumbersRoundsCompleted() { numbersRoundsCompleted++; _autoClaimAll(); Future.microtask(() => autoSaveProgress()); }
    static void incNumbersPerfectRounds() { numbersPerfectRounds++; _autoClaimAll(); Future.microtask(() => autoSaveProgress()); }

  // Colour helpers
    static void markColoursLearnAll() { learnedColoursAll = true; _autoClaimAll(); Future.microtask(() => autoSaveProgress()); }
    static void incColourRoundsCompleted() { colourRoundsCompleted++; _autoClaimAll(); Future.microtask(() => autoSaveProgress()); }
    static void updateColourBestStreak(int streak) { if (streak > colourBestStreak) colourBestStreak = streak; _autoClaimAll(); Future.microtask(() => autoSaveProgress()); }

  // Fruits helpers
    static void markFruitsLearnAll() { learnedFruitsAll = true; _autoClaimAll(); Future.microtask(() => autoSaveProgress()); }
    static void incFruitsRoundsCompleted() { fruitsRoundsCompleted++; _autoClaimAll(); Future.microtask(() => autoSaveProgress()); }
    static void updateFruitsBestStreak(int streak) { if (streak > fruitsBestStreak) fruitsBestStreak = streak; _autoClaimAll(); Future.microtask(() => autoSaveProgress()); }

  // Animals helpers
    static void markAnimalsLearnAll() { learnedAnimalsAll = true; _autoClaimAll(); Future.microtask(() => autoSaveProgress()); }
    static void incAnimalsRoundsCompleted() { animalsRoundsCompleted++; _autoClaimAll(); Future.microtask(() => autoSaveProgress()); }
    static void incAnimalsPerfectRounds() { animalsPerfectRounds++; _autoClaimAll(); Future.microtask(() => autoSaveProgress()); }

  /// Call this from any quiz when the user answers a question.
  /// Applies +25 XP for correct and then auto-claims any newly satisfied quests.
  static void onAnswer({required bool correct}) {
    if (correct) addXp(xpPerCorrect);
    _autoClaimAll();
     Future.microtask(() => autoSaveProgress());
  }

  // ================= Chest Progress (goal grows +20 per chest) =================
  static int claimedPoints   = 0;  // progress within current chest tier (your UI shows this)
  static int levelGoalPoints = 30; // starting chest goal (first bar length)
  static int chestsOpened    = 0;

  static double get chestProgress =>
      levelGoalPoints == 0 ? 0 : (claimedPoints / levelGoalPoints).clamp(0.0, 1.0);

  // Each chest opened raises the next goal by +20
  static void advanceChestTier() {
    levelGoalPoints += 20;
     Future.microtask(() => autoSaveProgress());
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
      Future.microtask(() => autoSaveProgress());
  }

  // ================= Achievements =================
  static Set<String> achievements = <String>{};
  static bool awardAchievement(String name) {
    if (achievements.contains(name)) return false;
    achievements.add(name);
      Future.microtask(() => autoSaveProgress());
    return true;
  }

  // ================= XP / Level (XP to next grows +50/level) =================
  static int xp    = 0;
  static int level = 1;

  // Level bar rule: base 100, +50 per level-up step
  static int xpForLevel(int lvl) => 100 + (lvl - 1) * 50;
  static int get xpToNext     => xpForLevel(level);
  static double get xpProgress => xpToNext == 0 ? 0 : xp / xpToNext;

  static int addXp(int amount) {
    int levelsUp = 0;
    if (amount <= 0) return 0;
    xp += amount;
    while (xp >= xpToNext) {
      xp -= xpToNext;
      level += 1;
      levelsUp += 1;
        Future.microtask(() => autoSaveProgress());
    }
      Future.microtask(() => autoSaveProgress());
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
    if (userPoints < unlockCost)       return UnlockStatus.needKeys;

    userPoints -= unlockCost;
    _unlockedContent.add(key);

    // Auto-claim dispatcher may unlock related quests immediately
    _autoClaimAll();
    await autoSaveProgress();
    return UnlockStatus.success;
  }

  // ================= Quests (Q1 – Q24) with auto-claim =================

  // ---- Claimed flags
  static bool quest1Claimed  = false; // Start Alphabet
  static bool quest2Claimed  = false; // Learn ALL Alphabet
  static bool quest3Claimed  = false; // Start Alphabet quiz
  static bool quest4Claimed  = false; // 3 correct in a row (Alphabet)
  static bool quest5Claimed  = false; // Start Numbers
  static bool quest6Claimed  = false; // Learn ALL Numbers
  static bool quest7Claimed  = false; // Numbers perfect round
  static bool quest8Claimed  = false; // Finish 3 rounds Numbers
  static bool quest9Claimed  = false; // Start Colour
  static bool quest10Claimed = false; // Learn ALL Colour
  static bool quest11Claimed = false; // 5-correct streak Colour
  static bool quest12Claimed = false; // Finish 2 rounds Colour
  static bool quest13Claimed = false; // Start Fruits
  static bool quest14Claimed = false; // Learn ALL Fruits
  static bool quest15Claimed = false; // 4-correct streak Fruits
  static bool quest16Claimed = false; // Finish 2 rounds Fruits
  static bool quest17Claimed = false; // Start Animals
  static bool quest18Claimed = false; // Learn ALL Animals
  static bool quest19Claimed = false; // Finish 3 rounds Animals
  static bool quest20Claimed = false; // 1 perfect round Animals
  static bool quest21Claimed = false; // Open 3 chests
  static bool quest22Claimed = false; // Reach Level 10
  static bool quest23Claimed = false; // Unlock all categories
  static bool quest24Claimed = false; // Reach Level 25

  // ---- Conditions & Claims (Rewards tuned to help reach L25)
  static bool canClaimQuest1() => completedQuestions >= 1 && !quest1Claimed;
  static int  claimQuest1({int reward = 100, int progress = 15}) {
    if (!canClaimQuest1()) return 0;
     quest1Claimed = true; userPoints += reward; _applyChestProgress(progress); addXp(50); return reward;
  }

  static bool canClaimQuest2() => learnedAlphabetAll && !quest2Claimed;
  static int  claimQuest2({int reward = 120, int progress = 15}) {
    if (!canClaimQuest2()) return 0;
     quest2Claimed = true; userPoints += reward; _applyChestProgress(progress); addXp(80); return reward;
  }

  static bool canClaimQuest3() => alphabetQuizStarted && !quest3Claimed;
  static int  claimQuest3({int reward = 80, int progress = 10}) {
    if (!canClaimQuest3()) return 0;
     quest3Claimed = true; userPoints += reward; _applyChestProgress(progress); addXp(60); return reward;
  }

  static bool canClaimQuest4() => level1BestStreak >= 3 && !quest4Claimed;
  static int  claimQuest4({int reward = 120, int progress = 15}) {
    if (!canClaimQuest4()) return 0;
     quest4Claimed = true; userPoints += reward; _applyChestProgress(progress); addXp(100); return reward;
  }

  static bool canClaimQuest5() => isContentUnlocked(levelNumbers) && !quest5Claimed;
  static int  claimQuest5({int reward = 100, int progress = 15}) {
    if (!canClaimQuest5()) return 0;
     quest5Claimed = true; userPoints += reward; _applyChestProgress(progress); addXp(50); return reward;
  }

  static bool canClaimQuest6() => learnedNumbersAll && !quest6Claimed;
  static int  claimQuest6({int reward = 120, int progress = 15}) {
    if (!canClaimQuest6()) return 0;
     quest6Claimed = true; userPoints += reward; _applyChestProgress(progress); addXp(80); return reward;
  }

  static bool canClaimQuest7() => numbersPerfectRounds >= 1 && !quest7Claimed;
  static int  claimQuest7({int reward = 200, int progress = 20}) {
    if (!canClaimQuest7()) return 0;
     quest7Claimed = true; userPoints += reward; _applyChestProgress(progress); addXp(160); return reward;
  }

  static bool canClaimQuest8() => numbersRoundsCompleted >= 3 && !quest8Claimed;
  static int  claimQuest8({int reward = 200, int progress = 20}) {
    if (!canClaimQuest8()) return 0;
     quest8Claimed = true; userPoints += reward; _applyChestProgress(progress); addXp(150); return reward;
  }

  static bool canClaimQuest9() => isContentUnlocked(levelColour) && !quest9Claimed;
  static int  claimQuest9({int reward = 100, int progress = 15}) {
    if (!canClaimQuest9()) return 0;
     quest9Claimed = true; userPoints += reward; _applyChestProgress(progress); addXp(50); return reward;
  }

  static bool canClaimQuest10() => learnedColoursAll && !quest10Claimed;
  static int  claimQuest10({int reward = 120, int progress = 15}) {
    if (!canClaimQuest10()) return 0;
     quest10Claimed = true; userPoints += reward; _applyChestProgress(progress); addXp(80); return reward;
  }

  static bool canClaimQuest11() => colourBestStreak >= 5 && !quest11Claimed;
  static int  claimQuest11({int reward = 150, int progress = 15}) {
    if (!canClaimQuest11()) return 0;
     quest11Claimed = true; userPoints += reward; _applyChestProgress(progress); addXp(100); return reward;
  }

  static bool canClaimQuest12() => colourRoundsCompleted >= 2 && !quest12Claimed;
  static int  claimQuest12({int reward = 200, int progress = 20}) {
    if (!canClaimQuest12()) return 0;
     quest12Claimed = true; userPoints += reward; _applyChestProgress(progress); addXp(150); return reward;
  }

  static bool canClaimQuest13() => isContentUnlocked(levelGreetings) && !quest13Claimed;
  static int  claimQuest13({int reward = 100, int progress = 15}) {
    if (!canClaimQuest13()) return 0;
     quest13Claimed = true; userPoints += reward; _applyChestProgress(progress); addXp(50); return reward;
  }

  static bool canClaimQuest14() => learnedFruitsAll && !quest14Claimed;
  static int  claimQuest14({int reward = 120, int progress = 15}) {
    if (!canClaimQuest14()) return 0;
     quest14Claimed = true; userPoints += reward; _applyChestProgress(progress); addXp(80); return reward;
  }

  static bool canClaimQuest15() => fruitsBestStreak >= 4 && !quest15Claimed;
  static int  claimQuest15({int reward = 150, int progress = 15}) {
    if (!canClaimQuest15()) return 0;
     quest15Claimed = true; userPoints += reward; _applyChestProgress(progress); addXp(100); return reward;
  }

  static bool canClaimQuest16() => fruitsRoundsCompleted >= 2 && !quest16Claimed;
  static int  claimQuest16({int reward = 200, int progress = 20}) {
    if (!canClaimQuest16()) return 0;
     quest16Claimed = true; userPoints += reward; _applyChestProgress(progress); addXp(150); return reward;
  }

  static bool canClaimQuest17() => isContentUnlocked(levelCommonVerb) && !quest17Claimed;
  static int  claimQuest17({int reward = 100, int progress = 15}) {
    if (!canClaimQuest17()) return 0;
     quest17Claimed = true; userPoints += reward; _applyChestProgress(progress); addXp(50); return reward;
  }

  static bool canClaimQuest18() => learnedAnimalsAll && !quest18Claimed;
  static int  claimQuest18({int reward = 120, int progress = 15}) {
    if (!canClaimQuest18()) return 0;
     quest18Claimed = true; userPoints += reward; _applyChestProgress(progress); addXp(80); return reward;
  }

  static bool canClaimQuest19() => animalsRoundsCompleted >= 3 && !quest19Claimed;
  static int  claimQuest19({int reward = 150, int progress = 20}) {
    if (!canClaimQuest19()) return 0;
     quest19Claimed = true; userPoints += reward; _applyChestProgress(progress); addXp(150); return reward;
  }

  static bool canClaimQuest20() => animalsPerfectRounds >= 1 && !quest20Claimed;
  static int  claimQuest20({int reward = 200, int progress = 20}) {
    if (!canClaimQuest20()) return 0;
     quest20Claimed = true; userPoints += reward; _applyChestProgress(progress); addXp(180); return reward;
  }

  static bool canClaimQuest21() => chestsOpened >= 3 && !quest21Claimed;
  static int  claimQuest21({int reward = 150, int progress = 20}) {
    if (!canClaimQuest21()) return 0;
     quest21Claimed = true; userPoints += reward; _applyChestProgress(progress); addXp(120); return reward;
  }

  static bool canClaimQuest22() => level >= 10 && !quest22Claimed;
  static int  claimQuest22({int reward = 150, int progress = 20}) {
    if (!canClaimQuest22()) return 0;
     quest22Claimed = true; userPoints += reward; _applyChestProgress(progress); addXp(120); return reward;
  }

  static bool canClaimQuest23() =>
      isContentUnlocked(levelNumbers) &&
          isContentUnlocked(levelColour)  &&
          isContentUnlocked(levelGreetings) &&
          isContentUnlocked(levelCommonVerb) &&
          !quest23Claimed;
  static int  claimQuest23({int reward = 200, int progress = 20}) {
    if (!canClaimQuest23()) return 0;
     quest23Claimed = true; userPoints += reward; _applyChestProgress(progress); addXp(160); return reward;
  }

  static bool canClaimQuest24() => level >= 25 && !quest24Claimed;
  static int  claimQuest24({int reward = 300, int progress = 30}) {
    if (!canClaimQuest24()) return 0;
     quest24Claimed = true; userPoints += reward; _applyChestProgress(progress); addXp(200); return reward;
  }

  // Auto-claim dispatcher (idempotent; safe to call often)
  static void _autoClaimAll() {
    if (canClaimQuest1())  { claimQuest1(); }
    if (canClaimQuest2())  { claimQuest2(); }
    if (canClaimQuest3())  { claimQuest3(); }
    if (canClaimQuest4())  { claimQuest4(); }
    if (canClaimQuest5())  { claimQuest5(); }
    if (canClaimQuest6())  { claimQuest6(); }
    if (canClaimQuest7())  { claimQuest7(); }
    if (canClaimQuest8())  { claimQuest8(); }
    if (canClaimQuest9())  { claimQuest9(); }
    if (canClaimQuest10()) { claimQuest10(); }
    if (canClaimQuest11()) { claimQuest11(); }
    if (canClaimQuest12()) { claimQuest12(); }
    if (canClaimQuest13()) { claimQuest13(); }
    if (canClaimQuest14()) { claimQuest14(); }
    if (canClaimQuest15()) { claimQuest15(); }
    if (canClaimQuest16()) { claimQuest16(); }
    if (canClaimQuest17()) { claimQuest17(); }
    if (canClaimQuest18()) { claimQuest18(); }
    if (canClaimQuest19()) { claimQuest19(); }
    if (canClaimQuest20()) { claimQuest20(); }
    if (canClaimQuest21()) { claimQuest21(); }
    if (canClaimQuest22()) { claimQuest22(); }
    if (canClaimQuest23()) { claimQuest23(); }
    if (canClaimQuest24()) { claimQuest24(); }
    Future.microtask(() => autoSaveProgress());
  }

  // ================= Utility / Titles / Newly Unlocked =================
  static Future<void> ensureUnlocksLoaded() async {
    await Future.delayed(const Duration(milliseconds: 1));
    _autoClaimAll(); // ensure state is up-to-date at entry
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
      case levelAlphabet:   return 'Alphabet Quest';
      case levelNumbers:    return 'Numbers Quest';
      case levelGreetings:  return 'Fruits Quest';
      case levelColour:     return 'Colors Quest';
      case levelCommonVerb: return 'Animals Quest';
      default:
        return key.replaceAll(RegExp(r'([a-z])([A-Z])'), r'$1 $2');
    }
  }

  static bool markFirstQuizMedalEarned() {
    if (firstQuizMedalEarned) return false;
    firstQuizMedalEarned = true;
    addXp(25); // small XP boost for first ever quiz
    Future.microtask(() => autoSaveProgress());
    return true;
  }

  // ================= Streak (24h window) =================
  static int      streakDays = 0;
  static int      longestStreak = 0;
  static DateTime? lastStreakUtc;

  static bool addStreakForLevel({DateTime? now}) {
    final n = (now ?? DateTime.now()).toUtc();
    if (lastStreakUtc == null || n.difference(lastStreakUtc!).inHours >= 24) {
      streakDays += 1;
      if (streakDays > longestStreak) longestStreak = streakDays;
      lastStreakUtc = n;
      _autoClaimAll();
        Future.microtask(() => autoSaveProgress());
      return true;
    }
    return false;
  }

  static void resetStreak() {
    streakDays = 0;
    longestStreak = 0;
    lastStreakUtc = null;
      Future.microtask(() => autoSaveProgress());
  }

  // ================= User Session Management =================
  static String? _currentUserId;

  /// Reset all static variables to default values (for user switching)
  static void resetToDefaults() {
    // reset quest claims
    quest1Claimed = quest2Claimed = quest3Claimed = false;
    quest4Claimed = quest5Claimed = quest6Claimed = false;
    quest7Claimed = quest8Claimed = quest9Claimed = quest10Claimed = false;
    quest11Claimed = quest12Claimed = quest13Claimed = quest14Claimed = false;
    quest15Claimed = quest16Claimed = quest17Claimed = quest18Claimed = false;
    quest19Claimed = quest20Claimed = quest21Claimed = quest22Claimed = false;
    quest23Claimed = quest24Claimed = false;

    // reset learning/quiz flags & counters
    learnedAlphabetAll = false;
    alphabetQuizStarted = false;
    alphabetRoundsCompleted = 0;

    learnedNumbersAll = false;
    numbersRoundsCompleted = 0;
    numbersPerfectRounds = 0;

    learnedColoursAll = false;
    colourRoundsCompleted = 0;
    colourBestStreak = 0;

    learnedFruitsAll = false;
    fruitsRoundsCompleted = 0;
    fruitsBestStreak = 0;

    learnedAnimalsAll = false;
    animalsRoundsCompleted = 0;
    animalsPerfectRounds = 0;

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
    
    // Reset level 1 answers
    level1Answers = List<bool?>.filled(5, null);
    
    // Note: Don't save progress here to avoid potential performance issues
  }

  /// Load progress for a specific user, ensuring isolation between users
  // Flag to prevent auto-saving during progress loading
  static bool _loadingProgress = false;

  static Future<void> loadProgressForUser(String userId) async {
    print('loadProgressForUser called for userId: $userId');
    print('Current userId: $_currentUserId');
    
    // Set loading flag to prevent auto-saves during loading
    _loadingProgress = true;
    
    try {
      // Always reset to defaults first to ensure clean state
      // This is especially important after logout when _currentUserId is null
      if (_currentUserId != userId) {
        print('Loading different user or after logout - resetting to defaults first');
        resetToDefaults();
      }
      
      _currentUserId = userId;
      
      final progress = await UserProgressService().getProgress();
      print('Progress data from Firestore: $progress');
      
      if (progress != null) {
        loadFromProgress(progress);
        print('Progress loaded for user: $userId');
        print('Level after loading: $level, XP: $xp, Chests: $chestsOpened, Streak: $streakDays, UserPoints: $userPoints');
      } else {
        print('No saved progress found for user: $userId - using defaults');
        // Start fresh for new users (resetToDefaults already called above)
        _currentUserId = userId; // Keep the user ID even with defaults
      }
    } catch (e) {
      print('Error loading progress for user $userId: $e');
      // Don't reset on error - preserve any existing progress
      // But make sure we have the right user ID
      _currentUserId = userId;
    } finally {
      // Always clear loading flag
      _loadingProgress = false;
      print('Progress loading completed for user: $userId');
    }
  }

  /// Get the current user ID
  static String? get currentUserId => _currentUserId;

  /// Clear the current user ID (for logout)
  static void clearCurrentUser() {
    _currentUserId = null;
    print('Current user ID cleared');
  }

  /// Debug method to show current progress
  static void showCurrentProgress() {
    print('=== CURRENT PROGRESS ===');
    print('User ID: $_currentUserId');
    print('Level: $level, XP: $xp');
    print('User Points: $userPoints');
    print('Chests Opened: $chestsOpened');
    print('Claimed Points: $claimedPoints/$levelGoalPoints');
    print('Streak Days: $streakDays');
    print('Achievements: ${achievements.length}');
    print('Unlocked Content: ${_unlockedContent.length}');
    print('========================');
  }

  /// Debug method to manually trigger save (for testing)
  static Future<void> forceSave() async {
    print('forceSave: Forcing save of current progress...');
    await autoSaveProgress();
    print('forceSave: Save completed');
  }

  /// Debug method to check if progress is currently being loaded
  static bool get isLoadingProgress => _loadingProgress;

  // ================= Resets =================
  static void resetLevel1Answers() {
    for (int i = 0; i < level1Answers.length; i++) {
      level1Answers[i] = null;
    }
    // Save progress asynchronously without blocking
    Future.microtask(() => autoSaveProgress());
  }

  static void resetAll() {
    resetLevel1Answers();

    // reset quest claims
    quest1Claimed = quest2Claimed = quest3Claimed = false;
    quest4Claimed = quest5Claimed = quest6Claimed = false;
    quest7Claimed = quest8Claimed = quest9Claimed = quest10Claimed = false;
    quest11Claimed = quest12Claimed = quest13Claimed = quest14Claimed = false;
    quest15Claimed = quest16Claimed = quest17Claimed = quest18Claimed = false;
    quest19Claimed = quest20Claimed = quest21Claimed = quest22Claimed = false;
    quest23Claimed = quest24Claimed = false;

    // reset learning/quiz flags & counters
    learnedAlphabetAll = false;
    alphabetQuizStarted = false;
    alphabetRoundsCompleted = 0;

    learnedNumbersAll = false;
    numbersRoundsCompleted = 0;
    numbersPerfectRounds = 0;

    learnedColoursAll = false;
    colourRoundsCompleted = 0;
    colourBestStreak = 0;

    learnedFruitsAll = false;
    fruitsRoundsCompleted = 0;
    fruitsBestStreak = 0;

    learnedAnimalsAll = false;
    animalsRoundsCompleted = 0;
    animalsPerfectRounds = 0;

    userPoints = 0;
    achievements.clear();
    claimedPoints   = 0;
    levelGoalPoints = 30;
    chestsOpened    = 0;

    xp = 0;
    level = 1;

    _unlockedContent.clear();
    resetStreak();

    firstQuizMedalEarned = false;
    
    // Save progress asynchronously without blocking
    Future.microtask(() => autoSaveProgress());
  }

  /// Save all progress to Firestore for the current user (coalesced)
  static Future<void> autoSaveProgress() async {
    // Don't save if we're currently loading progress to avoid overwriting with default values
    if (_loadingProgress) {
      print('autoSaveProgress: Currently loading progress - skipping save to avoid overwriting');
      return;
    }
    
    // If no user is logged in yet (e.g., on splash or after logout), skip saving.
    final currentUserId = UserProgressService().getCurrentUserId();
    if (currentUserId == null || _currentUserId == null) {
      print('autoSaveProgress: No user logged in (Firebase: $currentUserId, QuestStatus: $_currentUserId) - skipping save');
      // Clear saving flags to avoid getting stuck
      _saving = false;
      _saveQueued = false;
      return;
    }

    if (_saving) {
      _saveQueued = true;
      return;
    }
    _saving = true;
    try {
      print('autoSaveProgress: Saving progress for user $_currentUserId - Level: $level, XP: $xp, Chests: $chestsOpened, Streak: $streakDays, UserPoints: $userPoints');
      await UserProgressService().saveProgress(
        level: level,
        score: xp,
        achievements: achievements.toList(),
        userPoints: userPoints,
        claimedPoints: claimedPoints,
        levelGoalPoints: levelGoalPoints,
        chestsOpened: chestsOpened,
        streakDays: streakDays,
        longestStreak: longestStreak,
        lastStreakUtc: lastStreakUtc?.millisecondsSinceEpoch,
        // Quest states
        questStates: {
          'quest1Claimed': quest1Claimed,
          'quest2Claimed': quest2Claimed,
          'quest3Claimed': quest3Claimed,
          'quest4Claimed': quest4Claimed,
          'quest5Claimed': quest5Claimed,
          'quest6Claimed': quest6Claimed,
          'quest7Claimed': quest7Claimed,
          'quest8Claimed': quest8Claimed,
          'quest9Claimed': quest9Claimed,
          'quest10Claimed': quest10Claimed,
          'quest11Claimed': quest11Claimed,
          'quest12Claimed': quest12Claimed,
          'quest13Claimed': quest13Claimed,
          'quest14Claimed': quest14Claimed,
          'quest15Claimed': quest15Claimed,
          'quest16Claimed': quest16Claimed,
          'quest17Claimed': quest17Claimed,
          'quest18Claimed': quest18Claimed,
          'quest19Claimed': quest19Claimed,
          'quest20Claimed': quest20Claimed,
          'quest21Claimed': quest21Claimed,
          'quest22Claimed': quest22Claimed,
          'quest23Claimed': quest23Claimed,
          'quest24Claimed': quest24Claimed,
        },
        // Learning progress
        learningStates: {
          'learnedAlphabetAll': learnedAlphabetAll,
          'alphabetQuizStarted': alphabetQuizStarted,
          'alphabetRoundsCompleted': alphabetRoundsCompleted,
          'learnedNumbersAll': learnedNumbersAll,
          'numbersRoundsCompleted': numbersRoundsCompleted,
          'numbersPerfectRounds': numbersPerfectRounds,
          'learnedColoursAll': learnedColoursAll,
          'colourRoundsCompleted': colourRoundsCompleted,
          'colourBestStreak': colourBestStreak,
          'learnedFruitsAll': learnedFruitsAll,
          'fruitsRoundsCompleted': fruitsRoundsCompleted,
          'fruitsBestStreak': fruitsBestStreak,
          'learnedAnimalsAll': learnedAnimalsAll,
          'animalsRoundsCompleted': animalsRoundsCompleted,
          'animalsPerfectRounds': animalsPerfectRounds,
          'firstQuizMedalEarned': firstQuizMedalEarned,
        },
        // Unlocked content
        unlockedContent: _unlockedContent.toList(),
        // Level 1 answers
        level1Answers: level1Answers.map((e) => e == null ? null : (e ? 1 : 0)).toList(),
      );
    } finally {
      _saving = false;
      if (_saveQueued) {
        _saveQueued = false;
        // Coalesce multiple quick calls into one follow-up save
        Future.delayed(const Duration(milliseconds: 200), () => autoSaveProgress());
      }
    }
  }

  /// Load all progress from Firestore data
  static void loadFromProgress(Map<String, dynamic> data) {
    // Basic progress
    level = data['level'] ?? 1;
    xp = data['score'] ?? 0;
    achievements = Set<String>.from(data['achievements'] ?? []);
    userPoints = data['userPoints'] ?? 0;
    claimedPoints = data['claimedPoints'] ?? 0;
    levelGoalPoints = data['levelGoalPoints'] ?? 30;
    chestsOpened = data['chestsOpened'] ?? 0;
    streakDays = data['streakDays'] ?? 0;
    longestStreak = data['longestStreak'] ?? 0;
    
    if (data['lastStreakUtc'] != null) {
      lastStreakUtc = DateTime.fromMillisecondsSinceEpoch(data['lastStreakUtc']);
    }

    // Quest states
    final questStates = data['questStates'] as Map<String, dynamic>? ?? {};
    quest1Claimed = questStates['quest1Claimed'] ?? false;
    quest2Claimed = questStates['quest2Claimed'] ?? false;
    quest3Claimed = questStates['quest3Claimed'] ?? false;
    quest4Claimed = questStates['quest4Claimed'] ?? false;
    quest5Claimed = questStates['quest5Claimed'] ?? false;
    quest6Claimed = questStates['quest6Claimed'] ?? false;
    quest7Claimed = questStates['quest7Claimed'] ?? false;
    quest8Claimed = questStates['quest8Claimed'] ?? false;
    quest9Claimed = questStates['quest9Claimed'] ?? false;
    quest10Claimed = questStates['quest10Claimed'] ?? false;
    quest11Claimed = questStates['quest11Claimed'] ?? false;
    quest12Claimed = questStates['quest12Claimed'] ?? false;
    quest13Claimed = questStates['quest13Claimed'] ?? false;
    quest14Claimed = questStates['quest14Claimed'] ?? false;
    quest15Claimed = questStates['quest15Claimed'] ?? false;
    quest16Claimed = questStates['quest16Claimed'] ?? false;
    quest17Claimed = questStates['quest17Claimed'] ?? false;
    quest18Claimed = questStates['quest18Claimed'] ?? false;
    quest19Claimed = questStates['quest19Claimed'] ?? false;
    quest20Claimed = questStates['quest20Claimed'] ?? false;
    quest21Claimed = questStates['quest21Claimed'] ?? false;
    quest22Claimed = questStates['quest22Claimed'] ?? false;
    quest23Claimed = questStates['quest23Claimed'] ?? false;
    quest24Claimed = questStates['quest24Claimed'] ?? false;

    // Learning states
    final learningStates = data['learningStates'] as Map<String, dynamic>? ?? {};
    learnedAlphabetAll = learningStates['learnedAlphabetAll'] ?? false;
    alphabetQuizStarted = learningStates['alphabetQuizStarted'] ?? false;
    alphabetRoundsCompleted = learningStates['alphabetRoundsCompleted'] ?? 0;
    learnedNumbersAll = learningStates['learnedNumbersAll'] ?? false;
    numbersRoundsCompleted = learningStates['numbersRoundsCompleted'] ?? 0;
    numbersPerfectRounds = learningStates['numbersPerfectRounds'] ?? 0;
    learnedColoursAll = learningStates['learnedColoursAll'] ?? false;
    colourRoundsCompleted = learningStates['colourRoundsCompleted'] ?? 0;
    colourBestStreak = learningStates['colourBestStreak'] ?? 0;
    learnedFruitsAll = learningStates['learnedFruitsAll'] ?? false;
    fruitsRoundsCompleted = learningStates['fruitsRoundsCompleted'] ?? 0;
    fruitsBestStreak = learningStates['fruitsBestStreak'] ?? 0;
    learnedAnimalsAll = learningStates['learnedAnimalsAll'] ?? false;
    animalsRoundsCompleted = learningStates['animalsRoundsCompleted'] ?? 0;
    animalsPerfectRounds = learningStates['animalsPerfectRounds'] ?? 0;
    firstQuizMedalEarned = learningStates['firstQuizMedalEarned'] ?? false;

    // Unlocked content
    final unlockedList = data['unlockedContent'] as List? ?? [];
    _unlockedContent.clear();
    _unlockedContent.addAll(unlockedList.cast<String>());

    // Level 1 answers
    final level1List = data['level1Answers'] as List? ?? [];
    level1Answers = level1List.map((e) => e == null ? null : (e == 1)).toList();
    if (level1Answers.isEmpty) {
      level1Answers = List<bool?>.filled(5, null);
    }
  }
}

enum UnlockStatus { success, alreadyUnlocked, needLevel, needKeys }