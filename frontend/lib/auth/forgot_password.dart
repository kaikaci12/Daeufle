import 'package:Daeufle/constants/colors.dart';
import 'package:Daeufle/services/auth_manager.dart';
import 'package:Daeufle/widgets/custom_text_field.dart';
import 'package:flutter/material.dart';

class ForgotPassword extends StatefulWidget {
  const ForgotPassword({super.key});

  @override
  State<ForgotPassword> createState() => _ForgotPasswordState();
}

class _ForgotPasswordState extends State<ForgotPassword> {
  final TextEditingController emailController = TextEditingController();
  final _auth = AuthManager();
  @override
  void dispose() {
    emailController.dispose();
    super.dispose();
  }

  Future<void> handleSendPasswordResetLink() async {
    final error = await _auth.sendPasswordResetLink(
      emailController.text.trim(),
    );
    if (error == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Successfully sent password reset link to ${emailController.text}',
          ),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Password Reset"), centerTitle: true),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Text(
              'Please Provide Email address and We will send you the password reset link',
              style: TextStyle(
                color: Colors.black,
                fontSize: 20,
                fontWeight: FontWeight.w800,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 40.0),
            CustomTextField(
              labelText: 'Email',
              hintText: 'Enter Email',
              controller: emailController,
              keyboardType: TextInputType.emailAddress,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your email';
                }
                if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                  return 'Please enter a valid email address';
                }
                return null;
              },
            ),
            SizedBox(height: 30),
            ElevatedButton(
              onPressed: handleSendPasswordResetLink,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryBlue,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
                elevation: 0,
              ),
              child: const Text(
                'Send Link',
                style: TextStyle(
                  color: AppColors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
