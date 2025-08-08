class QuestStatus {
  // Tracks the number of questions completed
  static int completedQuestions = 0;

  // Tracks if Level 1 is completed
  static bool level1Completed = false;

  // Tracks if the quests are claimed
  static bool quest1Claimed = false; // "Complete 3 Questions"
  static bool quest2Claimed = false; // "Complete Level 1"

  // Add points (you can customize this for user-based points later)
  static int userPoints = 0;

  // Reset method (optional)
  static void reset() {
    completedQuestions = 0;
    level1Completed = false;
    quest1Claimed = false;
    quest2Claimed = false;
    userPoints = 0;
  }
}
