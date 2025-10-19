import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UserProgressService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> saveProgress({
    required int level,
    required int score,
    required List<String> achievements,
    required int userPoints,
    required int claimedPoints,
    required int levelGoalPoints,
    required int chestsOpened,
    required int streakDays,
    required int longestStreak,
    int? lastStreakUtc,
    required Map<String, bool> questStates,
    required Map<String, dynamic> learningStates,
    required List<String> unlockedContent,
    required List<int?> level1Answers,
  }) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) throw Exception('No user logged in');

    // This saves progress PER-USER, using their UID as document
    await _firestore.collection('progress').doc(user.uid).set({
      'level': level,
      'score': score,
      'achievements': achievements,
      'userPoints': userPoints,
      'claimedPoints': claimedPoints,
      'levelGoalPoints': levelGoalPoints,
      'chestsOpened': chestsOpened,
      'streakDays': streakDays,
      'longestStreak': longestStreak,
      'lastStreakUtc': lastStreakUtc,
      'questStates': questStates,
      'learningStates': learningStates,
      'unlockedContent': unlockedContent,
      'level1Answers': level1Answers,
      'timestamp': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  Future<Map<String, dynamic>?> getProgress() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) throw Exception('No user logged in');

    // This loads progress PER-USER, using their UID as document
    var doc = await _firestore.collection('progress').doc(user.uid).get();
    return doc.exists ? doc.data() : null;
  }

  /// Get the current user ID
  String? getCurrentUserId() {
    return FirebaseAuth.instance.currentUser?.uid;
  }

  /// Get global leaderboard data with display names
  Future<List<Map<String, dynamic>>> getLeaderboard({int limit = 20}) async {
    try {
      final snapshot = await _firestore
          .collection('progress')
          .orderBy('level', descending: true)
          .limit(limit)
          .get();

      final leaderboard = <Map<String, dynamic>>[];

      for (final doc in snapshot.docs) {
        final userData = doc.data();

        // Try to get display name from users collection
        String displayName = 'Player';
        try {
          final userDoc = await _firestore
              .collection('users')
              .doc(doc.id)
              .get();
          if (userDoc.exists) {
            displayName = userDoc.data()?['displayName'] ?? 'Player';
          }
        } catch (e) {
          print('Error getting display name for ${doc.id}: $e');
        }

        leaderboard.add({
          'userId': doc.id,
          'displayName': displayName,
          ...userData,
        });
      }

      return leaderboard;
    } catch (e) {
      print('Error fetching leaderboard: $e');
      return [];
    }
  }

  /// Clear user progress (for reset functionality)
  Future<void> clearProgress() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) throw Exception('No user logged in');

    await _firestore.collection('progress').doc(user.uid).delete();
    print('Progress cleared for user: ${user.uid}');
  }

  /// Save user display name and log changes for admin monitoring
  Future<void> saveDisplayName(String displayName) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) throw Exception('No user logged in');

    // Get old display name
    String? oldName;
    try {
      final doc = await _firestore.collection('users').doc(user.uid).get();
      if (doc.exists) {
        oldName = doc.data()?['displayName'] as String?;
      }
    } catch (e) {
      print('Error getting old display name: $e');
    }

    // Save new display name
    await _firestore.collection('users').doc(user.uid).set({
      'displayName': displayName,
      'email': user.email,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));

    // Log the change for admin monitoring
    await _firestore.collection('display_name_changes').add({
      'userId': user.uid,
      'oldName': oldName ?? '',
      'newName': displayName,
      'timestamp': FieldValue.serverTimestamp(),
    });

    print('Display name saved: $displayName and change logged');
  }

  /// Get user display name
  Future<String?> getDisplayName() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return null;

    try {
      final doc = await _firestore.collection('users').doc(user.uid).get();
      if (doc.exists) {
        return doc.data()?['displayName'] as String?;
      }
    } catch (e) {
      print('Error getting display name: $e');
    }
    return null;
  }
}
