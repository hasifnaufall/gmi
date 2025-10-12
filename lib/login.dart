import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'quiz_category.dart';
import 'signup.dart';
import 'auth_service.dart';
import 'quest_status.dart';          // <-- Import your QuestStatus class
import 'user_progress_service.dart'; // <-- Import your UserProgressService

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final auth = FirebaseAuth.instance;
  final authService = AuthService();

  Future<void> login() async {
    final email = emailController.text.trim();
    final password = passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      showError("Please fill in both fields.");
      return;
    }

    try {
      await auth.signInWithEmailAndPassword(email: email, password: password);

      // LOAD PROGRESS HERE
      final _progressService = UserProgressService();
      final progress = await _progressService.getProgress();
      if (progress != null) {
        QuestStatus.level = progress['level'];
        QuestStatus.xp = progress['score'];
        QuestStatus.achievements = Set<String>.from(progress['achievements'] ?? []);
        // Add more QuestStatus fields as needed
      } else {
        // Optionally reset QuestStatus fields to default for new users
        QuestStatus.level = 1;
        QuestStatus.xp = 0;
        QuestStatus.achievements = <String>{};
      }

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => QuizCategoryScreen()),
      );
    } on FirebaseAuthException catch (e) {
      String message;
      switch (e.code) {
        case 'invalid-email':
          message = "The email address is badly formatted.";
          break;
        case 'user-not-found':
          message = "No user found for that email.";
          break;
        case 'wrong-password':
          message = "Wrong password provided.";
          break;
        case 'network-request-failed':
          message = "Network error. Please check your connection.";
          break;
        case 'user-disabled':
          message = "This account has been disabled.";
          break;
        default:
          message = "[${e.code}] ${e.message}";
      }
      showError(message);
    } catch (e) {
      showError("An unexpected error occurred.\n${e.toString()}");
    }
  }

  Future<void> loginWithGoogle() async {
    try {
      await authService.signInWithGoogle();

      // LOAD PROGRESS HERE
      final _progressService = UserProgressService();
      final progress = await _progressService.getProgress();
      if (progress != null) {
        QuestStatus.level = progress['level'];
        QuestStatus.xp = progress['score'];
        QuestStatus.achievements = Set<String>.from(progress['achievements'] ?? []);
        // Add more QuestStatus fields as needed
      } else {
        // Optionally reset QuestStatus fields to default for new users
        QuestStatus.level = 1;
        QuestStatus.xp = 0;
        QuestStatus.achievements = <String>{};
      }

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => QuizCategoryScreen()),
      );
    } catch (e) {
      showError("Google Sign-In failed.\n${e.toString()}");
    }
  }

  void showError(String message) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Login Failed"),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("OK"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blue.shade100, Colors.blue.shade300],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(vertical: 50),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Centered WaveAct logo only
                Image.asset('assets/images/logo.png', height: 120),

                const SizedBox(height: 40),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 30),
                  child: TextField(
                    controller: emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(
                      prefixIcon: const Icon(Icons.person_outline),
                      hintText: "Email",
                      filled: true,
                      fillColor: Colors.white.withOpacity(0.9),
                      contentPadding: const EdgeInsets.symmetric(vertical: 15),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 30),
                  child: TextField(
                    controller: passwordController,
                    obscureText: true,
                    decoration: InputDecoration(
                      prefixIcon: const Icon(Icons.lock_outline),
                      hintText: "Password",
                      filled: true,
                      fillColor: Colors.white.withOpacity(0.9),
                      contentPadding: const EdgeInsets.symmetric(vertical: 15),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 30),
                ElevatedButton(
                  onPressed: login,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue.shade700,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    padding:
                    const EdgeInsets.symmetric(horizontal: 100, vertical: 15),
                    elevation: 5,
                  ),
                  child: const Text(
                    "LOGIN",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  icon: Image.asset(
                    'assets/images/google.png',
                    height: 24,
                  ),
                  label: const Text(
                    "Sign in with Google",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.redAccent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    padding:
                    const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                  ),
                  onPressed: loginWithGoogle,
                ),
                const SizedBox(height: 16),
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const SignUpScreen()),
                    );
                  },
                  child: const Text(
                    "Don't have an account? Sign Up",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                GestureDetector(
                  onTap: () {},
                  child: Text(
                    "LANGUAGE",
                    style: TextStyle(
                      color: Colors.blue.shade900,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}