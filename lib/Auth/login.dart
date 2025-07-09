// ignore_for_file: use_build_context_synchronously, deprecated_member_use

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:train_hard_reborn/Auth/auth_services.dart';
import 'package:train_hard_reborn/Components/snackbar.dart';
import 'package:train_hard_reborn/routes.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isPasswordVisible = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    CustomSnackbar.showLoading(context, message: "Logging in...");

    try {
      UserCredential userCredential = await FirebaseAuth.instance
          .signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      final uid = userCredential.user!.uid;
      // Check if user exists in Firestore
      var userSnapshot =
          await FirebaseFirestore.instance
              .collection('users')
              .doc(uid)
              .get();

      if (!userSnapshot.exists) {
        CustomSnackbar.hideSnackbar(context);
        CustomSnackbar.showMessage(
          context,
          message: "User not registered!",
          type: SnackbarType.error,
        );
        return;
      }

      // Sign in with Firebase Authentication
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      // ✅ Save login state
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setBool('isLoggedIn', true);

      CustomSnackbar.hideSnackbar(context);
      CustomSnackbar.showMessage(
        context,
        message: "Login successful!",
        type: SnackbarType.success,
      );
    
    // 🔎 Check if onboarding fields are present
    final userData = userSnapshot.data();
    final requiredFields = ['gender', 'weight', 'height', 'age', 'activity_level'];
    final isProfileIncomplete = requiredFields.any((field) {
      final value = userData?[field];

      if (value == null) return true;

      if (value is String) {
        return value.trim().isEmpty;
      }

      if (value is num) {
        return value <= 0; // assuming 0 is invalid for weight, height, or age
      }

      return false;
    });

    // 🧭 Navigate accordingly
    if (isProfileIncomplete) {
      Navigator.pushReplacementNamed(context, '/user_profile_onboarding');
    } else {
      Navigator.pushReplacementNamed(context, '/home');
    }
    } catch (e) {
      CustomSnackbar.hideSnackbar(context);
      String errorMessage = "An error occurred. Please try again.";
      if (e is FirebaseAuthException) {
        errorMessage = e.message ?? errorMessage;
      }
      CustomSnackbar.showMessage(
        context,
        message: errorMessage,
        type: SnackbarType.error,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.blue.shade50,
              Colors.white,
            ],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Container(
                constraints: const BoxConstraints(maxWidth: 400),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Logo with animated container
                    Container(
                      height: 100,
                      width: 100,
                      decoration: BoxDecoration(
                        color: Colors.blue.shade100,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.blue.shade200,
                            blurRadius: 20,
                            spreadRadius: 5,
                          ),
                        ],
                      ),
                      child: Icon(
                        Icons.fitness_center_rounded,
                        size: 50,
                        color: Colors.blue.shade800,
                      ),
                    ),
                    const SizedBox(height: 30),

                    // Welcome Text with enhanced typography
                    const Text(
                      'Welcome',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Train smarter, achieve more',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 40),

                    // Login Form with enhanced styling
                    Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          // Email Field
                          TextFormField(
                            controller: _emailController,
                            keyboardType: TextInputType.emailAddress,
                            decoration: InputDecoration(
                              labelText: 'Email',
                              hintText: 'Enter your email',
                              prefixIcon: Icon(
                                Icons.email_outlined,
                                color: Colors.blue.shade700,
                              ),
                              filled: true,
                              fillColor: Colors.grey.shade50,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                                borderSide: BorderSide.none,
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                                borderSide: BorderSide(
                                  color: Colors.blue.shade700,
                                  width: 2,
                                ),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                                borderSide: BorderSide(
                                  color: Colors.grey.shade200,
                                  width: 1,
                                ),
                              ),
                              labelStyle: TextStyle(color: Colors.grey.shade700),
                              contentPadding: const EdgeInsets.symmetric(
                                vertical: 16,
                                horizontal: 16,
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter your email';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 20),

                          // Password Field
                          TextFormField(
                            controller: _passwordController,
                            obscureText: !_isPasswordVisible,
                            decoration: InputDecoration(
                              labelText: 'Password',
                              hintText: 'Enter your password',
                              prefixIcon: Icon(
                                Icons.lock_outline,
                                color: Colors.blue.shade700,
                              ),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _isPasswordVisible
                                      ? Icons.visibility_outlined
                                      : Icons.visibility_off_outlined,
                                  color: Colors.grey.shade600,
                                ),
                                onPressed: () {
                                  setState(() {
                                    _isPasswordVisible = !_isPasswordVisible;
                                  });
                                },
                              ),
                              filled: true,
                              fillColor: Colors.grey.shade50,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                                borderSide: BorderSide.none,
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                                borderSide: BorderSide(
                                  color: Colors.blue.shade700,
                                  width: 2,
                                ),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                                borderSide: BorderSide(
                                  color: Colors.grey.shade200,
                                  width: 1,
                                ),
                              ),
                              labelStyle: TextStyle(color: Colors.grey.shade700),
                              contentPadding: const EdgeInsets.symmetric(
                                vertical: 16,
                                horizontal: 16,
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter your password';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),

                          // Forgot Password with better styling
                          Align(
                            alignment: Alignment.centerRight,
                            child: TextButton(
                              onPressed: () {
                                AppRoutes.navigateToForgotPassword(context);
                              },
                              style: TextButton.styleFrom(
                                foregroundColor: Colors.blue.shade700,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                              ),
                              child: const Text(
                                'Forgot Password?',
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 30),

                          // Login Button with enhanced styling
                          SizedBox(
                            width: double.infinity,
                            height: 56,
                            child: ElevatedButton(
                              onPressed: _handleLogin,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blue.shade700,
                                foregroundColor: Colors.white,
                                elevation: 3,
                                shadowColor: Colors.blue.withOpacity(0.5),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                              ),
                              child: const Text(
                                'SIGN IN',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 1.2,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Sign Up Option with better spacing
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Don\'t have an account? ',
                          style: TextStyle(
                            color: Colors.grey[700],
                            fontSize: 15,
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            AppRoutes.navigateToSignUp(context);
                          },
                          style: TextButton.styleFrom(
                            foregroundColor: Colors.blue.shade700,
                            padding: EdgeInsets.zero,
                            minimumSize: const Size(50, 30),
                          ),
                          child: const Text(
                            'Sign Up',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 30),

                    // "Or continue with" divider
                    Row(
                      children: [
                        Expanded(
                          child: Divider(
                            color: Colors.grey.shade300,
                            thickness: 1,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Text(
                            'Or continue with',
                            style: TextStyle(
                              color: Colors.grey.shade600,
                              fontSize: 14,
                            ),
                          ),
                        ),
                        Expanded(
                          child: Divider(
                            color: Colors.grey.shade300,
                            thickness: 1,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Social Login Buttons in a row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Google Login Button
                        Expanded(
                          child: SizedBox(
                            height: 54,
                            child: ElevatedButton.icon(
                              icon: const Icon(Icons.g_mobiledata, size: 28),
                              label: const Text("Google"),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white,
                                foregroundColor: Colors.black87,
                                elevation: 2,
                                shadowColor: Colors.grey.withOpacity(0.3),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                  side: BorderSide(
                                    color: Colors.grey.shade300,
                                    width: 1,
                                  ),
                                ),
                              ),
                              onPressed: () async {
                                CustomSnackbar.showLoading(
                                  context,
                                  message: "Signing in with Google...",
                                );
                                try {
                                  final userCredential =
                                      await AuthServices.signInWithGoogle();
                                  if (userCredential != null) {
                                    SharedPreferences prefs =
                                        await SharedPreferences.getInstance();
                                    await prefs.setBool('isLoggedIn', true);
                                    CustomSnackbar.hideSnackbar(context);
                                    Navigator.pushReplacementNamed(context, '/home');
                                  } else {
                                    CustomSnackbar.hideSnackbar(context);
                                  }
                                } catch (e) {
                                  CustomSnackbar.hideSnackbar(context);
                                  CustomSnackbar.showMessage(
                                    context,
                                    message: "Google login failed",
                                    type: SnackbarType.error,
                                  );
                                }
                              },
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        // Facebook Login Button
                        Expanded(
                          child: SizedBox(
                            height: 54,
                            child: ElevatedButton.icon(
                              icon: const Icon(Icons.facebook, size: 24),
                              label: const Text("Facebook"),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white,
                                foregroundColor: Colors.blue.shade900,
                                elevation: 2,
                                shadowColor: Colors.grey.withOpacity(0.3),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                  side: BorderSide(
                                    color: Colors.grey.shade300,
                                    width: 1,
                                  ),
                                ),
                              ),
                              onPressed: () async {
                                CustomSnackbar.showLoading(
                                  context,
                                  message: "Signing in with Facebook...",
                                );
                                try {
                                  final userCredential =
                                      await AuthServices.signInWithFacebook();
                                  if (userCredential != null) {
                                    SharedPreferences prefs =
                                        await SharedPreferences.getInstance();
                                    await prefs.setBool('isLoggedIn', true);
                                    CustomSnackbar.hideSnackbar(context);
                                    Navigator.pushReplacementNamed(context, '/home');
                                  } else {
                                    CustomSnackbar.hideSnackbar(context);
                                  }
                                } catch (e) {
                                  CustomSnackbar.hideSnackbar(context);
                                  CustomSnackbar.showMessage(
                                    context,
                                    message: "Facebook login failed",
                                    type: SnackbarType.error,
                                  );
                                }
                              },
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
        ),
      ),
    );
  }
}