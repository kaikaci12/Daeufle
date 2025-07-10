// lib/widgets/custom_text_field.dart
import 'package:flutter/material.dart';
import 'package:Daeufle/constants/colors.dart'; // Adjust this path based on your actual project structure

class CustomTextField extends StatelessWidget {
  final String labelText;
  final String hintText;
  final bool obscureText;
  final TextInputType keyboardType;
  final TextEditingController? controller; // Optional controller
  // New: Validator function for form validation
  final String? Function(String?)? validator;

  const CustomTextField({
    super.key,
    required this.labelText,
    required this.hintText,
    this.obscureText = false,
    this.keyboardType = TextInputType.text,
    this.controller, // Make sure controller is optional in the constructor
    this.validator, // Initialize the validator
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          labelText,
          style: TextStyle(
            color: AppColors.darkBlueText,
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8.0),
        TextFormField(
          // Changed from TextField to TextFormField to support validator
          controller: controller,
          obscureText: obscureText,
          keyboardType: keyboardType,
          style: TextStyle(color: AppColors.darkBlueText),
          validator: validator, // Pass the validator to TextFormField
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: TextStyle(color: AppColors.darkGreyText),
            filled: true,
            fillColor: AppColors.lightGreyBackground,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 16.0,
            ),
            // Ensure error styles are defined for InputDecoration
            errorStyle: const TextStyle(color: Colors.red, fontSize: 12),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.0),
              borderSide: BorderSide(color: AppColors.borderGrey),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.0),
              borderSide: BorderSide(color: AppColors.borderGrey),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.0),
              borderSide: BorderSide(color: AppColors.primaryBlue, width: 2.0),
            ),
            errorBorder: OutlineInputBorder(
              // Style for when there's a validation error
              borderRadius: BorderRadius.circular(8.0),
              borderSide: const BorderSide(color: Colors.red, width: 2.0),
            ),
            focusedErrorBorder: OutlineInputBorder(
              // Style for when there's an error and the field is focused
              borderRadius: BorderRadius.circular(8.0),
              borderSide: const BorderSide(color: Colors.red, width: 2.0),
            ),
          ),
        ),
      ],
    );
  }
}
