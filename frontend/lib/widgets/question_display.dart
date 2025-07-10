// frontend/lib/widgets/question_display_widget.dart

import 'package:flutter/material.dart';
import 'package:Daeufle/constants/colors.dart'; // Assuming this import is correct for AppColors
// Removed imports for Question and Option models

/// A widget to display a single quiz question, its options, and navigation buttons.
class QuestionDisplayWidget extends StatelessWidget {
  // Changed type to Map<String, dynamic>
  final Map<String, dynamic> question; // The current question to display
  final String?
  selectedOptionId; // The ID of the option selected for this question
  final void Function(String questionId, String optionId)
  onOptionSelected; // Callback for option tap
  final VoidCallback onNextQuestion; // Callback for 'Next' button tap
  final VoidCallback?
  onPreviousQuestion; // Callback for 'Previous' button tap (can be null if disabled)
  final bool isLastQuestion; // True if this is the last question in the quiz

  const QuestionDisplayWidget({
    required this.question,
    this.selectedOptionId,
    required this.onOptionSelected,
    required this.onNextQuestion,
    this.onPreviousQuestion,
    required this.isLastQuestion,
  });

  @override
  Widget build(BuildContext context) {
    // Access question properties using string keys
    final List<dynamic> currentQuestionOptions =
        question['options'] as List<dynamic>;
    final String currentQuestionId = question['id'] as String;

    return Column(
      crossAxisAlignment:
          CrossAxisAlignment.stretch, // Stretch children horizontally
      children: [
        // Question Text
        Text(
          question['questionText'] as String, // Access using string key
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 20),

        // Options List
        Expanded(
          // Use Expanded to give ListView flexible space
          child: ListView.builder(
            shrinkWrap: true, // Important for ListView inside Column
            itemCount: currentQuestionOptions.length,
            itemBuilder: (context, optionIndex) {
              // Option is now a Map<String, dynamic>
              final Map<String, dynamic> option =
                  currentQuestionOptions[optionIndex] as Map<String, dynamic>;
              final bool isSelected =
                  selectedOptionId ==
                  (option['id'] as String); // Compare with option['id']

              return Card(
                // Use Card for better visual separation of options
                margin: const EdgeInsets.symmetric(vertical: 8.0),
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                color: isSelected
                    ? AppColors.primaryBlue
                    : AppColors
                          .lightGreyBackground, // Apply color based on selection
                child: InkWell(
                  // Use InkWell for tap feedback
                  onTap: () {
                    // Pass question['id'] and option['id']
                    onOptionSelected(currentQuestionId, option['id'] as String);
                  },
                  borderRadius: BorderRadius.circular(10),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(
                      option['text'] as String, // Access using string key
                      style: TextStyle(
                        fontSize: 16,
                        color: isSelected
                            ? Colors.white
                            : Colors.black, // Text color based on selection
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 20),

        // Navigation Buttons
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            ElevatedButton(
              onPressed: onPreviousQuestion, // Use the passed callback directly
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 30,
                  vertical: 15,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text("წინა", style: TextStyle(fontSize: 16)),
            ),
            ElevatedButton(
              onPressed: onNextQuestion, // Use the passed callback directly
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 30,
                  vertical: 15,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: Text(
                isLastQuestion
                    ? "დასრულება"
                    : "შემდეგი", // Text based on isLastQuestion
                style: const TextStyle(fontSize: 16),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
