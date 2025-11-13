import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'theme_manager.dart';
import 'login.dart'; // navigate back after sign up

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final auth = FirebaseAuth.instance;
  bool _obscurePassword = true;

  Future<void> signUp() async {
    final email = emailController.text.trim();
    final password = passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      showError("Please fill in both fields.");
      return;
    }

    try {
      await auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      final themeManager = Provider.of<ThemeManager>(context, listen: false);
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          backgroundColor: themeManager.isDarkMode
              ? Color(0xFF2C2C2E)
              : Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Text(
            "Sign Up Successful",
            style: GoogleFonts.montserrat(
              color: themeManager.isDarkMode
                  ? Color(0xFFD23232)
                  : Color(0xFF0891B2),
              fontWeight: FontWeight.w700,
              fontSize: 20,
            ),
          ),
          content: Text(
            "You can now log in.",
            style: GoogleFonts.montserrat(
              color: themeManager.isDarkMode
                  ? Color(0xFF8E8E93)
                  : Color(0xFF2D5263),
              fontSize: 15,
            ),
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context); // close dialog
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: themeManager.isDarkMode
                    ? Color(0xFFD23232)
                    : Color(0xFF0891B2),
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
              child: Text(
                "OK",
                style: GoogleFonts.montserrat(
                  fontWeight: FontWeight.w600,
                  fontSize: 15,
                ),
              ),
            ),
          ],
        ),
      );
    } on FirebaseAuthException catch (e) {
      String message;
      switch (e.code) {
        case 'invalid-email':
          message = "The email address is badly formatted.";
          break;
        case 'email-already-in-use':
          message = "This email is already registered. Please login instead.";
          break;
        case 'weak-password':
          message = "Password is too weak. Please use at least 6 characters.";
          break;
        case 'operation-not-allowed':
          message = "Email/password sign-up is currently disabled.";
          break;
        case 'network-request-failed':
          message = "Network error. Please check your connection.";
          break;
        default:
          message = "An error occurred. Please try again.";
      }
      showError(message);
    } catch (e) {
      showError("An unexpected error occurred. Please try again.");
    }
  }

  void showError(String message) {
    final themeManager = Provider.of<ThemeManager>(context, listen: false);
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: themeManager.isDarkMode
            ? Color(0xFF2C2C2E)
            : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          "Sign Up Failed",
          style: GoogleFonts.montserrat(
            color: themeManager.isDarkMode
                ? Color(0xFFD23232)
                : Color(0xFF0891B2),
            fontWeight: FontWeight.w700,
            fontSize: 20,
          ),
        ),
        content: Text(
          message,
          style: GoogleFonts.montserrat(
            color: themeManager.isDarkMode
                ? Color(0xFF8E8E93)
                : Color(0xFF2D5263),
            fontSize: 15,
          ),
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: themeManager.isDarkMode
                  ? Color(0xFFD23232)
                  : Color(0xFF0891B2),
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 0,
            ),
            child: Text(
              "OK",
              style: GoogleFonts.montserrat(
                fontWeight: FontWeight.w600,
                fontSize: 15,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeManager>(
      builder: (context, themeManager, child) {
        return Scaffold(
          body: Stack(
            children: [
              // Background with decorative circles
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: themeManager.isDarkMode
                        ? [
                            Color(0xFF1C1C1E), // Dark background
                            Color(0xFF2C2C2E), // Slightly lighter dark
                          ]
                        : [
                            Color(0xFFCFFFF7), // Light mint
                            Color(0xFFE0F2FE), // Very light cyan
                          ],
                  ),
                ),
              ),

              // Decorative circles
              Positioned(
                top: -120,
                right: -120,
                child: Container(
                  width: 350,
                  height: 350,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: themeManager.isDarkMode
                        ? Color(0xFF8B1F1F).withOpacity(0.2)
                        : Color(0xFF7C7FCC).withOpacity(0.1),
                  ),
                ),
              ),
              Positioned(
                bottom: -100,
                left: -100,
                child: Container(
                  width: 300,
                  height: 300,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: themeManager.isDarkMode
                        ? Color(0xFF8B1F1F).withOpacity(0.15)
                        : Color(0xFF0891B2).withOpacity(0.1),
                  ),
                ),
              ),
              Positioned(
                top: 150,
                left: 40,
                child: Container(
                  width: 70,
                  height: 70,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: themeManager.isDarkMode
                        ? Color(0xFF8B1F1F).withOpacity(0.25)
                        : Color(0xFFFFEB99).withOpacity(0.3),
                  ),
                ),
              ), // Main content
              SafeArea(
                child: Center(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const SizedBox(height: 40),

                        // Welcome text
                        Text(
                          'Create Account',
                          style: GoogleFonts.montserrat(
                            fontSize: 32,
                            fontWeight: FontWeight.w800,
                            color: themeManager.isDarkMode
                                ? Color(0xFFD23232)
                                : Color(0xFF0891B2),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Join us today!',
                          style: GoogleFonts.montserrat(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: themeManager.isDarkMode
                                ? Color(0xFF8E8E93)
                                : Color(0xFF2D5263),
                          ),
                        ),

                        const SizedBox(height: 50),

                        // Signup card
                        Container(
                          padding: const EdgeInsets.all(32),
                          decoration: BoxDecoration(
                            color: themeManager.isDarkMode
                                ? Color(0xFF2C2C2E)
                                : Colors.white,
                            borderRadius: BorderRadius.circular(30),
                            boxShadow: [
                              BoxShadow(
                                color: themeManager.isDarkMode
                                    ? Color(0xFF8B1F1F).withOpacity(0.15)
                                    : Color(0xFF0891B2).withOpacity(0.1),
                                blurRadius: 30,
                                offset: const Offset(0, 15),
                              ),
                            ],
                          ),
                          child: Column(
                            children: [
                              // Logo
                              Container(
                                padding: const EdgeInsets.all(20),
                                decoration: BoxDecoration(
                                  color: themeManager.isDarkMode
                                      ? const Color(0xFF3C3C3E)
                                      : const Color(0xFFCFFFF7),
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: themeManager.isDarkMode
                                        ? const Color(
                                            0xFFD23232,
                                          ).withOpacity(0.2)
                                        : const Color(
                                            0xFF0891B2,
                                          ).withOpacity(0.2),
                                    width: 2,
                                  ),
                                ),
                                child: themeManager.isDarkMode
                                    ? ColorFiltered(
                                        colorFilter: const ColorFilter.mode(
                                          Colors.white,
                                          BlendMode.srcIn,
                                        ),
                                        child: Image.asset(
                                          'assets/images/logo.png',
                                          height: 60,
                                        ),
                                      )
                                    : Image.asset(
                                        'assets/images/logo.png',
                                        height: 60,
                                      ),
                              ),

                              const SizedBox(height: 35),

                              // Email Field
                              Container(
                                decoration: BoxDecoration(
                                  color: themeManager.isDarkMode
                                      ? const Color(0xFF3C3C3E)
                                      : const Color(0xFFF8F9FA),
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color: themeManager.isDarkMode
                                        ? const Color(
                                            0xFF636366,
                                          ).withOpacity(0.1)
                                        : const Color(
                                            0xFF0891B2,
                                          ).withOpacity(0.1),
                                    width: 1,
                                  ),
                                ),
                                child: TextField(
                                  controller: emailController,
                                  keyboardType: TextInputType.emailAddress,
                                  style: GoogleFonts.montserrat(
                                    fontSize: 15,
                                    color: themeManager.isDarkMode
                                        ? const Color(0xFFE8E8E8)
                                        : const Color(0xFF2D5263),
                                    fontWeight: FontWeight.w500,
                                  ),
                                  decoration: InputDecoration(
                                    prefixIcon: Icon(
                                      Icons.email_outlined,
                                      color: themeManager.isDarkMode
                                          ? const Color(0xFFD23232)
                                          : const Color(0xFF0891B2),
                                      size: 22,
                                    ),
                                    hintText: "Email Address",
                                    hintStyle: GoogleFonts.montserrat(
                                      color: themeManager.isDarkMode
                                          ? const Color(0xFF8E8E93)
                                          : Colors.grey.shade400,
                                      fontWeight: FontWeight.w400,
                                    ),
                                    filled: true,
                                    fillColor: Colors.transparent,
                                    contentPadding: const EdgeInsets.symmetric(
                                      vertical: 18,
                                      horizontal: 20,
                                    ),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(16),
                                      borderSide: BorderSide.none,
                                    ),
                                  ),
                                ),
                              ),

                              const SizedBox(height: 16),

                              // Password Field
                              Container(
                                decoration: BoxDecoration(
                                  color: themeManager.isDarkMode
                                      ? const Color(0xFF3C3C3E)
                                      : const Color(0xFFF8F9FA),
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color: themeManager.isDarkMode
                                        ? const Color(
                                            0xFF636366,
                                          ).withOpacity(0.1)
                                        : const Color(
                                            0xFF0891B2,
                                          ).withOpacity(0.1),
                                    width: 1,
                                  ),
                                ),
                                child: TextField(
                                  controller: passwordController,
                                  obscureText: _obscurePassword,
                                  style: GoogleFonts.montserrat(
                                    fontSize: 15,
                                    color: themeManager.isDarkMode
                                        ? const Color(0xFFE8E8E8)
                                        : const Color(0xFF2D5263),
                                    fontWeight: FontWeight.w500,
                                  ),
                                  decoration: InputDecoration(
                                    prefixIcon: Icon(
                                      Icons.lock_outline_rounded,
                                      color: themeManager.isDarkMode
                                          ? const Color(0xFFD23232)
                                          : const Color(0xFF0891B2),
                                      size: 22,
                                    ),
                                    suffixIcon: IconButton(
                                      icon: Icon(
                                        _obscurePassword
                                            ? Icons.visibility_off_outlined
                                            : Icons.visibility_outlined,
                                        color: themeManager.isDarkMode
                                            ? const Color(0xFFD23232)
                                            : const Color(0xFF0891B2),
                                        size: 22,
                                      ),
                                      onPressed: () {
                                        setState(() {
                                          _obscurePassword = !_obscurePassword;
                                        });
                                      },
                                    ),
                                    hintText: "Create a password",
                                    hintStyle: GoogleFonts.montserrat(
                                      color: themeManager.isDarkMode
                                          ? const Color(0xFF8E8E93)
                                          : Colors.grey.shade400,
                                      fontWeight: FontWeight.w400,
                                    ),
                                    filled: true,
                                    fillColor: Colors.transparent,
                                    contentPadding: const EdgeInsets.symmetric(
                                      vertical: 18,
                                      horizontal: 20,
                                    ),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(16),
                                      borderSide: BorderSide.none,
                                    ),
                                  ),
                                ),
                              ),

                              const SizedBox(height: 28),

                              // Sign Up Button
                              Container(
                                width: double.infinity,
                                height: 54,
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: themeManager.isDarkMode
                                        ? [Color(0xFFD23232), Color(0xFF8B1F1F)]
                                        : [
                                            Color(0xFF0891B2),
                                            Color(0xFF06B6D4),
                                          ],
                                  ),
                                  borderRadius: BorderRadius.circular(16),
                                  boxShadow: [
                                    BoxShadow(
                                      color: themeManager.isDarkMode
                                          ? Color(0xFFD23232).withOpacity(0.4)
                                          : Color(0xFF0891B2).withOpacity(0.4),
                                      blurRadius: 15,
                                      offset: Offset(0, 8),
                                    ),
                                  ],
                                ),
                                child: ElevatedButton(
                                  onPressed: signUp,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.transparent,
                                    shadowColor: Colors.transparent,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                  ),
                                  child: Text(
                                    "Create Account",
                                    style: GoogleFonts.montserrat(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700,
                                      letterSpacing: 0.5,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),

                              const SizedBox(height: 20),

                              // Terms text
                              Text(
                                'By signing up, you agree to our\nTerms of Service and Privacy Policy',
                                textAlign: TextAlign.center,
                                style: GoogleFonts.montserrat(
                                  fontSize: 11,
                                  color: themeManager.isDarkMode
                                      ? Color(0xFF636366)
                                      : Colors.grey.shade500,
                                  fontWeight: FontWeight.w400,
                                  height: 1.4,
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 30),

                        // Login link
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "Already have an account? ",
                              style: GoogleFonts.montserrat(
                                color: themeManager.isDarkMode
                                    ? Color(0xFF8E8E93)
                                    : Color(0xFF2D5263),
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            GestureDetector(
                              onTap: () {
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => const LoginScreen(),
                                  ),
                                );
                              },
                              child: Text(
                                "Sign in",
                                style: GoogleFonts.montserrat(
                                  fontWeight: FontWeight.w700,
                                  color: themeManager.isDarkMode
                                      ? Color(0xFFD23232)
                                      : Color(0xFF0891B2),
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 40),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
