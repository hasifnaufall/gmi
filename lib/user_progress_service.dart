import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UserProgressService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> saveProgress({
    required int level,
    required int score,
    required List<String> achievements,
  }) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) throw Exception('No user logged in');
    // This saves progress PER-USER, using their UID as document
    await _firestore.collection('progress').doc(user.uid).set({
      'level': level,
      'score': score,
      'achievements': achievements,
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
}