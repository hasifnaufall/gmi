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
}