import 'package:Daeufle/constants/colors.dart';
import 'package:Daeufle/auth/sign_in.dart'; // Assuming you have a SignInScreen
import 'package:firebase_auth/firebase_auth.dart'; // Import Firebase Auth
import 'package:flutter/material.dart';

class CheckEmailScreen extends StatefulWidget {
  final String email;

  const CheckEmailScreen({super.key, required this.email});

  @override
  State<CheckEmailScreen> createState() => _CheckEmailScreenState();
}

class _CheckEmailScreenState extends State<CheckEmailScreen> {
  bool _isResending = false;

  Future<void> _resendVerificationEmail() async {
    setState(() {
      _isResending = true; // Show loading on button
    });
    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        // Ensure the user is not already verified before resending
        await user.reload(); // Get the latest verification status
        if (user.emailVerified) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Email is already verified!'),
                backgroundColor: Colors.green,
              ),
            );
          }
          // Optionally navigate to sign-in if already verified
          if (mounted) {
            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (context) => const SignInScreen()),
              (route) => false,
            );
          }
          return;
        }

        await user.sendEmailVerification();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Verification email re-sent! Please check your inbox.',
              ),
              backgroundColor: AppColors.primaryBlue,
            ),
          );
        }
      } else {
        // User might have logged out or session expired
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('No active user. Please sign in again.'),
              backgroundColor: Colors.orange,
            ),
          );
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (context) => const SignInScreen()),
            (route) => false,
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to resend email: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isResending = false; // Hide loading on button
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryBlue,
      appBar: AppBar(
        title: const Text(
          'Verify Your Email',
          style: TextStyle(color: AppColors.white),
        ),
        backgroundColor: AppColors.primaryBlue,
        iconTheme: const IconThemeData(color: AppColors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Icon(Icons.email_outlined, size: 100, color: AppColors.white),
            const SizedBox(height: 30),
            const Text(
              'A verification email has been sent to:',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.white, fontSize: 18),
            ),
            const SizedBox(height: 10),
            Text(
              widget.email, // Display the email here
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppColors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              ' Click the link in the email to verify your account',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.white, fontSize: 16),
            ),
            const Text(
              'If you do not see the email Please check your Spam folder',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.white, fontSize: 16),
            ),

            const SizedBox(height: 40),
            ElevatedButton.icon(
              onPressed: _isResending ? null : _resendVerificationEmail,
              icon: _isResending
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          AppColors.white,
                        ),
                      ),
                    )
                  : const Icon(Icons.send, color: AppColors.white),
              label: Text(
                _isResending ? 'Resending...' : 'Resend Email',
                style: const TextStyle(color: AppColors.white, fontSize: 16),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.secondaryBlue,
                padding: const EdgeInsets.symmetric(
                  horizontal: 30,
                  vertical: 15,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            const SizedBox(height: 20),
            TextButton(
              onPressed: () {
                // Allows user to go back to sign-in screen when they're ready to log in
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (context) => const SignInScreen()),
                  (route) => false, // Clears the navigation stack
                );
              },
              child: const Text(
                'Go to Sign In',
                style: TextStyle(
                  color: AppColors.white,
                  decoration: TextDecoration.underline,
                  fontSize: 16,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
