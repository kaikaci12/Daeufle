import 'package:Daeufle/auth/verify_email.dart';
import 'package:Daeufle/constants/colors.dart'; // Adjust import path if 'colors.dart' is in a different place
import 'package:Daeufle/services/auth_manager.dart';

import 'package:Daeufle/widgets/custom_text_field.dart'; // Import your custom text field
import 'package:flutter/material.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  // Global key for the form, used to validate and save form fields.
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  // State variable to track if the "agree to terms" checkbox is checked.
  bool _agreeToTerms = false;

  // State variable to manage the loading state (e.g., when an API call is in progress).
  bool _isLoading = false;

  // Controllers for text input fields to retrieve their values.
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  // Dispose controllers to free up resources when the widget is removed from the tree.
  @override
  void dispose() {
    usernameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  // Asynchronous function to handle the registration process.
  Future<void> register() async {
    final authManager = AuthManager();

    // Check if the "agree to terms" checkbox is not checked.
    if (!_agreeToTerms) {
      // Show a SnackBar message to the user if terms are not agreed.
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
            'Please agree to the processing of personal data.',
          ),
          backgroundColor: Colors.red, // Using a new error color
        ),
      );
      return; // Stop the registration process.
    }

    // Validate all form fields using the _formKey.
    if (_formKey.currentState?.validate() ?? false) {
      // If validation passes, set loading state to true.
      setState(() {
        _isLoading = true;
      });

      // Access the values from the controllers.
      final String username = usernameController.text;
      final String email = emailController.text;
      final String password = passwordController.text;
      final error = await authManager.signUpWithEmailAndPassword(
        email,
        password,
        username,
      );

      setState(() {
        _isLoading = false;
      });

      if (error == null) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => CheckEmailScreen(email: email),
          ),
        );
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
      body: Stack(
        children: [
          // Background Image
          Positioned.fill(
            child: Image.asset(
              'assets/images/backgrounds/welcome_background.png', // Your background image path
              fit: BoxFit.cover, // Ensures the image covers the whole area
            ),
          ),
          // Gradient Overlay to improve text readability on top of the image.
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withOpacity(0.3), // Slightly darker at the top
                    Colors.black.withOpacity(0.0), // Fades to transparent
                    Colors.black.withOpacity(
                      0.1,
                    ), // Slightly darker at the bottom
                  ],
                  stops: const [0.0, 0.4, 1.0], // Control gradient spread
                ),
              ),
            ),
          ),
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
                    // Get Started Text
                    Text(
                      'Get Started',
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
                            labelText: 'Full Name',
                            hintText: 'Enter Full Name',
                            controller:
                                usernameController, // Pass the controller
                            validator: (value) {
                              // Add validator for username
                              if (value == null || value.isEmpty) {
                                return 'Please enter your full name';
                              }
                              if (value.characters.length < 5) {
                                return "Username must contain at least 5 charachters";
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16.0),
                          CustomTextField(
                            labelText: 'Email',
                            hintText: 'Enter Email',
                            controller: emailController, // Pass the controller
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

                    // Checkbox and Agreement Text
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          width: 24,
                          height: 24,
                          child: Checkbox(
                            value: _agreeToTerms,
                            onChanged: (bool? newValue) {
                              setState(() {
                                _agreeToTerms = newValue ?? false;
                              });
                            },
                            activeColor: AppColors.primaryBlue,
                            checkColor: AppColors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(4),
                            ),
                            side: const BorderSide(
                              color:
                                  AppColors.white, // White border for checkbox
                              width: 1.5,
                            ),
                          ),
                        ),

                        const SizedBox(width: 8.0),
                        Expanded(
                          child: RichText(
                            text: TextSpan(
                              text: 'I agree to the processing of ',
                              style: TextStyle(
                                color: AppColors.white, // White text
                                fontSize: 14,
                                height: 1.5,
                              ),
                              children: <TextSpan>[
                                TextSpan(
                                  text: 'Personal data',
                                  style: TextStyle(
                                    color: AppColors
                                        .secondaryBlue, // Keep blue for link
                                    fontWeight: FontWeight.w600,
                                    decoration: TextDecoration.underline,
                                  ),
                                  // Add a recognizer for onTap if it's a clickable link
                                  // recognizer: TapGestureRecognizer()..onTap = () {
                                  //   print('Personal data terms clicked!');
                                  // },
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 40.0),

                    // Sign up Button
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: _isLoading
                            ? null
                            : register, // Disable button when loading
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
                                'Sign up',
                                style: TextStyle(
                                  color: AppColors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                      ),
                    ),
                    const SizedBox(height: 24.0),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
