
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Listen to auth state
  Stream<User?> authStateChanges() => _auth.authStateChanges();

  // Current user (nullable)
  User? get currentUser => _auth.currentUser;

  // Email/password sign in
  Future<UserCredential> signInWithEmail({
    required String email,
    required String password,
  }) {
    return _auth.signInWithEmailAndPassword(email: email, password: password);
  }

  // Email/password sign up
  Future<UserCredential> signUpWithEmail({
    required String email,
    required String password,
  }) {
    return _auth.createUserWithEmailAndPassword(email: email, password: password);
  }

  // Google sign-in (mobile & web)
  Future<UserCredential?> signInWithGoogle() async {
    if (kIsWeb) {
      final provider = GoogleAuthProvider();
      return _auth.signInWithPopup(provider);
    }

    // Android/iOS
    final googleUser = await GoogleSignIn().signIn();
    if (googleUser == null) return null; // user canceled

    final googleAuth = await googleUser.authentication;
    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );
    return _auth.signInWithCredential(credential);
  }

  // Sign out
  Future<void> signOut() async {
    // Sign out of Google, too (no-op on web if not used)
    try {
      if (!kIsWeb && (Platform.isAndroid || Platform.isIOS)) {
        await GoogleSignIn().signOut();
      }
    } catch (_) {}
    await _auth.signOut();
  }
}
