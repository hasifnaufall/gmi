class QuestStatus {
  // ===== Level 1 (Alphabet) =====
  static List<bool?> level1Answers = List<bool?>.filled(5, null);

  static int get completedQuestions =>
      level1Answers.where((e) => e != null).length;

  static bool get level1Completed =>
      level1Answers.every((e) => e != null);

  static int get level1Score =>
      level1Answers.where((e) => e == true).length;

  // ===== Quests / Points =====
  static bool quest1Claimed = false; // "Complete 3 Questions"
  static bool quest2Claimed = false; // "Complete Level 1"
  static int userPoints = 0;

  // ===== Chest reward =====
  static bool chestClaimed = false;          // ✅ NEW: prevent double-claim
  static const int chestReward = 200;        // ✅ change reward here

  // Ensure answers length matches the quiz size
  static void ensureLevel1Length(int length) {
    if (level1Answers.length != length) {
      final old = level1Answers;
      level1Answers = List<bool?>.filled(length, null);
      for (int i = 0; i < length && i < old.length; i++) {
        level1Answers[i] = old[i];
      }
    }
  }

  static void resetLevel1() {
    level1Answers = List<bool?>.filled(level1Answers.length, null);
    quest1Claimed = false;
    quest2Claimed = false;
    chestClaimed = false; // reset chest too
  }

  static void resetAll() {
    resetLevel1();
    userPoints = 0;
  }
}
