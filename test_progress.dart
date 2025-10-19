import 'dart:io';
import 'lib/quest_status.dart';

// Simple test to verify progress save/load functionality
void main() async {
  print('=== TESTING PROGRESS SAVE/LOAD ===');

  // Simulate user A login
  String userAId = 'test_user_a';
  print('\n1. Simulating User A login...');

  // Load progress for user A (should start fresh)
  await QuestStatus.loadProgressForUser(userAId);
  QuestStatus.showCurrentProgress();

  // Simulate some progress
  print('\n2. Simulating progress for User A...');
  QuestStatus.level = 5;
  QuestStatus.xp = 250;
  QuestStatus.userPoints = 100;
  QuestStatus.chestsOpened = 2;
  QuestStatus.claimedPoints = 150;
  QuestStatus.streakDays = 3;
  QuestStatus.showCurrentProgress();

  // Save progress
  print('\n3. Saving progress for User A...');
  await QuestStatus.autoSaveProgress();
  print('Progress saved!');

  // Simulate logout (clear user)
  print('\n4. Simulating logout...');
  QuestStatus.clearCurrentUser();
  QuestStatus.resetToDefaults();
  QuestStatus.showCurrentProgress();

  // Simulate user A login again
  print('\n5. Simulating User A login again...');
  await QuestStatus.loadProgressForUser(userAId);
  QuestStatus.showCurrentProgress();

  print('\n=== TEST COMPLETE ===');
  print('Expected: Progress should be restored to level 5, XP 250, etc.');
  print('Actual: Check the progress shown above');

  exit(0);
}
