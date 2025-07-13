// lib/screens/sign_in_screen.dart
import 'dart:math';

import 'package:Daeufle/constants/colors.dart'; // Adjust import path if 'colors.dart' is in a different place
import 'package:Daeufle/main.dart';
import 'package:Daeufle/screens/home.dart';
import 'package:Daeufle/services/auth_manager.dart';
import 'package:Daeufle/widgets/custom_text_field.dart'; // Import your custom text field
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  // Global key for the form, used to validate and save form fields.
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  // State variable to manage the loading state (e.g., when an API call is in progress).
  bool _isLoading = false;

  // Controllers for text input fields to retrieve their values.
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  void login() async {
    final error = await AuthManager().signInWithEmailAndPassword(
      emailController.text,
      passwordController.text,
    );
    if (error == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Sign-in successful!'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.of(
        context,
      ).pushReplacement(MaterialPageRoute(builder: (_) => AuthWrapper()));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error), backgroundColor: Colors.red),
      );
    }
  }

  // Dispose controllers to free up resources when the widget is removed from the tree.
  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  // Asynchronous function to handle the sign-in process.
  Future<void> signIn() async {
    // Validate all form fields using the _formKey.
    if (_formKey.currentState?.validate() ?? false) {
      // If validation passes, set loading state to true.
      setState(() {
        _isLoading = true;
      });

      // Access the values from the controllers.
      final String email = emailController.text;
      final String password = passwordController.text;

      final error = await AuthManager().signInWithEmailAndPassword(
        email,
        password,
      );
      if (error == null) {
        Navigator.of(
          context,
        ).pushReplacement(MaterialPageRoute(builder: (context) => Home()));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(error), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white, // Default background for safe area
      extendBodyBehindAppBar: true,
      body: SizedBox.expand(
        child: Stack(
          children: [
            // Background Image
            Positioned.fill(
              child: Image.asset(
                'assets/images/backgrounds/welcome_background.png', // Your background image path
                fit: BoxFit.cover, // Ensures the image covers the whole area
              ),
            ),

            // Gradient Overlay to improve text readability on top of the image.
            SafeArea(
              // Use SingleChildScrollView to prevent overflow when keyboard appears.
              child: Container(
                padding: const EdgeInsets.all(24.0),
                child: Form(
                  // Wrap input fields in a Form widget for validation.
                  key: _formKey, // Assign the GlobalKey to the Form.
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Back Button
                      GestureDetector(
                        onTap: () {
                          // Navigate back when the back button is pressed.
                          Navigator.of(context).pop();
                        },
                        child: Row(
                          mainAxisSize: MainAxisSize
                              .min, // Make row only as wide as its children
                          children: [
                            Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: AppColors.primaryBlue.withOpacity(
                                  0.8,
                                ), // Slightly transparent for background blend
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.arrow_back_ios_new,
                                color: AppColors.white,
                                size: 20,
                              ),
                            ),
                            const SizedBox(width: 8.0),
                            Text(
                              'Back',
                              style: TextStyle(
                                color: AppColors
                                    .white, // White text for contrast on dark background
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 40.0), // Space after back button
                      // Welcome Back Text
                      Text(
                        'Welcome Back',
                        style: TextStyle(
                          color: AppColors.white, // White for contrast
                          fontSize: 32,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 40.0),

                      // Input Fields (wrapped in a Container for a solid background to contrast with image)
                      Container(
                        padding: const EdgeInsets.all(16.0),
                        decoration: BoxDecoration(
                          color: AppColors.white.withOpacity(
                            0.9,
                          ), // Slightly transparent white background
                          borderRadius: BorderRadius.circular(16.0),
                        ),
                        child: Column(
                          children: [
                            CustomTextField(
                              labelText: 'Email',
                              hintText: 'Enter Email',
                              controller:
                                  emailController, // Pass the controller
                              keyboardType: TextInputType.emailAddress,
                              validator: (value) {
                                // Add validator for email
                                if (value == null || value.isEmpty) {
                                  return 'Please enter your email';
                                }
                                if (!RegExp(
                                  r'^[^@]+@[^@]+\.[^@]+',
                                ).hasMatch(value)) {
                                  return 'Please enter a valid email address';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 16.0),
                            CustomTextField(
                              labelText: 'Password',
                              hintText: 'Enter Password',
                              controller:
                                  passwordController, // Pass the controller
                              obscureText: true,
                              validator: (value) {
                                // Add validator for password
                                if (value == null || value.isEmpty) {
                                  return 'Please enter a password';
                                }
                                if (value.length < 6) {
                                  return 'Password must be at least 6 characters long';
                                }
                                return null;
                              },
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24.0),

                      // Forgot Password (optional)
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: () {
                            print('Forgot Password clicked!');
                            // Navigate to forgot password screen
                          },
                          child: Text(
                            'Forgot Password?',
                            style: TextStyle(
                              color: AppColors
                                  .secondaryBlue, // Consistent link color
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16.0), // Adjust spacing
                      // Sign In Button
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton(
                          onPressed: _isLoading
                              ? null
                              : login, // Disable button when loading
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primaryBlue,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                            elevation: 0,
                          ),
                          child:
                              _isLoading // Show loading indicator if loading
                              ? const CircularProgressIndicator(
                                  color: AppColors.white,
                                )
                              : const Text(
                                  'Sign in',
                                  style: TextStyle(
                                    color: AppColors.white,
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                        ),
                      ),
                      const SizedBox(height: 24.0),

                      // Sign in with Text
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
