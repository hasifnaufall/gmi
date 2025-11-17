// Manual Test Script for Streak Feature
// Run this in your Dart/Flutter console to test streak behavior

void main() {
  print('=== STREAK RESET TEST ===\n');
  
  // Scenario: User last active Sunday 2 PM
  final sunday2pm = DateTime(2024, 11, 17, 14, 0);
  print('Last active: Sunday, Nov 17, 2024 at 2:00 PM');
  
  // Test 1: Monday 2 PM (exactly 24 hours later)
  final monday2pm = DateTime(2024, 11, 18, 14, 0);
  final date1 = DateTime(sunday2pm.year, sunday2pm.month, sunday2pm.day);
  final date2 = DateTime(monday2pm.year, monday2pm.month, monday2pm.day);
  final dayDiff1 = date2.difference(date1).inDays;
  
  print('\nTest 1: Monday, Nov 18 at 2:00 PM');
  print('  Day difference: $dayDiff1');
  print('  Result: ${dayDiff1 == 1 ? "✅ SAFE - Streak continues" : "❌ RESET"}');
  
  // Test 2: Monday 11:59 PM (last minute of grace period)
  final monday1159pm = DateTime(2024, 11, 18, 23, 59);
  final date3 = DateTime(monday1159pm.year, monday1159pm.month, monday1159pm.day);
  final dayDiff2 = date3.difference(date1).inDays;
  
  print('\nTest 2: Monday, Nov 18 at 11:59 PM');
  print('  Day difference: $dayDiff2');
  print('  Result: ${dayDiff2 == 1 ? "✅ SAFE - Streak continues" : "❌ RESET"}');
  
  // Test 3: Tuesday 12:00 AM (first minute of 2nd day)
  final tuesday12am = DateTime(2024, 11, 19, 0, 0);
  final date4 = DateTime(tuesday12am.year, tuesday12am.month, tuesday12am.day);
  final dayDiff3 = date4.difference(date1).inDays;
  
  print('\nTest 3: Tuesday, Nov 19 at 12:00 AM');
  print('  Day difference: $dayDiff3');
  print('  Result: ${dayDiff3 > 1 ? "❌ RESET - Streak goes to 0" : "✅ SAFE"}');
  
  // Test 4: Tuesday 2 PM
  final tuesday2pm = DateTime(2024, 11, 19, 14, 0);
  final date5 = DateTime(tuesday2pm.year, tuesday2pm.month, tuesday2pm.day);
  final dayDiff4 = date5.difference(date1).inDays;
  
  print('\nTest 4: Tuesday, Nov 19 at 2:00 PM');
  print('  Day difference: $dayDiff4');
  print('  Result: ${dayDiff4 > 1 ? "❌ RESET - Streak goes to 0" : "✅ SAFE"}');
  
  print('\n=== SUMMARY ===');
  print('Last active: Sunday 2 PM');
  print('Grace period ends: Monday 11:59 PM');
  print('Streak resets: Tuesday 12:00 AM onwards');
  print('\n✅ Your streak is SAFE if you come back anytime on Monday');
  print('❌ Your streak RESETS if you don\'t come back until Tuesday or later');
}
